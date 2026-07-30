import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../recipes/providers/selected_ingredients_provider.dart';
import '../../../shared/providers/location_provider.dart';

class GroceryMatchScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const GroceryMatchScreen({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<GroceryMatchScreen> createState() => _GroceryMatchScreenState();
}

class _GroceryMatchScreenState extends ConsumerState<GroceryMatchScreen> {
  static const double _defaultRadiusKm = 5.0;

  bool _isLoading = false;
  String? _errorMessage;
  String? _aiRecommendation;
  List<_GroceryStoreMatch> _stores = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoreMatches();
    });
  }

  Future<void> _loadStoreMatches() async {
    final location = ref.read(locationProvider).valueOrNull;
    final latitude = location?.latitude ?? 3.0731;
    final longitude = location?.longitude ?? 101.6069;
    final selectedItems = ref.read(selectedIngredientsProvider);
    final ingredientNames = selectedItems
        .map((item) => item.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (ingredientNames.isEmpty) {
      setState(() {
        _stores = [];
        _aiRecommendation = null;
        _errorMessage = 'Select at least one ingredient first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiClient.post(
        ApiEndpoints.ingredientSearchNearbyStores,
        data: {
          'ingredients': ingredientNames,
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': _defaultRadiusKm,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final storesJson = data['stores'] as List<dynamic>? ?? [];

      final stores = storesJson
          .whereType<Map<String, dynamic>>()
          .map(_GroceryStoreMatch.fromJson)
          .toList();

      stores.sort((a, b) {
        final coverageCompare = b.coverage.compareTo(a.coverage);

        if (coverageCompare != 0) {
          return coverageCompare;
        }

        final aDistance = a.distanceKm ?? double.infinity;
        final bDistance = b.distanceKm ?? double.infinity;

        return aDistance.compareTo(bDistance);
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _stores = stores;
        _aiRecommendation = data['ai_recommendation']?.toString();
        _errorMessage = stores.isEmpty ? 'No nearby store matches found.' : null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _stores = [];
        _aiRecommendation = null;
        _errorMessage =
            'Unable to find nearby stores. Please try again later.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openStoreDetails(BuildContext context, _GroceryStoreMatch store) {
    context.push('/groceries/${store.id}');
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedIngredientsProvider);
    final sortedStores = List<_GroceryStoreMatch>.from(_stores);

    final bestMatch = sortedStores.isNotEmpty ? sortedStores.first : null;
    final List<_GroceryStoreMatch> otherStores = sortedStores.length > 1
        ? sortedStores.skip(1).toList()
        : <_GroceryStoreMatch>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadStoreMatches,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectedItemsCard(selectedItems),
                const SizedBox(height: AppSpacing.lg),
                if (_isLoading)
                  const _LoadingState()
                else if (_errorMessage != null)
                  _ErrorState(
                    message: _errorMessage!,
                    onRetry: _loadStoreMatches,
                  )
                else ...[
                  if (_aiRecommendation != null &&
                      _aiRecommendation!.trim().isNotEmpty) ...[
                    _buildAiRecommendationCard(_aiRecommendation!),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (bestMatch != null) ...[
                    _buildBestMatchSection(context, bestMatch),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (otherStores.isNotEmpty)
                    _buildOtherStoresSection(context, otherStores),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/recipes/${widget.recipeId}');
          }
        },
      ),
      title: Text(
        'Find Grocery Store',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      centerTitle: true,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildSelectedItemsCard(List<SelectedIngredient> items) {
    final totalCost = items.fold(0.0, (sum, item) => sum + item.cost);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Shopping for ${items.length} ingredient${items.length != 1 ? 's' : ''}',
                  style: AppTypography.headline3,
                ),
              ),
              if (totalCost > 0)
                Text(
                  'RM ${totalCost.toStringAsFixed(2)}',
                  style: AppTypography.headline3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${item.name}  ·  ${item.quantity}',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                    if (item.cost > 0)
                      Text(
                        'RM ${item.cost.toStringAsFixed(2)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiRecommendationCard(String recommendation) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              recommendation,
              style: AppTypography.body2.copyWith(
                color: AppColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestMatchSection(
    BuildContext context,
    _GroceryStoreMatch store,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, size: 20, color: AppColors.success),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Best Match',
              style: AppTypography.headline3.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _StoreMatchCard(
          store: store,
          isBestMatch: true,
          onTap: () => _openStoreDetails(context, store),
        ),
      ],
    );
  }

  Widget _buildOtherStoresSection(
    BuildContext context,
    List<_GroceryStoreMatch> stores,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Nearby Stores',
          style: AppTypography.headline3.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...stores.map(
          (store) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _StoreMatchCard(
              store: store,
              onTap: () => _openStoreDetails(context, store),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Store Match Card ─────────────────────────────────────────────────────────

class _StoreMatchCard extends StatelessWidget {
  final _GroceryStoreMatch store;
  final bool isBestMatch;
  final VoidCallback onTap;

  const _StoreMatchCard({
    required this.store,
    required this.onTap,
    this.isBestMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final coverageColor = store.coverage >= 1
        ? AppColors.success
        : store.coverage >= 0.7
            ? AppColors.primary
            : AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isBestMatch ? AppColors.success : AppColors.border,
            width: isBestMatch ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StoreImage(imageUrl: store.imageUrl),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: AppTypography.headline2),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.neutral400,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            store.distanceLabel,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items Available',
                  style: AppTypography.label.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                Text(
                  '${store.availableCount} / ${store.totalCount} (${store.coveragePercent}%)',
                  style: AppTypography.label.copyWith(
                    color: coverageColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: LinearProgressIndicator(
                value: store.coverage.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: AppColors.neutral100,
                valueColor: AlwaysStoppedAnimation<Color>(coverageColor),
              ),
            ),
            if (store.matchedIngredients.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _IngredientMatchWrap(
                title: 'Available',
                ingredients: store.matchedIngredients,
                color: AppColors.success,
              ),
            ],
            if (store.missingIngredients.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _IngredientMatchWrap(
                title: 'Missing',
                ingredients: store.missingIngredients,
                color: AppColors.warning,
              ),
            ],
            if (isBestMatch) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'View Store Details',
                onPressed: onTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoreImage extends StatelessWidget {
  final String? imageUrl;

  const _StoreImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: 56,
        height: 56,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}

class _IngredientMatchWrap extends StatelessWidget {
  final String title;
  final List<String> ingredients;
  final Color color;

  const _IngredientMatchWrap({
    required this.title,
    required this.ingredients,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$title:',
          style: AppTypography.caption.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.w600,
          ),
        ),
        ...ingredients.map(
          (ingredient) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              ingredient,
              style: AppTypography.caption.copyWith(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── States ──────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Finding nearby stores...',
            style: AppTypography.body1.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTypography.body1.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

// ─── API Model ────────────────────────────────────────────────────────────────

class _GroceryStoreMatch {
  final String id;
  final String name;
  final String? imageUrl;
  final double? distanceKm;
  final List<String> matchedIngredients;
  final List<String> missingIngredients;
  final int matchScore;

  const _GroceryStoreMatch({
    required this.id,
    required this.name,
    this.imageUrl,
    this.distanceKm,
    required this.matchedIngredients,
    required this.missingIngredients,
    required this.matchScore,
  });

  factory _GroceryStoreMatch.fromJson(Map<String, dynamic> json) {
    return _GroceryStoreMatch(
      id: json['store_id']?.toString() ?? '',
      name: json['business_name']?.toString() ?? 'Unknown Store',
      imageUrl: json['image']?.toString(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      matchedIngredients:
          _stringListFromJson(json['matched_ingredients'] as List<dynamic>?),
      missingIngredients:
          _stringListFromJson(json['missing_ingredients'] as List<dynamic>?),
      matchScore: (json['match_score'] as num?)?.toInt() ?? 0,
    );
  }

  int get availableCount => matchedIngredients.length;

  int get totalCount {
    final count = matchedIngredients.length + missingIngredients.length;

    if (count == 0) {
      return matchScore > 0 ? matchScore : matchedIngredients.length;
    }

    return count;
  }

  double get coverage {
    if (totalCount <= 0) {
      return 0;
    }

    return availableCount / totalCount;
  }

  int get coveragePercent => (coverage * 100).round();

  String get distanceLabel {
    final distance = distanceKm;

    if (distance == null) {
      return 'Distance unavailable';
    }

    return '${distance.toStringAsFixed(1)} km away';
  }
}

List<String> _stringListFromJson(List<dynamic>? values) {
  if (values == null) {
    return [];
  }

  return values.map((value) => value.toString()).toList();
}