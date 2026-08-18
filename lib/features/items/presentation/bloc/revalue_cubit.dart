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

  // Correction chain: after a preview, the NEXT correction's parent is the
  // analysis just produced — not the item's original one. Re-sending the
  // original would refine the stale identification and re-claim a retry the
  // backend already spent. Kept across reset() (Descartar) on purpose.
  String? _parentAnalysisId;

  RevalueCubit(this._revalue) : super(const RevalueInitial());

  // The sheet-owned cubit can be closed while the up-to-90s request is in
  // flight (drag/back/close); emitting then would throw StateError.
  void _safeEmit(RevalueState state) {
    if (!isClosed) emit(state);
  }

  Future<void> revalue({
    required String itemId,
    required String hint,
    String? parentAnalysisId,
  }) async {
    if (state is RevalueLoading) return;
    _parentAnalysisId ??= parentAnalysisId;
    emit(const RevalueLoading());
    try {
      final result = await _revalue(
        itemId,
        hint: hint,
        parentAnalysisId: _parentAnalysisId,
      );
      _parentAnalysisId = result.analysisId ?? _parentAnalysisId;
      _safeEmit(RevaluePreview(result));
    } on QuotaException {
      _safeEmit(const RevalueQuotaExceeded());
    } on RateLimitException {
      _safeEmit(const RevalueFailure(kAiRateLimitMessage));
    } on AppException catch (e) {
      _safeEmit(RevalueFailure(e.message));
    }
  }

  /// Back to the hint input (Descartar from the preview). The executed
  /// analysis stays counted, and the correction chain is preserved.
  void reset() => _safeEmit(const RevalueInitial());
}
