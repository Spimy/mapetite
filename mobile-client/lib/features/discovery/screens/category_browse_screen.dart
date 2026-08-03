import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class CategoryBrowseScreen extends StatelessWidget {
  const CategoryBrowseScreen({super.key});

  static const List<List<String>> _categories = [
    ['🍛', 'Mamak', '/dine-in?cuisine=Mamak'],
    ['☕', 'Kopitiam', '/dine-in?cuisine=Kopitiam'],
    ['🥢', 'Chinese', '/dine-in?cuisine=Chinese'],
    ['🍚', 'Malaysian', '/dine-in?cuisine=Malaysian'],
    ['🍣', 'Japanese', '/dine-in?cuisine=Japanese'],
    ['🍜', 'Korean', '/dine-in?cuisine=Korean'],
    ['🛒', 'Groceries', '/groceries'],
    ['📖', 'My Recipes', '/cook-in'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('Browse Categories',
            style: AppTypography.headline1.copyWith(color: AppColors.primary)),
        leading: BackButton(
          color: AppColors.primary,
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 120,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat = _categories[i];
            return _CategoryCard(
              emoji: cat[0],
              label: cat[1],
              onTap: () => context.push(cat[2]),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: _hovered ? AppColors.primaryLight : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.emoji,
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(height: AppSpacing.sm),
                Text(widget.label,
                    style: AppTypography.headline3
                        .copyWith(color: AppColors.neutral)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
