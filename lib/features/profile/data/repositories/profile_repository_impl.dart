import '../../domain/entities/user_plan.dart';
import '../../domain/repositories/profile_repository.dart';
import '../sources/profile_remote_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteSource _source;

  const ProfileRepositoryImpl(this._source);

  @override
  Future<UserPlan> getPlan() => _source.getPlan();
}
