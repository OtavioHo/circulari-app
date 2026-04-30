import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/domain/repositories/items_repository.dart';
import 'package:circulari/features/items/domain/usecases/create_item_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late CreateItemUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = CreateItemUsecase(repository);
  });

  test('forwards all fields to repository.createItem', () async {
    final item = tItem();
    when(() => repository.createItem(
          listId: any(named: 'listId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          categoryId: any(named: 'categoryId'),
          locationId: any(named: 'locationId'),
          userDefinedValue: any(named: 'userDefinedValue'),
          imagePath: any(named: 'imagePath'),
        )).thenAnswer((_) async => item);

    final result = await usecase(
      listId: 'list-1',
      name: 'Book',
      description: 'desc',
      quantity: 3,
      categoryId: 'cat-1',
      locationId: 'loc-1',
      userDefinedValue: 19.9,
      imagePath: '/tmp/x.jpg',
    );

    expect(result, item);
    verify(() => repository.createItem(
          listId: 'list-1',
          name: 'Book',
          description: 'desc',
          quantity: 3,
          categoryId: 'cat-1',
          locationId: 'loc-1',
          userDefinedValue: 19.9,
          imagePath: '/tmp/x.jpg',
        )).called(1);
  });

  test('uses default quantity = 1 when omitted', () async {
    when(() => repository.createItem(
          listId: any(named: 'listId'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          categoryId: any(named: 'categoryId'),
          locationId: any(named: 'locationId'),
          userDefinedValue: any(named: 'userDefinedValue'),
          imagePath: any(named: 'imagePath'),
        )).thenAnswer((_) async => tItem());

    await usecase(listId: 'list-1', name: 'Book');

    verify(() => repository.createItem(
          listId: 'list-1',
          name: 'Book',
          description: null,
          quantity: 1,
          categoryId: null,
          locationId: null,
          userDefinedValue: null,
          imagePath: null,
        )).called(1);
  });
}
