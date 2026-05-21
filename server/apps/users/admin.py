from django.contrib import admin
from .models import User, UserProfile


# Register your models here.
class UserProfileAdmin(admin.ModelAdmin):
    readonly_fields = ("created_at", "updated_at", "user")


admin.site.register(User)
admin.site.register(UserProfile, UserProfileAdmin)
