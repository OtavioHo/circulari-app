import 'package:flutter_test/flutter_test.dart';

import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';

void main() {
  AiAnalysisResult make(double min, double max) => AiAnalysisResult(
    name: 'x',
    description: 'x',
    priceMin: min,
    priceMax: max,
  );

  group('suggestedPrice', () {
    test('is the midpoint of the range, not the floor', () {
      expect(make(150, 250).suggestedPrice, 200);
      expect(make(40, 90).suggestedPrice, 65);
    });

    test('rounds to whole reais', () {
      expect(make(40, 95).suggestedPrice, 68); // 67.5 -> 68
    });

    test('equals the value when min == max', () {
      expect(make(80, 80).suggestedPrice, 80);
    });
  });
}
