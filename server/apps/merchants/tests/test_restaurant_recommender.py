from datetime import datetime, time
from decimal import Decimal
from unittest.mock import patch
from zoneinfo import ZoneInfo

from django.contrib.auth import get_user_model
from django.contrib.gis.geos import Point
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.merchants.models import ItemCategory, StoreItem, StoreOperatingHour, StoreProfile
from apps.merchants.services.restaurant_recommender import (
    RestaurantRecommender,
    WEIGHT_CUISINE,
    VECTOR_CUISINE_MAX_DISTANCE,
    _hybrid_cuisine_score,
    _rule_cuisine_score,
    _vector_cuisine_score,
    batch_best_item_distances,
    clear_user_cuisine_embed_cache,
    compute_menu_aggregates,
    get_or_embed_user_cuisine_vector,
    is_store_open_at,
    passes_hard_filters,
    pricing_bracket_from_avg,
)
from apps.users.models import UserProfile
from config.settings import WGS84_SRID

User = get_user_model()
KL = ZoneInfo("Asia/Kuala_Lumpur")

# Bandar Sunway reference point (near fixture restaurants)
ORIGIN = Point(101.6024, 3.0678, srid=WGS84_SRID)


def _aware(dt: datetime) -> datetime:
    if timezone.is_naive(dt):
        return timezone.make_aware(dt, KL)
    return dt.astimezone(KL)


class HelperUnitTests(TestCase):
    def test_pricing_bracket_thresholds(self):
        self.assertEqual(pricing_bracket_from_avg(None), "mid")
        self.assertEqual(pricing_bracket_from_avg(9.99), "budget")
        self.assertEqual(pricing_bracket_from_avg(10.0), "mid")
        self.assertEqual(pricing_bracket_from_avg(19.99), "mid")
        self.assertEqual(pricing_bracket_from_avg(20.0), "premium")

    def test_is_store_open_same_day_and_closed_day(self):
        store = StoreProfile.objects.create(
            business_name="Hours Cafe",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
            category=StoreProfile.Category.KOPITIAM,
            location=ORIGIN,
        )
        StoreOperatingHour.objects.create(
            store=store,
            day_of_week=0,  # Monday
            open_time=time(9, 0),
            close_time=time(17, 0),
        )
        monday_noon = _aware(datetime(2026, 7, 27, 12, 0))  # Monday
        monday_evening = _aware(datetime(2026, 7, 27, 20, 0))
        tuesday_noon = _aware(datetime(2026, 7, 28, 12, 0))

        self.assertTrue(is_store_open_at(store, monday_noon))
        self.assertFalse(is_store_open_at(store, monday_evening))
        self.assertFalse(is_store_open_at(store, tuesday_noon))

    def test_is_store_open_overnight(self):
        store = StoreProfile.objects.create(
            business_name="Night Spot",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
            location=ORIGIN,
        )
        StoreOperatingHour.objects.create(
            store=store,
            day_of_week=4,  # Friday
            open_time=time(22, 0),
            close_time=time(2, 0),
        )
        friday_late = _aware(datetime(2026, 7, 31, 23, 0))  # Friday
        saturday_early = _aware(datetime(2026, 8, 1, 1, 0))  # Saturday morning
        saturday_afternoon = _aware(datetime(2026, 8, 1, 15, 0))

        self.assertTrue(is_store_open_at(store, friday_late))
        self.assertTrue(is_store_open_at(store, saturday_early))
        self.assertFalse(is_store_open_at(store, saturday_afternoon))


class RestaurantRecommenderTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="rec_user",
            email="rec@example.com",
            password="password123",
        )
        self.profile: UserProfile = self.user.user_profile
        self.recommender = RestaurantRecommender()

        # Non-halal Chinese (like fixture stores 7/8)
        self.non_halal = self._make_store(
            "Zhia Kitchen",
            StoreProfile.Category.CHINESE,
            halal=False,
            vegan=False,
            lng=101.6030,
            lat=3.0680,
            avg_price=Decimal("15.00"),
            calories=700,
            vegetarian=False,
            contains_nuts=False,
            dairy_free=True,
            gluten_free=True,
        )
        # Halal mamak
        self.mamak = self._make_store(
            "Aman Mamak",
            StoreProfile.Category.MAMAK,
            halal=True,
            vegan=False,
            lng=101.6025,
            lat=3.0679,
            avg_price=Decimal("8.00"),
            calories=800,
            vegetarian=True,
            contains_nuts=False,
            dairy_free=True,
            gluten_free=False,
        )
        # Healthy vegan
        self.healthy = self._make_store(
            "Kubis Kale",
            StoreProfile.Category.HEALTHY,
            halal=True,
            vegan=True,
            lng=101.6035,
            lat=3.0685,
            avg_price=Decimal("12.00"),
            calories=350,
            vegetarian=True,
            contains_nuts=False,
            dairy_free=True,
            gluten_free=True,
        )
        # All-nuts menu
        self.nutty = self._make_store(
            "Nut House",
            StoreProfile.Category.FUSION,
            halal=True,
            vegan=False,
            lng=101.6040,
            lat=3.0690,
            avg_price=Decimal("18.00"),
            calories=600,
            vegetarian=False,
            contains_nuts=True,
            dairy_free=True,
            gluten_free=True,
        )
        # 24h open for open_now tests
        for day in range(7):
            StoreOperatingHour.objects.create(
                store=self.mamak,
                day_of_week=day,
                open_time=time(0, 0),
                close_time=time(23, 59),
            )
            StoreOperatingHour.objects.create(
                store=self.healthy,
                day_of_week=day,
                open_time=time(0, 0),
                close_time=time(23, 59),
            )
            StoreOperatingHour.objects.create(
                store=self.non_halal,
                day_of_week=day,
                open_time=time(0, 0),
                close_time=time(23, 59),
            )
        # Nutty only open Mondays 09–17
        StoreOperatingHour.objects.create(
            store=self.nutty,
            day_of_week=0,
            open_time=time(9, 0),
            close_time=time(17, 0),
        )

    def _make_store(
        self,
        name,
        category,
        *,
        halal,
        vegan,
        lng,
        lat,
        avg_price,
        calories,
        vegetarian,
        contains_nuts,
        dairy_free,
        gluten_free,
        extra_safe_item: bool = False,
    ):
        store = StoreProfile.objects.create(
            business_name=name,
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
            category=category,
            halal=halal,
            vegan=vegan,
            location=Point(lng, lat, srid=WGS84_SRID),
        )
        cat = ItemCategory.objects.create(store=store, name="Mains", display_order=1)
        StoreItem.objects.create(
            store=store,
            category=cat,
            name=f"{name} Main",
            price=avg_price,
            calories=calories,
            vegetarian=vegetarian,
            contains_nuts=contains_nuts,
            dairy_free=dairy_free,
            gluten_free=gluten_free,
            is_active=True,
        )
        if extra_safe_item:
            StoreItem.objects.create(
                store=store,
                category=cat,
                name=f"{name} Safe Side",
                price=Decimal("5.00"),
                calories=200,
                vegetarian=True,
                contains_nuts=False,
                dairy_free=True,
                gluten_free=True,
                is_active=True,
            )
        return store

    def _ids(self, results):
        return [r.store.id for r in results]

    def test_halal_user_excludes_non_halal(self):
        self.profile.is_halal = True
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True
        )
        ids = self._ids(results)
        self.assertNotIn(self.non_halal.id, ids)
        self.assertIn(self.mamak.id, ids)

    def test_vegan_user_only_vegan_stores(self):
        self.profile.is_vegan = True
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True
        )
        self.assertTrue(results)
        self.assertTrue(all(r.store.vegan for r in results))
        self.assertIn(self.healthy.id, self._ids(results))
        self.assertNotIn(self.mamak.id, self._ids(results))

    def test_preferred_cuisine_mamak_ranks_higher(self):
        self.profile.is_halal = True
        self.profile.preferred_cuisines = ["mamak"]
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True, limit=10
        )
        # Mamak should outrank healthy when cuisine is preferred and both pass filters
        mamak_score = next(r.match_score for r in results if r.store.id == self.mamak.id)
        healthy_score = next(
            r.match_score for r in results if r.store.id == self.healthy.id
        )
        self.assertGreater(mamak_score, healthy_score)
        self.assertIn(
            "cuisine_match",
            next(r.reasons for r in results if r.store.id == self.mamak.id),
        )

    def test_lose_weight_boosts_healthy(self):
        self.profile.is_halal = True
        self.profile.health_goal = UserProfile.HealthGoalChoices.LOSE_WEIGHT
        self.profile.target_calories = 1800
        self.profile.preferred_cuisines = []
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True, limit=10
        )
        healthy = next(r for r in results if r.store.id == self.healthy.id)
        mamak = next(r for r in results if r.store.id == self.mamak.id)
        self.assertGreaterEqual(healthy.score_parts["health"], mamak.score_parts["health"])
        # Overall: healthy low-cal vegan should beat high-cal mamak when cuisine unset
        self.assertGreater(healthy.match_score, mamak.match_score)

    def test_low_budget_prefers_cheaper_avg_price(self):
        self.profile.is_halal = True
        self.profile.dine_in_budget = Decimal("150.00")  # ~RM5/meal
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True, limit=10
        )
        mamak = next(r for r in results if r.store.id == self.mamak.id)
        healthy = next(r for r in results if r.store.id == self.healthy.id)
        self.assertGreater(mamak.score_parts["budget"], healthy.score_parts["budget"])

    def test_nuts_allergy_excludes_all_nut_menu(self):
        self.profile.is_halal = True
        self.profile.allergies = ["nuts"]
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True
        )
        ids = self._ids(results)
        self.assertNotIn(self.nutty.id, ids)
        self.assertIn(self.mamak.id, ids)

    def test_nuts_allergy_keeps_mixed_menu_with_safe_item(self):
        mixed = self._make_store(
            "Mixed Nuts Cafe",
            StoreProfile.Category.FUSION,
            halal=True,
            vegan=False,
            lng=101.6026,
            lat=3.0681,
            avg_price=Decimal("10.00"),
            calories=500,
            vegetarian=False,
            contains_nuts=True,
            dairy_free=True,
            gluten_free=True,
            extra_safe_item=True,
        )
        for day in range(7):
            StoreOperatingHour.objects.create(
                store=mixed,
                day_of_week=day,
                open_time=time(0, 0),
                close_time=time(23, 59),
            )
        self.profile.is_halal = True
        self.profile.allergies = ["nuts"]
        self.profile.save()
        aggregates = compute_menu_aggregates(mixed, ["nuts"])
        self.assertGreaterEqual(aggregates.safe_item_count, 1)
        self.assertTrue(
            passes_hard_filters(mixed, self.profile, aggregates, require_open=False)
        )
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, strict=True
        )
        self.assertIn(mixed.id, self._ids(results))

    def test_open_now_filter(self):
        self.profile.is_halal = True
        self.profile.allergies = []
        self.profile.save()
        # Tuesday evening — nutty is closed (only Mon 9–17)
        tuesday_evening = _aware(datetime(2026, 7, 28, 20, 0))
        results = self.recommender.recommend(
            self.user,
            ORIGIN,
            radius_km=5,
            open_now=True,
            strict=True,
            now=tuesday_evening,
        )
        ids = self._ids(results)
        self.assertNotIn(self.nutty.id, ids)
        self.assertIn(self.mamak.id, ids)

    def test_strict_top_pick_empty_when_no_safe_candidates(self):
        self.profile.is_vegan = True
        self.profile.is_halal = True
        self.profile.allergies = ["nuts", "dairy", "gluten"]
        self.profile.save()
        # Remove the only vegan store from consideration by moving it far away
        self.healthy.location = Point(100.0, 1.0, srid=WGS84_SRID)
        self.healthy.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=1, open_now=False, strict=True
        )
        self.assertEqual(results, [])

    def test_recommendation_reason_is_deterministic(self):
        self.profile.is_halal = True
        self.profile.preferred_cuisines = ["mamak"]
        self.profile.save()
        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, limit=1
        )
        self.assertTrue(results)
        self.assertTrue(results[0].recommendation_reason)
        self.assertIn(self.mamak.business_name, results[0].recommendation_reason)


class RestaurantRecommendationAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            username="api_rec",
            email="api_rec@example.com",
            password="password123",
        )
        self.profile = self.user.user_profile
        self.profile.is_halal = True
        self.profile.preferred_cuisines = ["healthy"]
        self.profile.health_goal = UserProfile.HealthGoalChoices.LOSE_WEIGHT
        self.profile.target_calories = 1800
        self.profile.save()
        self.client.force_authenticate(user=self.user)

        self.store = StoreProfile.objects.create(
            business_name="API Healthy Bowl",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
            category=StoreProfile.Category.HEALTHY,
            halal=True,
            vegan=True,
            location=ORIGIN,
        )
        cat = ItemCategory.objects.create(store=self.store, name="Bowls", display_order=1)
        StoreItem.objects.create(
            store=self.store,
            category=cat,
            name="Green Bowl",
            price=Decimal("11.00"),
            calories=400,
            vegetarian=True,
            dairy_free=True,
            gluten_free=True,
            contains_nuts=False,
        )
        for day in range(7):
            StoreOperatingHour.objects.create(
                store=self.store,
                day_of_week=day,
                open_time=time(0, 0),
                close_time=time(23, 59),
            )

    def test_top_pick_requires_auth(self):
        anon = APIClient()
        url = reverse("merchants:restaurant_top_pick")
        response = anon.get(url, {"lat": 3.0678, "lng": 101.6024})
        self.assertIn(
            response.status_code,
            (status.HTTP_401_UNAUTHORIZED, status.HTTP_403_FORBIDDEN),
        )

    def test_top_pick_success(self):
        url = reverse("merchants:restaurant_top_pick")
        response = self.client.get(
            url,
            {"lat": 3.0678, "lng": 101.6024, "open_now": "false"},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["store"]["id"], self.store.id)
        self.assertIn("match_score", response.data)
        self.assertIn("reasons", response.data)
        self.assertIn("recommendation_reason", response.data)

    def test_top_pick_404_when_strict_and_empty(self):
        self.profile.is_vegan = True
        self.profile.allergies = ["nuts"]
        self.profile.save()
        self.store.vegan = False
        self.store.halal = False
        self.store.save()
        # Make only item unsafe
        item = self.store.items.first()
        item.contains_nuts = True
        item.save()

        url = reverse("merchants:restaurant_top_pick")
        response = self.client.get(
            url,
            {"lat": 3.0678, "lng": 101.6024, "open_now": "false", "strict": "true"},
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_ranked_list(self):
        url = reverse("merchants:ranked_restaurants")
        response = self.client.get(
            url,
            {"lat": 3.0678, "lng": 101.6024, "limit": 5},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(response.data["count"], 1)
        self.assertEqual(response.data["results"][0]["store"]["id"], self.store.id)

    @patch(
        "apps.merchants.services.restaurant_recommender.enrich_recommendation_reason_with_gemini",
        side_effect=lambda store, reasons, fallback: "Gemini says try this place.",
    )
    def test_top_pick_optional_gemini(self, _mock):
        url = reverse("merchants:restaurant_top_pick")
        response = self.client.get(
            url,
            {
                "lat": 3.0678,
                "lng": 101.6024,
                "open_now": "false",
                "use_gemini": "true",
            },
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.data["recommendation_reason"], "Gemini says try this place."
        )


def _unit_vector(seed: float = 1.0) -> list[float]:
    """Deterministic 768-d vector for tests (avoids live Gemini)."""
    return [seed] + [0.0] * 767


class HybridCuisineScoreTests(TestCase):
    def setUp(self):
        clear_user_cuisine_embed_cache()
        self.user = User.objects.create_user(
            username="hybrid_user",
            email="hybrid@example.com",
            password="password123",
        )
        self.profile = self.user.user_profile
        self.recommender = RestaurantRecommender()

        self.fusion = StoreProfile.objects.create(
            business_name="Fusion Bowl",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
            category=StoreProfile.Category.FUSION,
            halal=True,
            vegan=False,
            location=ORIGIN,
        )
        self.mamak = StoreProfile.objects.create(
            business_name="Mamak Spot",
            merchant_type=StoreProfile.MerchantType.RESTAURANT,
            category=StoreProfile.Category.MAMAK,
            halal=True,
            vegan=False,
            location=Point(101.6025, 3.0679, srid=WGS84_SRID),
        )
        for store, name in ((self.fusion, "Fusion Salad"), (self.mamak, "Roti Canai")):
            cat = ItemCategory.objects.create(store=store, name="Mains", display_order=1)
            StoreItem.objects.create(
                store=store,
                category=cat,
                name=name,
                price=Decimal("10.00"),
                calories=500,
                vegetarian=True,
                dairy_free=True,
                gluten_free=True,
                contains_nuts=False,
            )
            for day in range(7):
                StoreOperatingHour.objects.create(
                    store=store,
                    day_of_week=day,
                    open_time=time(0, 0),
                    close_time=time(23, 59),
                )

    def tearDown(self):
        clear_user_cuisine_embed_cache()

    def test_vector_score_zero_when_distance_none_or_too_far(self):
        self.assertEqual(_vector_cuisine_score(None), 0.0)
        self.assertEqual(
            _vector_cuisine_score(VECTOR_CUISINE_MAX_DISTANCE + 0.01), 0.0
        )

    def test_vector_score_scales_with_similarity(self):
        # distance 0.2 → similarity 0.8 → 20 pts
        self.assertAlmostEqual(_vector_cuisine_score(0.2), WEIGHT_CUISINE * 0.8)

    def test_hybrid_max_preserves_exact_enum_match(self):
        # Rule gives full 25 for mamak; middling vector must not reduce it
        score = _hybrid_cuisine_score(
            self.mamak, ["mamak"], best_distance=0.4
        )
        self.assertEqual(score, float(WEIGHT_CUISINE))
        self.assertEqual(_rule_cuisine_score(self.mamak, ["mamak"]), float(WEIGHT_CUISINE))
        self.assertLess(_vector_cuisine_score(0.4), float(WEIGHT_CUISINE))

    def test_hybrid_vector_boosts_non_matching_category(self):
        rule = _rule_cuisine_score(self.fusion, ["mamak"])
        self.assertEqual(rule, 0.0)
        hybrid = _hybrid_cuisine_score(self.fusion, ["mamak"], best_distance=0.1)
        self.assertGreater(hybrid, rule)
        self.assertAlmostEqual(hybrid, WEIGHT_CUISINE * 0.9)

    def test_fallback_when_embedding_unavailable(self):
        self.profile.is_halal = True
        self.profile.preferred_cuisines = ["mamak"]
        self.profile.save()

        with patch(
            "apps.merchants.services.restaurant_recommender.get_or_embed_user_cuisine_vector",
            return_value=None,
        ):
            results = self.recommender.recommend(
                self.user, ORIGIN, radius_km=5, open_now=False, limit=10
            )
        mamak = next(r for r in results if r.store.id == self.mamak.id)
        self.assertEqual(mamak.score_parts["cuisine"], float(WEIGHT_CUISINE))

    @patch(
        "apps.merchants.services.restaurant_recommender.batch_best_item_distances",
        return_value={},
    )
    @patch(
        "apps.merchants.services.restaurant_recommender.get_or_embed_user_cuisine_vector",
    )
    def test_recommend_uses_vector_distances_for_cuisine(
        self, mock_embed, mock_batch
    ):
        self.profile.is_halal = True
        self.profile.preferred_cuisines = ["mamak"]
        self.profile.save()

        mock_embed.return_value = _unit_vector(1.0)
        # Fusion menu looks "mamak-like" to the vector path; mamak also exact enum
        mock_batch.return_value = {
            self.fusion.id: 0.05,
            self.mamak.id: 0.3,
        }

        results = self.recommender.recommend(
            self.user, ORIGIN, radius_km=5, open_now=False, limit=10
        )
        fusion = next(r for r in results if r.store.id == self.fusion.id)
        mamak = next(r for r in results if r.store.id == self.mamak.id)

        # Fusion: rule 0, vector ~23.75
        self.assertAlmostEqual(fusion.score_parts["cuisine"], WEIGHT_CUISINE * 0.95)
        # Mamak: max(25, 25*0.7) = 25
        self.assertEqual(mamak.score_parts["cuisine"], float(WEIGHT_CUISINE))
        mock_batch.assert_called_once()

    def test_cuisine_embed_cache_hits_on_second_call(self):
        fake_vector = _unit_vector(0.5)
        mock_embedding = type("E", (), {"values": fake_vector})()
        mock_response = type("R", (), {"embeddings": [mock_embedding]})()
        mock_models = type("M", (), {"embed_content": lambda *a, **k: mock_response})()
        mock_client = type("C", (), {"models": mock_models})()

        with patch(
            "apps.merchants.services.restaurant_recommender.GeminiService.get_client",
            return_value=mock_client,
        ) as get_client:
            # Make embed_content a MagicMock so we can count calls
            from unittest.mock import MagicMock

            embed_mock = MagicMock(return_value=mock_response)
            mock_client.models.embed_content = embed_mock

            first = get_or_embed_user_cuisine_vector(self.user.pk, ["mamak", "healthy"])
            second = get_or_embed_user_cuisine_vector(self.user.pk, ["healthy", "mamak"])

        self.assertEqual(first, fake_vector)
        self.assertEqual(second, fake_vector)
        self.assertEqual(embed_mock.call_count, 1)
        get_client.assert_called()

    def test_batch_best_item_distances_returns_min_per_store(self):
        close = _unit_vector(1.0)
        far = [0.0] * 384 + [1.0] + [0.0] * 383
        # Bypass StoreItem.save Gemini hook
        StoreItem.objects.filter(store=self.fusion).update(embedding=close)
        StoreItem.objects.filter(store=self.mamak).update(embedding=far)

        distances = batch_best_item_distances(
            [self.fusion.id, self.mamak.id],
            close,
        )
        self.assertIn(self.fusion.id, distances)
        self.assertIn(self.mamak.id, distances)
        # Identical vector should be closer (lower distance) than orthogonal
        self.assertLess(distances[self.fusion.id], distances[self.mamak.id])
