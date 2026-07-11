from rest_framework.generics import (
    ListCreateAPIView,
    RetrieveUpdateDestroyAPIView,
)
from django.db.models import Count, Value, Q
from django.contrib.postgres.search import TrigramSimilarity
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from drf_spectacular.utils import extend_schema, extend_schema_view
from apps.recipes.utils import extract_recipe_data
from apps.users.permissions import IsAuthorOrReadOnly
from .models import Recipe
from .serializers import (
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
            queryset = (
                queryset.annotate(similarity=TrigramSimilarity("title", Value(query)))
                .filter(
                    # Similarity threshold because PostgreSQL is goated like that providing easy way to do fuzzy search without any extra effort.
                    Q(title__icontains=query)
                    | Q(similarity__gt=0.15)
                )
                .order_by("-similarity")
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
