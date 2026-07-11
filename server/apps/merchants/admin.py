from django.contrib import admin
from .models import (
    Promotion,
    StoreProfile,
    StoreOperatingHour,
    ItemCategory,
    StoreItem,
    StoreInvitation,
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


admin.site.register(StoreProfile, StoreProfileAdmin)
admin.site.register(StoreOperatingHour, StoreOperatingHourAdmin)
admin.site.register(ItemCategory, ItemCategoryAdmin)
admin.site.register(StoreItem, StoreItemAdmin)
admin.site.register(Promotion, PromotionAdmin)
admin.site.register(StoreInvitation, StoreInvitationAdmin)
