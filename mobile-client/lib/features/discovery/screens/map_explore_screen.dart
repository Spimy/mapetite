import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';

class _MarkerData {
  final String id;
  final String name;
  final String type;
  final String distance;
  final LatLng pos;
  final bool isGrocery;

  const _MarkerData({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.pos,
    this.isGrocery = false,
  });
}

class MapExploreScreen extends StatefulWidget {
  const MapExploreScreen({super.key});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  final MapController _mapController = MapController();
  int _activeFilterIndex = 0;
  String? _selectedMarkerId;

  static const LatLng _center = LatLng(3.0731, 101.6069);

  static const List<_MarkerData> _allMarkers = [
    _MarkerData(
      id: 'r1',
      name: 'Restoran Nasi Kandar Ali',
      type: 'Mamak',
      distance: '0.4 km',
      pos: LatLng(3.0738, 101.6055),
    ),
    _MarkerData(
      id: 'r2',
      name: 'Kopitiam Old Town',
      type: 'Kopitiam',
      distance: '0.7 km',
      pos: LatLng(3.0745, 101.6078),
    ),
    _MarkerData(
      id: 'r3',
      name: 'Sushi King Sunway',
      type: 'Japanese',
      distance: '1.2 km',
      pos: LatLng(3.0718, 101.6082),
    ),
    _MarkerData(
      id: 'r4',
      name: 'Mamak Corner',
      type: 'Mamak',
      distance: '0.6 km',
      pos: LatLng(3.0722, 101.6048),
    ),
    _MarkerData(
      id: 'r5',
      name: 'The Grill House',
      type: 'Western',
      distance: '0.9 km',
      pos: LatLng(3.0752, 101.6092),
    ),
    _MarkerData(
      id: 'g1',
      name: 'Jaya Grocer',
      type: 'Grocery',
      distance: '0.5 km',
      pos: LatLng(3.0726, 101.6063),
      isGrocery: true,
    ),
    _MarkerData(
      id: 'g2',
      name: '99 Speedmart',
      type: 'Grocery',
      distance: '0.3 km',
      pos: LatLng(3.0736, 101.6043),
      isGrocery: true,
    ),
  ];

  static const _filterLabels = ['All', 'Restaurants', 'Groceries'];

  List<_MarkerData> get _visibleMarkers {
    switch (_activeFilterIndex) {
      case 1:
        return _allMarkers.where((m) => !m.isGrocery).toList();
      case 2:
        return _allMarkers.where((m) => m.isGrocery).toList();
      default:
        return _allMarkers;
    }
  }

  _MarkerData? get _selectedMarker => _selectedMarkerId != null
      ? _allMarkers.where((m) => m.id == _selectedMarkerId).firstOrNull
      : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _center,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.mapetite.app',
              ),
              MarkerLayer(
                markers: _visibleMarkers
                    .map((m) => Marker(
                          point: m.pos,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                _selectedMarkerId =
                                    _selectedMarkerId == m.id ? null : m.id),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: m.isGrocery
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
                                m.isGrocery
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
            child: _buildMiniSheet(context),
          ),

          // Callout card — centered, max 300dp wide
          if (_selectedMarker != null)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 210,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: _buildCalloutCard(context, _selectedMarker!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/explore'),
      child: Container(
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
            Text('Search nearby...',
                style: AppTypography.body1
                    .copyWith(color: AppColors.neutral400)),
          ],
        ),
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
      onTap: () => _mapController.move(_center, 15.0),
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

  Widget _buildMiniSheet(BuildContext context) {
    final restaurants = _allMarkers.where((m) => !m.isGrocery).length;
    final groceries = _allMarkers.where((m) => m.isGrocery).length;

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
              children: _allMarkers
                  .take(3)
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: _buildVenueMiniCard(context, m),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueMiniCard(BuildContext context, _MarkerData m) {
    return GestureDetector(
      onTap: () {
        final route =
            m.isGrocery ? '/groceries/${m.id}' : '/restaurants/${m.id}';
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
            Text(m.name,
                style: AppTypography.headline3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(m.type, style: AppTypography.body2),
            const SizedBox(height: 2),
            Text(m.distance,
                style:
                    AppTypography.caption.copyWith(color: AppColors.neutral600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalloutCard(BuildContext context, _MarkerData m) {
    final accentColor = m.isGrocery ? AppColors.secondary : AppColors.primary;
    final accentLight =
        m.isGrocery ? AppColors.secondaryLight : AppColors.primaryLight;
    final typeIcon = m.isGrocery ? Icons.eco_outlined : Icons.restaurant;
    final route =
        m.isGrocery ? '/groceries/${m.id}' : '/restaurants/${m.id}';

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
                          m.name,
                          style: AppTypography.headline3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          m.type,
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
                          m.distance,
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
