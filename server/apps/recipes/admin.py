from django.contrib import admin
from .models import Recipe, RecipeIngredient, RecipeStep, SavedRecipe


@admin.register(Recipe)
class RecipeAdmin(admin.ModelAdmin):
    list_display = ("title", "author", "cuisine_type", "prep_time", "created_at")
    list_filter = (
        "cuisine_type",
        "is_halal",
        "is_vegan",
        "is_vegetarian",
        "is_gluten_free",
    )
    search_fields = ("title", "author__username", "author__email")
    readonly_fields = ("created_at", "updated_at")
    autocomplete_fields = ["author"]


@admin.register(RecipeIngredient)
class RecipeIngredientAdmin(admin.ModelAdmin):
    list_display = ("name", "recipe", "quantity", "unit")
    search_fields = ("name", "recipe__title")
    autocomplete_fields = ["recipe"]
    readonly_fields = ("created_at", "updated_at")


@admin.register(RecipeStep)
class RecipeStepAdmin(admin.ModelAdmin):
    list_display = ("recipe", "step_number", "short_instruction")
    search_fields = ("recipe__title", "instruction")
    autocomplete_fields = ["recipe"]
    readonly_fields = ("created_at", "updated_at")

    @admin.display(description="Instruction")
    def short_instruction(self, obj):
        return (
            obj.instruction[:50] + "..."
            if len(obj.instruction) > 50
            else obj.instruction
        )


@admin.register(SavedRecipe)
class SavedRecipeAdmin(admin.ModelAdmin):
    list_display = ("user", "recipe", "saved_at")
    search_fields = ("user__username", "recipe__title")
    autocomplete_fields = ["user", "recipe"]
    readonly_fields = ("saved_at",)
