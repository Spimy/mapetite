import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/store_model.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/providers/store_providers.dart';
import '../../../shared/widgets/location_denied_state.dart';

class MapExploreScreen extends ConsumerStatefulWidget {
  const MapExploreScreen({super.key});

  @override
  ConsumerState<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends ConsumerState<MapExploreScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  int _activeFilterIndex = 0;
  String? _selectedMarkerId;
  String _searchQuery = '';

  static const LatLng _defaultCenter = LatLng(3.0731, 101.6069);

  static const _filterLabels = ['All', 'Restaurants', 'Groceries'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StoreModel> _visibleMarkers(List<StoreModel> stores) {
    var markers = switch (_activeFilterIndex) {
      1 => stores.where((s) => s.merchantType == StoreType.restaurant).toList(),
      2 => stores.where((s) => s.merchantType == StoreType.grocery).toList(),
      _ => stores,
    };
    if (_searchQuery.isNotEmpty) {
      markers = markers
          .where((s) =>
              s.businessName.toLowerCase().contains(_searchQuery) ||
              (s.category?.toLowerCase().contains(_searchQuery) ?? false))
          .toList();
    }
    return markers;
  }

  StoreModel? _selectedMarker(List<StoreModel> stores) =>
      _selectedMarkerId != null
          ? stores.where((s) => s.id == _selectedMarkerId).firstOrNull
          : null;

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(locationProvider).valueOrNull;
    final permissionStatus =
        ref.watch(locationPermissionStatusProvider).valueOrNull;
    final isLocationDenied = loc == null &&
        (permissionStatus == LocationPermission.denied ||
            permissionStatus == LocationPermission.deniedForever);

    if (isLocationDenied) {
      return const Scaffold(
        body: SafeArea(child: LocationDeniedState()),
      );
    }

    final lat = loc?.latitude ?? _defaultCenter.latitude;
    final lng = loc?.longitude ?? _defaultCenter.longitude;
    // `type: null` fetches both restaurants and groceries in one request —
    // StoreService.getNearbyStores only filters by type when non-null.
    final query =
        NearbyStoresQuery(lat: lat, lng: lng, radiusKm: 10, type: null);

    // Surface a fetch error as a non-blocking SnackBar rather than hiding
    // the map — the map itself doesn't depend on this fetch to be usable.
    ref.listen(nearbyStoresProvider(query), (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load nearby stores.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final stores = ref.watch(nearbyStoresProvider(query)).when(
          data: (data) => data,
          loading: () => const <StoreModel>[],
          error: (_, _) => const <StoreModel>[],
        );
    final visibleMarkers = _visibleMarkers(stores);
    final selectedMarker = _selectedMarker(stores);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(lat, lng),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.mapetite.app',
              ),
              MarkerLayer(
                markers: visibleMarkers
                    .map((s) => Marker(
                          point: LatLng(s.latitude ?? 0, s.longitude ?? 0),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                _selectedMarkerId =
                                    _selectedMarkerId == s.id ? null : s.id),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: s.merchantType == StoreType.grocery
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                s.merchantType == StoreType.grocery
                                    ? Icons.eco_outlined
                                    : Icons.restaurant,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              // User location marker
              Consumer(
                builder: (context, ref, _) {
                  final loc = ref.watch(locationProvider).valueOrNull;
                  if (loc == null) return const SizedBox.shrink();
                  final userPos = LatLng(loc.latitude, loc.longitude);
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: userPos,
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsing halo
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Solid dot with white border
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Top overlays
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: _buildSearchBar(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  child: _buildFilterChips(),
                ),
              ],
            ),
          ),

          // My Location FAB
          Positioned(
            right: AppSpacing.lg,
            bottom: 170,
            child: _buildLocationFab(),
          ),

          // Mini bottom sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMiniSheet(context, stores),
          ),

          // Callout card — centered, max 300dp wide
          if (selectedMarker != null)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 210,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: _buildCalloutCard(context, selectedMarker),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.search,
              size: AppSpacing.iconSm, color: AppColors.neutral400),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTypography.body1,
              decoration: InputDecoration(
                hintText: 'Search nearby...',
                hintStyle: AppTypography.body1
                    .copyWith(color: AppColors.neutral400),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => _searchController.clear(),
              child: const Icon(Icons.close,
                  size: AppSpacing.iconSm, color: AppColors.neutral400),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filterLabels.length, (i) {
          final active = _activeFilterIndex == i;
          return Padding(
            padding: EdgeInsets.only(
                right: i < _filterLabels.length - 1 ? AppSpacing.sm : 0),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _filterLabels[i],
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

  Widget _buildLocationFab() {
    return GestureDetector(
      onTap: () {
        final loc = ref.read(locationProvider).valueOrNull;
        final center = loc != null
            ? LatLng(loc.latitude, loc.longitude)
            : _defaultCenter;
        _mapController.move(center, 15.0);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.my_location,
            size: AppSpacing.iconMd, color: AppColors.primary),
      ),
    );
  }

  Widget _buildMiniSheet(BuildContext context, List<StoreModel> stores) {
    final restaurants =
        stores.where((s) => s.merchantType == StoreType.restaurant).length;
    final groceries =
        stores.where((s) => s.merchantType == StoreType.grocery).length;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          Text(
            '$restaurants restaurants · $groceries grocery stores nearby',
            style: AppTypography.body1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: stores
                  .take(3)
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: _buildVenueMiniCard(context, s),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueMiniCard(BuildContext context, StoreModel s) {
    final distance = '${(s.distanceKm ?? 0).toStringAsFixed(1)} km';
    return GestureDetector(
      onTap: () {
        final route = s.merchantType == StoreType.grocery
            ? '/groceries/${s.id}'
            : '/restaurants/${s.id}';
        context.push(route);
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.businessName,
                style: AppTypography.headline3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (s.category != null) ...[
              const SizedBox(height: 2),
              Text(s.category!, style: AppTypography.body2),
            ],
            const SizedBox(height: 2),
            Text(distance,
                style:
                    AppTypography.caption.copyWith(color: AppColors.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalloutCard(BuildContext context, StoreModel s) {
    final isGrocery = s.merchantType == StoreType.grocery;
    final accentColor = isGrocery ? AppColors.secondary : AppColors.primary;
    final accentLight =
        isGrocery ? AppColors.secondaryLight : AppColors.primaryLight;
    final typeIcon = isGrocery ? Icons.eco_outlined : Icons.restaurant;
    final route =
        isGrocery ? '/groceries/${s.id}' : '/restaurants/${s.id}';
    final distance = '${(s.distanceKm ?? 0).toStringAsFixed(1)} km';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Coloured header strip ──────────────────────────────────────
            Container(
              height: 64,
              color: accentColor,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon,
                        size: AppSpacing.iconMd, color: AppColors.white),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.businessName,
                          style: AppTypography.headline3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (s.category != null)
                          Text(
                            s.category!,
                            style: AppTypography.body2.copyWith(
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedMarkerId = null),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined,
                            size: 12, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: AppTypography.caption
                              .copyWith(color: accentColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // View Details button — full width, prominent
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => context.push(route),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('View Details',
                              style: AppTypography.button),
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.arrow_forward,
                              size: 16, color: AppColors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
