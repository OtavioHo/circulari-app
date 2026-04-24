import '../entities/dashboard_summary.dart';

abstract interface class HomeRepository {
  Future<DashboardSummary> getDashboard();
}
