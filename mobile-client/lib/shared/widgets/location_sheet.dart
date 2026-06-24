import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/app_colors.dart';
import '../providers/location_provider.dart';

void showLocationSheet(BuildContext context) {
  final container = ProviderScope.containerOf(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: const LocationSheet(),
    ),
  );
}

class LocationSheet extends ConsumerWidget {
  const LocationSheet({super.key});

  static const LatLng _defaultCenter = LatLng(3.0731, 101.6069);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationProvider);
    final city = ref.watch(locationCityProvider);

    final position = locationAsync.maybeWhen(
      data: (loc) =>
          loc != null ? LatLng(loc.latitude, loc.longitude) : _defaultCenter,
      orElse: () => _defaultCenter,
    );

    final hasRealPosition = locationAsync.maybeWhen(
      data: (loc) => loc != null,
      orElse: () => false,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: AppTypography.headline2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (hasRealPosition)
                        Text(
                          '${position.latitude.toStringAsFixed(4)}, '
                          '${position.longitude.toStringAsFixed(4)}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.neutral400),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close,
                      size: 20, color: AppColors.neutral400),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppSpacing.radiusXl),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: position,
                      initialZoom: 14.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.mapetite.app',
                      ),
                      if (hasRealPosition)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: position,
                              width: 48,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.white, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (hasRealPosition)
                    Positioned(
                      bottom: AppSpacing.md,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'You are here',
                                style: AppTypography.label
                                    .copyWith(color: AppColors.neutral),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
