import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/usecases/create_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/get_items_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/items_event.dart';
import 'package:circulari/features/items/presentation/bloc/items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final GetItemsUsecase _getItems;
  final CreateItemUsecase _createItem;
  final UpdateItemUsecase _updateItem;
  final DeleteItemUsecase _deleteItem;

  ItemsBloc({
    required GetItemsUsecase getItems,
    required CreateItemUsecase createItem,
    required UpdateItemUsecase updateItem,
    required DeleteItemUsecase deleteItem,
  }) : _getItems = getItems,
       _createItem = createItem,
       _updateItem = updateItem,
       _deleteItem = deleteItem,
       super(const ItemsInitial()) {
    on<ItemsLoadRequested>(_onLoad);
    on<ItemsLoadMoreRequested>(_onLoadMore);
    on<ItemsCreateRequested>(_onCreate);
    on<ItemsUpdateRequested>(_onUpdate);
    on<ItemsDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
    ItemsLoadRequested event,
    Emitter<ItemsState> emit,
  ) async {
    emit(const ItemsLoading());
    try {
      final result = await _getItems(event.listId);
      emit(
        ItemsSuccess(
          result.data,
          nextCursor: result.nextCursor,
          totalValue: result.totalValue,
        ),
      );
    } on AppException catch (e) {
      emit(ItemsFailure(e.message));
    }
  }

  Future<void> _onLoadMore(
    ItemsLoadMoreRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final current = state;
    if (current is! ItemsSuccess || !current.hasMore || current.isLoadingMore) {
      return;
    }
    // This attempt clears any previous load-more error (one-shot semantics).
    emit(current.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    try {
      final result = await _getItems(event.listId, cursor: current.nextCursor);
      emit(
        current.copyWith(
          items: [...current.items, ...result.data],
          nextCursor: result.nextCursor,
          clearCursor: result.nextCursor == null,
          isLoadingMore: false,
          clearLoadMoreError: true,
          totalValue: result.totalValue,
        ),
      );
    } on AppException catch (e) {
      // Keep the loaded pages (and cursor, so an explicit retry can resume);
      // surface the error in-state so the page can snackbar it. The page
      // gates auto-dispatch on loadMoreError == null, preventing a scroll
      // burst of retries.
      emit(current.copyWith(isLoadingMore: false, loadMoreError: e.message));
    }
  }

  Future<void> _onCreate(
    ItemsCreateRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final current = _snapshot;
    // Items-carrying in-progress state: a bare ItemsLoading would blank the
    // whole list (and lose scroll) for the duration of the request.
    emit(
      ItemsCreateInProgress(
        current.items,
        nextCursor: current.nextCursor,
        isLoadingMore: current.isLoadingMore,
        totalValue: current.totalValue,
        loadMoreError: current.loadMoreError,
      ),
    );
    try {
      final created = await _createItem(
        listId: event.listId,
        name: event.name,
        description: event.description,
        quantity: event.quantity,
        categoryId: event.categoryId,
        locationId: event.locationId,
        userDefinedValue: event.userDefinedValue,
        imagePath: event.imagePath,
        aiAnalysisId: event.aiAnalysisId,
      );
      emit(
        ItemsCreateSuccess(
          [...current.items, created],
          created,
          nextCursor: current.nextCursor,
          isLoadingMore: current.isLoadingMore,
          totalValue: _shiftTotal(
            current.totalValue,
            created.userDefinedValue ?? 0,
          ),
          loadMoreError: current.loadMoreError,
        ),
      );
    } on QuotaException {
      emit(
        ItemsQuotaExceeded(
          current.items,
          nextCursor: current.nextCursor,
          totalValue: current.totalValue,
        ),
      );
    } on AppException catch (e) {
      emit(
        ItemsActionFailure(
          current.items,
          e.message,
          nextCursor: current.nextCursor,
          totalValue: current.totalValue,
        ),
      );
    }
  }

  Future<void> _onUpdate(
    ItemsUpdateRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final current = _snapshot;
    try {
      final updated = await _updateItem(
        event.id,
        name: event.name,
        description: event.description,
        quantity: event.quantity,
        categoryId: event.categoryId,
        locationId: event.locationId,
        userDefinedValue: event.userDefinedValue,
      );
      emit(
        current.copyWith(
          items: current.items
              .map((i) => i.id == event.id ? updated : i)
              .toList(),
          totalValue: _shiftTotal(
            current.totalValue,
            (updated.userDefinedValue ?? 0) - _valueOf(current.items, event.id),
          ),
          clearLoadMoreError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        ItemsActionFailure(
          current.items,
          e.message,
          nextCursor: current.nextCursor,
          totalValue: current.totalValue,
        ),
      );
    }
  }

  Future<void> _onDelete(
    ItemsDeleteRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final current = _snapshot;
    try {
      await _deleteItem(event.id);
      emit(
        current.copyWith(
          items: current.items.where((i) => i.id != event.id).toList(),
          totalValue: _shiftTotal(
            current.totalValue,
            -_valueOf(current.items, event.id),
          ),
          clearLoadMoreError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        ItemsActionFailure(
          current.items,
          e.message,
          nextCursor: current.nextCursor,
          totalValue: current.totalValue,
        ),
      );
    }
  }

  /// Shifts the server-computed whole-list total by a local mutation's delta.
  ///
  /// [ItemsSuccess.totalValue] spans ALL pages, so it cannot be recomputed by
  /// folding the loaded items — and views prefer it over that fold while pages
  /// remain unloaded. Leaving it untouched after a create/update/delete makes
  /// the header keep counting a removed item (or ignore a new one) until the
  /// next page lands, which for a fully loaded list is never. Null (an older
  /// backend that doesn't send the total) stays null.
  double? _shiftTotal(double? total, double delta) =>
      total == null ? null : total + delta;

  /// The pre-mutation value of [id], or 0 when the item isn't in the loaded
  /// pages (nothing to subtract in that case — the delta is the caller's).
  double _valueOf(List<Item> items, String id) {
    for (final item in items) {
      if (item.id == id) return item.userDefinedValue ?? 0;
    }
    return 0;
  }

  /// The current items-carrying state collapsed to a base [ItemsSuccess], so
  /// mutation handlers can start from whichever state is active without
  /// per-field switch helpers.
  ItemsSuccess get _snapshot => switch (state) {
    final ItemsSuccess s => s,
    ItemsActionFailure(:final items, :final nextCursor, :final totalValue) =>
      ItemsSuccess(items, nextCursor: nextCursor, totalValue: totalValue),
    ItemsQuotaExceeded(:final items, :final nextCursor, :final totalValue) =>
      ItemsSuccess(items, nextCursor: nextCursor, totalValue: totalValue),
    _ => const ItemsSuccess([]),
  };
}
