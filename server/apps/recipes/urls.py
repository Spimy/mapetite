from django.urls import path

from apps.recipes import views

app_name = "recipes"

urlpatterns = [
    path("api/recipes/", view=views.RecipeListAPIView.as_view(), name="recipe_list"),
]
