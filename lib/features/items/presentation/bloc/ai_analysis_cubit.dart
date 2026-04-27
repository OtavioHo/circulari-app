import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/ai_analysis_result.dart';
import '../../domain/usecases/analyze_item_image_usecase.dart';

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

class AiAnalysisCubit extends Cubit<AiAnalysisState> {
  final AnalyzeItemImageUsecase _analyze;

  AiAnalysisCubit(this._analyze) : super(const AiAnalysisInitial());

  Future<void> analyze(String imagePath) async {
    emit(const AiAnalysisLoading());
    try {
      final result = await _analyze(imagePath);
      emit(AiAnalysisSuccess(result));
    } on PlanLimitException {
      emit(const AiAnalysisQuotaExceeded());
    } on TierRequiredException {
      emit(const AiAnalysisQuotaExceeded());
    } on AppException catch (e) {
      emit(AiAnalysisFailure(e.message));
    }
  }
}
