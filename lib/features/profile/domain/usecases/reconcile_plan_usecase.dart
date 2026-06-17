import 'package:circulari/features/profile/domain/entities/user_plan.dart';
import 'package:circulari/features/profile/domain/repositories/profile_repository.dart';

class ReconcilePlanUsecase {
  final ProfileRepository _repository;

  const ReconcilePlanUsecase(this._repository);

  Future<UserPlan> call() => _repository.reconcilePlan();
}
