from django.db import models
from django.utils.text import slugify
from django.contrib.auth.models import AbstractUser, UserManager
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.postgres.fields import ArrayField


# Create your models here.
class CaseInsensitiveUserManager(UserManager):
    def get_by_natural_key(self, username):
        """
        Override Django's default case-sensitive username check

        This makes the username case-insensitve so only one user
        can have a specific username regardless of its letter casing
        """
        case_insensitive_username_field = f"{self.model.USERNAME_FIELD}__iexact"
        return self.get(**{case_insensitive_username_field: username})


class User(AbstractUser):
    slug = models.SlugField(max_length=255, blank=True, unique=True)
    email = models.EmailField(unique=True)
    is_merchant = models.BooleanField(default=False)

    objects = CaseInsensitiveUserManager()

    def save(self, *args, **kwargs):
        self.slug = slugify(self.username)
        return super().save(*args, **kwargs)

    def __str__(self):
        return self.username


class UserProfile(models.Model):
    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="user_profile"
    )

    # Profile data
    avatar = models.ImageField(upload_to="users/avatars", blank=True)

    # Module 1: Location data
    address = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100, blank=True)
    country = models.CharField(max_length=100, blank=True)

    # Module 2: Health & Preferences
    budget_monthly = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )

    is_halal = models.BooleanField(default=False)
    is_vegan = models.BooleanField(default=False)
    allergies = ArrayField(
        models.CharField(max_length=50),
        blank=True,
        default=list,
        help_text="List of user allergies",
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s profile"


class StoreProfile(models.Model):
    # The choices for the type of business
    class MerchantType(models.TextChoices):
        RESTAURANT = "RESTAURANT", "Restaurant"
        GROCERY = "GROCERY", "Grocery Store"

    # Merchant staff and ownership
    owner = models.ForeignKey(
        User, on_delete=models.PROTECT, related_name="owned_stores"
    )
    staff = models.ManyToManyField(
        User, related_name="managed_stores", blank=True)

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


@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    """Automatically create a UserProfile when a new User is registered."""
    if created:
        UserProfile.objects.create(user=instance)
    else:
        # Save profile if the user object is updated
        if hasattr(instance, "profile"):
            instance.profile.save()
