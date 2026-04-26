import '../../domain/entities/user_plan.dart';

sealed class PlanState {
  const PlanState();
}

final class PlanInitial extends PlanState {
  const PlanInitial();
}

final class PlanLoading extends PlanState {
  const PlanLoading();
}

final class PlanSuccess extends PlanState {
  final UserPlan plan;
  const PlanSuccess(this.plan);
}

final class PlanFailure extends PlanState {
  final String message;
  const PlanFailure(this.message);
}
