import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/core/error/app_exception.dart';
import 'package:app/core/models/paginated_result.dart';
import 'package:app/features/items/domain/entities/item.dart';
import 'package:app/features/items/domain/usecases/search_items_usecase.dart';
import 'package:app/features/items/presentation/bloc/search_items_bloc.dart';
import 'package:app/features/items/presentation/bloc/search_items_event.dart';
import 'package:app/features/items/presentation/bloc/search_items_state.dart';

import '../../../../helpers/fixtures.dart';

class MockSearchItemsUsecase extends Mock implements SearchItemsUsecase {}

void main() {
  late MockSearchItemsUsecase search;

  final page1 = tItem(id: '1');
  final page2 = tItem(id: '2');

  setUp(() => search = MockSearchItemsUsecase());

  SearchItemsBloc buildBloc() => SearchItemsBloc(searchItems: search);

  test('initial state is SearchItemsInitial', () {
    expect(buildBloc().state, isA<SearchItemsInitial>());
  });

  group('SearchItemsLoadRequested', () {
    blocTest<SearchItemsBloc, SearchItemsState>(
      'emits [Loading, Success] with items and nextCursor',
      build: buildBloc,
      setUp: () => when(() => search(
            search: any(named: 'search'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => PaginatedResult<Item>(
                data: [page1],
                nextCursor: 'next',
              )),
      act: (b) => b.add(const SearchItemsLoadRequested(search: 'q')),
      expect: () => [
        isA<SearchItemsLoading>(),
        isA<SearchItemsSuccess>()
            .having((s) => s.items, 'items', [page1])
            .having((s) => s.nextCursor, 'nextCursor', 'next')
            .having((s) => s.hasMore, 'hasMore', true),
      ],
      verify: (_) => verify(() => search(search: 'q')).called(1),
    );

    blocTest<SearchItemsBloc, SearchItemsState>(
      'emits Failure on Exception',
      build: buildBloc,
      setUp: () => when(() => search(
            search: any(named: 'search'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenThrow(const NetworkException()),
      act: (b) => b.add(const SearchItemsLoadRequested()),
      expect: () => [
        isA<SearchItemsLoading>(),
        isA<SearchItemsFailure>(),
      ],
    );
  });

  group('SearchItemsLoadMoreRequested', () {
    blocTest<SearchItemsBloc, SearchItemsState>(
      'appends next page and clears cursor when no more results',
      build: buildBloc,
      seed: () => SearchItemsSuccess(items: [page1], nextCursor: 'next'),
      setUp: () => when(() => search(
            search: any(named: 'search'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => PaginatedResult<Item>(data: [page2])),
      act: (b) => b.add(const SearchItemsLoadMoreRequested()),
      expect: () => [
        isA<SearchItemsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<SearchItemsSuccess>()
            .having((s) => s.items, 'items', [page1, page2])
            .having((s) => s.nextCursor, 'nextCursor', isNull)
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
    );

    blocTest<SearchItemsBloc, SearchItemsState>(
      'is a no-op when there are no more pages',
      build: buildBloc,
      seed: () => const SearchItemsSuccess(items: []),
      act: (b) => b.add(const SearchItemsLoadMoreRequested()),
      expect: () => const <SearchItemsState>[],
      verify: (_) => verifyNever(() => search(
            search: any(named: 'search'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )),
    );

    blocTest<SearchItemsBloc, SearchItemsState>(
      'is a no-op while a previous loadMore is in flight',
      build: buildBloc,
      seed: () => SearchItemsSuccess(
        items: [page1],
        nextCursor: 'next',
        isLoadingMore: true,
      ),
      act: (b) => b.add(const SearchItemsLoadMoreRequested()),
      expect: () => const <SearchItemsState>[],
    );

    blocTest<SearchItemsBloc, SearchItemsState>(
      'resets isLoadingMore to false on failure',
      build: buildBloc,
      seed: () => SearchItemsSuccess(items: [page1], nextCursor: 'next'),
      setUp: () => when(() => search(
            search: any(named: 'search'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          )).thenThrow(const NetworkException()),
      act: (b) => b.add(const SearchItemsLoadMoreRequested()),
      errors: () => [isA<NetworkException>()],
      expect: () => [
        isA<SearchItemsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<SearchItemsSuccess>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.items, 'items', [page1]),
      ],
    );
  });
}
