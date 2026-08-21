import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/lists/domain/repositories/lists_repository.dart';
import 'package:circulari/features/lists/domain/usecases/update_list_usecase.dart';

class MockListsRepository extends Mock implements ListsRepository {}

void main() {
  late MockListsRepository repository;
  late UpdateListUsecase usecase;

  setUp(() {
    repository = MockListsRepository();
    usecase = UpdateListUsecase(repository);
  });

  test('forwards all fields to repository.updateList', () async {
    when(() => repository.updateList(
          any(),
          name: any(named: 'name'),
          location: any(named: 'location'),
          colorId: any(named: 'colorId'),
          iconId: any(named: 'iconId'),
          pictureId: any(named: 'pictureId'),
        )).thenAnswer((_) async {});

    await usecase(
      'list-1',
      name: 'Renamed',
      location: 'SP',
      colorId: '#FF0000',
      iconId: 'home',
      pictureId: 'nature',
    );

    verify(() => repository.updateList(
          'list-1',
          name: 'Renamed',
          location: 'SP',
          colorId: '#FF0000',
          iconId: 'home',
          pictureId: 'nature',
        )).called(1);
  });
}
