from django.contrib import admin
from .models import SpendingRecord


@admin.register(SpendingRecord)
class SpendingRecordAdmin(admin.ModelAdmin):
    list_display = ("user", "store", "amount", "spending_type", "date_spent")
    list_filter = ("spending_type", "date_spent")
    search_fields = ("user__username", "user__email", "store__business_name", "notes")
    autocomplete_fields = ["user", "store"]
    readonly_fields = ("created_at", "updated_at")
