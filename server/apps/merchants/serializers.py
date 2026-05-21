# apps/merchants/serializers.py
from rest_framework import serializers
from .models import StoreProfile, StoreOperatingHour


class StoreProfileSerializer(serializers.ModelSerializer):
    operating_hours = serializers.SerializerMethodField()

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

    def get_operating_hours(self, obj):
        """Formats the DB records into a guaranteed 7-day array for the frontend."""

        existing_hours = {hour.day_of_week: hour for hour in obj.operating_hours.all()}

        day_names = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
        ]
        schedule = []

        for i in range(7):
            if i in existing_hours:
                hour = existing_hours[i]
                schedule.append(
                    {
                        "day": hour.get_day_of_week_display(),
                        "is_closed": False,
                        "open_time": hour.open_time.strftime("%H:%M"),
                        "close_time": hour.close_time.strftime("%H:%M"),
                    }
                )
            else:
                schedule.append(
                    {
                        "day": day_names[i],
                        "is_closed": True,
                        "open_time": None,
                        "close_time": None,
                    }
                )

        return schedule


class StoreOperatingHourSerializer(serializers.ModelSerializer):
    day_name = serializers.CharField(source="get_day_of_week_display", read_only=True)

    class Meta:
        model = StoreOperatingHour
        fields = ["day_of_week", "day_name", "open_time", "close_time"]
