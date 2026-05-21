from datetime import time
from django.db import IntegrityError
from django.test import TestCase
from django.contrib.auth import get_user_model
from .models import StoreProfile, StoreOperatingHour

User = get_user_model()


# Create your tests here.
class StoreProfileModelTests(TestCase):
    def setUp(self):
        self.merchant_user = User.objects.create_user(
            username="MerchantUser",
            email="merchant@example.com",
            password="password123",
            is_merchant=True,
        )

    def test_store_profile_creation(self):
        """Test creation of a StoreProfile under a merchant user."""
        store = StoreProfile.objects.create(
            owner=self.merchant_user,
            business_name="Test Restaurant",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
        )
        self.assertEqual(store.business_name, "Test Restaurant")
        self.assertEqual(store.merchant_type, "RESTAURANT")
        self.assertEqual(store.owner, self.merchant_user)


class StoreOperatingHourModelTests(TestCase):
    def setUp(self):
        self.merchant_user = User.objects.create_user(
            username="MerchantUser",
            email="merchant@example.com",
            password="password123",
            is_merchant=True,
        )
        self.store = StoreProfile.objects.create(
            owner=self.merchant_user,
            business_name="Test Restaurant",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
        )

    def test_operating_hour_creation(self):
        """Test creation of an operating hour for a store."""
        operating_hour = StoreOperatingHour.objects.create(
            store=self.store,
            day_of_week=0,  # Monday
            open_time=time(9, 0),
            close_time=time(17, 0),
        )
        self.assertEqual(operating_hour.store, self.store)
        self.assertEqual(operating_hour.day_of_week, 0)
        self.assertEqual(operating_hour.open_time, time(9, 0))
        self.assertEqual(operating_hour.close_time, time(17, 0))

    def test_unique_day_of_week_per_store(self):
        """Test that a store can only have one operating hour per day of the week."""
        StoreOperatingHour.objects.create(
            store=self.store,
            day_of_week=0,  # Monday
            open_time=time(9, 0),
            close_time=time(17, 0),
        )
        with self.assertRaises(IntegrityError):
            StoreOperatingHour.objects.create(
                store=self.store,
                day_of_week=0,  # Monday again
                open_time=time(10, 0),
                close_time=time(18, 0),
            )

    def test_string_representation(self):
        """Test the string representation of an operating hour."""
        operating_hour = StoreOperatingHour.objects.create(
            store=self.store,
            day_of_week=4,  # Friday
            open_time=time(10, 30),
            close_time=time(22, 0),
        )
        self.assertEqual(
            str(operating_hour), "Test Restaurant - Friday: 10:30:00 to 22:00:00"
        )
