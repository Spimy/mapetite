import '../../../../shared/widgets/pricing_badge.dart';
import '../home_feed_models.dart';

abstract class ExploreMocks {
  static const List<NearbyVenueSummary> nearbyVenues = [
    NearbyVenueSummary(
      id: 'ev_greenbowl',
      name: 'Green Bowl Oasis',
      cuisineType: 'Healthy • Salads',
      distanceKm: 0.3,
      rating: 4.8,
      isOpen: true,
      isHalal: true,
      isVegan: false,
      pricingBracket: 'RM 5-10',
      imageUrl: null,
    ),
    NearbyVenueSummary(
      id: 'ev_urbanroast',
      name: 'Urban Roast',
      cuisineType: 'Cafe • Pastries',
      distanceKm: 0.5,
      rating: 4.5,
      isOpen: true,
      isHalal: false,
      isVegan: false,
      pricingBracket: 'RM 10-20',
      imageUrl: null,
    ),
    NearbyVenueSummary(
      id: 'ev_plantbase',
      name: 'Plant Base',
      cuisineType: 'Burgers • Healthy',
      distanceKm: 0.8,
      rating: 4.9,
      isOpen: true,
      isHalal: false,
      isVegan: true,
      pricingBracket: 'RM 10-20',
      imageUrl: null,
    ),
  ];

  static PricingBracket pricingBracketFor(NearbyVenueSummary venue) {
    final b = venue.pricingBracket;
    if (b.contains('5-10') || b.contains('5–10')) return PricingBracket.budget;
    if (b.contains('20+')) return PricingBracket.premium;
    return PricingBracket.mid;
  }
}
