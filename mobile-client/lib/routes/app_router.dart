import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/discovery/screens/home_feed_screen.dart';
import '../features/profile/screens/dietary_preferences_screen.dart';
import '../features/profile/screens/budget_setup_screen.dart';
import '../features/profile/screens/health_goals_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/budget/screens/budget_overview_screen.dart';
import '../features/budget/screens/spending_analytics_screen.dart';
import '../features/budget/screens/transactions_screen.dart';
import '../features/recipes/screens/recipe_listing_screen.dart';
import '../features/recipes/screens/recipe_detail_screen.dart';
import '../features/grocery/screens/grocery_list_screen.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String map = '/map';
  static const String budget = '/budget';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String directions = '/directions';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipes/:id';
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
      // TODO: Notifications list — deal alerts, order updates, nearby events
      builder: (context, state) => const _WipScreen(label: 'Notifications'),
    ),
    GoRoute(
      path: AppRoutes.directions,
      // TODO: Map view with optimised route to selected restaurant / grocery
      builder: (context, state) => const _WipScreen(label: 'Get Directions'),
    ),
    GoRoute(
      path: AppRoutes.profile,
      // TODO: Full profile page — account details, dietary preferences, history
      builder: (context, state) => const _WipScreen(label: 'Profile'),
    ),
    GoRoute(
      path: AppRoutes.recipes,
      builder: (context, state) => const RecipeListingScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => RecipeDetailScreen(
            recipeId: state.pathParameters['id'] ?? '',
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.myList,
      builder: (context, state) => const GroceryListScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      // TODO: App preferences, notification settings, dietary filters
      builder: (context, state) => const _WipScreen(label: 'Settings'),
    ),
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
              builder: (context, state) =>
                  const _PlaceholderScreen(label: 'Explore'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.map,
              builder: (context, state) =>
                  const _PlaceholderScreen(label: 'Map'),
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
                  builder: (context, state) => SpendingAnalyticsScreen(
                    categoryFilter:
                        state.uri.queryParameters['category'],
                  ),
                ),
                GoRoute(
                  path: 'transactions',
                  builder: (context, state) => const TransactionsScreen(),
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

// ─── WIP Screen (top-level pages not yet built) ───────────────────────────────

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
        leading: const BackButton(color: AppColors.primary),
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

// ─── Placeholder Screens (bottom nav shell tabs not yet built) ────────────────

class _PlaceholderScreen extends StatelessWidget {
  final String label;

  const _PlaceholderScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '$label — coming soon',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
