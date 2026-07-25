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
    class HealthGoalChoices(models.TextChoices):
        MAINTAIN_WEIGHT = "maintain_weight", "Maintain Weight"
        LOSE_WEIGHT = "lose_weight", "Lose Weight"
        GAIN_MUSCLE = "gain_muscle", "Gain Muscle"
        GENERAL_HEALTH = "general_health", "General Health"

    class ActivityLevelChoices(models.TextChoices):
        SEDENTARY = "sedentary", "Sedentary"
        LIGHT = "light", "Light"
        MODERATE = "moderate", "Moderate"
        ACTIVE = "active", "Active"

    class AllergyChoices(models.TextChoices):
        NUTS = "nuts", "Nuts"
        DAIRY = "dairy", "Dairy"
        GLUTEN = "gluten", "Gluten"
        SHELLFISH = "shellfish", "Shellfish"
        EGGS = "eggs", "Eggs"
        SOY = "soy", "Soy"

    class PreferredCuisineChoices(models.TextChoices):
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

    user = models.OneToOneField(
        User, on_delete=models.CASCADE, related_name="user_profile"
    )
    onboarding_completed = models.BooleanField(default=False)

    # Profile data
    avatar = models.ImageField(upload_to="users/avatars", blank=True)
    phone_number = models.CharField(max_length=20, blank=True)

    # Module 1: Location data
    address = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100, blank=True)
    country = models.CharField(max_length=100, blank=True)

    # Module 2: Health & Preferences
    target_calories = models.PositiveIntegerField(null=True, blank=True)
    dine_in_budget = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    grocery_budget = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    spending_alert_percent = models.PositiveSmallIntegerField(default=80)

    health_goal = models.CharField(
        max_length=30,
        choices=HealthGoalChoices.choices,
        blank=True,
        default="",
    )
    activity_level = models.CharField(
        max_length=20,
        choices=ActivityLevelChoices.choices,
        blank=True,
        default="",
    )
    current_weight = models.DecimalField(
        max_digits=6, decimal_places=2, null=True, blank=True
    )

    is_halal = models.BooleanField(default=False)
    is_vegan = models.BooleanField(default=False)
    is_vegetarian = models.BooleanField(default=False)
    allergies = ArrayField(
        models.CharField(
            max_length=20,
            choices=AllergyChoices.choices,
        ),
        blank=True,
        default=list,
        help_text="List of user allergies",
    )

    preferred_cuisines = ArrayField(
        models.CharField(
            max_length=30,
            choices=PreferredCuisineChoices.choices,
        ),
        blank=True,
        default=list,
        help_text="List of user's preferred cuisines",
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s profile"


@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    """Automatically create a UserProfile when a new User is registered."""
    if created:
        UserProfile.objects.create(user=instance)
    else:
        # Save profile if the user object is updated
        if hasattr(instance, "profile"):
            instance.profile.save()
