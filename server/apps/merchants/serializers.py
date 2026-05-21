# apps/merchants/serializers.py
from rest_framework import serializers
from .models import StoreProfile


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

        existing_hours = {
            hour.day_of_week: hour for hour in obj.operating_hours.all()}

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

        # 2. Loop through all 7 days (0 to 6)
        for i in range(7):
            if i in existing_hours:
                # Store is open: send the times
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
                # Store is closed: inject the fake "Closed" object for the frontend
                schedule.append(
                    {
                        "day": day_names[i],
                        "is_closed": True,
                        "open_time": None,
                        "close_time": None,
                    }
                )

        return schedule
