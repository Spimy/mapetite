from django.contrib import admin
from .models import StoreProfile


# Register your models here.
class StoreProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


admin.site.register(StoreProfile, StoreProfileAdmin)
