from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, UserProfile


# Register your models here.
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = (
        "username",
        "email",
        "first_name",
        "last_name",
        "is_merchant",
        "is_staff",
    )
    list_filter = ("is_merchant", "is_staff", "is_superuser", "is_active")
    search_fields = ("username", "email", "first_name", "last_name")

    # Add your custom fields to the admin fieldsets
    fieldsets = BaseUserAdmin.fieldsets + (  # type: ignore
        ("Custom Info", {"fields": ("slug", "is_merchant")}),
    )


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = (
        "user",
        "onboarding_completed",
        "phone_number",
        "city",
        "health_goal",
    )
    list_filter = (
        "onboarding_completed",
        "health_goal",
        "activity_level",
        "is_halal",
        "is_vegan",
    )
    search_fields = ("user__username", "user__email", "phone_number", "city")
    readonly_fields = ("created_at", "updated_at")
    autocomplete_fields = ["user"]  # Requires search_fields on UserAdmin
