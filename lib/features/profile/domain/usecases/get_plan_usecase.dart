import 'package:circulari/features/profile/domain/entities/user_plan.dart';
import 'package:circulari/features/profile/domain/repositories/profile_repository.dart';

class GetPlanUsecase {
  final ProfileRepository _repository;

  const GetPlanUsecase(this._repository);

  Future<UserPlan> call() => _repository.getPlan();
}
