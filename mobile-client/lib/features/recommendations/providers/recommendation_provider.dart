import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/store_model.dart';
import '../services/recommendation_service.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService();
});

/// Holds the store from the most recently accepted restaurant recommendation,
/// so the next Add Transaction sheet can pre-select it. Session-only (no
/// persistence) and one-shot: cleared as soon as it's been read once.
final lastAcceptedRecommendationStoreProvider =
    StateProvider<StoreModel?>((ref) => null);