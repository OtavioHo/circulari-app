import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide SubscriptionOption;

import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/core/purchases/purchases_service.dart';
import 'package:circulari/features/subscription/data/sources/subscription_remote_source.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';

class MockPurchasesService extends Mock implements PurchasesService {}

class MockOfferings extends Mock implements Offerings {}

class MockOffering extends Mock implements Offering {}

class MockPackage extends Mock implements Package {}

class MockStoreProduct extends Mock implements StoreProduct {}

/// Builds a mock RevenueCat package with a *custom* identifier — the case the
/// paywall must now support so both paid tiers fit in one offering.
Package _package({
  required String packageId,
  required String productId,
  required String subscriptionPeriod,
}) {
  final product = MockStoreProduct();
  when(() => product.identifier).thenReturn(productId);
  when(() => product.subscriptionPeriod).thenReturn(subscriptionPeriod);
  when(() => product.title).thenReturn(productId);
  when(() => product.priceString).thenReturn('R\$ 0,00');

  final pkg = MockPackage();
  when(() => pkg.identifier).thenReturn(packageId);
  when(() => pkg.storeProduct).thenReturn(product);
  // Custom identifiers report PackageType.custom — the value that used to make
  // the old _periodFrom(packageType) drop the package entirely.
  when(() => pkg.packageType).thenReturn(PackageType.custom);
  return pkg;
}

void main() {
  late MockPurchasesService purchases;
  late SubscriptionRemoteSource source;

  setUp(() {
    purchases = MockPurchasesService();
    source = SubscriptionRemoteSource(purchases);
  });

  void stubOffering(List<Package> packages) {
    final offering = MockOffering();
    when(() => offering.availablePackages).thenReturn(packages);
    final offerings = MockOfferings();
    when(() => offerings.current).thenReturn(offering);
    when(() => purchases.getOfferings()).thenAnswer((_) async => offerings);
  }

  test('surfaces all four custom packages across both paid tiers', () async {
    stubOffering([
      _package(
        packageId: 'essencial_monthly',
        productId: 'circulari_essencial:essencial-monthly',
        subscriptionPeriod: 'P1M',
      ),
      _package(
        packageId: 'essencial_annual',
        productId: 'circulari_essencial:essencial-annual',
        subscriptionPeriod: 'P1Y',
      ),
      _package(
        packageId: 'pro_monthly',
        productId: 'circulari_pro:pro-monthly',
        subscriptionPeriod: 'P1M',
      ),
      _package(
        packageId: 'pro_annual',
        productId: 'circulari_pro:pro-annual',
        subscriptionPeriod: 'P12M',
      ),
    ]);

    final options = await source.getOptions();

    expect(options, hasLength(4));
    // Both paid tiers present, each with both cadences.
    expect(
      options
          .where((o) => o.tier == PlanTier.essencial)
          .map((o) => o.period)
          .toSet(),
      {BillingPeriod.monthly, BillingPeriod.annual},
    );
    expect(
      options.where((o) => o.tier == PlanTier.pro).map((o) => o.period).toSet(),
      {BillingPeriod.monthly, BillingPeriod.annual},
    );
    // Sorted so lower tiers come first.
    expect(options.first.tier, PlanTier.essencial);
    expect(options.last.tier, PlanTier.pro);
  });

  test('skips packages with a cadence the paywall does not offer', () async {
    stubOffering([
      _package(
        packageId: 'pro_weekly',
        productId: 'circulari_pro:pro-weekly',
        subscriptionPeriod: 'P1W',
      ),
      _package(
        packageId: 'pro_monthly',
        productId: 'circulari_pro:pro-monthly',
        subscriptionPeriod: 'P1M',
      ),
    ]);

    final options = await source.getOptions();

    expect(options, hasLength(1));
    expect(options.single.period, BillingPeriod.monthly);
  });

  test('returns empty list when there is no current offering', () async {
    final offerings = MockOfferings();
    when(() => offerings.current).thenReturn(null);
    when(() => purchases.getOfferings()).thenAnswer((_) async => offerings);

    expect(await source.getOptions(), isEmpty);
  });
}
