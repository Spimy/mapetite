from django.contrib import admin

from apps.recipes.models import Recipe, RecipeIngredient, RecipeStep, SavedRecipe


# Register your models here.
class RecipeAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class RecipeIngredientAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class RecipeStepAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class SavedRecipeAdmin(admin.ModelAdmin):
    readonly_fields = ("saved_at",)


admin.site.register(Recipe, RecipeAdmin)
admin.site.register(RecipeIngredient, RecipeIngredientAdmin)
admin.site.register(RecipeStep, RecipeStepAdmin)
admin.site.register(SavedRecipe, SavedRecipeAdmin)
