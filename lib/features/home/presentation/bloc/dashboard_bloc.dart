import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/home/domain/usecases/get_dashboard_usecase.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_event.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUsecase _getDashboard;

  DashboardBloc(this._getDashboard) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final summary = await _getDashboard();
      emit(DashboardSuccess(summary));
    } on AppException catch (e) {
      emit(DashboardFailure(e.message));
    }
  }
}
