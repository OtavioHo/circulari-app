import 'package:flutter_bloc/flutter_bloc.dart';

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

final class AiAnalysisSuccess extends AiAnalysisState {
  final AiAnalysisResult result;

  /// Set only right after a successful refine — enables the "valor atualizado"
  /// delta banner and Desfazer. Null on initial analyses and after undo.
  final AiAnalysisResult? previous;

  const AiAnalysisSuccess(this.result, {this.previous});
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

/// A refine failed — the previous result stays current so the UI loses
/// nothing; the message goes to a snackbar.
final class AiAnalysisRefineFailure extends AiAnalysisState {
  final AiAnalysisResult previous;
  final String message;
  const AiAnalysisRefineFailure(this.previous, this.message);
}

class AiAnalysisCubit extends Cubit<AiAnalysisState> {
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
      emit(AiAnalysisSuccess(result));
    } on PlanLimitException {
      emit(const AiAnalysisQuotaExceeded());
    } on TierRequiredException {
      emit(const AiAnalysisQuotaExceeded());
    } on AppException catch (e) {
      emit(AiAnalysisFailure(e.message));
    }
  }

  /// Re-runs the analysis with a user correction ("é um iPhone 15 de 256GB"),
  /// riding the current analysis's free retry when available. No-op without a
  /// prior successful analysis.
  Future<void> refine(String hint) async {
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
      emit(AiAnalysisSuccess(result, previous: previous));
    } on PlanLimitException {
      // Paywall via the QuotaExceeded listener, then restore the previous
      // result so the correction UI stays usable.
      emit(const AiAnalysisQuotaExceeded());
      emit(AiAnalysisSuccess(previous));
    } on TierRequiredException {
      emit(const AiAnalysisQuotaExceeded());
      emit(AiAnalysisSuccess(previous));
    } on RateLimitException {
      emit(AiAnalysisRefineFailure(
        previous,
        'Muitas análises seguidas. Aguarde um instante.',
      ));
    } on AppException {
      emit(AiAnalysisRefineFailure(
        previous,
        'Não foi possível reanalisar. Tente novamente.',
      ));
    }
  }

  /// Restores the pre-refine analysis. The executed refine stays counted —
  /// this only rolls the *displayed* result back.
  void undo() {
    final previous = _previous;
    if (previous == null) return;
    _previous = null;
    _current = previous;
    emit(AiAnalysisSuccess(previous));
  }
}
