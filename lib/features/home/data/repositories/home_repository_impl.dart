import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../sources/home_remote_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteSource _source;

  const HomeRepositoryImpl(this._source);

  @override
  Future<DashboardSummary> getDashboard() => _source.getDashboard();
}
