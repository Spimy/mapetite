from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from allauth.account.models import EmailAddress
from .models import User, UserProfile


class ChoiceOptionSerializer(serializers.Serializer):
    value = serializers.CharField()
    label = serializers.CharField()


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = [
            "onboarding_completed",
            "avatar",
            "phone_number",
            "address",
            "city",
            "country",
            "target_calories",
            "dine_in_budget",
            "grocery_budget",
            "spending_alert_percent",
            "health_goal",
            "activity_level",
            "current_weight",
            "is_halal",
            "is_vegan",
            "allergies",
        ]


class UserDetailSerializer(serializers.ModelSerializer):
    """Serializer for the currently authenticated user's details"""

    is_verified = serializers.SerializerMethodField()
    profile = UserProfileSerializer(source="user_profile", read_only=True)
    allergy_options = serializers.SerializerMethodField()
    health_goal_options = serializers.SerializerMethodField()
    activity_level_options = serializers.SerializerMethodField()

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
            "allergy_options",
            "health_goal_options",
            "activity_level_options",
        ]

    def get_is_verified(self, obj):
        # Checks if the user has any verified email addresses
        return EmailAddress.objects.filter(user=obj, verified=True).exists()

    @extend_schema_field(ChoiceOptionSerializer(many=True))
    def get_allergy_options(self, obj):
        return [
            {"value": value, "label": label}
            for value, label in UserProfile.AllergyChoices.choices
        ]

    @extend_schema_field(ChoiceOptionSerializer(many=True))
    def get_health_goal_options(self, obj):
        return [
            {"value": value, "label": label}
            for value, label in UserProfile.HealthGoalChoices.choices
        ]

    @extend_schema_field(ChoiceOptionSerializer(many=True))
    def get_activity_level_options(self, obj):
        return [
            {"value": value, "label": label}
            for value, label in UserProfile.ActivityLevelChoices.choices
        ]
