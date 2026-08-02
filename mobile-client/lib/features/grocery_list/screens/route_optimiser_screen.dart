import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../grocery/models/grocery_list_model.dart';
import '../../grocery/providers/grocery_list_provider.dart';
import '../../../shared/providers/location_provider.dart';

class _Stop {
  final String storeId;
  final String storeName;
  final double lat;
  final double lng;
  final List<GroceryListItem> items;

  _Stop({
    required this.storeId,
    required this.storeName,
    required this.lat,
    required this.lng,
    required this.items,
  });
}

/// Straight-line (haversine) distance in km — no external routing engine,
/// matching how the rest of the app already computes "distance" figures.
double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const distance = Distance();
  return distance.as(LengthUnit.Kilometer, LatLng(lat1, lng1), LatLng(lat2, lng2));
}

/// Orders stops by nearest-neighbor from the starting point.
List<_Stop> _orderStops(List<_Stop> stops, double startLat, double startLng) {
  final remaining = List<_Stop>.from(stops);
  final ordered = <_Stop>[];
  var currentLat = startLat;
  var currentLng = startLng;

  while (remaining.isNotEmpty) {
    remaining.sort((a, b) => _distanceKm(currentLat, currentLng, a.lat, a.lng)
        .compareTo(_distanceKm(currentLat, currentLng, b.lat, b.lng)));
    final next = remaining.removeAt(0);
    ordered.add(next);
    currentLat = next.lat;
    currentLng = next.lng;
  }

  return ordered;
}

class RouteOptimiserScreen extends ConsumerWidget {
  const RouteOptimiserScreen({super.key});

  List<_Stop> _buildStops(List<GroceryListItem> items) {
    final byStore = <String, List<GroceryListItem>>{};
    for (final item in items.where((i) => i.hasLinkedStore)) {
      byStore.putIfAbsent(item.storeId!, () => []).add(item);
    }
    return byStore.entries
        .map((e) => _Stop(
              storeId: e.key,
              storeName: e.value.first.storeName,
              lat: e.value.first.storeLatitude!,
              lng: e.value.first.storeLongitude!,
              items: e.value,
            ))
        .toList();
  }

  Future<void> _openGoogleMaps(
    BuildContext context,
    double startLat,
    double startLng,
    List<_Stop> orderedStops,
  ) async {
    if (orderedStops.isEmpty) return;
    final destination = orderedStops.last;
    final waypoints = orderedStops
        .take(orderedStops.length - 1)
        .map((s) => '${s.lat},${s.lng}')
        .join('|');

    final params = {
      'api': '1',
      'origin': '$startLat,$startLng',
      'destination': '${destination.lat},${destination.lng}',
      if (waypoints.isNotEmpty) 'waypoints': waypoints,
      'travelmode': 'walking',
    };
    final uri = Uri.https('www.google.com', '/maps/dir/', params);

    final launched =
        await canLaunchUrl(uri) && await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(groceryListProvider);
    final locationAsync = ref.watch(locationProvider);

    final allStops = _buildStops(items);
    final unassignedItems = items.where((i) => !i.hasLinkedStore).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: locationAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('Unable to get your location.')),
          data: (location) {
            if (location == null) {
              return const Center(child: Text('Enable location to plan a route.'));
            }
            final orderedStops =
                _orderStops(allStops, location.latitude, location.longitude);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMap(location.latitude, location.longitude, orderedStops),
                        _buildStopList(orderedStops),
                        if (unassignedItems.isNotEmpty)
                          _buildUnassignedSection(unassignedItems),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                _buildStickyFooter(
                  context,
                  location.latitude,
                  location.longitude,
                  orderedStops,
                ),
              ],
            );
          },
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

  Widget _buildMap(double lat, double lng, List<_Stop> stops) {
    return SizedBox(
      height: 260,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.mapetite.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lng),
                width: 32,
                height: 32,
                child: const Icon(Icons.my_location, color: AppColors.secondary),
              ),
              for (final stop in stops)
                Marker(
                  point: LatLng(stop.lat, stop.lng),
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 32),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopList(List<_Stop> stops) {
    if (stops.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text('No stores linked to your list yet.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: Column(
        children: [
          for (final entry in stops.asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildStopCard(entry.key + 1, entry.value),
            ),
        ],
      ),
    );
  }

  Widget _buildStopCard(int stopNumber, _Stop stop) {
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
                child: Text(stop.storeName, style: AppTypography.headline2),
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
                  'Stop $stopNumber',
                  style: AppTypography.label.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.border, height: AppSpacing.lg),
          Text(
            'TO PICK UP HERE',
            style: AppTypography.label.copyWith(color: AppColors.neutral600, letterSpacing: 0.8),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in stop.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(item.name, style: AppTypography.body1),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnassignedSection(List<GroceryListItem> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unassigned items', style: AppTypography.headline3),
            Text(
              'These items aren\'t linked to a store, so they can\'t be routed.',
              style: AppTypography.body2.copyWith(color: AppColors.neutral600),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(child: Text(item.name, style: AppTypography.body1)),
                    Text(
                      item.storeName,
                      style: AppTypography.body2.copyWith(color: AppColors.neutral600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter(
    BuildContext context,
    double lat,
    double lng,
    List<_Stop> orderedStops,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: 'Open in Google Maps',
          leadingIcon: Icons.map,
          onPressed: orderedStops.isEmpty
              ? null
              : () => _openGoogleMaps(context, lat, lng, orderedStops),
        ),
      ),
    );
  }
}
