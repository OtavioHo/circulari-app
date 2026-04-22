import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/features/lists/domain/entities/item_list.dart';
import 'package:app/features/lists/domain/entities/list_color.dart';
import 'package:app/features/lists/domain/entities/list_icon.dart';
import 'package:app/features/lists/domain/entities/list_picture.dart';
import 'package:app/features/lists/domain/usecases/delete_list_usecase.dart';
import 'package:app/features/lists/domain/usecases/get_lists_usecase.dart';
import 'package:app/features/lists/domain/usecases/rename_list_usecase.dart';
import 'package:app/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:app/features/lists/presentation/bloc/lists_event.dart';
import 'package:app/features/lists/presentation/bloc/lists_state.dart';

class MockGetListsUsecase extends Mock implements GetListsUsecase {}

class MockDeleteListUsecase extends Mock implements DeleteListUsecase {}

class MockRenameListUsecase extends Mock implements RenameListUsecase {}

final _tColor = ListColor(hexCode: '#FF0000', name: 'Red', order: 0);
final _tIcon = ListIcon(slug: 'home', name: 'Home', order: 0);
final _tPicture = ListPicture(slug: 'nature', order: 0);

final _tList = ItemList(
  id: 'abc',
  name: 'Books',
  color: _tColor,
  icon: _tIcon,
  picture: _tPicture,
  itemCount: 2,
  totalValue: 80.0,
  createdAt: DateTime(2024),
);

void main() {
  late MockGetListsUsecase getLists;
  late MockDeleteListUsecase deleteList;
  late MockRenameListUsecase renameList;

  setUp(() {
    getLists = MockGetListsUsecase();
    deleteList = MockDeleteListUsecase();
    renameList = MockRenameListUsecase();
  });

  ListsBloc buildBloc() => ListsBloc(
        getLists: getLists,
        renameList: renameList,
        deleteList: deleteList,
      );

  test('initial state is ListsInitial', () {
    expect(buildBloc().state, isA<ListsInitial>());
  });

  group('ListsLoadRequested', () {
    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Success] on success',
      build: buildBloc,
      setUp: () => when(() => getLists()).thenAnswer((_) async => [_tList]),
      act: (bloc) => bloc.add(const ListsLoadRequested()),
      expect: () => [
        isA<ListsLoading>(),
        isA<ListsSuccess>(),
      ],
      verify: (_) => verify(() => getLists()).called(1),
    );

    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Failure] on exception',
      build: buildBloc,
      setUp: () => when(() => getLists())
          .thenThrow(const ServerException('Something went wrong.')),
      act: (bloc) => bloc.add(const ListsLoadRequested()),
      expect: () => [
        isA<ListsLoading>(),
        isA<ListsFailure>(),
      ],
    );

    blocTest<ListsBloc, ListsState>(
      'Failure carries the exception message',
      build: buildBloc,
      setUp: () =>
          when(() => getLists()).thenThrow(const NetworkException()),
      act: (bloc) => bloc.add(const ListsLoadRequested()),
      expect: () => [
        isA<ListsLoading>(),
        isA<ListsFailure>().having(
          (s) => s.message,
          'message',
          'No internet connection.',
        ),
      ],
    );

    blocTest<ListsBloc, ListsState>(
      'Success carries the returned lists',
      build: buildBloc,
      setUp: () =>
          when(() => getLists()).thenAnswer((_) async => [_tList]),
      act: (bloc) => bloc.add(const ListsLoadRequested()),
      expect: () => [
        isA<ListsLoading>(),
        isA<ListsSuccess>().having(
          (s) => s.lists,
          'lists',
          [_tList],
        ),
      ],
    );
  });

  group('ListsDeleteRequested', () {
    blocTest<ListsBloc, ListsState>(
      'removes item from list on success',
      build: buildBloc,
      seed: () => ListsSuccess([_tList]),
      setUp: () =>
          when(() => deleteList(any())).thenAnswer((_) async {}),
      act: (bloc) => bloc.add(const ListsDeleteRequested('abc')),
      expect: () => [
        isA<ListsSuccess>().having((s) => s.lists, 'lists', isEmpty),
      ],
      verify: (_) => verify(() => deleteList('abc')).called(1),
    );

    blocTest<ListsBloc, ListsState>(
      'emits ActionFailure when delete throws',
      build: buildBloc,
      seed: () => ListsSuccess([_tList]),
      setUp: () => when(() => deleteList(any()))
          .thenThrow(const ServerException('Could not delete.')),
      act: (bloc) => bloc.add(const ListsDeleteRequested('abc')),
      expect: () => [isA<ListsActionFailure>()],
    );
  });

  group('ListsRenameRequested', () {
    blocTest<ListsBloc, ListsState>(
      'updates name in existing list on success',
      build: buildBloc,
      seed: () => ListsSuccess([_tList]),
      setUp: () =>
          when(() => renameList(any(), any())).thenAnswer((_) async {}),
      act: (bloc) =>
          bloc.add(const ListsRenameRequested('abc', 'New Name')),
      expect: () => [
        isA<ListsSuccess>().having(
          (s) => s.lists.first.name,
          'name',
          'New Name',
        ),
      ],
      verify: (_) => verify(() => renameList('abc', 'New Name')).called(1),
    );

    blocTest<ListsBloc, ListsState>(
      'emits ActionFailure when rename throws',
      build: buildBloc,
      seed: () => ListsSuccess([_tList]),
      setUp: () => when(() => renameList(any(), any()))
          .thenThrow(const ServerException('Could not rename.')),
      act: (bloc) =>
          bloc.add(const ListsRenameRequested('abc', 'New Name')),
      expect: () => [isA<ListsActionFailure>()],
    );
  });
}
