import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/items_page.dart';
import 'package:circulari/features/items/domain/usecases/create_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/get_items_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/items_event.dart';
import 'package:circulari/features/items/presentation/bloc/items_state.dart';

import '../../../../helpers/fixtures.dart';

class MockGetItemsUsecase extends Mock implements GetItemsUsecase {}

class MockCreateItemUsecase extends Mock implements CreateItemUsecase {}

class MockUpdateItemUsecase extends Mock implements UpdateItemUsecase {}

class MockDeleteItemUsecase extends Mock implements DeleteItemUsecase {}

void main() {
  late MockGetItemsUsecase getItems;
  late MockCreateItemUsecase createItem;
  late MockUpdateItemUsecase updateItem;
  late MockDeleteItemUsecase deleteItem;

  final existing = tItem(id: 'a');
  final created = tItem(id: 'b', name: 'New');
  final updated = tItem(id: 'a', name: 'Renamed');

  setUp(() {
    getItems = MockGetItemsUsecase();
    createItem = MockCreateItemUsecase();
    updateItem = MockUpdateItemUsecase();
    deleteItem = MockDeleteItemUsecase();
  });

  ItemsBloc buildBloc() => ItemsBloc(
        getItems: getItems,
        createItem: createItem,
        updateItem: updateItem,
        deleteItem: deleteItem,
      );

  test('initial state is ItemsInitial', () {
    expect(buildBloc().state, isA<ItemsInitial>());
  });

  group('ItemsLoadRequested', () {
    blocTest<ItemsBloc, ItemsState>(
      'emits [Loading, Success] with first page items and nextCursor',
      build: buildBloc,
      setUp: () => when(() => getItems(
                any(),
                cursor: any(named: 'cursor'),
                limit: any(named: 'limit'),
              ))
          .thenAnswer((_) async => ItemsPage(
              data: [existing], nextCursor: 'cur-1', totalValue: 420.0)),
      act: (b) => b.add(const ItemsLoadRequested('list-1')),
      expect: () => [
        isA<ItemsLoading>(),
        isA<ItemsSuccess>()
            .having((s) => s.items, 'items', [existing])
            .having((s) => s.nextCursor, 'nextCursor', 'cur-1')
            .having((s) => s.hasMore, 'hasMore', true)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.totalValue, 'totalValue', 420.0),
      ],
      verify: (_) => verify(() => getItems('list-1')).called(1),
    );

    blocTest<ItemsBloc, ItemsState>(
      'emits [Loading, Failure] on AppException',
      build: buildBloc,
      setUp: () => when(() => getItems(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenThrow(const NetworkException()),
      act: (b) => b.add(const ItemsLoadRequested('list-1')),
      expect: () => [
        isA<ItemsLoading>(),
        isA<ItemsFailure>().having(
          (s) => s.message,
          'message',
          'No internet connection.',
        ),
      ],
    );
  });

  group('ItemsLoadMoreRequested', () {
    final page2 = tItem(id: 'c', name: 'Page 2');

    blocTest<ItemsBloc, ItemsState>(
      'appends next page, clears cursor when no more results, and refreshes '
      'totalValue from the envelope',
      build: buildBloc,
      seed: () =>
          ItemsSuccess([existing], nextCursor: 'cur-1', totalValue: 100.0),
      setUp: () => when(() => getItems(
                any(),
                cursor: any(named: 'cursor'),
                limit: any(named: 'limit'),
              ))
          .thenAnswer(
              (_) async => ItemsPage(data: [page2], totalValue: 175.0)),
      act: (b) => b.add(const ItemsLoadMoreRequested('list-1')),
      expect: () => [
        isA<ItemsSuccess>()
            .having((s) => s.items, 'items', [existing])
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<ItemsSuccess>()
            .having((s) => s.items, 'items', [existing, page2])
            .having((s) => s.nextCursor, 'nextCursor', isNull)
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.totalValue, 'totalValue', 175.0),
      ],
      verify: (_) =>
          verify(() => getItems('list-1', cursor: 'cur-1')).called(1),
    );

    blocTest<ItemsBloc, ItemsState>(
      'is a no-op when there are no more pages',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      act: (b) => b.add(const ItemsLoadMoreRequested('list-1')),
      expect: () => const <ItemsState>[],
      verify: (_) => verifyNever(() => getItems(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )),
    );

    blocTest<ItemsBloc, ItemsState>(
      'is a no-op while a previous loadMore is in flight',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        isLoadingMore: true,
      ),
      act: (b) => b.add(const ItemsLoadMoreRequested('list-1')),
      expect: () => const <ItemsState>[],
      verify: (_) => verifyNever(() => getItems(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )),
    );

    blocTest<ItemsBloc, ItemsState>(
      'keeps loaded items and cursor, resets isLoadingMore and surfaces '
      'loadMoreError on failure',
      build: buildBloc,
      seed: () => ItemsSuccess([existing], nextCursor: 'cur-1'),
      setUp: () => when(() => getItems(
            any(),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenThrow(const NetworkException()),
      act: (b) => b.add(const ItemsLoadMoreRequested('list-1')),
      expect: () => [
        isA<ItemsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.loadMoreError, 'loadMoreError', isNull),
        isA<ItemsSuccess>()
            .having((s) => s.items, 'items', [existing])
            .having((s) => s.nextCursor, 'nextCursor', 'cur-1')
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having(
              (s) => s.loadMoreError,
              'loadMoreError',
              'No internet connection.',
            ),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'clears loadMoreError on the retry attempt (one-shot)',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        loadMoreError: 'No internet connection.',
      ),
      setUp: () => when(() => getItems(
                any(),
                cursor: any(named: 'cursor'),
                limit: any(named: 'limit'),
              ))
          .thenAnswer((_) async => ItemsPage(data: [page2])),
      act: (b) => b.add(const ItemsLoadMoreRequested('list-1')),
      expect: () => [
        isA<ItemsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.loadMoreError, 'loadMoreError', isNull),
        isA<ItemsSuccess>()
            .having((s) => s.items, 'items', [existing, page2])
            .having((s) => s.loadMoreError, 'loadMoreError', isNull),
      ],
    );
  });

  group('ItemsSuccess.copyWith', () {
    test('keeps every field when called with no arguments', () {
      final state = ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        isLoadingMore: true,
        totalValue: 99.0,
        loadMoreError: 'boom',
      );

      final copy = state.copyWith();

      expect(copy.items, [existing]);
      expect(copy.nextCursor, 'cur-1');
      expect(copy.isLoadingMore, isTrue);
      expect(copy.totalValue, 99.0);
      expect(copy.loadMoreError, 'boom');
    });

    test('clearCursor and clearLoadMoreError null the fields', () {
      final state = ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        loadMoreError: 'boom',
      );

      final copy =
          state.copyWith(clearCursor: true, clearLoadMoreError: true);

      expect(copy.nextCursor, isNull);
      expect(copy.hasMore, isFalse);
      expect(copy.loadMoreError, isNull);
    });

    test('overrides fields when provided', () {
      final state = ItemsSuccess([existing], totalValue: 1.0);

      final copy = state.copyWith(
        items: [existing, created],
        nextCursor: 'cur-2',
        isLoadingMore: true,
        totalValue: 2.0,
        loadMoreError: 'later',
      );

      expect(copy.items, [existing, created]);
      expect(copy.nextCursor, 'cur-2');
      expect(copy.isLoadingMore, isTrue);
      expect(copy.totalValue, 2.0);
      expect(copy.loadMoreError, 'later');
    });

    test('returns a base ItemsSuccess when called on a create subtype', () {
      final state = ItemsCreateSuccess([existing], existing);

      final copy = state.copyWith(isLoadingMore: true);

      expect(copy, isA<ItemsSuccess>());
      expect(copy, isNot(isA<ItemsCreateSuccess>()));
    });
  });

  group('ItemsCreateRequested', () {
    blocTest<ItemsBloc, ItemsState>(
      'appends created item to existing list on success',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => created),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>().having((s) => s.items, 'items', [existing]),
        isA<ItemsCreateSuccess>()
            .having((s) => s.items.length, 'length', 2)
            .having((s) => s.items.last, 'last', created),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'preserves previous items in QuotaExceeded on PlanLimitException',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenThrow(const PlanLimitException()),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>().having((s) => s.items, 'items', [existing]),
        isA<ItemsQuotaExceeded>().having((s) => s.items, 'items', [existing]),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'preserves previous items in QuotaExceeded on TierRequiredException',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenThrow(const TierRequiredException()),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [isA<ItemsCreateInProgress>(), isA<ItemsQuotaExceeded>()],
    );

    blocTest<ItemsBloc, ItemsState>(
      'emits ItemsActionFailure with message on generic AppException',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenThrow(const ServerException('boom')),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>().having((s) => s.items, 'items', [existing]),
        isA<ItemsActionFailure>()
            .having((s) => s.items, 'items', [existing])
            .having((s) => s.message, 'message', 'boom'),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'starts from empty list when state is ItemsInitial',
      build: buildBloc,
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => created),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>().having((s) => s.items, 'items', isEmpty),
        isA<ItemsCreateSuccess>().having((s) => s.items, 'items', [created]),
      ],
    );
  });

  group('ItemsUpdateRequested', () {
    blocTest<ItemsBloc, ItemsState>(
      'replaces matching item on success',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
          )).thenAnswer((_) async => updated),
      act: (b) => b.add(const ItemsUpdateRequested('a', name: 'Renamed')),
      expect: () => [
        isA<ItemsSuccess>().having((s) => s.items.first.name, 'name', 'Renamed'),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'preserves items list on update failure',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
          )).thenThrow(const ServerException('nope')),
      act: (b) => b.add(const ItemsUpdateRequested('a', name: 'X')),
      expect: () => [
        isA<ItemsActionFailure>().having((s) => s.items, 'items', [existing]),
      ],
    );
  });

  group('ItemsDeleteRequested', () {
    blocTest<ItemsBloc, ItemsState>(
      'removes the item on success',
      build: buildBloc,
      seed: () => ItemsSuccess([existing, created]),
      setUp: () => when(() => deleteItem(any())).thenAnswer((_) async {}),
      act: (b) => b.add(const ItemsDeleteRequested('a')),
      expect: () => [
        isA<ItemsSuccess>().having(
          (s) => s.items.map((i) => i.id),
          'ids',
          ['b'],
        ),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'emits ActionFailure preserving items on delete failure',
      build: buildBloc,
      seed: () => ItemsSuccess([existing]),
      setUp: () => when(() => deleteItem(any()))
          .thenThrow(const ServerException('nope')),
      act: (b) => b.add(const ItemsDeleteRequested('a')),
      expect: () => [
        isA<ItemsActionFailure>().having((s) => s.items, 'items', [existing]),
      ],
    );
  });

  // The server totalValue spans ALL pages, so views prefer it over folding the
  // loaded items while pages remain unloaded. A local mutation that leaves it
  // untouched makes the header keep counting a deleted item (or ignore a new
  // one) until the next page lands — never, for a fully loaded list.
  group('totalValue after local mutations', () {
    blocTest<ItemsBloc, ItemsState>(
      'delete subtracts the removed item value from the server total',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [tItem(id: 'a', userDefinedValue: 30.0), created],
        nextCursor: 'cur-1',
        totalValue: 100.0,
      ),
      setUp: () => when(() => deleteItem(any())).thenAnswer((_) async {}),
      act: (b) => b.add(const ItemsDeleteRequested('a')),
      expect: () => [
        isA<ItemsSuccess>().having((s) => s.totalValue, 'totalValue', 70.0),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'update shifts the server total by the value delta',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [tItem(id: 'a', userDefinedValue: 30.0)],
        nextCursor: 'cur-1',
        totalValue: 100.0,
      ),
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
          )).thenAnswer(
        (_) async => tItem(id: 'a', userDefinedValue: 50.0),
      ),
      act: (b) => b.add(const ItemsUpdateRequested('a', name: 'Renamed')),
      expect: () => [
        isA<ItemsSuccess>().having((s) => s.totalValue, 'totalValue', 120.0),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'create adds the new item value to the server total',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        totalValue: 100.0,
      ),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer(
        (_) async => tItem(id: 'b', userDefinedValue: 25.0),
      ),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>()
            .having((s) => s.totalValue, 'totalValue', 100.0),
        isA<ItemsCreateSuccess>()
            .having((s) => s.totalValue, 'totalValue', 125.0),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'leaves totalValue null when the backend never sent one',
      build: buildBloc,
      seed: () => ItemsSuccess([existing], nextCursor: 'cur-1'),
      setUp: () => when(() => deleteItem(any())).thenAnswer((_) async {}),
      act: (b) => b.add(const ItemsDeleteRequested('a')),
      expect: () => [
        isA<ItemsSuccess>().having((s) => s.totalValue, 'totalValue', isNull),
      ],
    );
  });

  // The create subtypes are ItemsSuccess, and list views gate load-more
  // dispatch on isLoadingMore/loadMoreError for ANY ItemsSuccess. Dropping
  // either field on a create emit reopens that gate mid-flight, refetching the
  // same cursor and appending the page twice.
  group('create subtypes forward pagination fields', () {
    blocTest<ItemsBloc, ItemsState>(
      'ItemsCreateInProgress/Success keep isLoadingMore while a page is in '
      'flight',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        isLoadingMore: true,
      ),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => created),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.nextCursor, 'nextCursor', 'cur-1'),
        isA<ItemsCreateSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.nextCursor, 'nextCursor', 'cur-1'),
      ],
    );

    blocTest<ItemsBloc, ItemsState>(
      'ItemsCreateInProgress/Success keep a pending loadMoreError',
      build: buildBloc,
      seed: () => ItemsSuccess(
        [existing],
        nextCursor: 'cur-1',
        loadMoreError: 'No internet connection.',
      ),
      setUp: () => when(() => createItem(
            listId: any(named: 'listId'),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            locationId: any(named: 'locationId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            imagePath: any(named: 'imagePath'),
          )).thenAnswer((_) async => created),
      act: (b) => b.add(const ItemsCreateRequested(
        listId: 'list-1',
        name: 'New',
      )),
      expect: () => [
        isA<ItemsCreateInProgress>().having(
          (s) => s.loadMoreError,
          'loadMoreError',
          'No internet connection.',
        ),
        isA<ItemsCreateSuccess>().having(
          (s) => s.loadMoreError,
          'loadMoreError',
          'No internet connection.',
        ),
      ],
    );
  });
}
