import 'package:circulari/features/lists/domain/entities/item_list.dart';

sealed class ListsState {
  const ListsState();
}

final class ListsInitial extends ListsState {
  const ListsInitial();
}

final class ListsLoading extends ListsState {
  const ListsLoading();
}

final class ListsSuccess extends ListsState {
  final List<ItemList> lists;
  const ListsSuccess(this.lists);
}

final class ListsFailure extends ListsState {
  final String message;
  const ListsFailure(this.message);
}

/// Emitted when a create/rename/delete operation fails.
/// The [lists] from before the operation are preserved so the UI stays
/// interactive and the user can retry or keep working.
final class ListsActionFailure extends ListsState {
  final List<ItemList> lists;
  final String message;
  const ListsActionFailure(this.lists, this.message);
}
