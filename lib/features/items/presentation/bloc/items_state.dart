import 'package:circulari/features/items/domain/entities/item.dart';

sealed class ItemsState {
  const ItemsState();
}

final class ItemsInitial extends ItemsState {
  const ItemsInitial();
}

final class ItemsLoading extends ItemsState {
  const ItemsLoading();
}

base class ItemsSuccess extends ItemsState {
  final List<Item> items;
  const ItemsSuccess(this.items);
}

/// Emitted while a create request is in flight. Subtype of [ItemsSuccess] so
/// list views keep rendering the current items instead of blanking to a
/// spinner (update/delete already preserve items; create must too). The add
/// form watches this type to disable its submit button.
final class ItemsCreateInProgress extends ItemsSuccess {
  const ItemsCreateInProgress(super.items);
}

/// Emitted when an item was just created. Subtype of [ItemsSuccess] so existing
/// listeners that observe successful state transitions still match.
final class ItemsCreateSuccess extends ItemsSuccess {
  final Item created;
  const ItemsCreateSuccess(super.items, this.created);
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

/// Emitted when item creation is blocked by a plan limit.
/// The [items] from before the attempt are preserved so the UI stays interactive.
final class ItemsQuotaExceeded extends ItemsState {
  final List<Item> items;
  const ItemsQuotaExceeded(this.items);
}
