from google.genai import types
from pgvector.django import CosineDistance
from rest_framework.generics import (
    ListCreateAPIView,
    RetrieveUpdateDestroyAPIView,
    get_object_or_404,
)
from rest_framework.views import APIView
from django.db.models import Count, Value, Q
from django.contrib.postgres.search import TrigramSimilarity
from django.contrib.gis.geos import Point
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from drf_spectacular.utils import extend_schema, extend_schema_view
from apps.core.services import GeminiService
from apps.core.utils import trigram_fuzzy_search
from apps.merchants.models import StoreItem, StoreProfile
from apps.recipes.utils import extract_recipe_data
from apps.users.permissions import IsAuthorOrReadOnly
from config.settings import DEFAULT_RADIUS_KM, WGS84_SRID
from .models import Recipe, SavedRecipe
from .serializers import (
    IngredientMatchRequestSerializer,
    MatchResponseSerializer,
    MatchResponseSerializer,
    RecipeCreateUpdateSerializer,
    RecipeDetailSerializer,
    RecipeListSerializer,
)


# Create your views here.
@extend_schema_view(
    get=extend_schema(
        summary="List all recipes",
        description="Retrieve a list of all recipes with their respective authors and the count of users who have saved them. Users can also search for recipes by title using a query parameter `q`.",
    ),
    post=extend_schema(
        summary="Create a new recipe",
        description="Create a new recipe with its ingredients and steps. The request should include the recipe details, ingredients, and steps in JSON format.",
    ),
)
class RecipeCreateListAPIView(ListCreateAPIView):
    queryset = Recipe.objects.all()
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_serializer_class(self):  # type: ignore
        if self.request.method == "POST":
            return RecipeCreateUpdateSerializer
        return RecipeListSerializer

    def get_queryset(self):
        queryset = (
            super()
            .get_queryset()
            .select_related(
                "author",
                "author__user_profile",
            )
            .annotate(saves_count=Count("saved_by_users"))
        )

        query = self.request.GET.get("q", None)

        if query:
            queryset = trigram_fuzzy_search(
                queryset=queryset, search_field="title", query=query
            )
        else:
            queryset = queryset.order_by("-created_at")

        return queryset

    def create(self, request, *args, **kwargs):
        data, json_parsing_errors = extract_recipe_data(
            request, self.get_serializer_class()
        )

        serializer = self.get_serializer(data=data)

        if not serializer.is_valid(raise_exception=False):
            final_errors = serializer.errors
            final_errors.update(json_parsing_errors)
            return Response(final_errors, status=status.HTTP_400_BAD_REQUEST)

        if json_parsing_errors:
            return Response(
                json_parsing_errors,
                status=status.HTTP_400_BAD_REQUEST,
            )

        self.perform_create(serializer)

        headers = self.get_success_headers(serializer.data)
        return Response(
            serializer.data, status=status.HTTP_201_CREATED, headers=headers
        )

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)


@extend_schema_view(
    get=extend_schema(
        summary="Retrieve a recipe",
        description="Get detailed information about a specific recipe, including its ingredients, steps, and the count of users who have saved it.",
    ),
    put=extend_schema(
        summary="Replace a recipe",
        description="Completely replace a recipe, including wiping and recreating all nested ingredients and steps.",
    ),
    patch=extend_schema(
        summary="Partially update a recipe",
        description="Update specific fields of a recipe. If ingredients or steps are omitted, the existing ones are preserved.",
    ),
    delete=extend_schema(
        summary="Delete a recipe",
        description="Permanently delete a recipe. Automatically removes all associated ingredients and steps due to cascading delete.",
    ),
)
class RecipeDetailUpdateDeleteAPIView(RetrieveUpdateDestroyAPIView):
    queryset = Recipe.objects.all()
    permission_classes = [IsAuthorOrReadOnly]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_serializer_class(self):  # type: ignore
        if self.request.method in ["PUT", "PATCH"]:
            return RecipeCreateUpdateSerializer
        return RecipeDetailSerializer

    def get_queryset(self):
        return super().get_queryset().annotate(saves_count=Count("saved_by_users"))

    def update(self, request, *args, **kwargs):
        data, json_parsing_errors = extract_recipe_data(
            request, self.get_serializer_class()
        )

        partial = kwargs.pop("partial", False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=data, partial=partial)

        if not serializer.is_valid(raise_exception=False):
            final_errors = serializer.errors
            final_errors.update(json_parsing_errors)
            return Response(final_errors, status=status.HTTP_400_BAD_REQUEST)

        if json_parsing_errors:
            return Response(
                json_parsing_errors,
                status=status.HTTP_400_BAD_REQUEST,
            )

        self.perform_update(serializer)

        if getattr(instance, "_prefetched_objects_cache", None):
            # If 'prefetch_related' has been applied to a queryset,
            # forcibly invalidate the prefetch cache on the instance.
            instance._prefetched_objects_cache = {}

        return Response(serializer.data)


class SaveRecipeAPIView(APIView):
    queryset = SavedRecipe.objects.annotate(saves_count=Count("recipe")).all()
    permission_classes = [IsAuthenticated]
    serializer_class = RecipeDetailSerializer

    @extend_schema(
        summary="Save a recipe",
        description="Adds the recipe to the user's saved list. This endpoint is idempotent (calling it multiple times safely does nothing). Returns the updated recipe details.",
        responses={201: RecipeDetailSerializer, 200: RecipeDetailSerializer},
    )
    def post(self, request, pk, *args, **kwargs):
        recipe = get_object_or_404(Recipe, pk=pk)

        _, created = SavedRecipe.objects.get_or_create(user=request.user, recipe=recipe)

        serializer = self.serializer_class(recipe, context={"request": request})
        recipe.saves_count = recipe.saved_by_users.count()  # type: ignore

        # 201 if successfully created the save, 200 if it was already saved
        status_code = status.HTTP_201_CREATED if created else status.HTTP_200_OK
        return Response(serializer.data, status=status_code)

    @extend_schema(
        summary="Unsave a recipe",
        description="Removes the recipe from the user's saved list. This endpoint is idempotent. Returns the updated recipe details.",
        responses={200: RecipeDetailSerializer},
    )
    def delete(self, request, pk, *args, **kwargs):
        recipe = get_object_or_404(Recipe, pk=pk)

        SavedRecipe.objects.filter(user=request.user, recipe=recipe).delete()

        # Normally DELETE returns 204 No Content. However, returning 200 OK
        # with the serialized recipe here to instantly get the decremented saves_count
        serializer = self.serializer_class(recipe, context={"request": request})
        recipe.saves_count = recipe.saved_by_users.count()  # type: ignore

        return Response(serializer.data, status=status.HTTP_200_OK)


class SmartIngredientMatchAPIView(APIView):
    permission_classes = [IsAuthenticated]
    client = GeminiService.get_client()

    @extend_schema(
        summary="Smart Merchant Ingredient Matcher",
        description="Finds nearby grocery stores that stock requested recipe ingredients using Vector AI and PostGIS.",
        request=IngredientMatchRequestSerializer,
        responses={200: MatchResponseSerializer},
    )
    def post(self, request, *args, **kwargs):
        serializer = IngredientMatchRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_lat = serializer.validated_data["latitude"]  # type: ignore
        user_lon = serializer.validated_data["longitude"]  # type: ignore
        radius_km = serializer.validated_data["radius_km"] or DEFAULT_RADIUS_KM  # type: ignore
        requested_ingredients = serializer.validated_data["ingredients"]  # type: ignore

        user_location = Point(user_lon, user_lat, srid=WGS84_SRID)

        # Find stores within the radius
        nearby_stores = StoreProfile.objects.nearby(user_location, radius_km).filter(
            merchant_type=StoreProfile.MerchantType.GROCERY
        )

        if not nearby_stores.exists():
            return Response(
                {"detail": "No grocery stores found within your area."},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Vector Embeddings
        embedded_ingredients = []
        for ing_name in requested_ingredients:
            embedding_response = self.client.models.embed_content(
                model=GeminiService.get_model("embedding"),
                contents=ing_name,
                config=types.EmbedContentConfig(output_dimensionality=768),
            )
            assert embedding_response.embeddings is not None

            vector = embedding_response.embeddings[0].values
            embedded_ingredients.append({"name": ing_name, "vector": vector})

        # Semantic Match to find which stores have these items
        store_results = {
            store.pk: {
                "store_id": store.pk,
                "business_name": store.business_name,
                "image": (
                    request.build_absolute_uri(store.image.url) if store.image else None
                ),
                "distance_km": (
                    round(getattr(store, "distance").km, 2)
                    if getattr(store, "distance", None)
                    else 0.0
                ),
                "matched_ingredients": [],
                "missing_ingredients": [],
                "match_score": 0,
            }
            for store in nearby_stores
        }

        SIMILARITY_THRESHOLD = 0.3

        for target in embedded_ingredients:
            matches = (
                StoreItem.objects.filter(
                    store__in=nearby_stores, stock_status__in=["IN_STOCK", "LOW_STOCK"]
                )
                .annotate(distance=CosineDistance("embedding", target["vector"]))
                .filter(distance__lt=SIMILARITY_THRESHOLD)
            )

            matched_store_ids = matches.values_list("store_id", flat=True)

            for store_id in store_results.keys():
                if store_id in matched_store_ids:
                    store_results[store_id]["matched_ingredients"].append(
                        target["name"]
                    )
                    store_results[store_id]["match_score"] += 1
                else:
                    store_results[store_id]["missing_ingredients"].append(
                        target["name"]
                    )

        sorted_stores = sorted(
            store_results.values(), key=lambda x: (-x["match_score"], x["distance_km"])
        )

        sorted_stores = [s for s in sorted_stores if s["match_score"] > 0]

        # RAG for recommendation reasoning
        if sorted_stores:
            top_store = sorted_stores[0]
            prompt = (
                f"I am cooking a recipe and need these ingredients: {requested_ingredients}. "
                f"I searched my database and found that a store named '{top_store['business_name']}' "
                f"has {top_store['match_score']} out of {len(requested_ingredients)} items in stock. "
                f"Write a 1-2 sentence friendly, helpful recommendation telling me where to go. "
                f"Do not use markdown."
            )

            # Using Gemini 3.1 Flash Lite for faster response time
            response = self.client.models.generate_content(
                model=GeminiService.get_model("fast"), contents=prompt
            )
            ai_recommendation = (
                response.text.strip()
                if response.text
                else "Something went wrong with AI recommendation reasoning."
            )
        else:
            ai_recommendation = "I couldn't find any nearby stores with those specific ingredients in stock today."

        return Response(
            {"ai_recommendation": ai_recommendation, "stores": sorted_stores},
            status=status.HTTP_200_OK,
        )
