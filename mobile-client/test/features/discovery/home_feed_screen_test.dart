import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/core/errors/app_exception.dart';
import 'package:mapetite/features/auth/controllers/auth_controller.dart';
import 'package:mapetite/features/auth/models/auth_state.dart';
import 'package:mapetite/features/auth/models/current_user.dart';
import 'package:mapetite/features/auth/services/auth_service.dart';
import 'package:mapetite/features/discovery/models/home_feed_models.dart';
import 'package:mapetite/features/discovery/screens/home_feed_screen.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/store_providers.dart';
import 'package:mapetite/shared/widgets/app_drawer.dart';
import 'package:mapetite/shared/widgets/app_empty_state.dart';
import 'package:mapetite/shared/widgets/dietary_chip.dart';
import 'package:mapetite/shared/widgets/food_card.dart';
import 'package:mapetite/shared/widgets/loading_indicator.dart';

// ─── Test fixtures ─────────────────────────────────────────────────────────────

const _testRestaurant = RestaurantSummary(
  id: 'test-1',
  name: 'Test Nasi Lemak',
  cuisine: 'Malaysian',
  distanceKm: 0.5,
  rating: 4.8,
  reviewCount: 50,
  isOpen: true,
  isHalal: true,
  isVegan: false,
  isClaimed: true,
  walkMinutes: 8,
  matchScore: 95,
);

const _testRestaurantVeganOnly = RestaurantSummary(
  id: 'test-2',
  name: 'Green Garden',
  cuisine: 'International',
  distanceKm: 1.2,
  rating: 4.2,
  reviewCount: 30,
  isOpen: true,
  isHalal: false,
  isVegan: true,
  isClaimed: false,
  walkMinutes: 15,
  matchScore: 78,
);

const _testGrocery = GrocerySummary(
  id: 'g-test',
  name: 'Test Grocer',
  type: 'Supermarket',
  distanceKm: 1.2,
  isOpen: true,
  isClaimed: false,
);

const _testRecipe = RecipeSummary(
  id: 'rc-test',
  name: 'Test Nasi Goreng',
  cuisine: 'Malaysian',
  prepMinutes: 25,
  calories: 400,
  isHalal: true,
  isVegan: false,
  authorName: 'Test Chef',
);

const _testRecipeVegan = RecipeSummary(
  id: 'rc-test-2',
  name: 'Smoothie Bowl',
  cuisine: 'Healthy',
  prepMinutes: 10,
  calories: 280,
  isHalal: false,
  isVegan: true,
  authorName: 'Test Chef',
);

// ─── StoreModel fixtures for HomeFeedScreen's real-data sections ───────────────

const _testRestaurantStore = StoreModel(
  id: 'r-1',
  businessName: 'Test Nasi Lemak',
  description: '',
  merchantType: StoreType.restaurant,
  halal: true,
  vegan: false,
  streetAddress: 'Jalan Test',
  category: 'Malaysian',
  distanceKm: 0.5,
);

const _testGroceryStore = StoreModel(
  id: 'g-1',
  businessName: 'Test Grocer',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Jalan Grocer',
  category: 'Supermarket',
  distanceKm: 1.2,
);

const _defaultRestaurants = [_testRestaurantStore];
const _defaultGroceries = [_testGroceryStore];

const _testUserProfile = UserProfile(
  onboardingCompleted: true,
  avatar: null,
  phoneNumber: '',
  address: '',
  city: '',
  country: '',
  spendingAlertPercent: 80,
  healthGoal: '',
  activityLevel: '',
  isHalal: false,
  isVegan: false,
  allergies: [],
);

const _testCurrentUser = CurrentUser(
  id: 1,
  email: 'joshua@example.com',
  username: 'joshua',
  firstName: 'Joshua',
  lastName: '',
  isVerified: true,
  profile: _testUserProfile,
);

Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: child));
}

// ─── Router helpers for HomeFeedScreen tests ────────────────────────────────

GoRouter _testRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const HomeFeedScreen(),
        ),
        GoRoute(
          path: '/dine-in',
          builder: (_, _) => const Scaffold(body: Text('DineIn')),
        ),
        GoRoute(
          path: '/cook-in',
          builder: (_, _) => const Scaffold(body: Text('CookIn')),
        ),
        GoRoute(
          path: '/recipes',
          builder: (_, _) => const Scaffold(body: Text('Recipes')),
        ),
        GoRoute(
          path: '/restaurants',
          builder: (_, _) => const Scaffold(body: Text('Restaurants')),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, _) =>
                  const Scaffold(body: Text('RestaurantDetail')),
            ),
          ],
        ),
        GoRoute(
          path: '/map',
          builder: (_, _) => const Scaffold(body: Text('Map')),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const Scaffold(body: Text('Notifications')),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (_, _) => const Scaffold(body: Text('ProfileEdit')),
        ),
        GoRoute(
          path: '/groceries',
          builder: (_, _) => const Scaffold(body: Text('Groceries')),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, _) => const Scaffold(body: Text('GroceryDetail')),
            ),
          ],
        ),
        GoRoute(
          path: '/list',
          builder: (_, _) => const Scaffold(body: Text('List')),
        ),
        GoRoute(
          path: '/my-list',
          builder: (_, _) => const Scaffold(body: Text('MyList')),
        ),
        GoRoute(
          path: '/list/route',
          builder: (_, _) => const Scaffold(body: Text('Route')),
        ),
        GoRoute(
          path: '/budget/analytics',
          builder: (_, _) => const Scaffold(body: Text('Analytics')),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Scaffold(body: Text('Settings')),
        ),
      ],
    );

/// Builds the [NearbyStoresQuery] result for a given query. Defaults to
/// returning [_defaultRestaurants]/[_defaultGroceries] depending on
/// [NearbyStoresQuery.type], letting most tests just call `_routerWrap()`.
/// Individual tests override [storesBuilder] to simulate loading/error
/// states for one or both of the restaurant/grocery fetches independently.
typedef _StoresBuilder = Future<List<StoreModel>> Function(
  NearbyStoresQuery query,
);

Future<List<StoreModel>> _defaultStoresBuilder(NearbyStoresQuery query) async {
  return query.type == StoreType.grocery
      ? _defaultGroceries
      : _defaultRestaurants;
}

Widget _routerWrap({_StoresBuilder? storesBuilder}) => ProviderScope(
      overrides: [
        nearbyStoresProvider.overrideWith(
          (ref, query) => (storesBuilder ?? _defaultStoresBuilder)(query),
        ),
        authControllerProvider.overrideWith(
          (ref) => AuthController(AuthService())
            ..state = const AuthState(currentUser: _testCurrentUser),
        ),
      ],
      child: MaterialApp.router(routerConfig: _testRouter()),
    );

// ─── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('RestaurantMiniCard', () {
    testWidgets('renders restaurant name', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RestaurantMiniCard(restaurant: _testRestaurant, onTap: () {}),
        )),
      );
      expect(find.text('Test Nasi Lemak'), findsOneWidget);
    });

    testWidgets('renders rating and distance caption', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RestaurantMiniCard(restaurant: _testRestaurant, onTap: () {}),
        )),
      );
      expect(find.text('4.8 ★  ·  0.5 km'), findsOneWidget);
    });

    testWidgets('renders halal dietary chip when isHalal is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RestaurantMiniCard(restaurant: _testRestaurant, onTap: () {}),
        )),
      );
      expect(find.text('Halal'), findsOneWidget);
    });

    testWidgets('renders vegan dietary chip when isVegan is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RestaurantMiniCard(
              restaurant: _testRestaurantVeganOnly, onTap: () {}),
        )),
      );
      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('Halal'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RestaurantMiniCard(
            restaurant: _testRestaurant,
            onTap: () => tapped = true,
          ),
        )),
      );
      await tester.tap(find.byType(RestaurantMiniCard));
      expect(tapped, isTrue);
    });
  });

  group('GroceryMiniCard', () {
    testWidgets('renders grocery name', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: GroceryMiniCard(grocery: _testGrocery, onTap: () {}),
        )),
      );
      expect(find.text('Test Grocer'), findsOneWidget);
    });

    testWidgets('renders type and distance caption', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: GroceryMiniCard(grocery: _testGrocery, onTap: () {}),
        )),
      );
      expect(find.text('Supermarket  ·  1.2 km'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: GroceryMiniCard(
            grocery: _testGrocery,
            onTap: () => tapped = true,
          ),
        )),
      );
      await tester.tap(find.byType(GroceryMiniCard));
      expect(tapped, isTrue);
    });
  });

  group('RecipeMiniCard', () {
    testWidgets('renders recipe name', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RecipeMiniCard(recipe: _testRecipe, onTap: () {}),
        )),
      );
      expect(find.text('Test Nasi Goreng'), findsOneWidget);
    });

    testWidgets('renders cuisine', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RecipeMiniCard(recipe: _testRecipe, onTap: () {}),
        )),
      );
      expect(find.text('Malaysian'), findsOneWidget);
    });

    testWidgets('renders prep time', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RecipeMiniCard(recipe: _testRecipe, onTap: () {}),
        )),
      );
      expect(find.textContaining('25 min'), findsOneWidget);
    });

    testWidgets('renders halal dietary chip when isHalal is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RecipeMiniCard(recipe: _testRecipe, onTap: () {}),
        )),
      );
      expect(find.text('Halal'), findsOneWidget);
    });

    testWidgets('renders vegan dietary chip when isVegan is true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RecipeMiniCard(recipe: _testRecipeVegan, onTap: () {}),
        )),
      );
      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('Halal'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: RecipeMiniCard(
            recipe: _testRecipe,
            onTap: () => tapped = true,
          ),
        )),
      );
      await tester.tap(find.byType(RecipeMiniCard));
      expect(tapped, isTrue);
    });
  });

  group('DietaryChip', () {
    testWidgets('renders Halal label', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: DietaryChip(tag: DietaryTag.halal))),
      );
      expect(find.text('Halal'), findsOneWidget);
    });

    testWidgets('renders Vegan label', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: DietaryChip(tag: DietaryTag.vegan))),
      );
      expect(find.text('Vegan'), findsOneWidget);
    });

    testWidgets('renders Vegetarian label', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: DietaryChip(tag: DietaryTag.vegetarian))),
      );
      expect(find.text('Vegetarian'), findsOneWidget);
    });

    testWidgets('renders Allergen label', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: DietaryChip(tag: DietaryTag.allergen))),
      );
      expect(find.text('Allergen'), findsOneWidget);
    });
  });

  group('HomeFeedSkeleton', () {
    testWidgets('renders skeleton widget directly', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: HomeFeedSkeleton())),
      );
      expect(find.byType(HomeFeedSkeleton), findsOneWidget);
    });

    testWidgets(
        'HomeFeedScreen shows skeleton while the restaurant fetch is loading',
        (tester) async {
      // Never-completing future: keeps the restaurant query in the
      // "loading" state for the duration of this test without leaving a
      // real pending Timer behind (unlike Future.delayed), which would
      // trip flutter_test's post-test "timer still pending" invariant
      // check.
      final completer = Completer<List<StoreModel>>();
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) => query.type == StoreType.restaurant
            ? completer.future
            : Future.value(_defaultGroceries),
      ));
      await tester.pump();
      expect(find.byType(HomeFeedSkeleton), findsOneWidget);
    });
  });

  group('AppEmptyState', () {
    testWidgets('renders title, description, and CTA', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: AppEmptyState(
            icon: Icons.map_outlined,
            title: 'Nothing nearby yet',
            description: 'No venues found near your location.',
            ctaLabel: 'Explore Map',
            onCta: () {},
          ),
        )),
      );
      expect(find.text('Nothing nearby yet'), findsOneWidget);
      expect(find.text('No venues found near your location.'), findsOneWidget);
      expect(find.text('Explore Map'), findsOneWidget);
    });
  });

  group('HomeFeedScreen — new layout', () {
    testWidgets('renders personalised greeting with user name', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Hi, Joshua.'), findsOneWidget);
    });

    testWidgets('renders contextual meal-time second line', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Any one of the contextual greeting lines should appear
      final greetingFinder = find.textContaining(
        RegExp(
          r'(breakfast|brunch|craving|snack|tonight|something|supper)',
          caseSensitive: false,
        ),
      );
      expect(greetingFinder, findsOneWidget);
    });

    testWidgets('renders Dine-In mode card', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Dine-In'), findsOneWidget);
    });

    testWidgets('renders Cook-In mode card', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Cook-In'), findsOneWidget);
    });

    testWidgets('does not render the AI nudge pill', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('AI SUGGESTION'), findsNothing);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);
    });

    testWidgets("does not render Today's Top Pick section", (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text("Today's Top Pick"), findsNothing);
      expect(find.text("Let's Eat!"), findsNothing);
    });

    testWidgets('renders real restaurant and grocery data', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Test Nasi Lemak'), findsOneWidget);
      expect(find.text('Test Grocer'), findsOneWidget);
    });

    testWidgets('renders Nearby Options section header', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Nearby Options'), findsOneWidget);
    });

    testWidgets('renders Nearby Groceries section header', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Nearby Groceries'), findsOneWidget);
    });

    testWidgets('Dine-In card shows the real nearby restaurant count',
        (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.text('${_defaultRestaurants.length} nearby'),
        findsOneWidget,
      );
    });

    testWidgets('renders View map button', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('View map'), findsOneWidget);
    });

    testWidgets('does not render FAB', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('shows an error state when the restaurant fetch errors',
        (tester) async {
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) async {
          if (query.type == StoreType.restaurant) {
            throw Exception('network error');
          }
          return _defaultGroceries;
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
        'tapping Retry on a restaurant fetch error re-fetches both queries',
        (tester) async {
      var restaurantCalls = 0;
      var groceryCalls = 0;
      var shouldError = true;
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) async {
          if (query.type == StoreType.restaurant) {
            restaurantCalls++;
            if (shouldError) throw Exception('network error');
            return _defaultRestaurants;
          }
          groceryCalls++;
          return _defaultGroceries;
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(restaurantCalls, 1);
      expect(groceryCalls, 1);

      shouldError = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Both the restaurant and grocery queries are invalidated on retry
      // from the outer (restaurant) error branch, mirroring how
      // restaurant_detail_screen.dart invalidates both providers when its
      // outer dual-gate error fires.
      expect(restaurantCalls, 2);
      expect(groceryCalls, 2);
      expect(find.text('Something went wrong'), findsNothing);
      expect(find.text('Test Nasi Lemak'), findsOneWidget);
    });

    testWidgets('shows an error state when the grocery fetch errors',
        (tester) async {
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) async {
          if (query.type == StoreType.grocery) {
            throw Exception('network error');
          }
          return _defaultRestaurants;
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping Retry on a grocery fetch error re-fetches groceries',
        (tester) async {
      var restaurantCalls = 0;
      var groceryCalls = 0;
      var shouldError = true;
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) async {
          if (query.type == StoreType.grocery) {
            groceryCalls++;
            if (shouldError) throw Exception('network error');
            return _defaultGroceries;
          }
          restaurantCalls++;
          return _defaultRestaurants;
        },
      ));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(restaurantCalls, 1);
      expect(groceryCalls, 1);

      shouldError = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Only the grocery query is invalidated on retry from the inner
      // (grocery) error branch — the restaurant fetch already succeeded.
      expect(restaurantCalls, 1);
      expect(groceryCalls, 2);
      expect(find.text('Something went wrong'), findsNothing);
      expect(find.text('Test Grocer'), findsOneWidget);
    });

    testWidgets('Dine-In card tap navigates to /dine-in', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Dine-In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('DineIn'), findsOneWidget);
    });

    testWidgets('Cook-In card tap navigates to /cook-in', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Cook-In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('CookIn'), findsOneWidget);
    });

    testWidgets('View map tap navigates to /map', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -600),
      );
      await tester.pump();
      await tester.tap(find.text('View map'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Map'), findsOneWidget);
    });

    testWidgets('tapping a grocery row navigates to /groceries/<id>',
        (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -1200),
      );
      await tester.pump();
      await tester.tap(find.text('Test Grocer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('GroceryDetail'), findsOneWidget);
    });

    testWidgets(
        'shows NetworkErrorState instead of the generic error when the restaurant fetch is a network error',
        (tester) async {
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) async {
          if (query.type == StoreType.restaurant) {
            throw const AppException(
              message: 'No internet connection.',
              isNetworkError: true,
            );
          }
          return _defaultGroceries;
        },
      ));
      await tester.pumpAndSettle();

      expect(find.text('Could not connect.'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets(
        'shows EmptyFeedState with Expand Radius when both nearby lists are empty, and tapping it re-fetches at the max radius',
        (tester) async {
      final seenRadii = <double>[];
      await tester.pumpWidget(_routerWrap(
        storesBuilder: (query) async {
          seenRadii.add(query.radiusKm);
          return <StoreModel>[];
        },
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nothing nearby.'), findsOneWidget);
      expect(find.text('Expand Radius'), findsOneWidget);
      expect(seenRadii, everyElement(5.0));

      await tester.tap(find.text('Expand Radius'));
      await tester.pumpAndSettle();

      expect(seenRadii, contains(20.0));
    });
  });

  group('HomeFeedScreen — drawer', () {
    testWidgets('renders AppDrawer when drawer is opened', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final scaffoldState =
          tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppDrawer), findsOneWidget);
    });
  });
}
