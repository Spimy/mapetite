# Mapetite Mobile Client

The consumer-facing Flutter app for Mapetite. It's the "zero-input" front door for users — surfacing personalised discovery and recommendations, letting them plan meals, shop groceries or dine out, and track their food budget along the way.

## Features

- **Discovery & recommendations** — personalised home feed, search, category browse, and map-based exploration of nearby merchants.
- **Recipes ("cook-in")** — browse, create, and edit recipes, then match ingredients to a grocery store's stock.
- **Groceries & dine-in** — browse grocery stores and restaurants, build a shopping list, and get an optimised shopping route.
- **Budget tracking** — monthly overview, spending analytics, and transaction history.
- **Profile & preferences** — a guided setup wizard for dietary preferences, budget, and health goals, used to personalise recommendations.
- **Notifications** — a notification centre plus granular settings (including AI recommendation alerts).

## Tech Stack

- **Flutter / Dart** — cross-platform UI
- **flutter_riverpod** — state management
- **go_router** — declarative routing, incl. the bottom-nav shell
- **dio** — networking, with a JWT refresh interceptor for the Django API
- **flutter_map** / **geolocator** — maps and location
- **flutter_screenutil**, **google_fonts**, **fl_chart** — responsive UI, typography, charts

## Prerequisites

- **Flutter SDK 3.41+** (Dart 3.11+) installed and on your `PATH`.
- The Mapetite backend running — see the [root README](../README.md) for the Docker/PostGIS setup, migrations, and seeding. This app expects that API to be reachable; nothing here duplicates that setup.

## Getting Started

1. Install dependencies:

   ```bash
   cd mobile-client
   flutter pub get
   ```

2. Run the app on your platform of choice:

   ```bash
   flutter run                # picks up a connected device/emulator
   flutter run -d chrome      # web
   ```

   Alternatively, from the **repo root** there's a `make` target that runs the app as a web server (`flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`):

   ```bash
   make flutter-run
   ```

   This is defined in the root [`Makefile`](../Makefile) alongside the backend's `make migrate`/`make seed` targets.

3. Point it at your backend. The API base URL defaults to `http://localhost:8000/api/` and can be overridden at build/run time:

   ```bash
   flutter run --dart-define=BASE_URL=http://localhost:8000/api/
   ```

   **Android emulator note:** `localhost` refers to the emulator itself, not your host machine. Use `http://10.0.2.2:8000/api/` instead so the app can reach Docker on your host.

## Project Structure

The app is organised feature-first under `lib/features/`, where each feature owns its own `screens/`, `widgets/`, `models/`, `providers/`, and `services/` (e.g. `lib/features/budget/screens/budget_overview_screen.dart`). Cross-cutting code lives in `lib/core/` (theme, network client, config, constants) and `lib/shared/` (reusable widgets and services used across multiple features, like `AppCard` or `LocationService`). Routing is centralised — see below.

## Development Conventions

Always use the shared design system instead of hardcoded values:

- Colours from `AppColors`, type styles from `AppTypography`, and spacing from `AppSpacing` (`lib/core/theme/`, `lib/core/constants/`).
- Shared widgets like `AppCard`, `CustomButton`, `AppChip`, and the empty/error states in `lib/shared/widgets/` instead of one-off implementations.

Lint rules are enforced via `analysis_options.yaml` (`flutter analyze` should stay clean).

## Testing

```bash
flutter test
```

Tests live under `test/`, mirroring the structure of `lib/` (e.g. `test/features/budget/services/budget_service_test.dart` tests `lib/features/budget/services/budget_service.dart`).

## Routing

Navigation is defined in a single `go_router` config at `lib/routes/app_router.dart`. A `StatefulShellRoute` provides the bottom-nav shell for Home, Explore, Map, and Budget; every other screen (auth, profile setup, recipes, restaurants, settings, etc.) is pushed on top of it.
