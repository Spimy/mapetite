from django.db import models
from django.conf import settings
from apps.merchants.models import StoreProfile


# Create your models here.
class SpendingRecord(models.Model):
    class SpendingType(models.TextChoices):
        DINE_IN = "dine_in", "Dine In"
        GROCERY = "grocery", "Grocery"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="spending_records",
    )
    store = models.ForeignKey(
        StoreProfile,
        on_delete=models.SET_NULL,  # If a store is deleted, keep the user's spending history
        null=True,
        blank=True,  # Allow spending records without a store reference because the store might not be in the system yet, users can use notes to specify the store name instead
        related_name="customer_spendings",
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    spending_type = models.CharField(max_length=20, choices=SpendingType.choices)
    notes = models.CharField(max_length=255, blank=True, null=True)

    date_spent = models.DateField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} spent {self.amount} at {self.store.business_name if self.store else 'Unknown'}"
