import json

from rest_framework.generics import ListCreateAPIView, RetrieveAPIView
from django.db.models import Count, Value, Q
from django.contrib.postgres.search import TrigramSimilarity
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .models import Recipe
from .serializers import (
    RecipeCreateSerializer,
    RecipeDetailSerializer,
    RecipeListSerializer,
)


# Create your views here.
class RecipeCreateListAPIView(ListCreateAPIView):
    """
    API view to list all recipes with their respective authors and the count of users who have saved them.
    Users can also search for recipes by title using a query parameter `q`. The search is case-insensitive and uses trigram similarity for fuzzy matching.
    """

    queryset = Recipe.objects.all()
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_serializer_class(self):  # type: ignore
        if self.request.method == "POST":
            return RecipeCreateSerializer
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
        data = {key: value for key, value in request.data.items()}

        empty_serializer = self.get_serializer()
        json_parsing_errors = {}

        for field in ["ingredients", "steps"]:
            if field in data and isinstance(data[field], str):
                try:
                    data[field] = json.loads(data[field])
                except json.JSONDecodeError:
                    nested_serializer = empty_serializer.fields[field].child
                    expected_keys = list(nested_serializer.fields.keys())
                    keys_string = ", ".join(f"'{k}'" for k in expected_keys)

                    json_parsing_errors[field] = [
                        f"Invalid JSON format. Expected an array of objects containing keys: {keys_string}."
                    ]

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


class RecipeDetailAPIView(RetrieveAPIView):
    """
    Get detailed information about a specific recipe, including its ingredients, steps, and the count of users who have saved it.
    """

    queryset = Recipe.objects.all()
    permission_classes = [IsAuthenticated]
    serializer_class = RecipeDetailSerializer
