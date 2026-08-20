import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/features/items/domain/entities/items_page.dart';
import 'package:circulari/features/items/domain/repositories/items_repository.dart';
import 'package:circulari/features/items/domain/usecases/get_items_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late GetItemsUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = GetItemsUsecase(repository);
  });

  test('forwards listId and returns the paginated result', () async {
    final result = ItemsPage(
      data: [tItem(), tItem(id: 'item-2')],
      nextCursor: 'cur-1',
      totalValue: 350.0,
    );
    when(() => repository.getItems(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => result);

    final actual = await usecase('list-1');

    expect(actual, result);
    verify(() => repository.getItems('list-1')).called(1);
  });

  test('forwards cursor and limit', () async {
    const result = ItemsPage(data: []);
    when(() => repository.getItems(
          any(),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => result);

    await usecase('list-1', cursor: 'cur-1', limit: 50);

    verify(() => repository.getItems('list-1', cursor: 'cur-1', limit: 50))
        .called(1);
  });
}
