import 'package:circulari/features/home/domain/entities/dashboard_summary.dart';
import 'package:circulari/features/home/domain/repositories/home_repository.dart';

class GetDashboardUsecase {
  final HomeRepository _repository;

  const GetDashboardUsecase(this._repository);

  Future<DashboardSummary> call() => _repository.getDashboard();
}
