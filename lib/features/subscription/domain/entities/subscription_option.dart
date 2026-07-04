import 'package:circulari/core/models/plan_tier.dart';

/// Billing cadence of a purchasable option. Only the two cadences the paywall
/// toggles between are represented; other RevenueCat package types are ignored.
enum BillingPeriod { monthly, annual }

/// A purchasable plan shown on the paywall, mapped from a RevenueCat package.
class SubscriptionOption {
  final PlanTier tier;
  final BillingPeriod period;

  /// RevenueCat package identifier — used to locate the package when purchasing.
  final String packageId;
  final String title;
  final String priceString;

  const SubscriptionOption({
    required this.tier,
    required this.period,
    required this.packageId,
    required this.title,
    required this.priceString,
  });
}
