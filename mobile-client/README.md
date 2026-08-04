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

## 🔐 Google Sign-In Setup

For the backend side (Web OAuth client, Django `SocialApp`), see the **🔐 Google Authentication Setup** section in [`server/README.md`](../server/README.md) — do that first. This section covers wiring the mobile client itself to those credentials. Scope: iOS + Web (Android not set up yet — add later following the same pattern).

**Architecture:** two OAuth client IDs exist in Google Cloud Console, but only the **Web** one is ever registered with Django. The Web client is used directly by the Flutter web build and is what `GoogleLoginView` (`server/apps/users/views_api.py`) validates tokens against. The **iOS** client only exists to let the native Google Sign-In sheet launch (tied to the bundle ID `com.mapetite.mapetite`) — the iOS app requests its ID token with `serverClientId` set to the Web client ID, so the token it actually sends to Django is audienced to the Web client. Without `serverClientId`, iOS tokens would be rejected by the backend.

**Already wired up** in this codebase (client IDs are public identifiers, safe to commit — no secret lives here):
- `ios/Runner/Info.plist` — `GIDClientID` + URL scheme (reversed iOS client ID). This one **is** shared across the team: it's tied to the app's bundle ID, and the URL scheme has to be baked into `Info.plist` at build time, so it can't reasonably differ per developer.
- `lib/features/auth/screens/login_screen.dart` — `clientId` (web only) and `serverClientId` both come from `AppConfig.googleWebClientId` (`lib/core/config/app_config.dart`), **not** hardcoded.

**The Web client ID is per-developer**, not shared — per the backend setup steps, each teammate generates their own and registers it against their own local `SocialApp`. So `AppConfig.googleWebClientId` follows the same `String.fromEnvironment` pattern as `baseUrl`: it has a default value checked in so the app runs out of the box, but if you generate your own Web client, override it at run time so it matches whatever you registered in your own local Django admin:

```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=your-client-id.apps.googleusercontent.com
```

**For staging/prod:**
- If reusing the same Web client as dev, add the prod domain to its **Authorized JavaScript origins** in Console — Google's Identity Services library enforces this for web sign-in, so a domain not listed there fails even with a valid client ID.
- The iOS client doesn't need to change per environment — it's tied to the bundle ID, not a domain.
- If the OAuth consent screen is still in **Testing** publishing status, only accounts added as test users can sign in — move it to **Production** (or add test users) before QA/demo with non-team accounts.
- If a different Web client ID is used for that environment, update `AppConfig.googleWebClientId`'s default (or pass it via `--dart-define` at build time).
