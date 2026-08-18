import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/entities/item_image.dart';
import 'package:circulari/features/items/domain/entities/list_info.dart';

class Item {
  final String id;
  final String listId;
  final String name;
  final String? description;
  final int quantity;
  final String? locationId;
  final double? userDefinedValue;
  final Category? category;
  final List<ItemImage> images;
  final ListInfo? listInfo;
  final DateTime createdAt;

  // AI valuation snapshot persisted with the item (server-copied from the
  // applied analysis). Null for manual or pre-snapshot items.
  final double? aiPriceMin;
  final double? aiPriceMax;
  final PriceConfidence? aiPriceConfidence;
  final List<PriceComp> aiPriceEvidence;
  final String? aiAnalysisId;
  final DateTime? aiAnalyzedAt;

  const Item({
    required this.id,
    required this.listId,
    required this.name,
    this.description,
    required this.quantity,
    this.locationId,
    this.userDefinedValue,
    this.category,
    required this.images,
    this.listInfo,
    required this.createdAt,
    this.aiPriceMin,
    this.aiPriceMax,
    this.aiPriceConfidence,
    this.aiPriceEvidence = const [],
    this.aiAnalysisId,
    this.aiAnalyzedAt,
  });

  /// The persisted snapshot as an [AiAnalysisResult], so widgets built for the
  /// analyze flow (e.g. PriceInsight) render it unchanged. Null when the item
  /// carries no snapshot.
  AiAnalysisResult? get aiInsight {
    final min = aiPriceMin;
    final max = aiPriceMax;
    if (min == null || max == null) return null;
    return AiAnalysisResult(
      analysisId: aiAnalysisId,
      name: name,
      description: description ?? '',
      priceMin: min,
      priceMax: max,
      priceConfidence: aiPriceConfidence ?? PriceConfidence.low,
      priceEvidence: aiPriceEvidence,
    );
  }
}
