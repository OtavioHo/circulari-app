import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/domain/repositories/items_repository.dart';
import 'package:circulari/features/items/domain/usecases/analyze_item_image_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late AnalyzeItemImageUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = AnalyzeItemImageUsecase(repository);
  });

  test('forwards imagePath and returns analysis result', () async {
    when(() => repository.analyzeImage(any()))
        .thenAnswer((_) async => tAiResult);

    final result = await usecase('/tmp/x.jpg');

    expect(result, tAiResult);
    verify(() => repository.analyzeImage('/tmp/x.jpg')).called(1);
  });
}
