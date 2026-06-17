import 'package:circulari/core/models/plan_tier.dart';

/// A purchasable plan shown on the paywall, mapped from a RevenueCat package.
class SubscriptionOption {
  final PlanTier tier;

  /// RevenueCat package identifier — used to locate the package when purchasing.
  final String packageId;
  final String title;
  final String priceString;

  const SubscriptionOption({
    required this.tier,
    required this.packageId,
    required this.title,
    required this.priceString,
  });
}
