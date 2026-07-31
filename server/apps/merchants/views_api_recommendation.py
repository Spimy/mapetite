from drf_spectacular.utils import OpenApiParameter, extend_schema
from django.contrib.gis.geos import Point
from rest_framework.exceptions import NotFound, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.merchants.serializers import (
    NearbyStoreSerializer,
    RankedRestaurantsResponseSerializer,
    TopPickResponseSerializer,
)
from apps.merchants.services.restaurant_recommender import (
    RestaurantRecommender,
    ScoredRestaurant,
)
from config.settings import DEFAULT_RADIUS_KM, WGS84_SRID


def _parse_geo_params(request) -> tuple[float, float, float]:
    lat = request.query_params.get("lat")
    lng = request.query_params.get("lng")
    if lat is None or lng is None:
        raise ValidationError("Both 'lat' and 'lng' query parameters are required.")
    try:
        lat_f = float(lat)
        lng_f = float(lng)
        radius_km = float(request.query_params.get("radius", DEFAULT_RADIUS_KM))
    except (TypeError, ValueError) as exc:
        raise ValidationError("Invalid coordinates or radius provided.") from exc
    if radius_km <= 0:
        raise ValidationError("'radius' must be a positive number.")
    return lat_f, lng_f, radius_km


def _parse_bool(value, default: bool) -> bool:
    if value is None:
        return default
    return str(value).lower() in {"1", "true", "yes"}


def _scored_to_dict(scored: ScoredRestaurant, request) -> dict:
    store_data = NearbyStoreSerializer(scored.store, context={"request": request}).data
    # Prefer the recommender's rounded distance when annotation is present
    if store_data.get("distance_km") is None:  # type: ignore
        store_data["distance_km"] = scored.distance_km  # type: ignore
    return {
        "store": store_data,
        "match_score": scored.match_score,
        "reasons": scored.reasons,
        "distance_km": scored.distance_km,
        "pricing_bracket": scored.pricing_bracket,
        "is_open": scored.is_open,
        "avg_price": scored.avg_price,
        "avg_calories": scored.avg_calories,
        "recommendation_reason": scored.recommendation_reason,
    }


class RestaurantTopPickAPIView(APIView):
    """
    Return the single best nearby restaurant for the authenticated user.

    Hard dietary filters are strict by default (404 when nothing is safe).
    Open-now filtering defaults to true.
    """

    permission_classes = [IsAuthenticated]

    @extend_schema(
        parameters=[
            OpenApiParameter("lat", float, required=True),
            OpenApiParameter("lng", float, required=True),
            OpenApiParameter("radius", float, required=False),
            OpenApiParameter(
                "open_now",
                bool,
                required=False,
                description="Default true. Only consider currently open stores.",
            ),
            OpenApiParameter(
                "strict",
                bool,
                required=False,
                description="Default true. When false, may fall back without dietary filters.",
            ),
            OpenApiParameter(
                "use_gemini",
                bool,
                required=False,
                description="Default false. Optionally polish recommendation_reason with Gemini.",
            ),
        ],
        responses={200: TopPickResponseSerializer},
    )
    def get(self, request, *args, **kwargs):
        lat, lng, radius_km = _parse_geo_params(request)
        open_now = _parse_bool(request.query_params.get("open_now"), default=True)
        strict = _parse_bool(request.query_params.get("strict"), default=True)
        use_gemini = _parse_bool(request.query_params.get("use_gemini"), default=False)

        point = Point(lng, lat, srid=WGS84_SRID)
        results = RestaurantRecommender().recommend(
            request.user,
            point,
            radius_km=radius_km,
            limit=1,
            open_now=open_now,
            strict=strict,
            use_gemini_caption=use_gemini,
        )

        if not results:
            raise NotFound("No restaurants match your preferences nearby.")

        return Response(_scored_to_dict(results[0], request))


class RankedRestaurantsAPIView(APIView):
    """
    Return nearby restaurants ranked by personalised match score.

    Open-now filtering defaults to false so browse still includes closed venues.
    """

    permission_classes = [IsAuthenticated]

    @extend_schema(
        parameters=[
            OpenApiParameter("lat", float, required=True),
            OpenApiParameter("lng", float, required=True),
            OpenApiParameter("radius", float, required=False),
            OpenApiParameter("limit", int, required=False),
            OpenApiParameter(
                "open_now",
                bool,
                required=False,
                description="Default false.",
            ),
            OpenApiParameter(
                "strict",
                bool,
                required=False,
                description="Default true.",
            ),
        ],
        responses={200: RankedRestaurantsResponseSerializer},
    )
    def get(self, request, *args, **kwargs):
        lat, lng, radius_km = _parse_geo_params(request)
        open_now = _parse_bool(request.query_params.get("open_now"), default=False)
        strict = _parse_bool(request.query_params.get("strict"), default=True)
        try:
            limit = int(request.query_params.get("limit", 10))
        except (TypeError, ValueError) as exc:
            raise ValidationError("Invalid 'limit' provided.") from exc
        limit = max(1, min(limit, 50))

        point = Point(lng, lat, srid=WGS84_SRID)
        results = RestaurantRecommender().recommend(
            request.user,
            point,
            radius_km=radius_km,
            limit=limit,
            open_now=open_now,
            strict=strict,
            use_gemini_caption=False,
        )

        payload = {
            "search_point": {"lat": lat, "lng": lng},
            "radius_km": radius_km,
            "count": len(results),
            "results": [_scored_to_dict(r, request) for r in results],
        }
        return Response(payload)
