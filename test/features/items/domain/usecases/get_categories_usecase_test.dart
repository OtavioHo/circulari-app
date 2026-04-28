import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/items/domain/repositories/items_repository.dart';
import 'package:app/features/items/domain/usecases/get_categories_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late GetCategoriesUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = GetCategoriesUsecase(repository);
  });

  test('returns categories from repository', () async {
    when(() => repository.getCategories())
        .thenAnswer((_) async => const [tCategory]);

    final result = await usecase();

    expect(result, const [tCategory]);
    verify(() => repository.getCategories()).called(1);
  });
}
