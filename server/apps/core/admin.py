from django.contrib import admin
from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ("user", "title", "is_read", "created_at")
    list_filter = ("is_read", "created_at")
    search_fields = ("title", "message", "user__username", "user__email")
    autocomplete_fields = ["user"]
    actions = ["mark_as_read"]

    @admin.action(description="Mark selected notifications as read")
    def mark_as_read(self, request, queryset):
        queryset.update(is_read=True)
