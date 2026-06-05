import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mapetite/features/discovery/models/home_feed_models.dart';
import 'package:mapetite/features/discovery/providers/home_feed_providers.dart';
import 'package:mapetite/features/discovery/screens/home_feed_screen.dart';
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
          path: '/profile/edit',
          builder: (_, _) => const Scaffold(body: Text('ProfileEdit')),
        ),
        GoRoute(
          path: '/groceries',
          builder: (_, _) => const Scaffold(body: Text('Groceries')),
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

Widget _routerWrap() => ProviderScope(
      overrides: [
        homeFeedProvider.overrideWith((_) async {}),
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

    testWidgets('HomeFeedScreen shows skeleton when provider is loading',
        (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeFeedProvider.overrideWith((ref) => completer.future),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => const HomeFeedScreen(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(HomeFeedSkeleton), findsOneWidget);
      completer.complete();
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
    testWidgets('renders greeting section', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
            RegExp(r'Good (morning|afternoon|evening)\.')),
        findsOneWidget,
      );
    });

    testWidgets("renders Today's Top Pick section header", (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(find.text("Today's Top Pick"), findsOneWidget);
    });

    testWidgets('renders Cook Something? section header', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(find.text('Cook Something?'), findsOneWidget);
    });

    testWidgets('renders Browse Recipes button', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(find.text('Browse Recipes'), findsOneWidget);
    });

    testWidgets('renders Nearby Options section header', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(find.text('Nearby Options'), findsOneWidget);
    });

    testWidgets('renders See All button', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('renders FAB', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB tap opens mode choice sheet', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('What do you want to do?'), findsOneWidget);
    });

    testWidgets('top pick card tap navigates to /dine-in', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('top_pick_card')));
      await tester.pumpAndSettle();
      expect(find.text('DineIn'), findsOneWidget);
    });

    testWidgets('Browse Recipes tap navigates to cook-in', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse Recipes'));
      await tester.pumpAndSettle();
      // /cook-in redirects to /recipes in real router; in test router it goes to CookIn
      expect(find.text('CookIn'), findsOneWidget);
    });

    testWidgets('See All tap navigates to /restaurants', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      // Scroll down to bring Nearby Options section into viewport
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('See All'));
      await tester.pumpAndSettle();
      expect(find.text('Restaurants'), findsOneWidget);
    });
  });

  group('HomeFeedScreen — drawer', () {
    testWidgets('renders AppDrawer when drawer is opened', (tester) async {
      await tester.pumpWidget(_routerWrap());
      await tester.pumpAndSettle();
      final scaffoldState =
          tester.state<ScaffoldState>(find.byType(Scaffold).first);
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();
      expect(find.byType(AppDrawer), findsOneWidget);
    });
  });
}
