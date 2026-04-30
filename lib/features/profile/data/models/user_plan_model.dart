import 'package:circulari/features/profile/domain/entities/user_plan.dart';
import 'package:circulari/features/profile/data/models/plan_usage_model.dart';

class UserPlanModel extends UserPlan {
  const UserPlanModel({
    required super.plan,
    required super.lists,
    required super.items,
    required super.aiCalls,
  });

  factory UserPlanModel.fromJson(Map<String, dynamic> json) {
    return UserPlanModel(
      plan: json['plan'] as String,
      lists: PlanUsageModel.fromJson(json['lists'] as Map<String, dynamic>),
      items: PlanUsageModel.fromJson(json['items'] as Map<String, dynamic>),
      aiCalls: PlanUsageModel.fromJson(json['aiCalls'] as Map<String, dynamic>),
    );
  }
}
