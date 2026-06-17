import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';

sealed class PaywallState {
  const PaywallState();
}

final class PaywallInitial extends PaywallState {
  const PaywallInitial();
}

final class PaywallLoading extends PaywallState {
  const PaywallLoading();
}

/// Offering loaded. Purchase progress and one-shot signals live here so the
/// option list stays visible throughout the purchase flow.
final class PaywallReady extends PaywallState {
  final List<SubscriptionOption> options;

  /// True while a purchase/restore is in flight.
  final bool busy;

  /// Transient error to surface (non-cancel failures). One-shot.
  final String? error;

  /// Set once a purchase/restore succeeds with a paid tier. The page reacts to
  /// this by reconciling the plan and closing the paywall. One-shot.
  final PlanTier? purchasedTier;

  const PaywallReady(
    this.options, {
    this.busy = false,
    this.error,
    this.purchasedTier,
  });

  PaywallReady copyWith({
    bool? busy,
    String? error,
    PlanTier? purchasedTier,
    bool clearError = false,
    bool clearPurchased = false,
  }) =>
      PaywallReady(
        options,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
        purchasedTier: clearPurchased ? null : (purchasedTier ?? this.purchasedTier),
      );
}

final class PaywallFailure extends PaywallState {
  final String message;
  const PaywallFailure(this.message);
}
