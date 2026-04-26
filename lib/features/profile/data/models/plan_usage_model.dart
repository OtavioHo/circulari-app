import '../../domain/entities/plan_usage.dart';

class PlanUsageModel extends PlanUsage {
  const PlanUsageModel({required super.used, required super.max});

  factory PlanUsageModel.fromJson(Map<String, dynamic> json) {
    return PlanUsageModel(
      used: json['used'] as int,
      max: json['max'] as int?,
    );
  }
}
