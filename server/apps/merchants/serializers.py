# apps/merchants/serializers.py
from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import StoreProfile, StoreOperatingHour, StoreItem, ItemCategory


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


class StoreItemSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source="category.name", read_only=True)

    class Meta:
        model = StoreItem
        fields = [
            "id",
            "name",
            "description",
            "price",
            "calories",
            "category_name",
            "stock_status",
            "vegetarian",
            "organic",
            "gluten_free",
            "dairy_free",
            "contains_nuts",
            "eco_packaging",
            "locally_sourced",
            "thumbnail",
        ]


class StoreProfileSerializer(serializers.ModelSerializer):
    operating_hours = StoreOperatingHourSerializer(many=True, read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = StoreProfile
        fields = [
            "id",
            "business_name",
            "description",
            "merchant_type",
            "halal",
            "vegan",
            "street_address",
            "image_url",
            "operating_hours",
            "latitude",
            "longitude",
        ]

    @extend_schema_field(serializers.CharField(allow_null=True))
    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        return None
