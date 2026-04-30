import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';
import 'package:circulari/features/lists/domain/usecases/delete_list_usecase.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late DeleteListUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = DeleteListUsecase(repository);
  });

  test('forwards id to repository.deleteList', () async {
    when(() => repository.deleteList(any())).thenAnswer((_) async {});

    await usecase('list-1');

    verify(() => repository.deleteList('list-1')).called(1);
  });
}
