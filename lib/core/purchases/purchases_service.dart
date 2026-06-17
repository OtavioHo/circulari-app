import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Thin wrapper around the RevenueCat SDK.
///
/// Holds all RevenueCat calls behind a small surface so the rest of the app
/// never imports `purchases_flutter` directly. The **public** SDK keys are
/// injected at build time via `--dart-define` and are safe to ship; the server
/// secrets (REST key, webhook secret) live only on the backend.
///
/// Every method is a no-op when the SDK could not be configured (web, or no key
/// supplied) so the app keeps working without subscriptions in those cases.
class PurchasesService {
  static const _iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');

  bool _configured = false;
  bool get isConfigured => _configured;

  Future<void> configure() async {
    if (kIsWeb) return; // RevenueCat purchases are mobile-only here.
    final apiKey = _apiKeyForPlatform();
    if (apiKey.isEmpty) {
      debugPrint('PurchasesService: no RevenueCat key for this platform; subscriptions disabled.');
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (e) {
      debugPrint('PurchasesService.configure failed: $e');
    }
  }

  String _apiKeyForPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _iosKey;
      case TargetPlatform.android:
        return _androidKey;
      default:
        return '';
    }
  }

  /// Binds RevenueCat's app_user_id to the backend user id so webhooks resolve
  /// to the right account. Must run before any purchase is possible.
  Future<void> login(String userId) async {
    if (!_configured) return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('PurchasesService.login failed: $e');
    }
  }

  Future<void> logout() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      // logOut throws for anonymous users — harmless here.
      debugPrint('PurchasesService.logout failed: $e');
    }
  }

  Future<Offerings?> getOfferings() async {
    if (!_configured) return null;
    return Purchases.getOfferings();
  }

  Future<CustomerInfo> purchase(Package package) {
    return Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restore() {
    return Purchases.restorePurchases();
  }

  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!_configured) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) {
    if (!_configured) return;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }
}
