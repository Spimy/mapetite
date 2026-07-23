from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = [
            "id",
            "title",
            "message",
            "is_read",
            "created_at",
            "updated_at",
        ]
        # Lock down all fields except is_read so they cannot be modified via PUT/PATCH
        read_only_fields = ["id", "title", "message", "created_at", "updated_at"]
