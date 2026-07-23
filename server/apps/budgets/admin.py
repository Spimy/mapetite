from django.contrib import admin
from .models import SpendingRecord


# Register your models here.
class SpendingRecordAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


admin.site.register(SpendingRecord, SpendingRecordAdmin)
