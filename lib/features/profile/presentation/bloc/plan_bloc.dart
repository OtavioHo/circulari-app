import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/profile/domain/usecases/get_plan_usecase.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_event.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final GetPlanUsecase _getPlan;

  PlanBloc(this._getPlan) : super(const PlanInitial()) {
    on<PlanLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    PlanLoadRequested event,
    Emitter<PlanState> emit,
  ) async {
    emit(const PlanLoading());
    try {
      final plan = await _getPlan();
      emit(PlanSuccess(plan));
    } on AppException catch (e) {
      emit(PlanFailure(e.message));
    }
  }
}
