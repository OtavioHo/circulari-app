import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/features/items/domain/usecases/search_items_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_event.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_state.dart';

class SearchItemsBloc extends Bloc<SearchItemsEvent, SearchItemsState> {
  final SearchItemsUsecase _searchItems;

  SearchItemsBloc({required SearchItemsUsecase searchItems})
      : _searchItems = searchItems,
        super(const SearchItemsInitial()) {
    on<SearchItemsLoadRequested>(_onLoad);
    on<SearchItemsLoadMoreRequested>(_onLoadMore);
  }

  String? _currentSearch;

  Future<void> _onLoad(
    SearchItemsLoadRequested event,
    Emitter<SearchItemsState> emit,
  ) async {
    _currentSearch = event.search;
    emit(const SearchItemsLoading());
    try {
      final result = await _searchItems(search: event.search);
      emit(SearchItemsSuccess(items: result.data, nextCursor: result.nextCursor));
    } on Exception catch (e) {
      emit(SearchItemsFailure(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    SearchItemsLoadMoreRequested event,
    Emitter<SearchItemsState> emit,
  ) async {
    final current = state;
    if (current is! SearchItemsSuccess || !current.hasMore || current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));
    try {
      final result = await _searchItems(
        search: _currentSearch,
        cursor: current.nextCursor,
      );
      emit(current.copyWith(
        items: [...current.items, ...result.data],
        nextCursor: result.nextCursor,
        clearCursor: result.nextCursor == null,
        isLoadingMore: false,
      ));
    } on Exception catch (e) {
      emit(current.copyWith(isLoadingMore: false));
      addError(e);
    }
  }
}
