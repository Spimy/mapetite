from rest_framework import serializers
from allauth.account.models import EmailAddress
from django.db import IntegrityError, transaction
from dj_rest_auth.registration.serializers import RegisterSerializer

from .models import User, UserProfile


class MapetiteRegisterSerializer(RegisterSerializer):
    """Return validation errors before unique database constraints fail."""

    def validate_email(self, email):
        email = super().validate_email(email)

        if User.objects.filter(email__iexact=email).exists():
            raise serializers.ValidationError(
                'An account already exists with this email address.',
            )

        return email

    def validate_username(self, username):
        username = super().validate_username(username)

        if User.objects.filter(username__iexact=username).exists():
            raise serializers.ValidationError(
                'This username is already in use.',
            )

        return username

    def save(self, request):
        try:
            with transaction.atomic():
                return super().save(request)
        except IntegrityError as error:
            # Covers rare race conditions or another unique database constraint.
            raise serializers.ValidationError(
                {
                    'detail': (
                        'Unable to create the account because the username '
                        'or email is already in use.'
                    ),
                },
            ) from error

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
