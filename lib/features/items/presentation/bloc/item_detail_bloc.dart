import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/update_item_usecase.dart';
import 'item_detail_event.dart';
import 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final UpdateItemUsecase _updateItem;
  final DeleteItemUsecase _deleteItem;

  ItemDetailBloc({
    required Item item,
    required UpdateItemUsecase updateItem,
    required DeleteItemUsecase deleteItem,
  })  : _updateItem = updateItem,
        _deleteItem = deleteItem,
        super(ItemDetailInitial(item)) {
    on<ItemDetailUpdateRequested>(_onUpdate);
    on<ItemDetailDeleteRequested>(_onDelete);
  }

  Item get _currentItem => switch (state) {
        ItemDetailInitial(:final item) => item,
        ItemDetailLoading(:final item) => item,
        ItemDetailSuccess(:final item) => item,
        ItemDetailFailure(:final item) => item,
        ItemDetailDeleted() => throw StateError('item already deleted'),
      };

  Future<void> _onUpdate(
    ItemDetailUpdateRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    final current = _currentItem;
    emit(ItemDetailLoading(current));
    try {
      final updated = await _updateItem(
        event.id,
        name: event.name,
        description: event.description,
        quantity: event.quantity,
        categoryId: event.categoryId,
        userDefinedValue: event.userDefinedValue,
      );
      emit(ItemDetailSuccess(updated));
    } on AppException catch (e) {
      emit(ItemDetailFailure(current, e.message));
    }
  }

  Future<void> _onDelete(
    ItemDetailDeleteRequested event,
    Emitter<ItemDetailState> emit,
  ) async {
    final current = _currentItem;
    emit(ItemDetailLoading(current));
    try {
      await _deleteItem(event.id);
      emit(const ItemDetailDeleted());
    } on AppException catch (e) {
      emit(ItemDetailFailure(current, e.message));
    }
  }
}
