import '../../domain/entities/item.dart';

sealed class ItemsState {
  const ItemsState();
}

final class ItemsInitial extends ItemsState {
  const ItemsInitial();
}

final class ItemsLoading extends ItemsState {
  const ItemsLoading();
}

final class ItemsSuccess extends ItemsState {
  final List<Item> items;
  const ItemsSuccess(this.items);
}

final class ItemsFailure extends ItemsState {
  final String message;
  const ItemsFailure(this.message);
}

/// Emitted when a create/update/delete/upload operation fails.
/// The [items] from before the operation are preserved so the UI stays interactive.
final class ItemsActionFailure extends ItemsState {
  final List<Item> items;
  final String message;
  const ItemsActionFailure(this.items, this.message);
}
