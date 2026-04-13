sealed class ListsEvent {
  const ListsEvent();
}

final class ListsLoadRequested extends ListsEvent {
  const ListsLoadRequested();
}

final class ListsCreateRequested extends ListsEvent {
  final String name;
  const ListsCreateRequested(this.name);
}

final class ListsRenameRequested extends ListsEvent {
  final String id;
  final String name;
  const ListsRenameRequested(this.id, this.name);
}

final class ListsDeleteRequested extends ListsEvent {
  final String id;
  const ListsDeleteRequested(this.id);
}
