"""
Rule-based restaurant recommendation engine.

Ranks nearby RESTAURANT stores against a user's dietary prefs, cuisine prefs,
budget, and health goals. Ranking is deterministic; Gemini is only used
optionally for a top-pick caption.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field
from datetime import datetime, time
from decimal import Decimal
from typing import Iterable, Sequence

from django.contrib.gis.geos import Point
from django.utils import timezone

from apps.core.services import GeminiService
from apps.merchants.models import StoreItem, StoreOperatingHour, StoreProfile
from apps.users.models import User, UserProfile
from config.settings import DEFAULT_RADIUS_KM

logger = logging.getLogger(__name__)

# Soft-score weights (sum to 100)
WEIGHT_CUISINE = 25
WEIGHT_PROXIMITY = 20
WEIGHT_DIET = 20
WEIGHT_BUDGET = 15
WEIGHT_HEALTH = 15
WEIGHT_OPEN_NOW = 5

DEFAULT_MEAL_CALORIES = 600
REASON_THRESHOLD = {
    "cuisine_match": 12,
    "nearby": 10,
    "diet_match": 10,
    "budget_fit": 8,
    "calorie_fit": 8,
}

# Allergies with item-level flags on StoreItem. shellfish/eggs/soy have no
# item fields yet — documented data gap; those are not hard-filtered.
TRACKABLE_ALLERGIES = frozenset({"nuts", "dairy", "gluten"})


@dataclass
class MenuAggregates:
    item_count: int = 0
    avg_price: float | None = None
    avg_calories: float | None = None
    vegetarian_item_ratio: float = 0.0
    safe_item_ratio: float = 1.0
    safe_item_count: int = 0
    vegetarian_item_count: int = 0


@dataclass
class ScoredRestaurant:
    store: StoreProfile
    match_score: int
    reasons: list[str] = field(default_factory=list)
    distance_km: float = 0.0
    pricing_bracket: str = "mid"
    is_open: bool = False
    avg_price: float | None = None
    avg_calories: float | None = None
    recommendation_reason: str = ""
    score_parts: dict[str, float] = field(default_factory=dict)


def pricing_bracket_from_avg(avg_price: float | None) -> str:
    """Match mobile-client pricing_util.dart thresholds."""
    if avg_price is None:
        return "mid"
    if avg_price < 10:
        return "budget"
    if avg_price < 20:
        return "mid"
    return "premium"


def _time_in_hours_window(current: time, open_t: time, close_t: time) -> bool:
    if open_t <= close_t:
        return open_t <= current <= close_t
    # Overnight on the open day: from open_t until midnight
    return current >= open_t


def is_store_open_at(
    store: StoreProfile,
    at: datetime | None = None,
) -> bool:
    """
    Return whether the store is open at the given local datetime.

    Handles same-day windows (open <= close) and overnight windows
    (open > close, e.g. 22:00–02:00). Missing hours for the weekday => closed,
    unless the previous day's overnight window still covers the current time.
    """
    when = at or timezone.localtime()
    if timezone.is_naive(when):
        when = timezone.make_aware(when, timezone.get_current_timezone())
    else:
        when = timezone.localtime(when)

    weekday = when.weekday()  # Monday=0 … Sunday=6 (matches StoreOperatingHour)
    current = when.time()

    hours_by_day: dict[int, StoreOperatingHour] = {}
    prefetched = getattr(store, "_prefetched_objects_cache", {}).get("operating_hours")
    if prefetched is not None:
        for row in prefetched:
            hours_by_day[row.day_of_week] = row
    else:
        for row in store.operating_hours.all():
            hours_by_day[row.day_of_week] = row

    today = hours_by_day.get(weekday)
    if today is not None and _time_in_hours_window(
        current, today.open_time, today.close_time
    ):
        return True

    # After midnight: still covered by previous day's overnight close
    prev_day = (weekday - 1) % 7
    prev = hours_by_day.get(prev_day)
    if (
        prev is not None
        and prev.open_time > prev.close_time
        and current <= prev.close_time
    ):
        return True

    return False


def _item_safe_for_allergies(item: StoreItem, allergies: Sequence[str]) -> bool:
    for allergy in allergies:
        if allergy == "nuts" and item.contains_nuts:
            return False
        if allergy == "dairy" and not item.dairy_free:
            return False
        if allergy == "gluten" and not item.gluten_free:
            return False
    return True


def compute_menu_aggregates(
    store: StoreProfile,
    allergies: Sequence[str] | None = None,
) -> MenuAggregates:
    """Aggregate active menu stats used for filtering and soft scoring."""
    trackable = [a for a in (allergies or []) if a in TRACKABLE_ALLERGIES]

    prefetched = getattr(store, "_prefetched_objects_cache", {}).get("items")
    if prefetched is not None:
        items = [i for i in prefetched if i.is_active]
    else:
        items = list(store.items.filter(is_active=True))

    if not items:
        # No menu: treat as fully "safe" for ratio math but zero counts so
        # allergen hard-filter (needs >=1 safe item) still excludes when needed.
        return MenuAggregates(
            item_count=0,
            safe_item_ratio=1.0 if not trackable else 0.0,
            safe_item_count=0,
        )

    prices: list[float] = []
    calories: list[float] = []
    veg_count = 0
    safe_count = 0

    for item in items:
        if item.price is not None:
            prices.append(float(item.price))
        if item.calories is not None:
            calories.append(float(item.calories))
        if item.vegetarian or store.vegan:
            veg_count += 1
        if _item_safe_for_allergies(item, trackable):
            safe_count += 1

    count = len(items)
    return MenuAggregates(
        item_count=count,
        avg_price=(sum(prices) / len(prices)) if prices else None,
        avg_calories=(sum(calories) / len(calories)) if calories else None,
        vegetarian_item_ratio=veg_count / count,
        vegetarian_item_count=veg_count,
        safe_item_ratio=safe_count / count,
        safe_item_count=safe_count,
    )


def passes_hard_filters(
    store: StoreProfile,
    profile: UserProfile,
    aggregates: MenuAggregates,
    *,
    require_open: bool = False,
    now: datetime | None = None,
) -> bool:
    if profile.is_halal and not store.halal:
        return False
    if profile.is_vegan and not store.vegan:
        return False
    if profile.is_vegetarian:
        is_veg_store = (
            store.vegan
            or store.category == StoreProfile.Category.VEGETARIAN
            or aggregates.vegetarian_item_count >= 1
        )
        if not is_veg_store:
            return False

    trackable = [a for a in (profile.allergies or []) if a in TRACKABLE_ALLERGIES]
    if trackable and aggregates.safe_item_count < 1:
        return False

    if require_open and not is_store_open_at(store, now):
        return False

    return True


def _cuisine_score(store: StoreProfile, preferred: Sequence[str]) -> float:
    if not preferred:
        return 0.0
    preferred_set = {c.lower() for c in preferred}
    category = (store.category or "").lower()
    if category and category in preferred_set:
        return float(WEIGHT_CUISINE)
    # Partial credit for healthy/vegetarian preference overlap
    if "healthy" in preferred_set and category == "healthy":
        return float(WEIGHT_CUISINE)
    if "vegetarian" in preferred_set and category in {"vegetarian", "healthy"}:
        return float(WEIGHT_CUISINE) * 0.8
    if "healthy" in preferred_set and category == "vegetarian":
        return float(WEIGHT_CUISINE) * 0.6
    return 0.0


def _proximity_score(distance_km: float, radius_km: float) -> float:
    if radius_km <= 0:
        return 0.0
    return WEIGHT_PROXIMITY * max(0.0, 1.0 - (distance_km / radius_km))


def _diet_score(
    store: StoreProfile,
    profile: UserProfile,
    aggregates: MenuAggregates,
) -> float:
    if profile.is_vegan and store.vegan:
        return float(WEIGHT_DIET)

    parts: list[float] = []
    trackable = [a for a in (profile.allergies or []) if a in TRACKABLE_ALLERGIES]
    if trackable:
        parts.append(aggregates.safe_item_ratio)
    if profile.is_vegetarian or profile.is_vegan:
        parts.append(aggregates.vegetarian_item_ratio)
    elif store.halal and profile.is_halal:
        parts.append(1.0)

    if not parts:
        # No dietary prefs: mild credit for generally accommodating menus
        return WEIGHT_DIET * 0.4

    return WEIGHT_DIET * (sum(parts) / len(parts))


def _budget_score(
    avg_price: float | None,
    dine_in_budget: Decimal | None,
) -> float:
    if avg_price is None:
        return WEIGHT_BUDGET * 0.4

    if dine_in_budget is not None and float(dine_in_budget) > 0:
        meal_budget = float(dine_in_budget) / 30.0
        if avg_price <= meal_budget:
            return float(WEIGHT_BUDGET)
        # Taper: full at meal_budget, zero at 2x meal_budget
        over = avg_price - meal_budget
        return WEIGHT_BUDGET * max(0.0, 1.0 - (over / max(meal_budget, 1.0)))

    # No budget set: mild preference for mid bracket
    bracket = pricing_bracket_from_avg(avg_price)
    if bracket == "mid":
        return WEIGHT_BUDGET * 0.7
    if bracket == "budget":
        return WEIGHT_BUDGET * 0.6
    return WEIGHT_BUDGET * 0.3


def _health_score(
    store: StoreProfile,
    profile: UserProfile,
    avg_calories: float | None,
) -> float:
    goal = profile.health_goal or ""
    target = profile.target_calories
    meal_target = (target / 3.0) if target else float(DEFAULT_MEAL_CALORIES)
    category = store.category or ""

    healthy_category_boost = 0.0
    if category in {
        StoreProfile.Category.HEALTHY,
        StoreProfile.Category.VEGETARIAN,
    }:
        healthy_category_boost = 0.35

    if avg_calories is None:
        # Fall back to category signal only
        base = 0.4 + healthy_category_boost
        return WEIGHT_HEALTH * min(1.0, base)

    if goal == UserProfile.HealthGoalChoices.LOSE_WEIGHT:
        # Prefer lower calories; full marks at <= 70% of meal target
        if avg_calories <= meal_target * 0.7:
            calorie_fit = 1.0
        elif avg_calories >= meal_target * 1.5:
            calorie_fit = 0.0
        else:
            span = meal_target * 0.8
            calorie_fit = max(
                0.0, 1.0 - (avg_calories - meal_target * 0.7) / span
            )
        return WEIGHT_HEALTH * min(1.0, calorie_fit + healthy_category_boost)

    if goal == UserProfile.HealthGoalChoices.GAIN_MUSCLE:
        # Prefer mid-high calorie mains near meal_target
        delta = abs(avg_calories - meal_target)
        calorie_fit = max(0.0, 1.0 - (delta / max(meal_target, 1.0)))
        if avg_calories < meal_target * 0.5:
            calorie_fit *= 0.5
        return WEIGHT_HEALTH * min(1.0, calorie_fit + healthy_category_boost * 0.5)

    # maintain_weight / general_health / unset: closeness to meal target
    delta = abs(avg_calories - meal_target)
    calorie_fit = max(0.0, 1.0 - (delta / max(meal_target, 1.0)))
    return WEIGHT_HEALTH * min(1.0, calorie_fit + healthy_category_boost * 0.5)


def _distance_km(store: StoreProfile) -> float:
    distance = getattr(store, "distance", None)
    if distance is None:
        return 0.0
    return float(round(distance.km, 4))


def build_reasons(score_parts: dict[str, float], is_open: bool) -> list[str]:
    reasons: list[str] = []
    mapping = [
        ("cuisine", "cuisine_match"),
        ("proximity", "nearby"),
        ("diet", "diet_match"),
        ("budget", "budget_fit"),
        ("health", "calorie_fit"),
    ]
    for key, reason in mapping:
        threshold = REASON_THRESHOLD.get(reason, 8)
        if score_parts.get(key, 0) >= threshold:
            reasons.append(reason)
    if is_open and score_parts.get("open_now", 0) > 0:
        reasons.append("open_now")
    return reasons


def build_recommendation_reason(
    store: StoreProfile,
    reasons: Sequence[str],
    pricing_bracket: str,
) -> str:
    """Deterministic 1–2 sentence caption from reason tags."""
    name = store.business_name
    cuisine = store.get_category_display() if store.category else "local"
    bits: list[str] = []

    if "diet_match" in reasons:
        if store.vegan:
            bits.append("vegan-friendly")
        elif store.halal:
            bits.append("halal")
    if "cuisine_match" in reasons:
        bits.append(f"{cuisine.lower()} cuisine")
    if "nearby" in reasons:
        bits.append("close by")
    if "budget_fit" in reasons:
        bits.append(f"a good {pricing_bracket} fit")
    if "calorie_fit" in reasons:
        bits.append("aligned with your calorie goals")
    if "open_now" in reasons:
        bits.append("open now")

    if not bits:
        return f"{name} is a solid nearby option based on your preferences."

    if len(bits) == 1:
        return f"{name} stands out for being {bits[0]}."
    if len(bits) == 2:
        return f"{name} is {bits[0]} and {bits[1]}."
    return f"{name} is {', '.join(bits[:-1])}, and {bits[-1]}."


def enrich_recommendation_reason_with_gemini(
    store: StoreProfile,
    reasons: Sequence[str],
    fallback: str,
) -> str:
    """Optional Gemini polish; always falls back to the template string."""
    try:
        client = GeminiService.get_client()
        prompt = (
            f"Write one friendly sentence (max 25 words, no markdown) recommending "
            f"the restaurant '{store.business_name}' "
            f"({store.get_category_display() if store.category else 'restaurant'}). "
            f"Mention these match reasons: {', '.join(reasons) or 'nearby'}. "
            f"Do not invent ratings or deals."
        )
        response = client.models.generate_content(
            model=GeminiService.get_model("fast"),
            contents=prompt,
        )
        if response.text and response.text.strip():
            return response.text.strip()
    except Exception as exc:
        logger.info("Gemini caption skipped: %s", exc)
    return fallback


class RestaurantRecommender:
    """Score and rank nearby restaurants for a user profile."""

    def recommend(
        self,
        user: User,
        point: Point,
        *,
        radius_km: float = DEFAULT_RADIUS_KM,
        limit: int = 10,
        open_now: bool = False,
        strict: bool = True,
        now: datetime | None = None,
        use_gemini_caption: bool = False,
    ) -> list[ScoredRestaurant]:
        profile = getattr(user, "user_profile", None)
        if profile is None:
            profile = UserProfile.objects.get(user=user)

        candidates = list(
            StoreProfile.objects.nearby(point, radius_km)
            .filter(merchant_type=StoreProfile.MerchantType.RESTAURANT)
            .prefetch_related("operating_hours", "items")
        )

        scored = self._score_candidates(
            candidates,
            profile,
            radius_km=radius_km,
            require_open=open_now,
            now=now,
        )

        if not scored and not strict:
            # Fallback: nearest restaurants without dietary hard filters
            scored = self._score_candidates(
                candidates,
                profile,
                radius_km=radius_km,
                require_open=open_now,
                now=now,
                apply_hard_filters=False,
            )

        scored.sort(key=lambda s: (-s.match_score, s.distance_km))
        results = scored[:limit]

        if use_gemini_caption and results:
            top = results[0]
            top.recommendation_reason = enrich_recommendation_reason_with_gemini(
                top.store,
                top.reasons,
                top.recommendation_reason,
            )

        return results

    def _score_candidates(
        self,
        candidates: Iterable[StoreProfile],
        profile: UserProfile,
        *,
        radius_km: float,
        require_open: bool,
        now: datetime | None,
        apply_hard_filters: bool = True,
    ) -> list[ScoredRestaurant]:
        results: list[ScoredRestaurant] = []
        allergies = list(profile.allergies or [])

        for store in candidates:
            aggregates = compute_menu_aggregates(store, allergies)
            if apply_hard_filters and not passes_hard_filters(
                store,
                profile,
                aggregates,
                require_open=require_open,
                now=now,
            ):
                continue

            distance_km = _distance_km(store)
            is_open = is_store_open_at(store, now)

            cuisine = _cuisine_score(store, profile.preferred_cuisines or [])
            proximity = _proximity_score(distance_km, radius_km)
            diet = _diet_score(store, profile, aggregates)
            budget = _budget_score(aggregates.avg_price, profile.dine_in_budget)
            health = _health_score(store, profile, aggregates.avg_calories)
            open_bonus = float(WEIGHT_OPEN_NOW) if is_open else 0.0

            score_parts = {
                "cuisine": cuisine,
                "proximity": proximity,
                "diet": diet,
                "budget": budget,
                "health": health,
                "open_now": open_bonus,
            }
            match_score = int(
                round(sum(score_parts.values()))
            )
            match_score = max(0, min(100, match_score))

            reasons = build_reasons(score_parts, is_open)
            bracket = pricing_bracket_from_avg(aggregates.avg_price)
            reason_text = build_recommendation_reason(store, reasons, bracket)

            results.append(
                ScoredRestaurant(
                    store=store,
                    match_score=match_score,
                    reasons=reasons,
                    distance_km=round(distance_km, 2),
                    pricing_bracket=bracket,
                    is_open=is_open,
                    avg_price=(
                        round(aggregates.avg_price, 2)
                        if aggregates.avg_price is not None
                        else None
                    ),
                    avg_calories=(
                        round(aggregates.avg_calories, 1)
                        if aggregates.avg_calories is not None
                        else None
                    ),
                    recommendation_reason=reason_text,
                    score_parts=score_parts,
                )
            )

        return results
