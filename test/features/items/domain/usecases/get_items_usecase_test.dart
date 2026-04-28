import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/items/domain/repositories/items_repository.dart';
import 'package:app/features/items/domain/usecases/get_items_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late GetItemsUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = GetItemsUsecase(repository);
  });

  test('forwards listId and returns items', () async {
    final items = [tItem(), tItem(id: 'item-2')];
    when(() => repository.getItems(any())).thenAnswer((_) async => items);

    final result = await usecase('list-1');

    expect(result, items);
    verify(() => repository.getItems('list-1')).called(1);
  });
}
