import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/domain/repositories/items_repository.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late UpdateItemUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = UpdateItemUsecase(repository);
  });

  test('forwards id and named fields to repository.updateItem', () async {
    final item = tItem();
    when(() => repository.updateItem(
          any(),
          name: any(named: 'name'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          categoryId: any(named: 'categoryId'),
          locationId: any(named: 'locationId'),
          userDefinedValue: any(named: 'userDefinedValue'),
        )).thenAnswer((_) async => item);

    final result = await usecase(
      'item-1',
      name: 'New',
      quantity: 2,
      userDefinedValue: 5.0,
    );

    expect(result, item);
    verify(() => repository.updateItem(
          'item-1',
          name: 'New',
          description: null,
          quantity: 2,
          categoryId: null,
          locationId: null,
          userDefinedValue: 5.0,
        )).called(1);
  });
}
