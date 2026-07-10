from rest_framework.generics import ListAPIView
from django.db.models import Count
from django.contrib.postgres.search import TrigramSimilarity
from .models import Recipe
from .serializers import RecipeListSerializer
from rest_framework.permissions import IsAuthenticated


# Create your views here.
class RecipeListAPIView(ListAPIView):
    """
    API view to list all recipes with their respective authors and the count of users who have saved them.
    Users can also search for recipes by title using a query parameter `q`. The search is case-insensitive and uses trigram similarity for fuzzy matching.
    """

    queryset = Recipe.objects.all()
    serializer_class = RecipeListSerializer
    permission_classes = [IsAuthenticated]

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
