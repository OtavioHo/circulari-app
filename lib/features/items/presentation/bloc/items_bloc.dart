import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/create_item_usecase.dart';
import '../../domain/usecases/delete_item_usecase.dart';
import '../../domain/usecases/get_items_usecase.dart';
import '../../domain/usecases/update_item_usecase.dart';
import '../../domain/usecases/upload_item_image_usecase.dart';
import 'items_event.dart';
import 'items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final GetItemsUsecase _getItems;
  final CreateItemUsecase _createItem;
  final UpdateItemUsecase _updateItem;
  final DeleteItemUsecase _deleteItem;
  final UploadItemImageUsecase _uploadImage;

  ItemsBloc({
    required GetItemsUsecase getItems,
    required CreateItemUsecase createItem,
    required UpdateItemUsecase updateItem,
    required DeleteItemUsecase deleteItem,
    required UploadItemImageUsecase uploadImage,
  })  : _getItems = getItems,
        _createItem = createItem,
        _updateItem = updateItem,
        _deleteItem = deleteItem,
        _uploadImage = uploadImage,
        super(const ItemsInitial()) {
    on<ItemsLoadRequested>(_onLoad);
    on<ItemsCreateRequested>(_onCreate);
    on<ItemsUpdateRequested>(_onUpdate);
    on<ItemsDeleteRequested>(_onDelete);
    on<ItemsImageUploadRequested>(_onImageUpload);
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
    try {
      var created = await _createItem(
        listId: event.listId,
        name: event.name,
        description: event.description,
        quantity: event.quantity,
        locationId: event.locationId,
        userDefinedValue: event.userDefinedValue,
      );
      // If an image was picked, upload it right after creation.
      if (event.imagePath != null) {
        try {
          created = await _uploadImage(created.id, event.imagePath!);
        } on AppException {
          // Image upload failed — item is still created, show it without image.
        }
      }
      emit(ItemsSuccess([...previous, created]));
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

  Future<void> _onImageUpload(
    ItemsImageUploadRequested event,
    Emitter<ItemsState> emit,
  ) async {
    final previous = _currentItems();
    try {
      final updated = await _uploadImage(event.itemId, event.imagePath);
      emit(ItemsSuccess(
        previous.map((i) => i.id == event.itemId ? updated : i).toList(),
      ));
    } on AppException catch (e) {
      emit(ItemsActionFailure(previous, e.message));
    }
  }

  List<Item> _currentItems() => switch (state) {
        ItemsSuccess(:final items) => items,
        ItemsActionFailure(:final items) => items,
        _ => const [],
      };
}
