import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/features/items/domain/usecases/create_item_usecase.dart';
import 'package:app/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:app/features/items/domain/usecases/get_items_usecase.dart';
import 'package:app/features/items/domain/usecases/update_item_usecase.dart';
import 'package:app/features/items/presentation/bloc/items_bloc.dart';
import 'package:app/features/items/presentation/bloc/items_event.dart';
import 'package:app/features/items/presentation/bloc/items_state.dart';

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
      'emits [Loading, Success] with returned items',
      build: buildBloc,
      setUp: () => when(() => getItems(any()))
          .thenAnswer((_) async => [existing]),
      act: (b) => b.add(const ItemsLoadRequested('list-1')),
      expect: () => [
        isA<ItemsLoading>(),
        isA<ItemsSuccess>().having((s) => s.items, 'items', [existing]),
      ],
      verify: (_) => verify(() => getItems('list-1')).called(1),
    );

    blocTest<ItemsBloc, ItemsState>(
      'emits [Loading, Failure] on AppException',
      build: buildBloc,
      setUp: () => when(() => getItems(any()))
          .thenThrow(const NetworkException()),
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
        isA<ItemsSuccess>()
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
      expect: () => [isA<ItemsQuotaExceeded>()],
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
        isA<ItemsSuccess>().having((s) => s.items, 'items', [created]),
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
}
