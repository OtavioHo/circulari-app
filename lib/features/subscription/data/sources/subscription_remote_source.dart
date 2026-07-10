import 'package:flutter/foundation.dart';
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
        final period = _periodFrom(pkg);
        if (period == null) {
          // A paid tier whose cadence we can't resolve would silently vanish
          // from the paywall — log it rather than dropping it without a trace.
          debugPrint('SubscriptionRemoteSource: skipping package '
              '"${pkg.identifier}" (${pkg.storeProduct.identifier}) — '
              'unsupported subscriptionPeriod '
              '"${pkg.storeProduct.subscriptionPeriod}".');
          continue;
        }
        _packages[pkg.identifier] = pkg;
        options.add(SubscriptionOption(
          tier: tier,
          period: period,
          packageId: pkg.identifier,
          title: pkg.storeProduct.title,
          priceString: pkg.storeProduct.priceString,
        ));
      }
      // Sort by tier, then by cadence, so intra-tier order is deterministic
      // (List.sort is not stable).
      options.sort((a, b) {
        final byTier = a.tier.rank.compareTo(b.tier.rank);
        return byTier != 0 ? byTier : a.period.index.compareTo(b.period.index);
      });
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

  /// Resolves a package's paywall cadence.
  ///
  /// Prefers RevenueCat's [PackageType], which is reliable for the reserved
  /// `$rc_monthly`/`$rc_annual` slots even when the store omits the product's
  /// period (e.g. some iOS sandbox configs). Custom-identified packages report
  /// [PackageType.custom] and fall through to the product's ISO-8601
  /// [StoreProduct.subscriptionPeriod] — that fallback is what lets one
  /// offering carry a custom package per paid tier. Returns null (and the
  /// caller skips the package) for any cadence the paywall doesn't offer
  /// (weekly, quarterly, lifetime, …).
  BillingPeriod? _periodFrom(Package pkg) {
    switch (pkg.packageType) {
      case PackageType.monthly:
        return BillingPeriod.monthly;
      case PackageType.annual:
        return BillingPeriod.annual;
      default:
        break;
    }
    switch (pkg.storeProduct.subscriptionPeriod) {
      case 'P1M':
        return BillingPeriod.monthly;
      case 'P1Y':
      case 'P12M':
        return BillingPeriod.annual;
      default:
        return null;
    }
  }

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
