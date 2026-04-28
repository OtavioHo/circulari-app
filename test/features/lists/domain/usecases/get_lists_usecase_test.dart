import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/lists/domain/repositories/lists_repository.dart';
import 'package:app/features/lists/domain/usecases/get_lists_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late GetListsUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = GetListsUsecase(repository);
  });

  test('returns lists from repository', () async {
    final lists = [tItemList()];
    when(() => repository.getLists()).thenAnswer((_) async => lists);

    final result = await usecase();

    expect(result, lists);
    verify(() => repository.getLists()).called(1);
  });
}
