from django.db import models
from django.contrib.gis.db import models as gis_models
from django.contrib.gis.geos import Point
from django.conf import settings


# Create your models here.
class StoreProfile(gis_models.Model):
    # The choices for the type of business
    class MerchantType(models.TextChoices):
        RESTAURANT = "RESTAURANT", "Restaurant"
        GROCERY = "GROCERY", "Grocery Store"

    # Merchant staff and ownership
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, null=True, blank=True, related_name="owned_stores"
    )
    staff = models.ManyToManyField(
        settings.AUTH_USER_MODEL, related_name="managed_stores", blank=True
    )

    merchant_type = models.CharField(
        max_length=20, choices=MerchantType.choices, default=MerchantType.RESTAURANT
    )

    business_name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    
    # Halal and vegan are restaurant level attributes rather than item level because if a restaurant is halal-certified, then all its food items are halal.
    # Similarly, if a restaurant is fully vegan, then all its food items are vegan.
    halal = models.BooleanField(default=False)
    vegan = models.BooleanField(default=False)

    location = gis_models.PointField(geography=True, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def latitude(self):
        return self.location.y if self.location else None

    @property
    def longitude(self):
        return self.location.x if self.location else None

    def set_coordinates(self, lat, lon):
        if lat and lon:
            self.location = Point(float(lon), float(lat))
        else:
            self.location = None

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

class ItemCategory(models.Model):
    """
    Allows merchants to organise their offerings.
    Restaurant examples: 'Starters', 'Mains', 'Drinks'
    Grocery examples: 'Fresh Produce', 'Dairy', 'Snacks'
    """
    store = models.ForeignKey(
        StoreProfile, on_delete=models.CASCADE, related_name="categories"
    )
    name = models.CharField(max_length=100)
    display_order = models.PositiveIntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name_plural = "Item Categories"
        ordering = ["display_order", "name"]

    def __str__(self):
        return f"{self.store.business_name} - {self.name}"


class StoreItem(models.Model):
    class StockStatus(models.TextChoices):
        IN_STOCK = "IN_STOCK", "In Stock"
        LOW_STOCK = "LOW_STOCK", "Low Stock"
        OUT_OF_STOCK = "OUT_OF_STOCK", "Out of Stock"

    store = models.ForeignKey(
        StoreProfile, on_delete=models.CASCADE, related_name="items"
    )
    category = models.ForeignKey(
        ItemCategory, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True, 
        related_name="items"
    )
    
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    
    price = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    
    stock_status = models.CharField(
        max_length=20, 
        choices=StockStatus.choices, 
        default=StockStatus.IN_STOCK
    )
    
    # Nutritional information
    calories = models.PositiveIntegerField(null=True, blank=True)

    # Dietary attributes
    vegetarian = models.BooleanField(default=False)
    organic = models.BooleanField(default=False)
    gluten_free = models.BooleanField(default=False)
    dairy_free = models.BooleanField(default=False)
    contains_nuts = models.BooleanField(default=False)

    # Sustainability attributes
    eco_packaging = models.BooleanField(default=False)
    locally_sourced = models.BooleanField(default=False)
    
    # Allows merchants to completely hide an item (e.g., seasonal) without deleting it
    is_active = models.BooleanField(default=True)
    
    thumbnail = models.ImageField(upload_to="merchants/items", blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        status_label = self.StockStatus(self.stock_status).label
        return f"{self.name} ({status_label})"