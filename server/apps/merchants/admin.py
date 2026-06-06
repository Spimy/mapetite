from django.contrib import admin
from .models import Promotion, StoreProfile, StoreOperatingHour, ItemCategory, StoreItem


# Register your models here.
class StoreProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class StoreOperatingHourAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")

class ItemCategoryAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")
    
class StoreItemAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")
    
class PromotionAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")

admin.site.register(StoreProfile, StoreProfileAdmin)
admin.site.register(StoreOperatingHour, StoreOperatingHourAdmin)
admin.site.register(ItemCategory, ItemCategoryAdmin)
admin.site.register(StoreItem, StoreItemAdmin)
admin.site.register(Promotion, PromotionAdmin)