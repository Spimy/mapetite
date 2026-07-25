import calendar
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import extend_schema_field
from rest_framework import serializers
from .models import SpendingRecord


class SpendingRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = SpendingRecord
        fields = [
            "id",
            "store",
            "amount",
            "spending_type",
            "notes",
            "date_spent",
            "created_at",
        ]
        # Make created_at read-only so users can't edit it
        read_only_fields = ["id", "created_at"]


class SpendingQuerySerializer(serializers.Serializer):
    month = serializers.IntegerField(
        min_value=1,
        max_value=12,
        required=False,
        help_text="Month as an integer (1-12). Defaults to current month.",
    )
    year = serializers.IntegerField(
        min_value=2000,  # Wouldn't expect spendings before 2000
        required=False,
        help_text="Year as a 4-digit integer (e.g., 2026). Defaults to current year.",
    )


class BudgetCategorySummarySerializer(serializers.Serializer):
    spent = serializers.DecimalField(
        max_digits=10, decimal_places=2, help_text="Total spent in this category"
    )
    budget = serializers.DecimalField(
        max_digits=10, decimal_places=2, help_text="Total budget allocated"
    )
    percentage_used = serializers.FloatField(
        help_text="Percentage of budget used, rounded to 1 decimal"
    )


class SpendingSummaryResponseSerializer(serializers.Serializer):
    month = serializers.IntegerField(help_text="The month queried")
    month_name = serializers.SerializerMethodField(
        help_text="Full month name (e.g., January)"
    )
    month_short = serializers.SerializerMethodField(
        help_text="Abbreviated month name (e.g., Jan)"
    )

    year = serializers.IntegerField(help_text="The year queried")
    dine_in = BudgetCategorySummarySerializer()
    grocery = BudgetCategorySummarySerializer()

    @extend_schema_field(OpenApiTypes.STR)
    def get_month_name(self, obj):
        return calendar.month_name[obj["month"]]

    @extend_schema_field(OpenApiTypes.STR)
    def get_month_short(self, obj):
        return calendar.month_abbr[obj["month"]]
