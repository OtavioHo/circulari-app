import 'package:circulari/features/profile/domain/entities/user_plan.dart';
import 'package:circulari/features/profile/domain/repositories/profile_repository.dart';
import 'package:circulari/features/profile/data/sources/profile_remote_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteSource _source;

  const ProfileRepositoryImpl(this._source);

  @override
  Future<UserPlan> getPlan() => _source.getPlan();
}
