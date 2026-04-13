import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/features/lists/domain/entities/item_list.dart';
import 'package:app/features/lists/domain/usecases/create_list_usecase.dart';
import 'package:app/features/lists/domain/usecases/delete_list_usecase.dart';
import 'package:app/features/lists/domain/usecases/get_lists_usecase.dart';
import 'package:app/features/lists/domain/usecases/rename_list_usecase.dart';
import 'package:app/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:app/features/lists/presentation/bloc/lists_event.dart';
import 'package:app/features/lists/presentation/bloc/lists_state.dart';

class MockGetListsUsecase extends Mock implements GetListsUsecase {}

class MockCreateListUsecase extends Mock implements CreateListUsecase {}

class MockDeleteListUsecase extends Mock implements DeleteListUsecase {}

class MockRenameListUsecase extends Mock implements RenameListUsecase {}

final _tList = ItemList(
  id: 'abc',
  name: 'Books',
  itemCount: 2,
  totalValue: 80.0,
  createdAt: DateTime(2024),
);

void main() {
  late MockGetListsUsecase getLists;
  late MockCreateListUsecase createList;
  late MockDeleteListUsecase deleteList;
  late MockRenameListUsecase renameList;

  setUp(() {
    getLists = MockGetListsUsecase();
    createList = MockCreateListUsecase();
    deleteList = MockDeleteListUsecase();
    renameList = MockRenameListUsecase();
  });

  ListsBloc buildBloc() => ListsBloc(
        getLists: getLists,
        createList: createList,
        deleteList: deleteList,
        renameList: renameList,
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
      setUp: () => when(() => getLists())
          .thenThrow(const NetworkException()),
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

  group('ListsCreateRequested', () {
    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Success] after creating and reloading',
      build: buildBloc,
      setUp: () {
        when(() => createList(any())).thenAnswer((_) async => _tList);
        when(() => getLists()).thenAnswer((_) async => [_tList]);
      },
      act: (bloc) => bloc.add(const ListsCreateRequested('Books')),
      expect: () => [isA<ListsLoading>(), isA<ListsSuccess>()],
      verify: (_) {
        verify(() => createList('Books')).called(1);
        verify(() => getLists()).called(1);
      },
    );

    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Failure] when create throws',
      build: buildBloc,
      setUp: () => when(() => createList(any()))
          .thenThrow(const ServerException('Could not create.')),
      act: (bloc) => bloc.add(const ListsCreateRequested('Books')),
      expect: () => [isA<ListsLoading>(), isA<ListsFailure>()],
    );
  });

  group('ListsDeleteRequested', () {
    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Success] after deleting and reloading',
      build: buildBloc,
      setUp: () {
        when(() => deleteList(any())).thenAnswer((_) async {});
        when(() => getLists()).thenAnswer((_) async => []);
      },
      act: (bloc) => bloc.add(const ListsDeleteRequested('abc')),
      expect: () => [isA<ListsLoading>(), isA<ListsSuccess>()],
      verify: (_) {
        verify(() => deleteList('abc')).called(1);
        verify(() => getLists()).called(1);
      },
    );

    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Failure] when delete throws',
      build: buildBloc,
      setUp: () => when(() => deleteList(any()))
          .thenThrow(const ServerException('Could not delete.')),
      act: (bloc) => bloc.add(const ListsDeleteRequested('abc')),
      expect: () => [isA<ListsLoading>(), isA<ListsFailure>()],
    );
  });

  group('ListsRenameRequested', () {
    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Success] after renaming and reloading',
      build: buildBloc,
      setUp: () {
        when(() => renameList(any(), any()))
            .thenAnswer((_) async => _tList);
        when(() => getLists()).thenAnswer((_) async => [_tList]);
      },
      act: (bloc) =>
          bloc.add(const ListsRenameRequested('abc', 'New Name')),
      expect: () => [isA<ListsLoading>(), isA<ListsSuccess>()],
      verify: (_) {
        verify(() => renameList('abc', 'New Name')).called(1);
        verify(() => getLists()).called(1);
      },
    );

    blocTest<ListsBloc, ListsState>(
      'emits [Loading, Failure] when rename throws',
      build: buildBloc,
      setUp: () => when(() => renameList(any(), any()))
          .thenThrow(const ServerException('Could not rename.')),
      act: (bloc) =>
          bloc.add(const ListsRenameRequested('abc', 'New Name')),
      expect: () => [isA<ListsLoading>(), isA<ListsFailure>()],
    );
  });
}
