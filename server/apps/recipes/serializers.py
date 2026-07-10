from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.db import transaction
from .models import Recipe, RecipeIngredient, RecipeStep

User = get_user_model()


class RecipeAuthorSerializer(serializers.ModelSerializer):
    avatar = serializers.ImageField(source="user_profile.avatar", read_only=True)
    name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "name", "avatar"]

    def get_name(self, obj):
        # Prioritise full name, fallback to username
        full_name = f"{obj.first_name} {obj.last_name}".strip()
        return full_name if full_name else obj.username


class RecipeListSerializer(serializers.ModelSerializer):
    author = RecipeAuthorSerializer(read_only=True)
    saves_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Recipe
        fields = [
            "id",
            "title",
            "thumbnail",
            "prep_time",
            "calories",
            "is_halal",
            "is_vegan",
            "is_vegetarian",
            "is_gluten_free",
            "saves_count",
            "author",
        ]


class RecipeIngredientCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeIngredient
        fields = ["name", "quantity", "unit"]


class RecipeStepCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = RecipeStep
        fields = ["step_number", "instruction"]


class RecipeCreateSerializer(serializers.ModelSerializer):
    thumbnail = serializers.ImageField(
        required=False, allow_null=True, allow_empty_file=False
    )

    ingredients = RecipeIngredientCreateSerializer(many=True)
    steps = RecipeStepCreateSerializer(many=True)

    class Meta:
        model = Recipe
        fields = [
            "title",
            "thumbnail",
            "prep_time",
            "servings",
            "calories",
            "is_halal",
            "is_vegan",
            "is_vegetarian",
            "is_gluten_free",
            "ingredients",
            "steps",
        ]

    @transaction.atomic
    def create(self, validated_data):
        ingredients_data = validated_data.pop("ingredients", [])
        steps_data = validated_data.pop("steps", [])

        # Create the main Recipe object (author is passed in from the view)
        recipe = Recipe.objects.create(**validated_data)

        # Bulk create the Ingredients
        ingredients_to_create = [
            RecipeIngredient(recipe=recipe, **ingredient)
            for ingredient in ingredients_data
        ]
        RecipeIngredient.objects.bulk_create(ingredients_to_create)

        # Bulk create the Steps
        steps_to_create = [RecipeStep(recipe=recipe, **step) for step in steps_data]
        RecipeStep.objects.bulk_create(steps_to_create)

        return recipe

    def get_fields(self):
        fields = super().get_fields()
        return fields
