import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/store_model.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/providers/store_providers.dart';

class StorePickerSheet extends ConsumerStatefulWidget {
  const StorePickerSheet({super.key});

  @override
  ConsumerState<StorePickerSheet> createState() => _StorePickerSheetState();
}

class _StorePickerSheetState extends ConsumerState<StorePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider).valueOrNull;
    final query = NearbyStoresQuery(
      lat: location?.latitude ?? 3.0731,
      lng: location?.longitude ?? 101.6069,
      radiusKm: 20,
      type: StoreType.grocery,
    );
    final storesAsync = ref.watch(nearbyStoresProvider(query));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a store', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.md),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search grocery stores...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: storesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Unable to load nearby stores.',
                      style: AppTypography.body2.copyWith(color: AppColors.error),
                    ),
                  ),
                  data: (stores) {
                    final filtered = _query.isEmpty
                        ? stores
                        : stores
                            .where((s) => s.businessName
                                .toLowerCase()
                                .contains(_query.toLowerCase()))
                            .toList();
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text('No stores found.', style: AppTypography.body2),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final store = filtered[index];
                        return ListTile(
                          title: Text(store.businessName),
                          subtitle: store.streetAddress.isNotEmpty
                              ? Text(store.streetAddress)
                              : null,
                          onTap: () => Navigator.of(context).pop(store),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
