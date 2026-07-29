from django.utils.text import slugify
from django.contrib.auth.validators import UnicodeUsernameValidator
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
            "is_vegetarian",
            "allergies",
            "preferred_cuisines",
        ]


class UserDetailSerializer(serializers.ModelSerializer):
    """Serializer for the currently authenticated user's details"""

    is_verified = serializers.SerializerMethodField()
    profile = UserProfileSerializer(source="user_profile", read_only=True)
    allergy_options = serializers.SerializerMethodField()
    health_goal_options = serializers.SerializerMethodField()
    activity_level_options = serializers.SerializerMethodField()
    preferred_cuisine_options = serializers.SerializerMethodField()

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
            "preferred_cuisine_options",
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

    @extend_schema_field(ChoiceOptionSerializer(many=True))
    def get_preferred_cuisine_options(self, obj):
        return [
            {"value": value, "label": label}
            for value, label in UserProfile.PreferredCuisineChoices.choices
        ]


class UserProfileUpdateSerializer(serializers.Serializer):
    username = serializers.CharField(
        required=False,
        max_length=150,
        validators=[UnicodeUsernameValidator()],
    )

    first_name = serializers.CharField(required=False, max_length=150, allow_blank=True)
    last_name = serializers.CharField(required=False, max_length=150, allow_blank=True)

    onboarding_completed = serializers.BooleanField(required=False)

    avatar = serializers.ImageField(required=False, allow_null=True)
    phone_number = serializers.CharField(required=False, allow_blank=True)

    address = serializers.CharField(required=False, allow_blank=True)
    city = serializers.CharField(required=False, allow_blank=True)
    country = serializers.CharField(required=False, allow_blank=True)

    target_calories = serializers.IntegerField(required=False, allow_null=True)

    dine_in_budget = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=False, allow_null=True
    )
    grocery_budget = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=False, allow_null=True
    )
    spending_alert_percent = serializers.IntegerField(
        required=False, min_value=1, max_value=100
    )

    health_goal = serializers.ChoiceField(
        choices=UserProfile.HealthGoalChoices.choices,
        required=False,
        allow_blank=True,
    )
    activity_level = serializers.ChoiceField(
        choices=UserProfile.ActivityLevelChoices.choices,
        required=False,
        allow_blank=True,
    )
    current_weight = serializers.DecimalField(
        max_digits=6, decimal_places=2, required=False, allow_null=True
    )

    is_halal = serializers.BooleanField(required=False)
    is_vegan = serializers.BooleanField(required=False)
    is_vegetarian = serializers.BooleanField(required=False)
    allergies = serializers.ListField(
        child=serializers.ChoiceField(choices=UserProfile.AllergyChoices.choices),
        required=False,
    )
    preferred_cuisines = serializers.ListField(
        child=serializers.ChoiceField(
            choices=UserProfile.PreferredCuisineChoices.choices
        ),
        required=False,
    )

    def validate_username(self, value):
        if (
            User.objects.filter(username__iexact=value)
            .exclude(pk=self.instance.pk)  # type: ignore
            .exists()
        ):
            raise serializers.ValidationError(
                "A user with that username already exists."
            )

        new_slug = slugify(value)
        if User.objects.filter(slug=new_slug).exclude(pk=self.instance.pk).exists():  # type: ignore
            raise serializers.ValidationError(
                "A user with a very similar username already exists. Please try another."
            )

        return value

    def update(self, instance, validated_data):
        user_changed = False

        if "username" in validated_data:
            instance.username = validated_data.pop("username")
            user_changed = True

        if "first_name" in validated_data:
            instance.first_name = validated_data.pop("first_name")
            user_changed = True

        if "last_name" in validated_data:
            instance.last_name = validated_data.pop("last_name")
            user_changed = True

        if user_changed:
            instance.save()

        profile = getattr(instance, "user_profile", None)
        if profile is None:
            profile = UserProfile.objects.create(user=instance)

        for field_name, value in validated_data.items():
            setattr(profile, field_name, value)

        profile.save()

        return instance
