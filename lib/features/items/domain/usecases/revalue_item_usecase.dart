import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';

/// Re-runs the AI analysis for a saved item from its stored image (no upload),
/// guided by a user correction. Rides the item's applied analysis's free retry
/// when available.
class RevalueItemUsecase {
  final ItemsRepository _repository;
  const RevalueItemUsecase(this._repository);

  Future<AiAnalysisResult> call(
    String itemId, {
    required String hint,
    String? parentAnalysisId,
  }) =>
      _repository.analyzeItem(itemId, hint: hint, parentAnalysisId: parentAnalysisId);
}
