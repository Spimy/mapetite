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


# Register your models here.
class StoreProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class StoreOperatingHourAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class ItemCategoryAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class StoreItemAdmin(admin.ModelAdmin):
    readonly_fields = ("embedding", "created_at", "updated_at")


class PromotionAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class StoreInvitationAdmin(admin.ModelAdmin):
    # Token should not be editable as it is generated automatically and is important for the invitation process
    readonly_fields = ("token",)


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


admin.site.register(StoreProfile, StoreProfileAdmin)
admin.site.register(StoreOperatingHour, StoreOperatingHourAdmin)
admin.site.register(ItemCategory, ItemCategoryAdmin)
admin.site.register(StoreItem, StoreItemAdmin)
admin.site.register(Promotion, PromotionAdmin)
admin.site.register(StoreInvitation, StoreInvitationAdmin)
admin.site.register(StoreClaimRequest, StoreClaimRequestAdmin)
