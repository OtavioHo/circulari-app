import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/upload_item_image_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_event.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_state.dart';

import '../../../../helpers/fixtures.dart';

class MockUpdateItemUsecase extends Mock implements UpdateItemUsecase {}

class MockDeleteItemUsecase extends Mock implements DeleteItemUsecase {}

class MockUploadItemImageUsecase extends Mock
    implements UploadItemImageUsecase {}

void main() {
  late MockUpdateItemUsecase updateItem;
  late MockDeleteItemUsecase deleteItem;
  late MockUploadItemImageUsecase uploadItemImage;

  final original = tItem(id: 'a', name: 'Original');
  final updated = tItem(id: 'a', name: 'Updated');

  setUp(() {
    updateItem = MockUpdateItemUsecase();
    deleteItem = MockDeleteItemUsecase();
    uploadItemImage = MockUploadItemImageUsecase();
  });

  ItemDetailBloc buildBloc() => ItemDetailBloc(
        item: original,
        updateItem: updateItem,
        deleteItem: deleteItem,
        uploadItemImage: uploadItemImage,
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
      'forwards aiAnalysisId so the server applies the price snapshot',
      build: buildBloc,
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            aiAnalysisId: any(named: 'aiAnalysisId'),
          )).thenAnswer((_) async => updated),
      act: (b) => b.add(const ItemDetailUpdateRequested(
        'a',
        name: 'iPhone 15',
        userDefinedValue: 3400,
        aiAnalysisId: 'analysis-1',
      )),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailSuccess>(),
      ],
      verify: (_) => verify(() => updateItem(
            'a',
            name: 'iPhone 15',
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            userDefinedValue: 3400,
            aiAnalysisId: 'analysis-1',
          )).called(1),
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

  group('ItemDetailUpdateRequested with a new photo', () {
    final withImage = tItem(id: 'a', name: 'Updated');

    void stubUpdateOk() => when(() => updateItem(
          any(),
          name: any(named: 'name'),
          description: any(named: 'description'),
          quantity: any(named: 'quantity'),
          categoryId: any(named: 'categoryId'),
          userDefinedValue: any(named: 'userDefinedValue'),
          aiAnalysisId: any(named: 'aiAnalysisId'),
        )).thenAnswer((_) async => updated);

    blocTest<ItemDetailBloc, ItemDetailState>(
      'uploads the image after the update and emits the item with the image',
      build: buildBloc,
      setUp: () {
        stubUpdateOk();
        when(() => uploadItemImage(any(), any()))
            .thenAnswer((_) async => withImage);
      },
      act: (b) => b.add(const ItemDetailUpdateRequested(
        'a',
        name: 'Updated',
        imagePath: '/tmp/photo.jpg',
      )),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailSuccess>().having((s) => s.item, 'item', withImage),
      ],
      verify: (_) =>
          verify(() => uploadItemImage('a', '/tmp/photo.jpg')).called(1),
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'keeps the updated item and surfaces the message when the upload fails',
      build: buildBloc,
      setUp: () {
        stubUpdateOk();
        when(() => uploadItemImage(any(), any()))
            .thenThrow(const ServerException('upload boom'));
      },
      act: (b) => b.add(const ItemDetailUpdateRequested(
        'a',
        name: 'Updated',
        imagePath: '/tmp/photo.jpg',
      )),
      expect: () => [
        isA<ItemDetailLoading>(),
        // The field update succeeded — the failure must preserve it, not roll
        // back to the pre-edit item.
        isA<ItemDetailFailure>()
            .having((s) => s.item, 'item', updated)
            .having((s) => s.message, 'message', 'upload boom'),
      ],
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'does not upload when no photo was picked',
      build: buildBloc,
      setUp: stubUpdateOk,
      act: (b) => b.add(const ItemDetailUpdateRequested('a', name: 'Updated')),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailSuccess>().having((s) => s.item, 'item', updated),
      ],
      verify: (_) => verifyNever(() => uploadItemImage(any(), any())),
    );

    blocTest<ItemDetailBloc, ItemDetailState>(
      'does not upload when the update itself fails',
      build: buildBloc,
      setUp: () => when(() => updateItem(
            any(),
            name: any(named: 'name'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            categoryId: any(named: 'categoryId'),
            userDefinedValue: any(named: 'userDefinedValue'),
            aiAnalysisId: any(named: 'aiAnalysisId'),
          )).thenThrow(const ServerException('boom')),
      act: (b) => b.add(const ItemDetailUpdateRequested(
        'a',
        name: 'Updated',
        imagePath: '/tmp/photo.jpg',
      )),
      expect: () => [
        isA<ItemDetailLoading>(),
        isA<ItemDetailFailure>().having((s) => s.item, 'item', original),
      ],
      verify: (_) => verifyNever(() => uploadItemImage(any(), any())),
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
