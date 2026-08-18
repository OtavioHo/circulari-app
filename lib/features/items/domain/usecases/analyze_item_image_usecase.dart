import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';

class AnalyzeItemImageUsecase {
  final ItemsRepository _repository;
  const AnalyzeItemImageUsecase(this._repository);

  Future<AiAnalysisResult> call(
    String imagePath, {
    String? hint,
    String? parentAnalysisId,
  }) =>
      _repository.analyzeImage(imagePath, hint: hint, parentAnalysisId: parentAnalysisId);
}
