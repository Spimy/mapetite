from typing import cast
from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema, extend_schema_view
from django.db.models import Sum
from django.utils import timezone
from decimal import Decimal
from apps.core.models import Notification
from .models import SpendingRecord
from .serializers import (
    SpendingRecordSerializer,
    SpendingQuerySerializer,
    SpendingSummaryResponseSerializer,
)


# Create your views here.
@extend_schema_view(
    get=extend_schema(
        summary="List all spending records",
        description="Retrieve a list of all spending records for the logged-in user.",
    ),
    post=extend_schema(
        summary="Create a new spending record",
        description="Create a new spending record for the logged-in user.",
    ),
)
class SpendingRecordListCreateAPIView(generics.ListCreateAPIView):

    queryset = SpendingRecord.objects.all()
    serializer_class = SpendingRecordSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset().filter(user=self.request.user)
        query_serializer = SpendingQuerySerializer(data=self.request.query_params)

        query_serializer.is_valid(raise_exception=True)
        validated_data = cast(dict, query_serializer.validated_data)

        month = validated_data.get("month")
        year = validated_data.get("year")

        if month:
            queryset = queryset.filter(date_spent__month=month)

        if year:
            queryset = queryset.filter(date_spent__year=year)

        return queryset.order_by("-date_spent", "-created_at")

    def perform_create(self, serializer):
        spending_record = serializer.save(user=self.request.user)
        self.check_budget_alert(spending_record)

    def check_budget_alert(self, current_record):
        user = current_record.user
        profile = user.user_profile

        # Determine which budget we are checking
        if current_record.spending_type == SpendingRecord.SpendingType.DINE_IN:
            budget_limit = profile.dine_in_budget
            budget_name = "Dine-In"
        else:
            budget_limit = profile.grocery_budget
            budget_name = "Grocery"

        # If they haven't set a budget, there's nothing to alert them about
        if not budget_limit:
            return

        # Calculate total spent this month for this specific category
        current_month = current_record.date_spent.month
        current_year = current_record.date_spent.year

        total_spent_data = SpendingRecord.objects.filter(
            user=user,
            spending_type=current_record.spending_type,
            date_spent__year=current_year,
            date_spent__month=current_month,
        ).aggregate(total=Sum("amount"))

        total_spent = total_spent_data["total"] or Decimal("0.00")

        # Check against alert percentage
        # e.g., if total_spent is 85 and budget is 100. (85 / 100) * 100 = 85%
        current_percentage = (total_spent / budget_limit) * 100

        if current_percentage >= profile.spending_alert_percent:
            # Create a notification!
            Notification.objects.create(
                user=user,
                title=f"{budget_name} Budget Alert!",
                message=f"You have used {current_percentage:.1f}% of your {budget_name} budget for this month. You've spent RM{total_spent} out of RM{budget_limit}.",
            )


@extend_schema_view(
    get=extend_schema(
        summary="Retrieve a spending record",
        description="Retrieve details of a specific spending record for the logged-in user.",
    ),
    put=extend_schema(
        summary="Update a spending record",
        description="Update a specific spending record for the logged-in user.",
    ),
    patch=extend_schema(
        summary="Partially update a spending record",
        description="Partially update a specific spending record for the logged-in user.",
    ),
    delete=extend_schema(
        summary="Delete a spending record",
        description="Delete a specific spending record for the logged-in user.",
    ),
)
class SpendingRecordDetailAPIView(generics.RetrieveUpdateDestroyAPIView):

    queryset = SpendingRecord.objects.all()
    serializer_class = SpendingRecordSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # This ensures that if User A tries to DELETE User B's record,
        # DRF will return a 404 Not Found, because the query won't find it
        return super().get_queryset().filter(user=self.request.user)

    def perform_update(self, serializer):
        spending_record = serializer.save()

        view = SpendingRecordListCreateAPIView()
        view.check_budget_alert(spending_record)


class SpendingSummaryAPIView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary="Get monthly spending summary",
        description="Returns the total spent and budget percentage for both dine-in and grocery categories.",
        parameters=[SpendingQuerySerializer],
        responses={
            200: SpendingSummaryResponseSerializer
        },  # Swagger now knows the exact response shape!
    )
    def get(self, request):
        # Validate query parameters
        query_serializer = SpendingQuerySerializer(data=request.query_params)
        query_serializer.is_valid(raise_exception=True)

        now = timezone.now()

        validated_data = cast(dict, query_serializer.validated_data)

        current_month = validated_data.get("month", now.month)
        current_year = validated_data.get("year", now.year)

        user = request.user
        profile = user.user_profile

        monthly_records = SpendingRecord.objects.filter(
            user=user, date_spent__year=current_year, date_spent__month=current_month
        )

        dine_in_total = monthly_records.filter(
            spending_type=SpendingRecord.SpendingType.DINE_IN
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0.00")

        grocery_total = monthly_records.filter(
            spending_type=SpendingRecord.SpendingType.GROCERY
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0.00")

        # Calculate percentages
        dine_in_budget = profile.dine_in_budget or Decimal("0.00")
        grocery_budget = profile.grocery_budget or Decimal("0.00")

        dine_in_percentage = (
            (dine_in_total / dine_in_budget * 100) if dine_in_budget > 0 else 0
        )
        grocery_percentage = (
            (grocery_total / grocery_budget * 100) if grocery_budget > 0 else 0
        )

        response_data = {
            "month": current_month,
            "year": current_year,
            "dine_in": {
                "spent": dine_in_total,
                "budget": dine_in_budget,
                "percentage_used": round(dine_in_percentage, 1),
            },
            "grocery": {
                "spent": grocery_total,
                "budget": grocery_budget,
                "percentage_used": round(grocery_percentage, 1),
            },
        }

        response_serializer = SpendingSummaryResponseSerializer(response_data)
        return Response(response_serializer.data)
