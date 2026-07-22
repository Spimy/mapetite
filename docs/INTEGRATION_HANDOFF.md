# Mapetite — Integration & Backend Handoff

**Date:** 2026-06-06  
**Branch:** `joshua/ui-recipes-my-list`  
**Prepared by:** Joshua Bonham  

This document describes every screen in the mobile client, what data it currently renders from hardcoded mocks, and what the backend/integration team must replace with real API calls. A dedicated section at the end is provided for the **Data Collection Team** listing the exact fields needed per entity.

---

## Table of Contents

1. [Tech Stack Notes](#1-tech-stack-notes)
2. [Shared / Global Data](#2-shared--global-data)
3. [Auth Screens](#3-auth-screens)
4. [Home Feed Screen](#4-home-feed-screen)
5. [Explore (Search) Screen](#5-explore-search-screen)
6. [Map Screen](#6-map-screen)
7. [Budget Screens](#7-budget-screens)
8. [Recipe Screens (Cook-In)](#8-recipe-screens-cook-in)
9. [Restaurant Screens (Dine-In)](#9-restaurant-screens-dine-in)
10. [Grocery Screens](#10-grocery-screens)
11. [Profile & Settings Screens](#11-profile--settings-screens)
12. [Notification Screens](#12-notification-screens)
13. [Enumerated Value Reference](#13-enumerated-value-reference)
14. [Data Collection Team — Field Specifications](#14-data-collection-team--field-specifications)

---

## 1. Tech Stack Notes

- **Framework:** Flutter (Dart), state management via Riverpod
- **Routing:** `go_router`
- **Current data layer:** All data is served from in-memory Dart mock classes. There is no live API call anywhere in the app yet.
- **Integration pattern expected:** Replace each mock provider/service with a Riverpod `AsyncNotifierProvider` or `FutureProvider` that calls the REST API. The UI models (`RestaurantModel`, `RecipeModel`, etc.) are already defined — the backend response JSON should map 1-to-1 to these classes.
- **Currency:** Malaysian Ringgit (RM). All price fields are `double` in RM.
- **Distance:** kilometres (`double`), walking time in minutes (`int`).
- **Coordinates:** decimal degrees WGS84 (`lat: double`, `lng: double`).

---

## 2. Shared / Global Data

### Current user session
Hardcoded in `lib/features/profile/models/mocks/profile_mocks.dart`.

| Field | Mock value | Needs from backend |
|-------|-----------|-------------------|
| User ID | `'u1'` | JWT / session user ID |
| Display name | `'Joshua Bonham'` | Auth service |
| Email | `'joshua.bonham@example.com'` | Auth service |
| Phone | `'+60 12-345 6789'` | Auth service |
| Avatar URL | `null` | Object storage URL (S3 / GCS) |
| City | `'Bangsar, Kuala Lumpur'` | User-entered or reverse-geocoded |

### App Drawer / Profile Drawer
- **Display name & avatar initial** — hardcoded in `lib/shared/widgets/profile_drawer.dart`. Must read from authenticated user session.
- **"RM X Saved This Month"** — in `AppDrawer`, hardcoded as `47.50`. Must come from: `monthlyBudget − totalSpent` for the current month, same as the Budget screen.

---

## 3. Auth Screens

### Splash Screen (`/`)
- No mock data. Navigates to onboarding or home based on auth state.
- **Integration needed:** Check persisted auth token; redirect to `/onboarding` (first launch) or `/home` (authenticated).

### Onboarding Screen (`/onboarding`)
- Static copy only. No data.
- **Integration needed:** None beyond auth state check.

### Login Screen (`/login`)
- Fields: email, password.
- **Integration needed:** `POST /auth/login` → returns JWT + user profile.

### Register Screen (`/register`)
- Fields: display name, email, password, confirm password.
- **Integration needed:** `POST /auth/register` → creates account, returns JWT.

### Forgot Password Screen (`/forgot-password`)
- Field: email.
- **Integration needed:** `POST /auth/forgot-password` → sends reset email.

### Profile Setup Wizard (`/profile/dietary`, `/profile/budget-setup`, `/profile/health-goals`)
- Collects user preferences after first login (also accessible via edit mode from profile).
- **Integration needed:** `PUT /users/me/profile` — send the full `UserProfile` payload on wizard completion. In edit mode each step can `PATCH /users/me/profile`.

---

## 4. Home Feed Screen

**Route:** `/home` | **File:** `lib/features/discovery/screens/home_feed_screen.dart`

### What is hardcoded

| UI element | Hardcoded value | Source mock | Replace with |
|------------|----------------|-------------|--------------|
| Greeting name | `'Joshua'` | `HomeFeedMocks.userName` | Authenticated user's `displayName` (first name) |
| Budget remaining | `RM 366.00` | `HomeFeedMocks.budgetRemaining` | `monthlyBudget − totalSpent` for current month |
| User location label | `'Bangsar'` | `HomeFeedMocks.userLocation` | Reverse-geocoded from device GPS or user's saved city |
| Unread notification badge count | `2` | `HomeFeedMocks.unreadNotifications` | `GET /notifications/unread-count` |
| AI nudge pill text | Static string `"Botanica + Co has a lunch deal…"` | Inline in screen | `GET /recommendations/nudge` → `{ message: String }` |
| Top Pick card | Botanica + Co | `HomeFeedMocks.topPick` | `GET /recommendations/top-pick?userId=…` |
| Nearby Restaurants (mini-cards, up to 2) | The Fish Bowl, Pulp by PPP | `HomeFeedMocks.nearbyOptions` | `GET /restaurants/nearby?lat=…&lng=…&limit=2` |
| Nearby Groceries (mini-cards) | Jaya Grocer, 99 Speedmart | `HomeFeedMocks.nearbyGroceries` | `GET /grocery-stores/nearby?lat=…&lng=…&limit=2` |
| Cook-In recipe suggestions (mini-cards) | Nasi Goreng Kampung, Mee Goreng Mamak | `HomeFeedMocks.cookInRecipes` | `GET /recipes/suggested?userId=…&limit=2` |

### API summary
```
GET /recommendations/top-pick
GET /recommendations/nudge
GET /restaurants/nearby
GET /grocery-stores/nearby
GET /recipes/suggested
GET /notifications/unread-count
```

---

## 5. Explore (Search) Screen

**Route:** `/explore` | **File:** `lib/features/discovery/screens/search_screen.dart`

### What is hardcoded

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Nearby venues list (Restaurants tab) | `ExploreMocks.nearbyVenues` (3 venues: Green Bowl Oasis, Urban Roast, Plant Base) | `GET /venues/nearby?lat=…&lng=…&type=restaurant&filters=…` |
| Recipe search results (Recipes tab) | Filtered view of `RecipeMocks.all` | `GET /recipes/search?q=…&dietary=…` |
| Grocery search results (Groceries tab) | No mock — empty state shown | `GET /grocery-stores/search?q=…` |
| Filter options: Cuisines, Dietary, Price | Static chips from `AppConstants` | Static (these are enumerated values — see Section 13) |

### Active filters applied client-side (must move to server-side)
- Halal, Vegan flags
- Price range (`RM 5–10`, `RM 10–20`, `RM 20+`)
- Category tabs (Restaurants / Recipes / Groceries)

### API summary
```
GET /venues/nearby
GET /recipes/search
GET /grocery-stores/search
```

---

## 6. Map Screen

**Route:** `/map` | **File:** `lib/features/discovery/screens/map_explore_screen.dart`

### What is hardcoded

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Map center coordinates | `LatLng(3.0731, 101.6069)` (Sunway, Selangor) | Device GPS location |
| All map markers — restaurants (5) | Inline `_MarkerData` list: Nasi Kandar Ali, Kopitiam Old Town, Sushi King, Mamak Corner, The Grill House | `GET /map/markers?lat=…&lng=…&radius=…&type=restaurant` |
| All map markers — grocery stores (3) | Inline `_MarkerData` list: Jaya Grocer, 99 Speedmart, Village Grocer | `GET /map/markers?lat=…&lng=…&radius=…&type=grocery` |
| Bottom card when marker tapped | Venue name, type, distance | Same API response as markers, or `GET /venues/:id/summary` |
| Filter chips (All / Restaurants / Grocery) | Static | Static (UI-only filter of returned markers) |
| Search bar | No backend call — UI only | `GET /map/search?q=…&lat=…&lng=…` |

### Notes
- Distance values (`"0.4 km"`) should be computed from the device's real GPS position to the venue coordinates.
- The "My Location" FAB animates the map to device GPS — requires location permission.

### API summary
```
GET /map/markers
GET /map/search
```

---

## 7. Budget Screens

### Budget Overview (`/budget`)
**File:** `lib/features/budget/screens/budget_overview_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Monthly budget total | `RM 1000.00` | `GET /budget/current-month` → `monthlyBudget` |
| Groceries sub-budget | `RM 400.00` | Same response → `groceriesBudget` |
| Dining Out sub-budget | `RM 400.00` | Same response → `diningBudget` |
| Total spent | Computed from mock transactions | Same response → `totalSpent` or computed from transactions |
| Per-category spent (Groceries, Dining) | Computed from mock transactions | Same |
| Recent transactions (last 3) | `BudgetMocks.transactions` | `GET /transactions?limit=3&sort=desc` |
| Month selector | Client-computed from `DateTime.now()` | `GET /budget/month?year=…&month=…` for historic months |

### Budget Analytics (`/budget/analytics`)
**File:** `lib/features/budget/screens/budget_analytics_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Bar chart values (Dining Out) | Hardcoded arrays per period (7D/30D/90D) | `GET /analytics/spending?period=7D&category=dining` |
| Bar chart values (Cook-In) | Hardcoded arrays per period | `GET /analytics/spending?period=7D&category=groceries` |
| Forecast card values | Hardcoded (`RM 850`, `RM 950`, etc.) | `GET /analytics/forecast` |
| Cuisine breakdown donut | Hardcoded percentages | `GET /analytics/cuisine-breakdown` |
| Top merchant row | Hardcoded ("Nasi Kandar Ali, RM 24.50, 3×") | `GET /analytics/top-merchants?limit=5` |

### Transaction Log (`/budget/transactions`)
**File:** `lib/features/budget/screens/transaction_log_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Full transaction list | Inline `_TxData` list (8 records) | `GET /transactions?page=…&limit=20` |
| Category filter chips | `['All', 'Dining', 'Groceries']` | Static (matches `BudgetCategory` enum) |
| Export button | Shows loading state, no actual export | `GET /transactions/export?format=csv` |

### Add Transaction Sheet
- User-entered data (merchant name, amount, category, date).
- **Integration needed:** `POST /transactions` with body `{ name, amount, category, dateTime }`.

### Adjust Budget Sheet
- User sets monthly, groceries, dining budgets.
- **Integration needed:** `PUT /budget` with body `{ monthlyBudget, groceriesBudget, diningBudget }`.

### API summary
```
GET  /budget/current-month
GET  /budget/month
PUT  /budget
GET  /transactions
POST /transactions
GET  /transactions/export
GET  /analytics/spending
GET  /analytics/forecast
GET  /analytics/cuisine-breakdown
GET  /analytics/top-merchants
```

---

## 8. Recipe Screens (Cook-In)

### Recipe Listing (`/recipes`)
**File:** `lib/features/recipes/screens/recipe_listing_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Full recipe list | `RecipeMocks.all` (8 recipes) | `GET /recipes?page=…&sort=…&filters=…` |
| Filter chips (Halal, Vegan, Vegetarian, Under 30 min, My Recipes, Saved) | Client-side filter on mocks | Server-side filter params |
| Sort options (Newest, Most Popular, Lowest Calorie, Quickest) | Client-side sort | `?sort=newest\|popular\|calories\|time` |
| "My Recipes" tab | Filters for `isOwnedByCurrentUser == true` | `GET /recipes?owner=me` |
| "Saved" tab | No mock data | `GET /recipes/saved` |

### Recipe Detail (`/recipes/:id`)
**File:** `lib/features/recipes/screens/recipe_detail_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Recipe data (all fields) | `RecipeModel` from `RecipeMocks.all` | `GET /recipes/:id` |
| Saves count | Hardcoded `int saves` on model | Same endpoint |
| "Find Ingredients" button | Routes to `/recipes/:id/match` | Same |
| Share sheet — friend list | Hardcoded `_kMockFriends` tuple list (4 people) | `GET /users/me/friends` or `GET /users/me/contacts` |
| Review/comment section | Not yet implemented in UI | Future: `GET /recipes/:id/reviews` |

### Create Recipe (`/recipes/create`) & Edit Recipe
**File:** `lib/features/recipes/screens/create_recipe_screen.dart`

- User-entered data (title, description, ingredients, steps, dietary flags, visibility).
- Author is always the current user.
- **Integration needed:**
  - `POST /recipes` — create
  - `PUT /recipes/:id` — edit
  - `DELETE /recipes/:id` — delete (from recipe detail actions)
  - `POST /recipes/:id/save` — save/unsave a recipe
  - `PUT /recipes/:id/visibility` — toggle public/private

### Grocery Match Screen (`/recipes/:id/match`)
**File:** `lib/features/groceries/screens/grocery_match_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Recipe summary card | Inline — same recipe as parent detail | `GET /recipes/:id` (already fetched) |
| "Best Match" store + ingredient list | Hardcoded: Jaya Grocer with availability indicators | `GET /recipes/:id/grocery-match?lat=…&lng=…` |
| "Other stores" list | Hardcoded: 99 Speedmart, Village Grocer | Same response → `otherStores[]` |
| Item availability dots (green/orange/grey) | Hardcoded per item | Same response → per ingredient `{ available: bool, lowStock: bool }` |
| "Add all to My List" button | Adds hardcoded items to local list | Should add from recipe ingredient list via `POST /grocery-list/items/bulk` |

### API summary
```
GET    /recipes
GET    /recipes/:id
POST   /recipes
PUT    /recipes/:id
DELETE /recipes/:id
POST   /recipes/:id/save
GET    /recipes/saved
GET    /recipes/:id/grocery-match
GET    /recipes/suggested
GET    /users/me/friends
```

---

## 9. Restaurant Screens (Dine-In)

### Restaurant Listing (`/dine-in` or `/restaurants`)
**File:** `lib/features/restaurants/screens/restaurant_listing_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Full restaurant list | `RestaurantMocks.nearbyRestaurants` (4 restaurants) | `GET /restaurants?lat=…&lng=…&radius=…&filters=…` |
| Quick filter chips (Halal, Open Now, Vegan, Best Value, Nearest) | Client-side filter on mocks | Server-side query params: `?halal=true&open=true&pricing=budget&sort=distance` |
| Full filter sheet (cuisines, dietary, walk time, price) | Client-side filter | Same server-side params |
| Distance / walk time values | Hardcoded per mock | Computed server-side from user GPS + venue coordinates |
| "Open Now" state | Hardcoded `isOpen: true` on all mocks | Real opening hours check: `isOpen` flag from API, or compute from `openingHours` schedule |
| Rating and review count | Not shown in listing (only in detail) | `GET /restaurants/:id` |

### Restaurant Detail (`/restaurants/:id`)
**File:** `lib/features/restaurants/screens/restaurant_detail_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| All restaurant fields | `RestaurantMocks.nearbyRestaurants.firstWhere(id)` | `GET /restaurants/:id` |
| Restaurant image | `imageUrl: null` — shows placeholder | Real image URL from data collection |
| Menu items | Inline `menuItems[]` on mock model | `GET /restaurants/:id/menu` or included in main response |
| Menu item image | `imageUrl: null` | Real image URL |
| "Navigate" button | Opens navigate sheet (hardcoded destination label) | Use real `lat`/`lng` for the venue |
| "Share" button | Opens share sheet | Native share of deep link: `mapetite://restaurants/:id` |
| Reviews section | Hardcoded `_kMockReviews` (3 reviews with author names) | `GET /restaurants/:id/reviews?page=…` |
| Friend selector sheet | Hardcoded `_kMockFriends` tuple (4 people) | `GET /users/me/friends` |
| "Write a review" | Not yet wired | `POST /restaurants/:id/reviews` |

### API summary
```
GET /restaurants
GET /restaurants/:id
GET /restaurants/:id/menu
GET /restaurants/:id/reviews
POST /restaurants/:id/reviews
```

---

## 10. Grocery Screens

### Shopping List — My List (`/list`)
**File:** `lib/features/grocery_list/screens/grocery_list_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| List items | `GroceryListMocks.initialItems` (5 items pre-loaded) | `GET /grocery-list` — user's persisted list |
| Estimated price per item | `estimatedPrice: double` on each item | Same from API |
| Store name per item | `storeName: String` on each item | Same from API (populated when added from recipe match) |
| Weekly budget limit | `GroceryListMocks.weeklyBudgetLimit = 50.00` | Should come from user budget settings |
| "Recipe source" card | Hardcoded: "Nasi Goreng Kampung (6 items)" | Linked recipe ID from the list creation context |
| Total cost | Client-computed sum | Client-computed from API data |
| Route Optimiser button | Routes to `/list/route` | — |

### My List — Grocery List (`/my-list`)
**File:** `lib/features/grocery/screens/grocery_list_screen.dart`

This appears to be an alternate/older version of the shopping list. Connects to the same `groceryListProvider`. Confirm with the team whether `/my-list` and `/list` should consolidate to one route.

### Route Optimiser (`/list/route`)
**File:** `lib/features/grocery_list/screens/route_optimiser_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Route steps / store sequence | Hardcoded route plan (Jaya Grocer → Village Grocer → 99 Speedmart) | `GET /grocery-list/optimised-route?lat=…&lng=…` → ordered store list with directions |
| Estimated walking time per leg | Hardcoded per step | Computed from coordinates via routing API |
| Map view of route | Static placeholder | Real route polyline on map |

### Grocery Store Detail (`/groceries/:id`)
**File:** `lib/features/groceries/screens/grocery_store_detail_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Store name / info in header | Derived from `storeId` param — no lookup | `GET /grocery-stores/:id` |
| Product list | Hardcoded `_items` (5 products: Fresh Spinach, Eggs, Soy Sauce, Jasmine Rice, Oat Milk) | `GET /grocery-stores/:id/products?category=…&q=…` |
| Stock status per item (In Stock / Low Stock / Out of Stock) | Hardcoded `_StockLevel` enum | Same from API → `stockStatus: "in_stock" \| "low_stock" \| "out_of_stock"` |
| Price per item | Hardcoded string `'RM 2.50'` | `GET /grocery-stores/:id/products` → `price: double` |
| Product categories (All, Fresh Produce, Pantry, Dairy, Frozen) | Hardcoded tab list | `GET /grocery-stores/:id/categories` or static per store type |
| "Add to My List" action | Adds item name to local list | `POST /grocery-list/items` `{ name, quantity, storeId, price }` |

### API summary
```
GET  /grocery-list
POST /grocery-list/items
POST /grocery-list/items/bulk
DELETE /grocery-list/items/:id
PATCH  /grocery-list/items/:id/check
DELETE /grocery-list/completed
GET  /grocery-list/optimised-route
GET  /grocery-stores/:id
GET  /grocery-stores/:id/products
GET  /grocery-stores/:id/categories
GET  /grocery-stores/nearby
GET  /grocery-stores/search
```

---

## 11. Profile & Settings Screens

### Edit Profile (`/profile/edit`)
**File:** `lib/features/profile/screens/edit_profile_screen.dart`

| Field | Hardcoded mock value | Replace with |
|-------|---------------------|--------------|
| Display name | `'Joshua Bonham'` | `GET /users/me/profile` |
| Email | `'joshua.bonham@example.com'` | Same |
| Phone | `'+60 12-345 6789'` | Same |
| Avatar | `null` (initials shown) | Same → `avatarUrl` |
| City | `'Bangsar, Kuala Lumpur'` | Same |
| Dietary preferences (Halal/Veg/Vegan/Allergens) | Profile mock | Same |
| Cuisine preferences | `['Malaysian', 'Japanese']` | Same |
| Photo picker | Opens picker but no upload | `POST /users/me/avatar` (multipart) |
| Save button | Updates local Riverpod state only | `PUT /users/me/profile` |
| "Edit Dietary" / "Edit Budget" / "Edit Health" buttons | Navigate to wizard screens in edit mode | After wizard save: `PUT /users/me/profile` |

### App Settings (`/settings`)
**File:** `lib/features/settings/screens/app_settings_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Name + email at top | `'Joshua Bonham'`, `'joshua.bonham@example.com'` | Authenticated user session |
| Appearance toggle (Dark / Light) | Local SharedPreferences — no backend needed | Local only |
| Language selector | Static — no backend needed | Local only |
| Notification settings link | Routes to `/settings/notifications` | — |
| Logout button | Clears local state | `POST /auth/logout` (revoke token) |
| Delete Account | Shows dialog | `DELETE /users/me` |

### Notification Settings (`/settings/notifications`)
**File:** `lib/features/notifications/screens/notification_settings_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Budget alerts toggle | Local state | `PUT /users/me/notification-preferences` |
| Grocery reminders toggle | Local state | Same |
| Recommendation alerts toggle | Local state | Same |
| Push token | Not implemented | Register device token: `POST /users/me/push-token` |

### API summary
```
GET    /users/me/profile
PUT    /users/me/profile
POST   /users/me/avatar
DELETE /users/me
POST   /auth/logout
PUT    /users/me/notification-preferences
POST   /users/me/push-token
```

---

## 12. Notification Screens

### Notification Centre (`/notifications`)
**File:** `lib/features/notifications/screens/notification_centre_screen.dart`

| UI element | Hardcoded value | Replace with |
|------------|----------------|--------------|
| Notification list | `NotificationMocks.items` (4 notifications) | `GET /notifications?page=…&limit=20` |
| Unread badge | Count from local mock | `GET /notifications/unread-count` |
| "Mark all read" action | Updates local state | `POST /notifications/mark-all-read` |
| Per-notification categories | `budget`, `grocery`, `recommendation`, `welcome` | Same — `category` field from API |
| Timestamps | Static strings (`'Just now'`, `'2 hrs ago'`) | ISO 8601 datetime → format client-side |

### API summary
```
GET  /notifications
GET  /notifications/unread-count
POST /notifications/mark-all-read
PATCH /notifications/:id/read
```

---

## 13. Enumerated Value Reference

These are the exact string values used throughout the app. The backend must accept and return these exact values for filtering/matching to work correctly.

### Dietary Tags (restaurants & menu items)
```
"Halal"
"Vegan"
"Vegetarian"
```

### Allergens
```
"Nuts"
"Dairy"
"Gluten"
"Shellfish"
"Eggs"
"Soy"
```

### Cuisine Categories
```
"Malaysian"
"Chinese"
"Indian"
"Japanese"
"Western"
"Thai"
"Korean"
"Middle Eastern"
```

### Price Brackets
```
"budget"   → displays as "RM 5–10"
"mid"      → displays as "RM 10–20"
"premium"  → displays as "RM 20+"
```
> Backend should return the key (`budget` / `mid` / `premium`). The display label is rendered client-side.

### Recipe Visibility
```
"public"
"private"
```

### Budget Categories (transactions)
```
"groceries"   → displays as "Groceries"
"dining"      → displays as "Dining Out"
```

### Health Goals
```
"maintain_weight"
"lose_weight"
"gain_muscle"
"general_health"
```

### Activity Levels
```
"Sedentary"
"Light"
"Moderate"
"Active"
```

### Notification Categories
```
"budget"
"grocery"
"recommendation"
"welcome"
```

### Stock Status (grocery store products)
```
"in_stock"
"low_stock"
"out_of_stock"
```

---

## 14. Data Collection Team — Field Specifications

This section tells the data collection team **exactly what fields to record** for each entity. Do not use mock names or values — collect real data for each field listed.

---

### 14.1 Restaurants

Collect one record per restaurant.

| Field | Type | Description / Notes |
|-------|------|----------------------|
| `id` | `string` | Unique slug, e.g. `"botanica-co-bangsar-south"` |
| `name` | `string` | Full official restaurant name |
| `cuisineType` | `string` | One value from cuisine categories (Section 13) |
| `address` | `string` | Full street address including unit/lot number, area, city |
| `lat` | `decimal` | WGS84 latitude, 6 decimal places minimum |
| `lng` | `decimal` | WGS84 longitude, 6 decimal places minimum |
| `phone` | `string` | Format: `+60 X-XXXX XXXX` |
| `distanceKm` | `decimal` | Distance from app's default reference point (to be computed dynamically — leave blank, computed from coordinates) |
| `walkMinutes` | `integer` | Approximate walking time from the area (to be computed dynamically — leave blank) |
| `pricingBracket` | `string` | `budget` / `mid` / `premium` (see Section 13) |
| `isOpen` | `boolean` | Current open status (dynamic — computed from opening hours) |
| `closingTime` | `string` | Today's closing time, e.g. `"10:00 PM"`. Ideally provide full weekly schedule (see below) |
| `openingHours` | `object` | Weekly schedule: `{ mon: "8:00 AM–10:00 PM", tue: …, … }` |
| `dietaryTags` | `string[]` | One or more of `["Halal", "Vegan", "Vegetarian"]` — only include if the whole restaurant qualifies |
| `imageUrl` | `string` | URL of the hero/cover photo (hosted on CDN) |
| `recommendationReason` | `string` | 1–2 sentence summary of why this restaurant is recommended (used as a caption in the app) |
| `rating` | `decimal` | Aggregate star rating, 1–5, one decimal place, e.g. `4.8` |
| `reviewCount` | `integer` | Total number of reviews |
| `isHalal` | `boolean` | True if the entire restaurant is Halal-certified |
| `isVegan` | `boolean` | True if the restaurant is primarily or fully vegan |
| `isClaimed` | `boolean` | True if the business has claimed their listing |
| `brtRoute` | `string` | Optional. Nearest BRT/LRT/MRT line or stop, e.g. `"Sunway BRT"` |

#### 14.1.1 Menu Items (for each restaurant)

Collect all items on the menu, grouped by category.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique ID within the restaurant, e.g. `"bc-1"` |
| `category` | `string` | Menu section: `"Mains"`, `"Sides"`, `"Beverages"`, `"Desserts"`, etc. |
| `name` | `string` | Dish name as shown on the menu |
| `description` | `string` | 1–2 sentence description of the dish |
| `price` | `decimal` | Price in RM, e.g. `28.00` |
| `dietaryTags` | `string[]` | Applicable tags: `["Halal"]`, `["Halal", "Vegetarian"]`, `["Vegan"]`, etc. |
| `restrictions` | `string[]` | Allergens present: from `["Nuts", "Dairy", "Gluten", "Shellfish", "Eggs", "Soy"]` |
| `imageUrl` | `string` | URL of dish photo (optional but preferred) |

---

### 14.2 Grocery Stores

Collect one record per store location (different branches = different records).

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique slug, e.g. `"jaya-grocer-bangsar"` |
| `name` | `string` | Full store name including branch, e.g. `"Jaya Grocer Bangsar South"` |
| `type` | `string` | Store type: `"Supermarket"`, `"Hypermarket"`, `"Convenience"`, `"Specialty"`, `"Wet Market"` |
| `address` | `string` | Full street address |
| `lat` | `decimal` | WGS84 latitude |
| `lng` | `decimal` | WGS84 longitude |
| `phone` | `string` | Store phone number |
| `isOpen` | `boolean` | Current open status (dynamic — computed from opening hours) |
| `closingTime` | `string` | Today's closing time |
| `openingHours` | `object` | Weekly schedule (same format as restaurants) |
| `imageUrl` | `string` | Store front or logo image URL |
| `isClaimed` | `boolean` | Whether the store has claimed their listing |

#### 14.2.1 Products (for each grocery store)

Note: product catalogues are large. Prioritise items that appear in recipe ingredient lists.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique product ID within the store |
| `name` | `string` | Product name as labelled in store |
| `category` | `string` | `"Fresh Produce"`, `"Pantry"`, `"Dairy"`, `"Frozen"`, `"Bakery"`, `"Beverages"`, `"Household"` |
| `quantity` | `decimal` | Package amount, e.g. `200`, `1`, `6` (optional) |
| `unit` | `string` | Unit choice: `g`, `kg`, `ml`, `L`, `pcs`, `tbsp`, `tsp`, `cup` (optional) |
| `unitSize` | `string` | Computed display string from quantity + unit, e.g. `"200 g"`, `"1 L"`, `"6 pcs"` (null if unset) |
| `price` | `decimal` | Price in RM |
| `stockStatus` | `string` | `"in_stock"` / `"low_stock"` / `"out_of_stock"` |
| `imageUrl` | `string` | Product image URL (optional) |

---

### 14.3 Recipes (Community / Seeded Content)

For any seed/demo recipes to be loaded at launch.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique slug, e.g. `"nasi-goreng-kampung-1"` |
| `title` | `string` | Recipe name |
| `description` | `string` | 1–3 sentence description |
| `authorName` | `string` | Creator's display name |
| `authorInitial` | `string` | Single capital letter initial, e.g. `"A"` |
| `cookMinutes` | `integer` | Total prep + cook time in minutes |
| `calories` | `integer` | Calories per serving |
| `servings` | `integer` | Number of servings the recipe yields |
| `isHalal` | `boolean` | Whether the recipe is Halal |
| `isVegan` | `boolean` | Whether the recipe is vegan |
| `isVegetarian` | `boolean` | Whether the recipe is vegetarian |
| `cuisine` | `string` | One value from cuisine categories (Section 13) |
| `allergens` | `string[]` | Allergens present — from the allergen list (Section 13) |
| `visibility` | `string` | `"public"` for seed recipes |
| `saves` | `integer` | Initial save count (can be seeded as 0 or realistic number) |
| `createdAt` | `ISO 8601 datetime` | Creation timestamp |
| `imageUrl` | `string` | Hero photo of the finished dish (optional but preferred) |

#### 14.3.1 Ingredients (per recipe)

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Ingredient name |
| `quantity` | `string` | e.g. `"2 cups"`, `"100 g"`, `"1 pc"` |
| `storeName` | `string` | Which nearby store stocks this (optional — used by grocery match) |
| `estimatedCost` | `decimal` | Estimated cost in RM for the given quantity |
| `notSourcedNearby` | `boolean` | True if this ingredient is hard to find locally (shows a flag in UI) |

#### 14.3.2 Steps (per recipe)

| Field | Type | Description |
|-------|------|-------------|
| `stepNumber` | `integer` | Sequential step number starting at 1 |
| `description` | `string` | Full instruction for this step |

---

### 14.4 Map Venues (for map pin data)

The map uses a simplified summary of venues for pin rendering. This overlaps with restaurants and grocery stores but must include coordinate accuracy since pins are the primary use.

| Field | Type | Notes |
|-------|------|-------|
| `id` | `string` | Same ID as the parent restaurant or grocery store |
| `name` | `string` | Short display name for the map pin label |
| `type` | `string` | Cuisine type (for restaurants) or store type (for groceries) |
| `lat` | `decimal` | Must be accurate to street-level precision |
| `lng` | `decimal` | Must be accurate to street-level precision |
| `isGrocery` | `boolean` | True for grocery stores, false for restaurants |
| `distance` | `string` | Computed dynamically — do not collect |

---

### 14.5 Explore / Nearby Venues Feed

These are the cards shown on the Explore tab search results. They pull from the restaurant and grocery store data but use a summarised model:

| Field | Type | Source |
|-------|------|--------|
| `id` | `string` | From restaurant or grocery store |
| `name` | `string` | Same |
| `cuisineType` | `string` | Restaurant cuisine or store type |
| `distanceKm` | `decimal` | Computed dynamically |
| `rating` | `decimal` | From restaurant record |
| `isOpen` | `boolean` | Computed from opening hours |
| `isHalal` | `boolean` | From restaurant dietary tags |
| `isVegan` | `boolean` | From restaurant dietary tags |
| `pricingBracket` | `string` | `budget` / `mid` / `premium` |
| `imageUrl` | `string` | Hero image URL |

No separate data collection needed — this is derived from the restaurant and grocery store records.

---

### 14.6 Home Feed Top Pick & Recommendations

The recommendation engine will compute these server-side. The data collection team does not need to provide recommendation logic, but the quality of the top-pick card depends on complete restaurant data (especially `rating`, `reviewCount`, `dietaryTags`, `imageUrl`, `recommendationReason`).

| Field shown in Top Pick card | Source field |
|-----------------------------|--------------|
| Restaurant name | `name` |
| Cuisine / description | `recommendationReason` |
| Distance | Computed |
| Rating | `rating` |
| Review count | `reviewCount` |
| Walk time | Computed |
| Halal badge | `isHalal` |
| Price bracket | `pricingBracket` |
| Image | `imageUrl` |
| Match score (%) | Computed by recommendation engine — not a collected field |

---

### 14.7 User Reviews (Restaurants & Recipes)

Reviews are user-generated. The data collection team does not create review content. However, for **seed data** / demo reviews at launch, collect the following:

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique review ID |
| `authorName` | `string` | Reviewer display name |
| `authorInitial` | `string` | Single capital letter |
| `rating` | `integer` | 1–5 stars |
| `body` | `string` | Review text |
| `timestamp` | `ISO 8601 datetime` | Date of review |
| `subjectType` | `string` | `"restaurant"` or `"recipe"` |
| `subjectId` | `string` | ID of the restaurant or recipe being reviewed |

---

*End of document.*
