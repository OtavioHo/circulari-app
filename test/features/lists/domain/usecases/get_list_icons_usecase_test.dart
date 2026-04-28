import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/lists/domain/repositories/lists_repository.dart';
import 'package:app/features/lists/domain/usecases/get_list_icons_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late GetListIconsUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = GetListIconsUsecase(repository);
  });

  test('returns icons from repository', () async {
    when(() => repository.getIcons())
        .thenAnswer((_) async => const [tListIcon]);

    final result = await usecase();

    expect(result, const [tListIcon]);
    verify(() => repository.getIcons()).called(1);
  });
}
