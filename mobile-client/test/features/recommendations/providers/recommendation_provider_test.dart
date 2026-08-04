import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapetite/features/recommendations/providers/recommendation_provider.dart';
import 'package:mapetite/shared/models/store_model.dart';

const _testStore = StoreModel(
  id: 's-1',
  businessName: 'Test Restaurant',
  description: '',
  merchantType: StoreType.restaurant,
  halal: true,
  vegan: false,
  streetAddress: 'Jalan Test',
);

void main() {
  test('lastAcceptedRecommendationStoreProvider defaults to null', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(lastAcceptedRecommendationStoreProvider), isNull);
  });

  test('setting and clearing the notifier updates the provider value', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(lastAcceptedRecommendationStoreProvider.notifier).state =
        _testStore;
    expect(
      container.read(lastAcceptedRecommendationStoreProvider),
      _testStore,
    );

    container.read(lastAcceptedRecommendationStoreProvider.notifier).state =
        null;
    expect(container.read(lastAcceptedRecommendationStoreProvider), isNull);
  });
}
