from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema, extend_schema_view
from .models import SpendingRecord
from .serializers import SpendingRecordSerializer


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
        # Ensure a user can ONLY see their own spending records
        return (
            super()
            .get_queryset()
            .filter(user=self.request.user)
            .order_by("-date_spent", "-created_at")
        )

    def perform_create(self, serializer):
        spending_record = serializer.save(user=self.request.user)

        # TODO: Notification alert system for budget thresholds. This is a placeholder for future implementation.


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

        # TODO: Check budget again after updating a spending record to see if the user is still within their budget. This is a placeholder for future implementation.
