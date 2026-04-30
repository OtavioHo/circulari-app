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

  bool get isPremium => plan.toLowerCase() == 'premium';
}
