from rest_framework import serializers
from allauth.account.models import EmailAddress
from .models import User, UserProfile


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            "avatar",
            "address",
            "city",
            "country",
            "budget_monthly",
            "is_halal",
            "is_vegan",
            "allergies",
        ]


class UserDetailSerializer(serializers.ModelSerializer):
    """Serializer for the currently authenticated user's details"""

    is_verified = serializers.SerializerMethodField()
    profile = UserProfileSerializer(source="user_profile", read_only=True)

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "username",
            "first_name",
            "last_name",
            "is_verified",
            "profile",
        ]

    def get_is_verified(self, obj):
        # Checks if the user has any verified email addresses
        return EmailAddress.objects.filter(user=obj, verified=True).exists()
