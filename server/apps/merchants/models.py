from django.db import models
from django.conf import settings


# Create your models here.
class StoreProfile(models.Model):
    # The choices for the type of business
    class MerchantType(models.TextChoices):
        RESTAURANT = "RESTAURANT", "Restaurant"
        GROCERY = "GROCERY", "Grocery Store"

    # Merchant staff and ownership
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="owned_stores"
    )
    staff = models.ManyToManyField(
        settings.AUTH_USER_MODEL, related_name="managed_stores", blank=True
    )

    merchant_type = models.CharField(
        max_length=20, choices=MerchantType.choices, default=MerchantType.RESTAURANT
    )

    business_name = models.CharField(max_length=255)
    description = models.TextField(blank=True)

    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        display_name = self.MerchantType(self.merchant_type).label
        return f"{self.business_name} ({display_name})"


class StoreOperatingHour(models.Model):
    store = models.ForeignKey(
        StoreProfile, on_delete=models.CASCADE, related_name="operating_hours"
    )
    day_of_week = models.IntegerField(
        choices=[
            (0, "Monday"),
            (1, "Tuesday"),
            (2, "Wednesday"),
            (3, "Thursday"),
            (4, "Friday"),
            (5, "Saturday"),
            (6, "Sunday"),
        ]
    )
    open_time = models.TimeField()
    close_time = models.TimeField()

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ("store", "day_of_week")

    def __str__(self):
        days = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
        ]
        return f"{self.store.business_name} - {days[self.day_of_week]}: {self.open_time} to {self.close_time}"
