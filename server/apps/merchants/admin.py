from django.contrib import admin
from .models import StoreProfile, StoreOperatingHour


# Register your models here.
class StoreProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


class StoreOperatingHourAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


admin.site.register(StoreProfile, StoreProfileAdmin)
admin.site.register(StoreOperatingHour, StoreOperatingHourAdmin)
