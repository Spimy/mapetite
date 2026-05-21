# apps/merchants/serializers.py
from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import StoreProfile, StoreOperatingHour


class PaddedOperatingHoursListSerializer(serializers.ListSerializer):
    """Intercepts the list of hours and pads the missing days."""

    def to_representation(self, data):
        serialized_data = super().to_representation(data)
        existing_days = {item["day_of_week"]: item for item in serialized_data}

        day_names = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
        ]

        padded_schedule = []

        for i in range(7):
            if i in existing_days:
                day_data = existing_days[i]
                day_data["is_closed"] = False
                padded_schedule.append(day_data)
            else:
                padded_schedule.append(
                    {
                        "day_of_week": i,
                        "day_name": day_names[i],
                        "open_time": None,
                        "close_time": None,
                        "is_closed": True,
                    }
                )

        return padded_schedule


class StoreOperatingHourSerializer(serializers.ModelSerializer):
    day_name = serializers.CharField(source="get_day_of_week_display", read_only=True)
    is_closed = serializers.SerializerMethodField()

    class Meta:
        model = StoreOperatingHour
        fields = ["day_of_week", "day_name", "open_time", "close_time", "is_closed"]
        list_serializer_class = PaddedOperatingHoursListSerializer
        is_closed = serializers.SerializerMethodField()

    @extend_schema_field(serializers.BooleanField)
    def get_is_closed(self, obj):
        return False  # This field is added in the list serializer, not here


class StoreProfileSerializer(serializers.ModelSerializer):
    operating_hours = StoreOperatingHourSerializer(many=True, read_only=True)

    class Meta:
        model = StoreProfile
        fields = [
            "id",
            "business_name",
            "merchant_type",
            "operating_hours",
            "latitude",
            "longitude",
        ]
