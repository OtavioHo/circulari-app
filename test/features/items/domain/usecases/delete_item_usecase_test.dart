import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/domain/repositories/items_repository.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late DeleteItemUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = DeleteItemUsecase(repository);
  });

  test('forwards id to repository.deleteItem', () async {
    when(() => repository.deleteItem(any())).thenAnswer((_) async {});

    await usecase('item-1');

    verify(() => repository.deleteItem('item-1')).called(1);
  });
}
