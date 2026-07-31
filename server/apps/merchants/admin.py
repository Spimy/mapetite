from django.contrib import admin
from django.utils.html import format_html
from .models import (
    Promotion,
    StoreProfile,
    StoreOperatingHour,
    ItemCategory,
    StoreItem,
    StoreInvitation,
    StoreClaimRequest,
)


@admin.register(StoreProfile)
class StoreProfileAdmin(admin.ModelAdmin):
    list_display = (
        "business_name",
        "owner_display_name",
        "merchant_type",
        "category",
        "created_at",
    )
    list_filter = ("merchant_type", "category", "halal", "vegan")
    search_fields = (
        "business_name",
        "owner__username",
        "owner__email",
        "street_address",
    )
    readonly_fields = ("created_at", "updated_at")
    autocomplete_fields = ["owner", "staff"]  # Makes searching for users easy


@admin.register(StoreOperatingHour)
class StoreOperatingHourAdmin(admin.ModelAdmin):
    list_display = ("store", "day_of_week", "open_time", "close_time")
    list_filter = ("day_of_week",)
    search_fields = ("store__business_name",)
    autocomplete_fields = ["store"]


@admin.register(ItemCategory)
class ItemCategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "store", "display_order")
    list_filter = ("store",)
    search_fields = ("name", "store__business_name")
    autocomplete_fields = ["store"]
    list_editable = ("display_order",)  # Quickly reorder categories from the list view


@admin.register(StoreItem)
class StoreItemAdmin(admin.ModelAdmin):
    list_display = ("name", "store", "category", "price", "stock_status", "is_active")
    list_filter = ("stock_status", "is_active", "vegetarian", "gluten_free", "organic")
    search_fields = ("name", "store__business_name", "category__name")
    readonly_fields = ("embedding", "created_at", "updated_at")
    autocomplete_fields = ["store", "category"]
    list_editable = (
        "price",
        "stock_status",
        "is_active",
    )  # Perfect for quick stock updates!


@admin.register(Promotion)
class PromotionAdmin(admin.ModelAdmin):
    list_display = (
        "title",
        "store",
        "promotion_type",
        "status",
        "is_active",
        "start_date",
        "end_date",
    )
    list_filter = ("promotion_type", "is_active")
    search_fields = ("title", "store__business_name")
    readonly_fields = ("created_at", "updated_at")
    autocomplete_fields = ["store", "eligible_items", "reward_item", "bundle_items"]


@admin.register(StoreInvitation)
class StoreInvitationAdmin(admin.ModelAdmin):
    list_display = (
        "email",
        "store",
        "first_name",
        "last_name",
        "is_expired",
        "created_at",
    )
    search_fields = ("email", "store__business_name", "first_name")
    readonly_fields = ("token", "created_at")
    autocomplete_fields = ["store"]


class StoreClaimRequestAdmin(admin.ModelAdmin):
    list_display = (
        "store",
        "requested_by",
        "status",
        "created_at",
        "admin_reviewed_by",
    )
    list_filter = ("status", "created_at")
    search_fields = (
        "store__business_name",
        "requested_by__email",
        "requested_by__username",
    )
    fields = (
        "store",
        "requested_by",
        "proof",
        "proof_preview",
        "message",
        "status",
        "rejection_reason",
        "admin_reviewed_by",
        "admin_reviewed_at",
        "created_at",
        "updated_at",
    )
    readonly_fields = (
        "store",
        "requested_by",
        "proof",
        "proof_preview",
        "message",
        "created_at",
        "updated_at",
        "admin_reviewed_by",
        "admin_reviewed_at",
    )
    actions = ("approve_selected_claims", "reject_selected_claims")

    @admin.display(description="Proof Preview")
    def proof_preview(self, obj):
        if obj.proof:
            return format_html(
                '<img src="{}" style="width: 100%; height: auto; border-radius: 8px;" />',
                obj.proof.url,
            )
        return "No Image Uploaded"

    @admin.action(description="Approve selected claim requests")
    def approve_selected_claims(self, request, queryset):
        for claim in queryset.filter(status=StoreClaimRequest.Status.PENDING):
            claim.approve(request.user)

    @admin.action(description="Reject selected claim requests")
    def reject_selected_claims(self, request, queryset):
        for claim in queryset.filter(status=StoreClaimRequest.Status.PENDING):
            claim.reject(request.user, reason="Rejected in admin")

    def save_model(self, request, obj, form, change):
        if change and "status" in form.changed_data:

            if obj.status == StoreClaimRequest.Status.APPROVED:
                obj.approve(request.user, save=False)

            elif obj.status == StoreClaimRequest.Status.REJECTED:
                obj.reject(request.user, reason=obj.rejection_reason, save=False)

        super().save_model(request, obj, form, change)
