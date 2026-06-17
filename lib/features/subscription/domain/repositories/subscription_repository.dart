import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';

abstract interface class SubscriptionRepository {
  /// The paid options available in the current RevenueCat offering.
  Future<List<SubscriptionOption>> getOptions();

  /// Purchases [packageId]; returns the highest active tier from the resulting
  /// CustomerInfo (optimistic, client-side view).
  Future<PlanTier> purchase(String packageId);

  /// Restores prior purchases; returns the highest active tier (free if none).
  Future<PlanTier> restore();
}
