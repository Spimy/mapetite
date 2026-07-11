from django.urls import path

from apps.recipes import views

app_name = "recipes"

urlpatterns = [
    path(
        "api/recipes/", view=views.RecipeCreateListAPIView.as_view(), name="recipe_list"
    ),
    path(
        "api/recipes/<int:pk>/",
        view=views.RecipeDetailUpdateDeleteAPIView.as_view(),
        name="recipe_detail",
    ),
    path(
        "api/recipes/<int:pk>/save/",
        view=views.SaveRecipeAPIView.as_view(),
        name="recipe_toggle-save",
    ),
]
