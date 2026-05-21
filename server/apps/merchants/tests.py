from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import StoreProfile

User = get_user_model()


# Create your tests here.
class StoreProfileModelTests(TestCase):
    def setUp(self):
        self.merchant_user = User.objects.create_user(
            username="MerchantUser",
            email="merchant@example.com",
            password="password123",
            is_merchant=True
        )

    def test_store_profile_creation(self):
        """Test creation of a StoreProfile under a merchant user."""
        store = StoreProfile.objects.create(
            owner=self.merchant_user,
            business_name="Test Restaurant",
            merchant_type=StoreProfile.MerchantType.RESTAURANT
        )
        self.assertEqual(store.business_name, "Test Restaurant")
        self.assertEqual(store.merchant_type, "RESTAURANT")
        self.assertEqual(store.owner, self.merchant_user)
