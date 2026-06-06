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
    phone_number = models.CharField(max_length=20, blank=True)

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


@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    """Automatically create a UserProfile when a new User is registered."""
    if created:
        UserProfile.objects.create(user=instance)
    else:
        # Save profile if the user object is updated
        if hasattr(instance, "profile"):
            instance.profile.save()
