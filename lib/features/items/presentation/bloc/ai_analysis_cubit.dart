import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/bloc/safe_emit_mixin.dart';
import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/usecases/analyze_item_image_usecase.dart';

sealed class AiAnalysisState {
  const AiAnalysisState();
}

final class AiAnalysisInitial extends AiAnalysisState {
  const AiAnalysisInitial();
}

final class AiAnalysisLoading extends AiAnalysisState {
  const AiAnalysisLoading();
}

/// Initial analysis result — the form fills its still-empty fields from it.
final class AiAnalysisSuccess extends AiAnalysisState {
  final AiAnalysisResult result;
  const AiAnalysisSuccess(this.result);
}

final class AiAnalysisFailure extends AiAnalysisState {
  final String message;
  const AiAnalysisFailure(this.message);
}

/// Emitted when AI analysis is blocked by a plan limit.
final class AiAnalysisQuotaExceeded extends AiAnalysisState {
  const AiAnalysisQuotaExceeded();
}

/// A correction re-analysis is in flight. Carries the previous result so the
/// UI keeps the current card visible (dimmed) instead of blanking the form.
final class AiAnalysisRefining extends AiAnalysisState {
  final AiAnalysisResult previous;
  const AiAnalysisRefining(this.previous);
}

/// A correction landed — the form overwrites its AI-driven fields. Distinct
/// from [AiAnalysisSuccess] so overwrite semantics are compiler-checked
/// instead of hiding behind a nullable `previous`.
final class AiAnalysisRefineSuccess extends AiAnalysisState {
  final AiAnalysisResult result;
  final AiAnalysisResult previous;
  const AiAnalysisRefineSuccess(this.result, {required this.previous});
}

/// A refine failed — the previous result stays current so the UI loses
/// nothing; the message goes to a snackbar.
final class AiAnalysisRefineFailure extends AiAnalysisState {
  final AiAnalysisResult previous;
  final String message;
  const AiAnalysisRefineFailure(this.previous, this.message);
}

/// The displayed analysis rolled back (undo) or was restored after a blocked
/// refine. The form must NOT re-fill anything from it — its fields were either
/// just restored from the undo snapshot or never changed.
final class AiAnalysisRestored extends AiAnalysisState {
  final AiAnalysisResult result;
  const AiAnalysisRestored(this.result);
}

class AiAnalysisCubit extends Cubit<AiAnalysisState>
    with SafeEmitMixin<AiAnalysisState> {
  final AnalyzeItemImageUsecase _analyze;

  // Refines re-send the same image with a hint; undo restores the pre-refine
  // analysis so the correction chips/insight roll back with the form.
  String? _imagePath;
  AiAnalysisResult? _current;
  AiAnalysisResult? _previous;

  AiAnalysisCubit(this._analyze) : super(const AiAnalysisInitial());

  Future<void> analyze(String imagePath) async {
    _imagePath = imagePath;
    _current = null;
    _previous = null;
    emit(const AiAnalysisLoading());
    try {
      final result = await _analyze(imagePath);
      _current = result;
      safeEmit(AiAnalysisSuccess(result));
    } on QuotaException {
      safeEmit(const AiAnalysisQuotaExceeded());
    } on AppException catch (e) {
      safeEmit(AiAnalysisFailure(e.message));
    }
  }

  /// Re-runs the analysis with a user correction ("é um iPhone 15 de 256GB"),
  /// riding the current analysis's free retry when available. No-op without a
  /// prior successful analysis or while another refine is in flight (a double
  /// chip tap must not fire two paid requests).
  Future<void> refine(String hint) async {
    if (state is AiAnalysisRefining) return;
    final previous = _current;
    final imagePath = _imagePath;
    if (previous == null || imagePath == null) return;

    emit(AiAnalysisRefining(previous));
    try {
      final result = await _analyze(
        imagePath,
        hint: hint,
        parentAnalysisId: previous.analysisId,
      );
      _previous = previous;
      _current = result;
      safeEmit(AiAnalysisRefineSuccess(result, previous: previous));
    } on QuotaException {
      // Paywall via the QuotaExceeded listener, then restore the previous
      // result without touching the form.
      safeEmit(const AiAnalysisQuotaExceeded());
      safeEmit(AiAnalysisRestored(previous));
    } on RateLimitException {
      safeEmit(AiAnalysisRefineFailure(previous, kAiRateLimitMessage));
    } on AppException catch (e) {
      safeEmit(AiAnalysisRefineFailure(previous, e.message));
    }
  }

  /// Restores the pre-refine analysis. The executed refine stays counted —
  /// this only rolls the *displayed* result back.
  void undo() {
    final previous = _previous;
    if (previous == null) return;
    _previous = null;
    _current = previous;
    emit(AiAnalysisRestored(previous));
  }
}
