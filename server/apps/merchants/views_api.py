from django.utils import timezone
from drf_spectacular.utils import PolymorphicProxySerializer, extend_schema
from apps.merchants.models import StoreProfile
from config.settings import WGS84_SRID, DEFAULT_RADIUS_KM
from django.db.models import Q
from django.contrib.gis.geos import Point
from rest_framework.generics import ListAPIView, RetrieveAPIView, get_object_or_404
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from apps.core.utils import trigram_fuzzy_search
from .serializers import (
    BundlePromotionSerializer,
    DiscountPromotionSerializer,
    FreeItemPromotionSerializer,
    StoreItemSerializer,
    StoreOperatingHourSerializer,
    StoreProfileSerializer,
    NearbyStoreSerializer,
    NearbyStoresResponseSerializer,
    StorePromotionSerializer,
)
from .models import Promotion, StoreOperatingHour, StoreItem


class StoreListAPIView(ListAPIView):
    """Fetches all stores, optionally filtered by ?type=RESTAURANT or ?type=GROCERY"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        merchant_type = self.request.GET.get("type")
        query = self.request.GET.get("q")
        halal = self.request.GET.get("halal")
        vegan = self.request.GET.get("vegan")
        vegetarian = self.request.GET.get("vegetarian")
        cuisine = self.request.GET.get("cuisine")

        queryset = super().get_queryset()

        if merchant_type:
            queryset = queryset.filter(merchant_type=merchant_type.upper())

        if query:
            queryset = trigram_fuzzy_search(
                queryset=queryset, search_field="business_name", query=query
            )

        if halal:
            if halal.lower() == "true" or halal.lower() == "1":
                queryset = queryset.filter(halal=True)
            elif halal.lower() == "false" or halal.lower() == "0":
                queryset = queryset.filter(halal=False)

        if vegan:
            if vegan.lower() == "true" or vegan.lower() == "1":
                queryset = queryset.filter(vegan=True)
            elif vegan.lower() == "false" or vegan.lower() == "0":
                queryset = queryset.filter(vegan=False)

        if vegetarian:
            if vegetarian.lower() == "true" or vegetarian.lower() == "1":
                queryset = queryset.filter(items__vegetarian=True).distinct()
            elif vegetarian.lower() == "false" or vegetarian.lower() == "0":
                queryset = queryset.exclude(items__vegetarian=True).distinct()

        if cuisine:
            queryset = queryset.filter(category__iexact=cuisine).distinct()

        return queryset


class NearbyStoresListAPIView(ListAPIView):
    """Fetches stores within a certain radius of a given lat/lng point and filtered by ?type=RESTAURANT or ?type=GROCERY"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = NearbyStoresResponseSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        lat = self.request.GET.get("lat")
        lng = self.request.GET.get("lng")
        radius_km = self.request.GET.get("radius", DEFAULT_RADIUS_KM)
        merchant_type = self.request.GET.get("type")
        query = self.request.GET.get("q")
        halal = self.request.GET.get("halal")
        vegan = self.request.GET.get("vegan")
        vegetarian = self.request.GET.get("vegetarian")
        cuisine = self.request.GET.get("cuisine")

        if not lat or not lng:
            raise ValidationError("Please provide 'lat' and 'lng' query parameters.")

        if not radius_km or (radius_km is str and not radius_km.isdigit()):
            raise ValidationError(
                "Please provide a valid 'radius' query parameter in kilometers."
            )

        try:
            user_location = Point(float(lng), float(lat), srid=WGS84_SRID)
            queryset = super().get_queryset().nearby(user_location, float(radius_km))

            if merchant_type:
                queryset = queryset.filter(merchant_type=merchant_type.upper())

            if query:
                queryset = trigram_fuzzy_search(
                    queryset=queryset, search_field="business_name", query=query
                )

            if halal:
                if halal.lower() == "true" or halal.lower() == "1":
                    queryset = queryset.filter(halal=True)
                elif halal.lower() == "false" or halal.lower() == "0":
                    queryset = queryset.filter(halal=False)

            if vegan:
                if vegan.lower() == "true" or vegan.lower() == "1":
                    queryset = queryset.filter(vegan=True)
                elif vegan.lower() == "false" or vegan.lower() == "0":
                    queryset = queryset.filter(vegan=False)

            if vegetarian:
                if vegetarian.lower() == "true" or vegetarian.lower() == "1":
                    queryset = queryset.filter(items__vegetarian=True).distinct()
                elif vegetarian.lower() == "false" or vegetarian.lower() == "0":
                    queryset = queryset.exclude(items__vegetarian=True).distinct()

            if cuisine:
                queryset = queryset.filter(category__iexact=cuisine).distinct()

            return queryset

        except ValueError:
            raise ValidationError("Invalid coordinates provided.")

    def list(self, request, *args, **kwargs):
        # Queryset is already filtered and annotated in get_queryset()
        queryset = self.get_queryset()
        serializer = NearbyStoreSerializer(
            queryset, context={"request": request}, many=True
        )

        lat = request.query_params.get("lat")
        lng = request.query_params.get("lng")
        radius_km = request.query_params.get("radius", DEFAULT_RADIUS_KM)

        return Response(
            {
                "search_point": {"lat": float(lat), "lng": float(lng)},
                "radius_km": float(radius_km),
                "count": queryset.count(),
                "results": serializer.data,
            }
        )


class StoreAPIView(RetrieveAPIView):
    """Fetches a single store with its operating hours and items"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "id"
    lookup_url_kwarg = "store_id"


class StoreOperatingHoursAPIView(ListAPIView):
    """Fetches and pads the operating hours for a specific store"""

    queryset = StoreOperatingHour.objects.all()
    serializer_class = StoreOperatingHourSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        store_id = self.kwargs.get("store_id")
        get_object_or_404(StoreProfile, id=store_id)
        return super().get_queryset().filter(store_id=store_id).order_by("day_of_week")


class StoreItemsAPIView(ListAPIView):
    """Fetches all items for a specific store"""

    queryset = StoreItem.objects.select_related("category").filter(is_active=True).all()
    serializer_class = (
        StoreItemSerializer  # You might want to create a dedicated serializer for items
    )
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        store_id = self.kwargs.get("store_id")
        get_object_or_404(StoreProfile, id=store_id)
        # Order by category display order, then category name, then item name for consistent listing
        return (
            super()
            .get_queryset()
            .filter(store_id=store_id)
            .order_by("category__display_order", "category__name", "name")
        )


@extend_schema(
    responses={
        200: PolymorphicProxySerializer(
            component_name="Promotion",
            resource_type_field_name="promotion_type",
            serializers={
                Promotion.PromotionType.PERCENTAGE: DiscountPromotionSerializer,
                Promotion.PromotionType.FLAT_AMOUNT: DiscountPromotionSerializer,
                Promotion.PromotionType.FREE_ITEM: FreeItemPromotionSerializer,
                Promotion.PromotionType.BUNDLE: BundlePromotionSerializer,
            },
            many=True,
        )
    }
)
class StorePromotionsAPIView(ListAPIView):
    """
    Fetches all promotions for a specific store.
    Empty eligible items means the promotion applies to all items in the store.
    Only returns active (not paused), has started and not expired promotions.
    """

    queryset = Promotion.objects.filter(
        is_active=True,
        start_date__lte=timezone.now().date(),
        end_date__gte=timezone.now().date(),
    ).all()
    serializer_class = StorePromotionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        store_id = self.kwargs.get("store_id")
        get_object_or_404(StoreProfile, id=store_id)
        return super().get_queryset().filter(store_id=store_id).order_by("-created_at")


@extend_schema(
    responses={
        200: PolymorphicProxySerializer(
            component_name="Promotion",
            resource_type_field_name="promotion_type",
            serializers={
                Promotion.PromotionType.PERCENTAGE: DiscountPromotionSerializer,
                Promotion.PromotionType.FLAT_AMOUNT: DiscountPromotionSerializer,
                Promotion.PromotionType.FREE_ITEM: FreeItemPromotionSerializer,
                Promotion.PromotionType.BUNDLE: BundlePromotionSerializer,
            },
            many=True,
        )
    }
)
class ItemPromotionsAPIView(ListAPIView):
    """
    Fetches all active, unexpired promotions that include a specific item.
    Returns promotions that this item is involved in.
    Empty eligible items means the promotion applies to all items in the store.
    Only returns active (not paused), has started and not expired promotions.
    """

    queryset = Promotion.objects.filter(
        is_active=True,
        start_date__lte=timezone.now().date(),
        end_date__gte=timezone.now().date(),
    ).all()
    serializer_class = StorePromotionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        item_id = self.kwargs.get("item_id")
        get_object_or_404(StoreItem, id=item_id)

        return (
            super()
            .get_queryset()
            .filter(
                Q(eligible_items__id=item_id)
                | Q(reward_item_id=item_id)
                | Q(bundle_items__id=item_id),
            )
            .distinct()
            .order_by("-created_at")
        )
