import json

from rest_framework.generics import ListCreateAPIView
from django.db.models import Count
from django.contrib.postgres.search import TrigramSimilarity
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from .models import Recipe
from .serializers import RecipeCreateSerializer, RecipeListSerializer


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
                queryset.annotate(similarity=TrigramSimilarity("title", query))
                .filter(
                    # Similarity threshold because PostgreSQL is goated like that providing easy way to do fuzzy search without any extra effort.
                    similarity__gt=0.25
                )
                .order_by("-similarity")
            )
        else:
            queryset = queryset.order_by("-created_at")

        return queryset

    def create(self, request, *args, **kwargs):
        data = {key: value for key, value in request.data.items()}

        for field in ["ingredients", "steps"]:
            if field in data and isinstance(data[field], str):
                try:
                    data[field] = json.loads(data[field])
                except json.JSONDecodeError:
                    pass  # serializer should catch the error and return a 400 Bad Request

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)

        headers = self.get_success_headers(serializer.data)
        return Response(
            serializer.data, status=status.HTTP_201_CREATED, headers=headers
        )

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
