import '../../domain/entities/dashboard_summary.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardSuccess extends DashboardState {
  final DashboardSummary summary;

  const DashboardSuccess(this.summary);
}

final class DashboardFailure extends DashboardState {
  final String message;

  const DashboardFailure(this.message);
}
