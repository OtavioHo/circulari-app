import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_event.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_state.dart';

import '../../../../helpers/fixtures.dart';

class MockUpdateItemUsecase extends Mock implements UpdateItemUsecase {}

class MockDeleteItemUsecase extends Mock implements DeleteItemUsecase {}

void main() {
  late MockUpdateItemUsecase updateItem;
  late MockDeleteItemUsecase deleteItem;

  final original = tItem(id: 'a', name: 'Original');
  final updated = tItem(id: 'a', name: 'Updated');

  setUp(() {
    updateItem = MockUpdateItemUsecase();
    deleteItem = MockDeleteItemUsecase();
  });

  ItemDetailBloc buildBloc() => ItemDetailBloc(
        item: original,
        updateItem: updateItem,
        deleteItem: deleteItem,
      );

  test('initial state is ItemDetailInitial with the seeded item', () {
    final bloc = buildBloc();
    expect(bloc.state, isA<ItemDetailInitial>());
    expect((bloc.state as ItemDetailInitial).item, original);
  });

  group('ItemDetailUpdateRequested', () {
    blocTest<ItemDetailBloc, ItemDetailState>(
      'emits [Loading, Success] with updated item',
      build: buildBloc,
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            userDefinedValue: any(named: 'userDefinedValue'),
          )).thenAnswer((_) async => updated),
      act: (b) =>
          b.add(const ItemDetailUpdateRequested('a', name: 'Updated')),
      expect: () => [
        isA<ItemDetailLoading>().having((s) => s.item, 'item', original),
        isA<ItemDetailSuccess>().having((s) => s.item, 'item', updated),
      ],
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'emits [Loading, Failure] preserving the original item',
      build: buildBloc,
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            userDefinedValue: any(named: 'userDefinedValue'),
          )).thenThrow(const ServerException('boom')),
      act: (b) => b.add(const ItemDetailUpdateRequested('a', name: 'X')),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailFailure>()
            .having((s) => s.item, 'item', original)
            .having((s) => s.message, 'message', 'boom'),
      ],
    );
  });

  group('ItemDetailDeleteRequested', () {
    blocTest<ItemDetailBloc, ItemDetailState>(
      'emits [Loading, Deleted] on success',
      build: buildBloc,
      setUp: () =>
          when(() => deleteItem(any())).thenAnswer((_) async {}),
      act: (b) => b.add(const ItemDetailDeleteRequested('a')),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailDeleted>(),
      ],
      verify: (_) => verify(() => deleteItem('a')).called(1),
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'emits Failure preserving original item on AppException',
      build: buildBloc,
      setUp: () => when(() => deleteItem(any()))
          .thenThrow(const NetworkException()),
      act: (b) => b.add(const ItemDetailDeleteRequested('a')),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailFailure>().having((s) => s.item, 'item', original),
      ],
    );
  });
}
