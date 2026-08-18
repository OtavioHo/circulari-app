import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/usecases/revalue_item_usecase.dart';

sealed class RevalueState {
  const RevalueState();
}

final class RevalueInitial extends RevalueState {
  const RevalueInitial();
}

final class RevalueLoading extends RevalueState {
  const RevalueLoading();
}

/// The re-analysis landed — shown as a PREVIEW. Nothing is written to the item
/// until the user explicitly applies it.
final class RevaluePreview extends RevalueState {
  final AiAnalysisResult result;
  const RevaluePreview(this.result);
}

final class RevalueFailure extends RevalueState {
  final String message;
  const RevalueFailure(this.message);
}

/// Blocked by the monthly AI quota — surfaces the paywall.
final class RevalueQuotaExceeded extends RevalueState {
  const RevalueQuotaExceeded();
}

class RevalueCubit extends Cubit<RevalueState> {
  final RevalueItemUsecase _revalue;

  RevalueCubit(this._revalue) : super(const RevalueInitial());

  Future<void> revalue({
    required String itemId,
    required String hint,
    String? parentAnalysisId,
  }) async {
    if (state is RevalueLoading) return;
    emit(const RevalueLoading());
    try {
      final result = await _revalue(
        itemId,
        hint: hint,
        parentAnalysisId: parentAnalysisId,
      );
      emit(RevaluePreview(result));
    } on PlanLimitException {
      emit(const RevalueQuotaExceeded());
    } on TierRequiredException {
      emit(const RevalueQuotaExceeded());
    } on RateLimitException {
      emit(const RevalueFailure('Muitas análises seguidas. Aguarde um instante.'));
    } on AppException catch (e) {
      emit(RevalueFailure(e.message));
    }
  }

  /// Back to the hint input (Descartar from the preview). The executed
  /// analysis stays counted.
  void reset() => emit(const RevalueInitial());
}
