# apps/merchants/serializers.py
from typing import Any, Dict, cast
from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import Promotion, StoreProfile, StoreOperatingHour, StoreItem


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
    category = serializers.CharField(source="category.name", read_only=True)

    class Meta:
        model = StoreItem
        fields = [
            "id",
            "name",
            "description",
            "price",
            "calories",
            "category",
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
            "phone",
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


class NearbyStoreSerializer(StoreProfileSerializer):
    distance_km = serializers.SerializerMethodField()

    class Meta(StoreProfileSerializer.Meta):
        fields = StoreProfileSerializer.Meta.fields + ["distance_km"]

    @extend_schema_field(serializers.FloatField(allow_null=True))
    def get_distance_km(self, obj):
        store_distance = getattr(obj, 'distance', None)
        if store_distance:
            return round(store_distance.km, 2)
        return None


class SearchPointSerializer(serializers.Serializer):
    lat = serializers.FloatField()
    lng = serializers.FloatField()


class NearbyStoresResponseSerializer(serializers.Serializer):
    search_point = SearchPointSerializer()
    radius_km = serializers.FloatField()
    count = serializers.IntegerField()
    results = NearbyStoreSerializer(many=True)


class MinimalStoreItemSerializer(serializers.ModelSerializer):
    """
    Serializer for minimal representation of StoreItem, used in promotions.
    To avoid returning full item details when not necessary and to avoid the promotion serializer from returning only the item ID.
    """
    
    class Meta:
        model = StoreItem
        fields = ['id', 'name', 'price']
        
        
class BasePromotionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Promotion
        fields = ['id', 'title', 'description', 'promotion_type', 'start_date', 'end_date']


class DiscountPromotionSerializer(BasePromotionSerializer):
    promotion_type = serializers.ChoiceField(
        choices=[Promotion.PromotionType.PERCENTAGE, Promotion.PromotionType.FLAT_AMOUNT]
    )
    eligible_items = MinimalStoreItemSerializer(many=True, read_only=True)
    class Meta(BasePromotionSerializer.Meta):
        fields = BasePromotionSerializer.Meta.fields + ['promotion_amount', 'minimum_purchase_amount', 'eligible_items']


class FreeItemPromotionSerializer(BasePromotionSerializer):
    promotion_type = serializers.ChoiceField(choices=[Promotion.PromotionType.FREE_ITEM])
    reward_item = MinimalStoreItemSerializer(read_only=True)
    eligible_items = MinimalStoreItemSerializer(many=True, read_only=True)
    class Meta(BasePromotionSerializer.Meta):
        fields = BasePromotionSerializer.Meta.fields + ['reward_item', 'minimum_purchase_amount', 'eligible_items']


class BundlePromotionSerializer(BasePromotionSerializer):
    promotion_type = serializers.ChoiceField(choices=[Promotion.PromotionType.BUNDLE])
    bundle_items = MinimalStoreItemSerializer(many=True, read_only=True)
    class Meta(BasePromotionSerializer.Meta):
        fields = BasePromotionSerializer.Meta.fields + ['promotion_amount', 'bundle_items', 'bundle_description']


class StorePromotionSerializer(serializers.Serializer):
    def to_representation(self, instance):
        if instance.promotion_type in [Promotion.PromotionType.PERCENTAGE, Promotion.PromotionType.FLAT_AMOUNT]:
            serializer = DiscountPromotionSerializer(instance, context=self.context)
        elif instance.promotion_type == Promotion.PromotionType.FREE_ITEM:
            serializer = FreeItemPromotionSerializer(instance, context=self.context)
        elif instance.promotion_type == Promotion.PromotionType.BUNDLE:
            serializer = BundlePromotionSerializer(instance, context=self.context)
        else:
            return super().to_representation(instance)
            
        return cast(Dict[str, Any], serializer.data)
