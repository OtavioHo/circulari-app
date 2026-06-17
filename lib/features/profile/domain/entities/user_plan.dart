import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/profile/domain/entities/plan_usage.dart';

class UserPlan {
  final String plan;
  final PlanUsage lists;
  final PlanUsage items;
  final PlanUsage aiCalls;

  const UserPlan({
    required this.plan,
    required this.lists,
    required this.items,
    required this.aiCalls,
  });

  PlanTier get tier => planTierFromString(plan);

  /// True when the user can still move up a tier (free or essencial).
  bool get canUpgrade => tier != PlanTier.pro;
}
