import uuid
from google.genai import types
from django.db.models.signals import pre_save
from django.dispatch import receiver
from django.db import models
from django.contrib.gis.db import models as gis_models
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.contrib.gis.db.models.functions import Distance
from django.core.exceptions import ValidationError
from django.conf import settings
from django.utils import timezone
from django.utils.timezone import timedelta
from pgvector.django import VectorField

from apps.core.services import GeminiService


class StoreProfileQuerySet(models.QuerySet["StoreProfile"]):
    def nearby(self, user_location: Point, radius_km: float) -> "StoreProfileQuerySet":
        return (
            self.filter(location__distance_lte=(user_location, D(km=radius_km)))
            .annotate(distance=Distance("location", user_location))
            .order_by("distance")
        )


class StoreProfileManager(models.Manager["StoreProfile"]):
    def get_queryset(self) -> StoreProfileQuerySet:
        return StoreProfileQuerySet(self.model, using=self._db)

    def nearby(self, user_location: Point, radius_km: float) -> StoreProfileQuerySet:
        return self.get_queryset().nearby(user_location, radius_km)


# Create your models here.
class StoreProfile(gis_models.Model):
    # The choices for the type of business
    class MerchantType(models.TextChoices):
        RESTAURANT = "RESTAURANT", "Restaurant"
        GROCERY = "GROCERY", "Grocery Store"

    # Cuisine type (restaurants) or store sub-type (groceries)
    class Category(models.TextChoices):
        # Restaurant cuisines
        MAMAK = "MAMAK", "Mamak"
        NASI_KANDAR = "NASI_KANDAR", "Nasi Kandar"
        MALAYSIAN = "MALAYSIAN", "Malaysian"
        KOPITIAM = "KOPITIAM", "Kopitiam"
        CHINESE = "CHINESE", "Chinese"
        JAPANESE = "JAPANESE", "Japanese"
        KOREAN = "KOREAN", "Korean"
        FUSION = "FUSION", "Fusion"
        INDONESIAN = "INDONESIAN", "Indonesian"
        MEXICAN = "MEXICAN", "Mexican"
        MEDITERRANEAN = "MEDITERRANEAN", "Mediterranean"
        HEALTHY = "HEALTHY", "Healthy"
        VEGETARIAN = "VEGETARIAN", "Vegetarian"
        # Grocery sub-types
        SUPERMARKET = "SUPERMARKET", "Supermarket"
        CONVENIENCE = "CONVENIENCE", "Convenience Store"
        SPECIALTY = "SPECIALTY", "Specialty Mart"

    objects: StoreProfileManager = StoreProfileManager()  # type: ignore

    # Merchant staff and ownership
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="owned_stores",
    )
    staff = models.ManyToManyField(
        settings.AUTH_USER_MODEL, related_name="managed_stores", blank=True
    )

    merchant_type = models.CharField(
        max_length=20, choices=MerchantType.choices, default=MerchantType.RESTAURANT
    )
    category = models.CharField(
        max_length=40, choices=Category.choices, blank=True, default=""
    )

    business_name = models.CharField(max_length=255)
    description = models.TextField(blank=True)

    # Halal and vegan are restaurant level attributes rather than item level because if a restaurant is halal-certified, then all its food items are halal.
    # Similarly, if a restaurant is fully vegan, then all its food items are vegan.
    halal = models.BooleanField(default=False)
    vegan = models.BooleanField(default=False)

    street_address = models.CharField(max_length=255, blank=True)
    phone = models.CharField(max_length=32, blank=True)
    image = models.ImageField(upload_to="merchants/stores/", blank=True)

    location = gis_models.PointField(geography=True, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def latitude(self):
        return self.location.y if self.location else None

    @property
    def longitude(self):
        return self.location.x if self.location else None

    @property
    def owner_display_name(self):
        if not self.owner:
            return "No Owner"

        first = getattr(self.owner, "first_name", "")
        last = getattr(self.owner, "last_name", "")

        if first or last:
            return f"{first} {last}".strip()
        return self.owner.username

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

    class UnitChoices(models.TextChoices):
        G = "g", "Grams (g)"
        KG = "kg", "Kilograms (kg)"
        ML = "ml", "Milliliters (ml)"
        L = "L", "Liters (L)"
        PCS = "pcs", "Pieces (pcs)"
        TBS = "tbsp", "Tablespoon (tbsp)"
        TSP = "tsp", "Teaspoon (tsp)"
        CUP = "cup", "Cup"

    store = models.ForeignKey(
        StoreProfile, on_delete=models.CASCADE, related_name="items"
    )
    category = models.ForeignKey(
        ItemCategory,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="items",
    )

    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    quantity = models.DecimalField(
        max_digits=8, decimal_places=2, null=True, blank=True
    )
    unit = models.CharField(max_length=10, choices=UnitChoices.choices, blank=True)

    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    stock_status = models.CharField(
        max_length=20, choices=StockStatus.choices, default=StockStatus.IN_STOCK
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

    embedding = VectorField(dimensions=768, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        changed = False

        if not is_new:
            old_item = StoreItem.objects.get(pk=self.pk)
            changed = (old_item.name != self.name) or (
                old_item.description != self.description
            )

        if is_new or changed:
            try:
                client = GeminiService.get_client()
                text_to_embed = f"{self.name} {self.description or ''} {self.category.name if self.category else ''}".strip()

                response = client.models.embed_content(
                    model=GeminiService.get_model("embedding"),
                    contents=text_to_embed,
                    config=types.EmbedContentConfig(output_dimensionality=768),
                )

                if response.embeddings:
                    self.embedding = response.embeddings[0].values
            except Exception as e:
                # Log the error but do NOT crash the save;
                # keep the embedding as NULL so that it is possible to re-run the management command later
                print(f"Embedding failed: {e}")

        super().save(*args, **kwargs)

    def format_unit_size(self) -> str:
        if self.quantity is None or not self.unit:
            return ""
        quantity_str = f"{self.quantity:.2f}".rstrip("0").rstrip(".")
        return f"{quantity_str} {self.unit}"

    def __str__(self):
        status_label = self.StockStatus(self.stock_status).label
        return f"{self.name} ({status_label})"


class Promotion(models.Model):
    class PromotionType(models.TextChoices):
        PERCENTAGE = "PERCENTAGE", "Percentage Discount"
        FLAT_AMOUNT = "FLAT_AMOUNT", "Flat Amount Discount"
        FREE_ITEM = "FREE_ITEM", "Free Item with Purchase"
        BUNDLE = "BUNDLE", "Bundle Deal"

    store = models.ForeignKey(
        "StoreProfile", on_delete=models.CASCADE, related_name="promotions"
    )
    title = models.CharField(max_length=255)
    description = models.TextField(
        blank=True, help_text="General description for customers."
    )

    promotion_type = models.CharField(
        max_length=20, choices=PromotionType.choices, default=PromotionType.PERCENTAGE
    )

    # THE NUMBERS (Used by PERCENTAGE, FLAT_AMOUNT, and as the PRICE for BUNDLES)
    promotion_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        help_text="Discount amount OR the total fixed price of the bundle.",
    )
    minimum_purchase_amount = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )

    # ELIGIBILITY (Used by PERCENTAGE, FLAT_AMOUNT and FREE_ITEM)
    eligible_items = models.ManyToManyField(
        "StoreItem",
        blank=True,
        related_name="eligible_promotions",
        help_text="Items this promo applies to. Leave blank for store-wide.",
    )

    # REWARDS (Used by FREE_ITEM)
    reward_item = models.ForeignKey(
        "StoreItem",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="rewarded_promotions",
        help_text="The single item given away for free.",
    )

    # BUNDLE DETAILS (Used by BUNDLE)
    bundle_items = models.ManyToManyField(
        "StoreItem",
        blank=True,
        related_name="bundled_promotions",
        help_text="Select the actual items included in this bundle.",
    )
    bundle_description = models.TextField(
        blank=True, help_text="Extra info about the bundle (e.g., 'Serves 2-3 pax')."
    )

    is_active = models.BooleanField(default=True)

    start_date = models.DateField()
    end_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def can_reactivate(self):
        """Returns True if the promotion has not expired yet."""
        if not self.end_date:
            return False
        return self.end_date >= timezone.now().date()

    @property
    def status(self):
        """Returns the current real-world status of the promotion."""
        today = timezone.now().date()

        if self.end_date and self.end_date < today:
            return "Expired"

        if not self.is_active:
            return "Paused"

        if self.start_date and self.start_date > today:
            return "Scheduled"

        return "Live"

    @property
    def display_items(self):
        items = self.eligible_items.all() or self.bundle_items.all()
        if not items:
            return ""

        names = [i.name for i in items[:2]]
        suffix = f" +{items.count() - 2} more" if items.count() > 2 else ""
        return ", ".join(names) + suffix

    def clean(self):
        super().clean()

        # Validation for PERCENTAGE / FLAT AMOUNT
        if self.promotion_type in [
            self.PromotionType.PERCENTAGE,
            self.PromotionType.FLAT_AMOUNT,
        ]:
            if not self.promotion_amount:
                raise ValidationError(
                    {
                        "promotion_amount": "Amount is required for Percentage/Flat discounts."
                    }
                )

            # Clear fields belonging to other types
            self.reward_item = None
            self.bundle_description = ""

        # Validation for FREE ITEM
        elif self.promotion_type == self.PromotionType.FREE_ITEM:
            if not self.reward_item:
                raise ValidationError({"reward_item": "You must select a reward item."})

            self.promotion_amount = None
            self.bundle_description = ""

        # Validation for BUNDLE
        elif self.promotion_type == self.PromotionType.BUNDLE:
            if not self.promotion_amount:
                raise ValidationError(
                    {"promotion_amount": "Set a total price for the bundle."}
                )

            # Clear fields belonging to other types
            self.minimum_purchase_amount = None
            self.reward_item = None

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        if self.promotion_type == self.PromotionType.PERCENTAGE:
            return f"{self.title} - {self.promotion_amount}% off"
        elif self.promotion_type == self.PromotionType.FLAT_AMOUNT:
            return f"{self.title} - ${self.promotion_amount} off"
        elif self.promotion_type == self.PromotionType.FREE_ITEM:
            return f"{self.title} - Free {self.reward_item.name if self.reward_item else 'Item'}"
        elif self.promotion_type == self.PromotionType.BUNDLE:
            return f"{self.title} - Bundle (${self.promotion_amount})"
        return self.title


class StoreInvitation(models.Model):
    store = models.ForeignKey(
        "StoreProfile", on_delete=models.CASCADE, related_name="invitations"
    )
    email = models.EmailField()
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    token = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        # Prevent spamming the same email for the same store
        unique_together = ("store", "email")

    @property
    def is_expired(self):
        # Invites expire after 3 days
        return timezone.now() > self.created_at + timedelta(days=3)

    def __str__(self):
        return f"Invite to {self.email} for {self.store.business_name}"


class StoreClaimRequest(models.Model):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"

    store = models.ForeignKey(
        "StoreProfile",
        on_delete=models.CASCADE,
        related_name="claim_requests",
    )
    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="store_claim_requests",
    )
    proof = models.FileField(upload_to="merchants/claim-proofs/")
    message = models.TextField(blank=True)

    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.PENDING,
    )
    admin_reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="reviewed_store_claim_requests",
    )
    admin_reviewed_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]
        constraints = [
            models.UniqueConstraint(
                fields=["store", "requested_by"],
                condition=models.Q(status="PENDING"),
                name="unique_pending_claim_per_user_store",
            )
        ]

    def approve(self, reviewer, save=True):
        if self.store.owner_id is None:
            self.store.owner = self.requested_by
            self.store.save(update_fields=["owner", "updated_at"])

        self.status = self.Status.APPROVED
        self.admin_reviewed_by = reviewer
        self.admin_reviewed_at = timezone.now()
        self.rejection_reason = ""

        if save:
            self.save(
                update_fields=[
                    "status",
                    "admin_reviewed_by",
                    "admin_reviewed_at",
                    "rejection_reason",
                    "updated_at",
                ]
            )

    def reject(self, reviewer, reason="", save=True):
        self.status = self.Status.REJECTED
        self.admin_reviewed_by = reviewer
        self.admin_reviewed_at = timezone.now()
        self.rejection_reason = reason

        if save:
            self.save(
                update_fields=[
                    "status",
                    "admin_reviewed_by",
                    "admin_reviewed_at",
                    "rejection_reason",
                    "updated_at",
                ]
            )


@receiver(pre_save, sender=StoreProfile)
@receiver(pre_save, sender=StoreOperatingHour)
@receiver(pre_save, sender=ItemCategory)
@receiver(pre_save, sender=StoreItem)
def populate_timestamps_for_fixtures(sender, instance, **kwargs):
    """
    Ensure created_at and updated_at are populated during `loaddata`.
    Django raw/fixtures loader (kwargs['raw'] is True) bypasses normal auto_now_add.
    """
    if kwargs.get("raw", False):
        now = timezone.now()
        if hasattr(instance, "created_at") and not instance.created_at:
            instance.created_at = now
        if hasattr(instance, "updated_at") and not instance.updated_at:
            instance.updated_at = now
