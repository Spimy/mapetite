from django.test import TestCase, Client
from django.urls import reverse
from .models import User, UserProfile
from allauth.account.models import EmailAddress, EmailConfirmationHMAC


# Create your tests here.
class UserModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="TestUser",
            email="testuser@example.com",
            password="testpassword123"
        )

    def test_user_slug_generation(self):
        """Test that a slug is automatically generated from the username upon saving."""
        self.assertEqual(self.user.slug, "testuser")

    def test_case_insensitive_username(self):
        """Test the CaseInsensitiveUserManager returns the user regardless of casing."""
        fetched_user = User.objects.get_by_natural_key("TESTUSER")
        self.assertEqual(self.user, fetched_user)

        fetched_user_lower = User.objects.get_by_natural_key("testuser")
        self.assertEqual(self.user, fetched_user_lower)

    def test_string_representation(self):
        """Test the string representation of the model."""
        self.assertEqual(str(self.user), "TestUser")


class ProfileModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="NormalUser",
            email="normal@example.com",
            password="password123"
        )
        self.merchant_user = User.objects.create_user(
            username="MerchantUser",
            email="merchant@example.com",
            password="password123",
            is_merchant=True
        )

    def test_user_profile_creation(self):
        """Test default values of the auto-created UserProfile and updating it."""
        # The user profile is created automatically by the post_save signal
        profile = UserProfile.objects.get(user=self.user)

        # Test defaults
        self.assertEqual(str(profile), "NormalUser's profile")
        self.assertFalse(profile.is_halal)
        self.assertFalse(profile.is_vegan)

        # Test updating fields
        profile.city = "Paris"
        profile.is_halal = True
        profile.save()

        # Verify update
        profile.refresh_from_db()
        self.assertEqual(profile.city, "Paris")
        self.assertTrue(profile.is_halal)


class ViewTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="testuser@example.com",
            password="testpassword123"
        )

    def test_sign_in_view_get(self):
        """Test if the sign in page renders successfully."""
        response = self.client.get(reverse('users:sign_in'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'users/signin.html')

    def test_sign_in_view_post_success(self):
        """Test successful user login."""
        response = self.client.post(reverse('users:sign_in'), {
            'username': 'testuser',
            'password': 'testpassword123'
        })
        # Should redirect to the success_url
        self.assertEqual(response.status_code, 302)
        # Check if user is authenticated in the session
        self.assertTrue(response.wsgi_request.user.is_authenticated)

    def test_sign_out_view(self):
        """Test user logout functionality."""
        self.client.login(username='testuser', password='testpassword123')

        response = self.client.get(reverse('users:sign_out'))
        self.assertEqual(response.status_code, 302)
        self.assertFalse(response.wsgi_request.user.is_authenticated)

    def test_confirm_email_view_invalid_key(self):
        """Test email confirmation with an invalid key."""
        response = self.client.get(
            reverse('users:account_confirm_email', kwargs={'key': 'invalid-key'}))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(
            response, 'users/email_verification/email_verification_failed.html')

    def test_confirm_email_view_valid_key(self):
        """Test email confirmation with a valid key."""
        email_address = EmailAddress.objects.create(
            user=self.user,
            email=self.user.email,
            verified=False,
            primary=True
        )
        # Generating a valid HMAC confirmation for allauth
        confirmation = EmailConfirmationHMAC(email_address)

        response = self.client.get(
            reverse('users:account_confirm_email', kwargs={'key': confirmation.key}))

        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(
            response, 'users/email_verification/email_verification_success.html')

        # Verify that the address was successfully verified
        email_address.refresh_from_db()
        self.assertTrue(email_address.verified)
