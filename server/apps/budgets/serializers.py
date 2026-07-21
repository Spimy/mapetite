from rest_framework import serializers
from .models import SpendingRecord


class SpendingRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = SpendingRecord
        fields = ["id", "store", "amount", "spending_type", "date_spent", "created_at"]
        # Make created_at read-only so users can't edit it
        read_only_fields = ["id", "created_at"]
