import 'package:flutter_test/flutter_test.dart';

import 'package:circulari/features/items/data/models/item_model.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';

void main() {
  Map<String, dynamic> baseJson() => {
        'id': 'i1',
        'list_id': 'l1',
        'name': 'iPhone 15',
        'quantity': 1,
        'images': <dynamic>[],
        'created_at': '2026-08-17T00:00:00.000Z',
      };

  group('AI snapshot parsing', () {
    test('parses the persisted ai_* fields', () {
      final item = ItemModel.fromJson({
        ...baseJson(),
        'ai_price_min': 3000,
        'ai_price_max': 3800,
        'ai_price_confidence': 'high',
        'ai_price_evidence': [
          {'title': 'Usado', 'price': 3200, 'url': 'https://olx.com.br/x'},
          {'title': 'Sem url', 'price': 100}, // dropped
        ],
        'ai_analysis_id': 'analysis-1',
        'ai_analyzed_at': '2026-08-17T12:00:00.000Z',
      });

      expect(item.aiPriceMin, 3000);
      expect(item.aiPriceMax, 3800);
      expect(item.aiPriceConfidence, PriceConfidence.high);
      expect(item.aiPriceEvidence, hasLength(1));
      expect(item.aiAnalysisId, 'analysis-1');
      expect(item.aiAnalyzedAt, DateTime.parse('2026-08-17T12:00:00.000Z'));

      final insight = item.aiInsight;
      expect(insight, isNotNull);
      expect(insight!.priceMin, 3000);
      expect(insight.priceConfidence, PriceConfidence.high);
      expect(insight.analysisId, 'analysis-1');
    });

    test('defaults to no snapshot for pre-M3 responses', () {
      final item = ItemModel.fromJson(baseJson());

      expect(item.aiPriceMin, isNull);
      expect(item.aiPriceConfidence, isNull);
      expect(item.aiPriceEvidence, isEmpty);
      expect(item.aiInsight, isNull);
    });
  });
}
