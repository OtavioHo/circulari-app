import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/lists/domain/repositories/lists_repository.dart';
import 'package:app/features/lists/domain/usecases/create_list_usecase.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late CreateListUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = CreateListUsecase(repository);
  });

  test('forwards all named args to repository.createList', () async {
    when(() => repository.createList(
          name: any(named: 'name'),
          location: any(named: 'location'),
          colorId: any(named: 'colorId'),
          iconId: any(named: 'iconId'),
          pictureId: any(named: 'pictureId'),
        )).thenAnswer((_) async {});

    await usecase(
      name: 'Books',
      location: 'Shelf',
      colorId: 'c-1',
      iconId: 'i-1',
      pictureId: 'p-1',
    );

    verify(() => repository.createList(
          name: 'Books',
          location: 'Shelf',
          colorId: 'c-1',
          iconId: 'i-1',
          pictureId: 'p-1',
        )).called(1);
  });
}
