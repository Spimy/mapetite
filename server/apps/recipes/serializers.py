from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Recipe

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
