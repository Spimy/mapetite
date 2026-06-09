import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';

class RouteOptimiserScreen extends StatefulWidget {
  const RouteOptimiserScreen({super.key});

  @override
  State<RouteOptimiserScreen> createState() => _RouteOptimiserScreenState();
}

class _RouteOptimiserScreenState extends State<RouteOptimiserScreen> {
  bool _isWalking = true;
  bool _stop3Expanded = false;

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/Current+Location/Jaya+Grocer+Bangsar/Village+Grocer+Bangsar',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to open Google Maps',
              style: AppTypography.body1.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMapArea(),
                    _buildStopList(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(),
          ],
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
            context.go('/list');
          }
        },
      ),
      title: Text(
        'Shopping Route',
        style: AppTypography.headline1.copyWith(color: AppColors.primary),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildMapArea() {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 260,
            color: AppColors.neutral100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: AppColors.neutral400,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Map view coming soon',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Route: Home → Jaya Grocer → Village Grocer',
                  style: AppTypography.body2,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: _buildMapOverlayCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOverlayCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated: 22 min', style: AppTypography.headline3),
              const SizedBox(height: AppSpacing.xxs),
              Text('1.4 km · ${_isWalking ? 'Walking' : 'Driving'} route',
                  style: AppTypography.body2),
            ],
          ),
          const Spacer(),
          _buildTransitToggle(),
        ],
      ),
    );
  }

  Widget _buildTransitToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.directions_walk,
            isActive: _isWalking,
            onTap: () => setState(() => _isWalking = true),
          ),
          const SizedBox(width: AppSpacing.xs),
          _ToggleButton(
            icon: Icons.directions_car,
            isActive: !_isWalking,
            onTap: () => setState(() => _isWalking = false),
          ),
        ],
      ),
    );
  }

  Widget _buildStopList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStopLine(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              children: [
                _buildStop1(),
                const SizedBox(height: AppSpacing.md),
                _buildStop2(),
                const SizedBox(height: AppSpacing.md),
                _buildStop3(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopLine() {
    return Column(
      children: [
        const _StopCircle(number: '1'),
        Container(
          width: 2,
          height: 100,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
        const _StopCircle(number: '2'),
        Container(
          width: 2,
          height: _stop3Expanded ? 260 : 80,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
        const _StopCircle(number: '3'),
      ],
    );
  }

  Widget _buildStop1() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Location', style: AppTypography.headline3),
              Text('Starting point', style: AppTypography.body2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStop2() {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jaya Grocer', style: AppTypography.headline2),
                    Text('750m away', style: AppTypography.body2),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  'Stop 1',
                  style: AppTypography.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: AppSpacing.lg),
          Text(
            'TO PICK UP HERE',
            style: AppTypography.label.copyWith(
              color: AppColors.neutral600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._stop2Items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(item, style: AppTypography.body1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _stop2Items = [
    'Cooked rice',
    'Anchovies (Ikan Bilis)',
    'Shrimp Paste (Belacan)',
  ];

  Widget _buildStop3() {
    return GestureDetector(
      onTap: () => setState(() => _stop3Expanded = !_stop3Expanded),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Village Grocer', style: AppTypography.headline2),
                      Text(
                        'Final stop · 650m further',
                        style: AppTypography.body2,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '2 items',
                    style: AppTypography.label.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  _stop3Expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.neutral400,
                ),
              ],
            ),
            if (_stop3Expanded) ...[
              const Divider(color: AppColors.border, height: AppSpacing.lg),
              Text(
                'TO PICK UP HERE',
                style: AppTypography.label.copyWith(
                  color: AppColors.neutral600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._stop3Items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(item, style: AppTypography.body1),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _stop3Items = [
    'Egg',
    'Water Spinach (Kangkung)',
  ];

  Widget _buildStickyFooter() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: 'Open in Google Maps',
          leadingIcon: Icons.map,
          onPressed: _openGoogleMaps,
        ),
      ),
    );
  }
}

// ─── Stop Circle ──────────────────────────────────────────────────────────────

class _StopCircle extends StatelessWidget {
  final String number;

  const _StopCircle({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: AppTypography.label.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Toggle Button ────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primary : AppColors.neutral400,
        ),
      ),
    );
  }
}
