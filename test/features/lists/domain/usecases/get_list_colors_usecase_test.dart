import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';
import 'package:circulari/features/lists/domain/usecases/get_list_colors_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late GetListColorsUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = GetListColorsUsecase(repository);
  });

  test('returns colors from repository', () async {
    when(() => repository.getColors())
        .thenAnswer((_) async => const [tListColor]);

    final result = await usecase();

    expect(result, const [tListColor]);
    verify(() => repository.getColors()).called(1);
  });
}
