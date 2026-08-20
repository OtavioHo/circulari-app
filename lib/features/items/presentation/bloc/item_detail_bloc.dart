import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/domain/usecases/delete_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/update_item_usecase.dart';
import 'package:circulari/features/items/domain/usecases/upload_item_image_usecase.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_event.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final UpdateItemUsecase _updateItem;
  final DeleteItemUsecase _deleteItem;
  final UploadItemImageUsecase _uploadItemImage;

  ItemDetailBloc({
    required Item item,
    required UpdateItemUsecase updateItem,
    required DeleteItemUsecase deleteItem,
    required UploadItemImageUsecase uploadItemImage,
  })  : _updateItem = updateItem,
        _deleteItem = deleteItem,
        _uploadItemImage = uploadItemImage,
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
    final Item updated;
    try {
      updated = await _updateItem(
        event.id,
        name: event.name,
        description: event.description,
        quantity: event.quantity,
        categoryId: event.categoryId,
        userDefinedValue: event.userDefinedValue,
        aiAnalysisId: event.aiAnalysisId,
      );
    } on AppException catch (e) {
      // The field update itself failed — keep the pre-edit item.
      emit(ItemDetailFailure(current, e.message));
      return;
    }
    final imagePath = event.imagePath;
    if (imagePath == null) {
      emit(ItemDetailSuccess(updated));
      return;
    }
    // A new photo rides along with the edit: upload it after the field
    // update. An upload failure must not discard the successful update —
    // the Failure keeps the updated item and snackbars the message.
    try {
      final withImage = await _uploadItemImage(event.id, imagePath);
      emit(ItemDetailSuccess(withImage));
    } on AppException catch (e) {
      emit(ItemDetailFailure(updated, e.message));
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
