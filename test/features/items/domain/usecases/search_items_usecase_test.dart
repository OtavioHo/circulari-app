import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/models/paginated_result.dart';
import 'package:app/features/items/domain/entities/item.dart';
import 'package:app/features/items/domain/repositories/items_repository.dart';
import 'package:app/features/items/domain/usecases/search_items_usecase.dart';

import '../../../../helpers/fixtures.dart';

class MockItemsRepository extends Mock implements ItemsRepository {}

void main() {
  late MockItemsRepository repository;
  late SearchItemsUsecase usecase;

  setUp(() {
    repository = MockItemsRepository();
    usecase = SearchItemsUsecase(repository);
  });

  test('forwards args and returns paginated result', () async {
    final page = PaginatedResult<Item>(data: [tItem()], nextCursor: 'next');
    when(() => repository.searchItems(
          search: any(named: 'search'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => page);

    final result =
        await usecase(search: 'book', cursor: 'c1', limit: 20);

    expect(result, page);
    verify(() => repository.searchItems(
          search: 'book',
          cursor: 'c1',
          limit: 20,
        )).called(1);
  });
}
