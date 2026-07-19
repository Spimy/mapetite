from django.db.models import QuerySet, Q
from django.contrib.postgres.search import TrigramSimilarity


def trigram_fuzzy_search(
    queryset: QuerySet, search_field: str, query: str, threshold: float = 0.15
) -> QuerySet:
    """
    Applies PostGIS TrigramSimilarity fuzzy search to any Django QuerySet.

    :param queryset: The base queryset to filter.
    :param search_field: The model field to search against (e.g., "title", "business_name").
    :param query: The search string provided by the user.
    :param threshold: Minimum similarity score to match (0.0 to 1.0).
    """
    if not query:
        return queryset

    # Dynamically build the icontains lookup (e.g., {"title__icontains": query})
    icontains_lookup = {f"{search_field}__icontains": query}

    return (
        queryset.annotate(similarity=TrigramSimilarity(search_field, query))
        .filter(Q(**icontains_lookup) | Q(similarity__gt=threshold))
        .order_by("-similarity")
    )
