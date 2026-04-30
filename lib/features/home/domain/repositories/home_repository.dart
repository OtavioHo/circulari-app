import 'package:circulari/features/home/domain/entities/dashboard_summary.dart';

abstract interface class HomeRepository {
  Future<DashboardSummary> getDashboard();
}
