from django.db import models
from config import settings


# Create your models here.
class Recipe(models.Model):
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="recipes"
    )
    title = models.CharField(max_length=255)
    prep_time = models.PositiveIntegerField(help_text="Prep time in minutes")
    servings = models.PositiveIntegerField()
    calories = models.PositiveIntegerField(null=True, blank=True)

    is_halal = models.BooleanField(default=False)
    is_vegan = models.BooleanField(default=False)
    is_vegetarian = models.BooleanField(default=False)
    is_gluten_free = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title


class RecipeIngredient(models.Model):
    class UnitChoices(models.TextChoices):
        G = "g", "Grams (g)"
        KG = "kg", "Kilograms (kg)"
        ML = "ml", "Milliliters (ml)"
        L = "L", "Liters (L)"
        PCS = "pcs", "Pieces (pcs)"
        TBS = "tbsp", "Tablespoon (tbsp)"
        TSP = "tsp", "Teaspoon (tsp)"
        CUP = "cup", "Cup"

    recipe = models.ForeignKey(
        Recipe, on_delete=models.CASCADE, related_name="ingredients"
    )
    name = models.CharField(max_length=255)
    quantity = models.DecimalField(max_digits=8, decimal_places=2)
    unit = models.CharField(max_length=10, choices=UnitChoices.choices)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.quantity} {self.unit} of {self.name}"


class RecipeStep(models.Model):
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name="steps")
    step_number = models.PositiveIntegerField()
    instruction = models.TextField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("recipe", "step_number")
        ordering = ["step_number"]

    def __str__(self):
        return f"Step {self.step_number} for {self.recipe.title}"


class SavedRecipe(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="saved_recipes"
    )
    recipe = models.ForeignKey(
        Recipe, on_delete=models.CASCADE, related_name="saved_by_users"
    )
    saved_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        # Prevents a user from saving the same recipe twice
        unique_together = ("user", "recipe")
        ordering = ["-saved_at"]
