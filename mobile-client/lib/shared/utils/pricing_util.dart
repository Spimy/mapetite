import '../models/store_item_model.dart';
import '../widgets/pricing_badge.dart';

/// Computes a store's pricing bracket from its item prices, since the
/// backend does not provide one directly. Thresholds match the existing
/// PricingBadge labels (budget: RM5–10, mid: RM10–20, premium: RM20+).
PricingBracket computePricingBracket(List<StoreItemModel> items) {
  if (items.isEmpty) return PricingBracket.mid;

  final avgPrice =
      items.map((item) => item.price).reduce((a, b) => a + b) / items.length;

  if (avgPrice < 10) return PricingBracket.budget;
  if (avgPrice < 20) return PricingBracket.mid;
  return PricingBracket.premium;
}
