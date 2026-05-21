from django.contrib import admin
from .models import User, UserProfile, StoreProfile


# Register your models here.
class UserProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at", "user")


class StoreProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at")


admin.site.register(User)
admin.site.register(UserProfile, UserProfileAdmin)
admin.site.register(StoreProfile, StoreProfileAdmin)
