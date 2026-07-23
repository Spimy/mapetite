import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/discovery/screens/home_feed_screen.dart';
import '../features/discovery/screens/search_screen.dart';
import '../features/discovery/screens/category_browse_screen.dart';
import '../features/discovery/screens/map_explore_screen.dart';
import '../features/profile/screens/dietary_preferences_screen.dart';
import '../features/profile/screens/budget_setup_screen.dart';
import '../features/profile/screens/health_goals_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/budget/screens/budget_overview_screen.dart';
import '../features/budget/screens/spending_analytics_screen.dart';
import '../features/budget/screens/transactions_screen.dart';
import '../features/recipes/screens/recipe_listing_screen.dart';
import '../features/recipes/screens/recipe_detail_screen.dart';
import '../features/recipes/screens/create_recipe_screen.dart';
import '../features/grocery_list/screens/grocery_list_screen.dart' as sl;
import '../features/grocery_list/screens/route_optimiser_screen.dart';
import '../features/groceries/screens/grocery_listing_screen.dart';
import '../features/groceries/screens/grocery_match_screen.dart';
import '../features/groceries/screens/grocery_store_detail_screen.dart';
import '../features/restaurants/screens/restaurant_listing_screen.dart';
import '../features/restaurants/screens/restaurant_detail_screen.dart';
import '../features/notifications/screens/notification_centre_screen.dart';
import '../features/notifications/screens/notification_settings_screen.dart';
import '../features/settings/screens/app_settings_screen.dart';
import '../features/settings/screens/about_screen.dart';
import '../shared/screens/web_placeholder_screen.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String categories = '/categories';
  static const String map = '/map';
  static const String budget = '/budget';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String directions = '/directions';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipes/:id';
  static const String recipeCreate = '/recipes/create';
  static const String myList = '/my-list';
  static const String settings = '/settings';

  // Profile setup wizard — outside the shell (no bottom nav)
  static const String profileSetup = '/profile/setup';
  static const String profileDietary = '/profile/dietary';
  static const String profileBudgetSetup = '/profile/budget-setup';
  static const String profileHealthGoals = '/profile/health-goals';
  static const String profileEdit = '/profile/edit';

  // Budget sub-screens (pushed over shell)
  static const String budgetAnalytics = '/budget/analytics';
  static const String budgetTransactions = '/budget/transactions';

  static const String dineIn = '/dine-in';
  static const String cookIn = '/cook-in';
  static const String restaurants = '/restaurants';
  static const String restaurantDetail = '/restaurants/:id';
  static const String groceries = '/groceries';
  static const String list = '/list';
  static const String listRoute = '/list/route';

  static const String about = '/about';
  static const String aboutTerms = '/about/terms';
  static const String aboutPrivacy = '/about/privacy';
  static const String aboutLicences = '/about/licences';
  static const String settingsNotifications = '/settings/notifications';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ── Profile setup wizard (no shell / bottom nav) ──────────────────────
    GoRoute(
      path: AppRoutes.profileSetup,
      redirect: (_, _) => AppRoutes.profileDietary,
    ),
    GoRoute(
      path: AppRoutes.profileDietary,
      builder: (context, state) => DietaryPreferencesScreen(
        isEditMode: state.uri.queryParameters['mode'] == 'edit',
      ),
    ),
    GoRoute(
      path: AppRoutes.profileBudgetSetup,
      builder: (context, state) => BudgetSetupScreen(
        isEditMode: state.uri.queryParameters['mode'] == 'edit',
      ),
    ),
    GoRoute(
      path: AppRoutes.profileHealthGoals,
      builder: (context, state) => HealthGoalsScreen(
        isEditMode: state.uri.queryParameters['mode'] == 'edit',
      ),
    ),
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => const EditProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationCentreScreen(),
    ),
    GoRoute(
      path: AppRoutes.settingsNotifications,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.directions,
      builder: (context, state) => const _WipScreen(label: 'Get Directions'),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const _WipScreen(label: 'Profile'),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutScreen(),
      routes: [
        GoRoute(
          path: 'terms',
          builder: (context, state) =>
              const WebPlaceholderScreen(title: 'Terms of Service'),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) =>
              const WebPlaceholderScreen(title: 'Privacy Policy'),
        ),
        GoRoute(
          path: 'licences',
          builder: (context, state) =>
              const WebPlaceholderScreen(title: 'Open Source Licences'),
        ),
      ],
    ),

    // ── Category browse (accessible from explore & drawer) ───────────────
    GoRoute(
      path: AppRoutes.categories,
      builder: (context, state) => const CategoryBrowseScreen(),
    ),

    // ── Recipes (cook-in flow) ────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.recipes,
      builder: (context, state) => const RecipeListingScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateRecipeScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => RecipeDetailScreen(
            recipeId: state.pathParameters['id'] ?? '',
          ),
          routes: [
            GoRoute(
              path: 'match',
              builder: (context, state) => GroceryMatchScreen(
                recipeId: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.myList,
      redirect: (_, _) => AppRoutes.list,
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const AppSettingsScreen(),
    ),

    // ── Dine-in flow ──────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.dineIn,
      builder: (context, state) => const RestaurantListingScreen(),
    ),
    GoRoute(
      path: AppRoutes.cookIn,
      redirect: (_, _) => AppRoutes.recipes,
    ),
    GoRoute(
      path: AppRoutes.restaurants,
      builder: (context, state) => const RestaurantListingScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => RestaurantDetailScreen(
            restaurantId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    ),

    // ── Grocery stores ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.groceries,
      builder: (context, state) => const GroceryListingScreen(),
      routes: [
        GoRoute(
          path: 'match',
          builder: (context, state) => const GroceryMatchScreen(recipeId: ''),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => GroceryStoreDetailScreen(
            storeId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    ),

    // ── Shopping list flow ────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.listRoute,
      builder: (context, state) => const RouteOptimiserScreen(),
    ),
    GoRoute(
      path: AppRoutes.list,
      builder: (context, state) => const sl.ShoppingListScreen(),
    ),

    // ── Main shell (bottom nav) ───────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeFeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) => const MapExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.budget,
              builder: (context, state) => const BudgetOverviewScreen(),
              routes: [
                GoRoute(
                  path: 'analytics',
                  builder: (context, state) =>
                      const SpendingAnalyticsScreen(),
                ),
                GoRoute(
                  path: 'transactions',
                  builder: (context, state) =>
                      const TransactionsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// ─── Main Shell ───────────────────────────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Budget',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── WIP Screen ───────────────────────────────────────────────────────────────

class _WipScreen extends StatelessWidget {
  final String label;

  const _WipScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(label),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral,
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              '$label — work in progress',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.neutral600),
            ),
          ],
        ),
      ),
    );
  }
}
