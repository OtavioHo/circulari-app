import 'package:flutter/services.dart';
// Hide RevenueCat's own SubscriptionOption — we use our domain entity of the
// same name for the paywall.
import 'package:purchases_flutter/purchases_flutter.dart' hide SubscriptionOption;

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/core/purchases/purchases_service.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';

class SubscriptionRemoteSource {
  final PurchasesService _purchases;

  /// Packages from the last [getOptions] call, keyed by package identifier, so
  /// [purchase] can resolve the native [Package] without re-fetching.
  final Map<String, Package> _packages = {};

  SubscriptionRemoteSource(this._purchases);

  Future<List<SubscriptionOption>> getOptions() async {
    try {
      final offerings = await _purchases.getOfferings();
      final offering = offerings?.current;
      if (offering == null) return const [];

      _packages.clear();
      final options = <SubscriptionOption>[];
      for (final pkg in offering.availablePackages) {
        final tier = planTierFromIdentifier(pkg.storeProduct.identifier) ??
            planTierFromIdentifier(pkg.identifier);
        if (tier == null || !tier.isPaid) continue;
        final period = _periodFrom(pkg.packageType);
        if (period == null) continue;
        _packages[pkg.identifier] = pkg;
        options.add(SubscriptionOption(
          tier: tier,
          period: period,
          packageId: pkg.identifier,
          title: pkg.storeProduct.title,
          priceString: pkg.storeProduct.priceString,
        ));
      }
      options.sort((a, b) => a.tier.rank.compareTo(b.tier.rank));
      return options;
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  Future<PlanTier> purchase(String packageId) async {
    final pkg = _packages[packageId];
    if (pkg == null) {
      throw const PurchaseException('Plano indisponível. Recarregue e tente novamente.');
    }
    try {
      final info = await _purchases.purchase(pkg);
      return _tierFromCustomerInfo(info);
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  Future<PlanTier> restore() async {
    try {
      final info = await _purchases.restore();
      return _tierFromCustomerInfo(info);
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  /// Maps a RevenueCat [PackageType] to our paywall cadence; returns null for
  /// package types the paywall doesn't offer (weekly, lifetime, custom, …).
  BillingPeriod? _periodFrom(PackageType type) => switch (type) {
        PackageType.monthly => BillingPeriod.monthly,
        PackageType.annual => BillingPeriod.annual,
        _ => null,
      };

  PlanTier _tierFromCustomerInfo(CustomerInfo info) {
    var best = PlanTier.free;
    for (final entitlementId in info.entitlements.active.keys) {
      final tier = planTierFromIdentifier(entitlementId);
      if (tier != null && tier.rank > best.rank) best = tier;
    }
    return best;
  }

  AppException _map(PlatformException e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.purchaseCancelledError) {
      return const PurchaseCancelledException();
    }
    return PurchaseException(e.message ?? 'Não foi possível concluir a operação.');
  }
}
