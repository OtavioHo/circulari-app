import 'package:circulari/features/home/domain/entities/dashboard_summary.dart';
import 'package:circulari/features/home/domain/repositories/home_repository.dart';
import 'package:circulari/features/home/data/sources/home_remote_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteSource _source;

  const HomeRepositoryImpl(this._source);

  @override
  Future<DashboardSummary> getDashboard() => _source.getDashboard();
}
