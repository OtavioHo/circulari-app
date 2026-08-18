import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/entities/list_info.dart';
import 'package:circulari/features/items/data/models/item_image_model.dart';

class ItemModel extends Item {
  const ItemModel({
    required super.id,
    required super.listId,
    required super.name,
    super.description,
    required super.quantity,
    super.locationId,
    super.userDefinedValue,
    super.category,
    required super.images,
    super.listInfo,
    required super.createdAt,
    super.aiPriceMin,
    super.aiPriceMax,
    super.aiPriceConfidence,
    super.aiPriceEvidence,
    super.aiAnalysisId,
    super.aiAnalyzedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final rawImages = json['images'] as List? ?? [];

    final rawCategory = json['category'];
    Category? category;
    if (rawCategory is Map<String, dynamic>) {
      category = Category(
        id: rawCategory['id'] as String,
        name: rawCategory['name'] as String,
      );
    }

    final rawList = json['list'];
    ListInfo? listInfo;
    if (rawList is Map<String, dynamic>) {
      listInfo = ListInfo(
        name: rawList['name'] as String,
        color: rawList['color'] as String,
      );
    }

    return ItemModel(
      id: id,
      listId: json['list_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      locationId: json['location_id'] as String?,
      userDefinedValue: json['user_defined_value'] != null
          ? (json['user_defined_value'] as num).toDouble()
          : null,
      category: category,
      images: rawImages
          .map((e) => ItemImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      listInfo: listInfo,
      createdAt: DateTime.parse(json['created_at'] as String),
      aiPriceMin: (json['ai_price_min'] as num?)?.toDouble(),
      aiPriceMax: (json['ai_price_max'] as num?)?.toDouble(),
      aiPriceConfidence: _parseConfidence(json['ai_price_confidence']),
      aiPriceEvidence: _parseEvidence(json['ai_price_evidence']),
      aiAnalysisId: json['ai_analysis_id'] as String?,
      aiAnalyzedAt: json['ai_analyzed_at'] != null
          ? DateTime.tryParse(json['ai_analyzed_at'] as String)
          : null,
    );
  }

  static PriceConfidence? _parseConfidence(dynamic value) {
    return switch (value) {
      'high' => PriceConfidence.high,
      'medium' => PriceConfidence.medium,
      'low' => PriceConfidence.low,
      _ => null,
    };
  }

  static List<PriceComp> _parseEvidence(dynamic value) {
    if (value is! List) return const [];
    return [
      for (final entry in value)
        if (entry is Map &&
            entry['title'] is String &&
            (entry['title'] as String).isNotEmpty &&
            entry['url'] is String &&
            (entry['url'] as String).isNotEmpty &&
            entry['price'] is num)
          PriceComp(
            title: entry['title'] as String,
            price: (entry['price'] as num).toDouble(),
            url: entry['url'] as String,
          ),
    ];
  }
}
