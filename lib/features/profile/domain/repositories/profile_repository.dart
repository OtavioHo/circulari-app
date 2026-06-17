import 'package:circulari/features/profile/domain/entities/user_plan.dart';

abstract interface class ProfileRepository {
  Future<UserPlan> getPlan();

  /// Forces the backend to pull subscription state from RevenueCat now and
  /// returns the refreshed plan. Used right after a purchase/restore.
  Future<UserPlan> reconcilePlan();
}
