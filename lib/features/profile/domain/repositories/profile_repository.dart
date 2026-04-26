import '../entities/user_plan.dart';

abstract interface class ProfileRepository {
  Future<UserPlan> getPlan();
}
