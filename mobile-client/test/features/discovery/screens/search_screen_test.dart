import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/discovery/screens/search_screen.dart';
import 'package:mapetite/features/recipes/models/recipe_model.dart';
import 'package:mapetite/features/recipes/providers/recipe_provider.dart';
import 'package:mapetite/features/recipes/services/recipe_service.dart';
import 'package:mapetite/features/recipes/widgets/recipe_card.dart';
import 'package:mapetite/shared/models/location_model.dart';
import 'package:mapetite/shared/models/store_model.dart';
import 'package:mapetite/shared/providers/location_provider.dart';
import 'package:mapetite/shared/providers/store_providers.dart';
import 'package:shimmer/shimmer.dart';

// ─── Test fixtures ─────────────────────────────────────────────────────────

const _testRestaurant = StoreModel(
  id: 'r1',
  businessName: 'Ocean Bowl',
  description: '',
  merchantType: StoreType.restaurant,
  halal: true,
  vegan: false,
  streetAddress: 'Jalan Test',
  category: 'Seafood',
  distanceKm: 0.3,
);

const _testGrocery = StoreModel(
  id: 'g1',
  businessName: 'Ocean Mart',
  description: '',
  merchantType: StoreType.grocery,
  halal: false,
  vegan: false,
  streetAddress: 'Jalan Grocer',
  category: 'Supermarket',
  distanceKm: 0.5,
);

const _defaultRestaurants = [_testRestaurant];
const _defaultGroceries = [_testGrocery];

class _FakeRecipeService extends RecipeService {
  _FakeRecipeService(this._builder);

  final Future<List<RecipeModel>> Function() _builder;

  @override
  Future<List<RecipeModel>> getRecipes({
    String? query,
    int? currentUserId,
  }) {
    return _builder();
  }
}

RecipeModel _testRecipe(String id, String title) => RecipeModel(
  id: id,
  title: title,
  authorName: 'Chef Hafiz',
  authorInitial: 'C',
  cookMinutes: 25,
  calories: 450,
  servings: 2,
  ingredients: const [],
  steps: const [],
  createdAt: DateTime(2026, 1, 1),
);

final _defaultRecipes = [
  _testRecipe('rec1', 'Nasi Goreng Kampung'),
  _testRecipe('rec2', 'Mee Goreng Mamak'),
];

final _sixRecipes = List.generate(6, (i) => _testRecipe('rec$i', 'Recipe $i'));

/// No location so the screen doesn't depend on a real Geolocator platform
/// channel being available in the test environment — mirrors the pattern
/// established in map_explore_screen_test.dart.
class _FixedLocationNotifier extends LocationNotifier {
  @override
  Future<LocationModel?> build() async => null;
}

GoRouter _testRouter() => GoRouter(
  initialLocation: '/explore',
  routes: [
    GoRoute(path: '/explore', builder: (_, _) => const SearchScreen()),
    GoRoute(
      path: '/restaurants',
      builder: (_, _) => const Scaffold(body: Text('Restaurants')),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) => Scaffold(
            body: Text('RestaurantDetail:${state.pathParameters['id']}'),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/groceries',
      builder: (_, _) => const Scaffold(body: Text('Groceries')),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) => Scaffold(
            body: Text('GroceryDetail:${state.pathParameters['id']}'),
          ),
        ),
      ],
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
      path: '/recipes/:id',
      builder: (_, state) => Scaffold(
        body: Text('RecipeDetail:${state.pathParameters['id']}'),
      ),
    ),
  ],
);

typedef _StoresBuilder =
    Future<List<StoreModel>> Function(NearbyStoresQuery query);

Future<List<StoreModel>> _defaultStoresBuilder(NearbyStoresQuery query) async {
  return query.type == StoreType.grocery
      ? _defaultGroceries
      : _defaultRestaurants;
}

Widget _routerWrap({
  _StoresBuilder? storesBuilder,
  Future<List<RecipeModel>> Function()? recipesBuilder,
}) => ProviderScope(
  overrides: [
    nearbyStoresProvider.overrideWith(
      (ref, query) => (storesBuilder ?? _defaultStoresBuilder)(query),
    ),
    locationProvider.overrideWith(_FixedLocationNotifier.new),
    recipeServiceProvider.overrideWithValue(
      _FakeRecipeService(recipesBuilder ?? () async => const <RecipeModel>[]),
    ),
  ],
  child: MaterialApp.router(routerConfig: _testRouter()),
);

void main() {
  group('SearchScreen — discovery mode', () {
    testWidgets('renders real restaurant and grocery data', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();

      expect(find.text('Ocean Bowl'), findsOneWidget);

      // The Groceries section sits below the fold in this scroll view —
      // scroll down to bring it within the sliver cache extent, mirroring
      // the pattern established in home_feed_screen_test.dart.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Ocean Mart'), findsOneWidget);
    });

    testWidgets(
      'tapping a Near You restaurant card routes toward /restaurants/<id>',
      (tester) async {
        await tester.pumpWidget(_routerWrap());
        await tester.pumpAndSettle();

        // Ensure the card is scrolled into the hit-testable viewport before
        // tapping — the default 800x600 test surface doesn't fit the whole
        // discovery-mode scroll view.
        await tester.ensureVisible(find.text('Ocean Bowl'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ocean Bowl'));
        await tester.pumpAndSettle();

        expect(find.text('RestaurantDetail:r1'), findsOneWidget);
      },
    );

    testWidgets('tapping a grocery row routes toward /groceries/<id>', (
      tester,
    ) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ocean Mart'));
      await tester.pumpAndSettle();

      expect(find.text('GroceryDetail:g1'), findsOneWidget);
    });

    testWidgets('shows an error state when the restaurant fetch errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routerWrap(
          storesBuilder: (query) async {
            if (query.type == StoreType.restaurant) {
              throw Exception('network error');
            }
            return _defaultGroceries;
          },
        ),
      );
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
        await tester.pumpWidget(
          _routerWrap(
            storesBuilder: (query) async {
              if (query.type == StoreType.restaurant) {
                restaurantCalls++;
                if (shouldError) throw Exception('network error');
                return _defaultRestaurants;
              }
              groceryCalls++;
              return _defaultGroceries;
            },
          ),
        );
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
        expect(find.text('Ocean Bowl'), findsOneWidget);
      },
    );

    testWidgets('shows an error state when the grocery fetch errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routerWrap(
          storesBuilder: (query) async {
            if (query.type == StoreType.grocery) {
              throw Exception('network error');
            }
            return _defaultRestaurants;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
      'tapping Retry on a grocery fetch error re-fetches groceries',
      (tester) async {
        var restaurantCalls = 0;
        var groceryCalls = 0;
        var shouldError = true;
        await tester.pumpWidget(
          _routerWrap(
            storesBuilder: (query) async {
              if (query.type == StoreType.grocery) {
                groceryCalls++;
                if (shouldError) throw Exception('network error');
                return _defaultGroceries;
              }
              restaurantCalls++;
              return _defaultRestaurants;
            },
          ),
        );
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
        expect(find.text('Ocean Bowl'), findsOneWidget);
      },
    );
  });

  group('SearchScreen — search mode', () {
    testWidgets(
      'default Restaurants tab pill narrows results to restaurant-type stores only',
      (tester) async {
        await tester.pumpWidget(_routerWrap());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Ocean');
        await tester.pumpAndSettle();

        expect(find.text('Ocean Bowl'), findsOneWidget);
        expect(find.text('Ocean Mart'), findsNothing);
      },
    );

    testWidgets(
      'Groceries tab pill narrows results to grocery-type stores only',
      (tester) async {
        await tester.pumpWidget(_routerWrap());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Ocean');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Groceries'));
        await tester.pumpAndSettle();

        expect(find.text('Ocean Mart'), findsOneWidget);
        expect(find.text('Ocean Bowl'), findsNothing);
      },
    );

    testWidgets(
      'Recipes tab pill leaves both restaurant and grocery matches visible (out of scope, unfiltered)',
      (tester) async {
        await tester.pumpWidget(_routerWrap());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Ocean');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Recipes'));
        await tester.pumpAndSettle();

        expect(find.text('Ocean Bowl'), findsOneWidget);
        expect(find.text('Ocean Mart'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a restaurant search result card routes toward /restaurants/<id>',
      (tester) async {
        await tester.pumpWidget(_routerWrap());
        await tester.pumpAndSettle();

        // Lowercase query so the TextField's echoed text ("ocean bowl")
        // doesn't exact-match the result card's rendered name ("Ocean
        // Bowl") — avoids an ambiguous find.text() with two candidates.
        await tester.enterText(find.byType(TextField), 'ocean bowl');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Ocean Bowl'));
        await tester.pumpAndSettle();

        expect(find.text('RestaurantDetail:r1'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a grocery search result card routes toward /groceries/<id>',
      (tester) async {
        await tester.pumpWidget(_routerWrap());
        await tester.pumpAndSettle();

        // Lowercase query so the TextField's echoed text ("ocean mart")
        // doesn't exact-match the result card's rendered name ("Ocean
        // Mart") — avoids an ambiguous find.text() with two candidates.
        await tester.enterText(find.byType(TextField), 'ocean mart');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Groceries'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ocean Mart'));
        await tester.pumpAndSettle();

        expect(find.text('GroceryDetail:g1'), findsOneWidget);
      },
    );
  });

  group('SearchScreen — recipes teaser', () {
    testWidgets('renders real recipe cards from recipeListProvider', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routerWrap(recipesBuilder: () async => _defaultRecipes),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeCard), findsNWidgets(2));
      expect(find.text('Nasi Goreng Kampung'), findsOneWidget);
      expect(find.text('Mee Goreng Mamak'), findsOneWidget);
    });

    testWidgets(
      'tapping a recipe card in the teaser routes to /recipes/<id>',
      (tester) async {
        await tester.pumpWidget(
          _routerWrap(recipesBuilder: () async => _defaultRecipes),
        );
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -800),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Nasi Goreng Kampung'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Nasi Goreng Kampung'));
        await tester.pumpAndSettle();

        expect(find.text('RecipeDetail:rec1'), findsOneWidget);
      },
    );

    testWidgets('shows at most 5 recipes even when more are returned', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routerWrap(recipesBuilder: () async => _sixRecipes),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.byType(RecipeCard), findsNWidgets(5));
    });

    testWidgets('hides the recipes section when the fetch errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _routerWrap(
          recipesBuilder: () async => throw Exception('network error'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recipes to Try'), findsNothing);
      expect(find.byType(RecipeCard), findsNothing);
      // The rest of the page must still render — a broken teaser is
      // non-blocking, matching the restaurant/grocery fetches on this
      // same screen.
      expect(find.text('Browse by Category'), findsOneWidget);
    });

    testWidgets(
      'shows shimmer placeholders while the recipe fetch is in flight',
      (tester) async {
        final completer = Completer<List<RecipeModel>>();
        await tester.pumpWidget(
          _routerWrap(recipesBuilder: () => completer.future),
        );
        // Two pumps: the first lets initState's addPostFrameCallback fire
        // (which sets recipeLoadingProvider), the second reflects that
        // state change in the rebuilt tree. If this is still flaky, add a
        // third pump() here rather than switching to pumpAndSettle (which
        // would hang on the never-completing future).
        await tester.pump();
        await tester.pump();
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
        await tester.pump();

        expect(find.byType(Shimmer), findsWidgets);
        expect(find.byType(RecipeCard), findsNothing);

        completer.complete(_defaultRecipes);
        await tester.pumpAndSettle();

        expect(find.byType(RecipeCard), findsNWidgets(2));
      },
    );
  });
}
