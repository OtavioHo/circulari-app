sealed class PlanEvent {
  const PlanEvent();
}

final class PlanLoadRequested extends PlanEvent {
  const PlanLoadRequested();
}

/// Forces a backend reconcile (RevenueCat → users.tier) then refreshes usage.
/// Dispatched after a purchase/restore so the new tier shows immediately.
final class PlanReconcileRequested extends PlanEvent {
  const PlanReconcileRequested();
}
