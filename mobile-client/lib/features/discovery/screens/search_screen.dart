import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/pricing_badge.dart';
import '../../restaurants/models/mocks/restaurant_mocks.dart';
import '../../restaurants/models/restaurant_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  int _activeCategoryIndex = 0;
  final Set<String> _selectedDietary = {'Halal'};
  double _radius = 2.0;
  final List<String> _recentSearches = [
    'Nasi lemak near me',
    'Halal sushi',
    'Recipe mee goreng',
  ];

  static const _categories = ['Restaurants', 'Recipes', 'Groceries'];
  static const _dietaryOptions = ['Halal', 'Vegan', 'Vegetarian'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isSearching => _searchCtrl.text.trim().isNotEmpty;

  List<RestaurantModel> get _filteredResults {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return RestaurantMocks.nearbyRestaurants
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisineType.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStickyHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryTabs(),
                    if (!_isSearching) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildDietarySection(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRadiusCard(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildRecentSearchesSection(),
                    ] else ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildResultsSection(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: AppTypography.display.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.lg),
                const Icon(Icons.search,
                    size: AppSpacing.iconSm, color: AppColors.neutral400),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppTypography.body1,
                    decoration: InputDecoration(
                      hintText:
                          'Search restaurants, recipes, grocery stores...',
                      hintStyle: AppTypography.body1
                          .copyWith(color: AppColors.neutral400),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.tune,
                    size: AppSpacing.iconMd, color: AppColors.primary),
                const SizedBox(width: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (i) {
          final active = _activeCategoryIndex == i;
          return Padding(
            padding: EdgeInsets.only(
                right: i < _categories.length - 1 ? AppSpacing.sm : 0),
            child: GestureDetector(
              onTap: () => setState(() => _activeCategoryIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                      color: active ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  _categories[i],
                  style: AppTypography.label.copyWith(
                    color: active ? AppColors.white : AppColors.neutral,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDietarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dietary Preference',
            style: AppTypography.headline3
                .copyWith(color: AppColors.neutral700)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _dietaryOptions.map((opt) {
            final sel = _selectedDietary.contains(opt);
            return GestureDetector(
              onTap: () => setState(() {
                sel
                    ? _selectedDietary.remove(opt)
                    : _selectedDietary.add(opt);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sel) ...[
                      const Icon(Icons.check,
                          size: 13, color: AppColors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      opt,
                      style: AppTypography.label.copyWith(
                        color: sel ? AppColors.white : AppColors.neutral,
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadiusCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Search Area', style: AppTypography.headline3),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'Within ${_radius.toStringAsFixed(1)} km',
                  style: AppTypography.label
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: const _AppSliderThumb(),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.neutral100,
              thumbColor: AppColors.white,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: _radius,
              min: 0.5,
              max: 10.0,
              onChanged: (v) => setState(() => _radius = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nearby',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral400)),
              Text('Citywide',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.neutral400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recent Searches', style: AppTypography.headline2),
            const Spacer(),
            if (_recentSearches.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _recentSearches.clear()),
                child: Text('CLEAR',
                    style: AppTypography.label
                        .copyWith(color: AppColors.neutral600)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_recentSearches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: Text('No recent searches', style: AppTypography.body2),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List.generate(_recentSearches.length, (i) {
                final q = _recentSearches[i];
                return _buildRecentRow(q, i < _recentSearches.length - 1);
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentRow(String query, bool showDivider) {
    return Container(
      height: 48,
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1)))
          : null,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.history,
              size: AppSpacing.iconSm, color: AppColors.neutral400),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _searchCtrl.text = query;
                _searchCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: query.length));
              }),
              child: Text(query, style: AppTypography.body1),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                size: AppSpacing.iconSm, color: AppColors.neutral400),
            onPressed: () => setState(() => _recentSearches.remove(query)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final results = _filteredResults;
    if (results.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off,
        title: "No results for '${_searchCtrl.text.trim()}'",
        description: 'Try clearing some filters or expanding your radius.',
        ctaLabel: 'Clear Filters',
        onCta: () => setState(() {
          _searchCtrl.clear();
          _selectedDietary.clear();
          _radius = 2.0;
        }),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: results
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildResultCard(r),
              ))
          .toList(),
    );
  }

  Widget _buildResultCard(RestaurantModel r) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.restaurant,
                size: 32, color: AppColors.neutral400),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: AppTypography.headline3),
                const SizedBox(height: 2),
                Text(r.cuisineType, style: AppTypography.body2),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.neutral400),
                        const SizedBox(width: 2),
                        Text('${r.distanceKm.toStringAsFixed(1)} km',
                            style: AppTypography.caption),
                      ],
                    ),
                    ...r.dietaryTags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull),
                          ),
                          child: Text(tag,
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.primary)),
                        )),
                    PricingBadge(bracket: r.pricingBracket),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppSliderThumb extends SliderComponentShape {
  const _AppSliderThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, 12, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
