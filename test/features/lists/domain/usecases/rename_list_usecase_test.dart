import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';
import 'package:circulari/features/lists/domain/usecases/rename_list_usecase.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late RenameListUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = RenameListUsecase(repository);
  });

  test('forwards id and name to repository.renameList', () async {
    when(() => repository.renameList(any(), any())).thenAnswer((_) async {});

    await usecase('list-1', 'Renamed');

    verify(() => repository.renameList('list-1', 'Renamed')).called(1);
  });
}
