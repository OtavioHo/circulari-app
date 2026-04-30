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
  })  : _getItems = getItems,
        _createItem = createItem,
        _updateItem = updateItem,
        _deleteItem = deleteItem,
        super(const ItemsInitial()) {
    on<ItemsLoadRequested>(_onLoad);
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
      final items = await _getItems(event.listId);
      emit(ItemsSuccess(items));
    } on AppException catch (e) {
      emit(ItemsFailure(e.message));
    }
  }

  Future<void> _onCreate(
    ItemsCreateRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final previous = _currentItems();
    emit(const ItemsLoading());
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
      );
      emit(ItemsCreateSuccess([...previous, created], created));
    } on PlanLimitException {
      emit(ItemsQuotaExceeded(previous));
    } on TierRequiredException {
      emit(ItemsQuotaExceeded(previous));
    } on AppException catch (e) {
      emit(ItemsActionFailure(previous, e.message));
    }
  }

  Future<void> _onUpdate(
    ItemsUpdateRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final previous = _currentItems();
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
      emit(ItemsSuccess(
        previous.map((i) => i.id == event.id ? updated : i).toList(),
      ));
    } on AppException catch (e) {
      emit(ItemsActionFailure(previous, e.message));
    }
  }

  Future<void> _onDelete(
    ItemsDeleteRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final previous = _currentItems();
    try {
      await _deleteItem(event.id);
      emit(ItemsSuccess(previous.where((i) => i.id != event.id).toList()));
    } on AppException catch (e) {
      emit(ItemsActionFailure(previous, e.message));
    }
  }

  List<Item> _currentItems() => switch (state) {
        ItemsSuccess(:final items) => items,
        ItemsActionFailure(:final items) => items,
        ItemsQuotaExceeded(:final items) => items,
        _ => const [],
      };
}
