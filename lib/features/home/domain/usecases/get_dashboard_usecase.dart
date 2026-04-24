import '../entities/dashboard_summary.dart';
import '../repositories/home_repository.dart';

class GetDashboardUsecase {
  final HomeRepository _repository;

  const GetDashboardUsecase(this._repository);

  Future<DashboardSummary> call() => _repository.getDashboard();
}
