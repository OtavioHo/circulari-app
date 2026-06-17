sealed class PaywallEvent {
  const PaywallEvent();
}

final class PaywallLoadRequested extends PaywallEvent {
  const PaywallLoadRequested();
}

final class PaywallPurchaseRequested extends PaywallEvent {
  final String packageId;
  const PaywallPurchaseRequested(this.packageId);
}

final class PaywallRestoreRequested extends PaywallEvent {
  const PaywallRestoreRequested();
}
