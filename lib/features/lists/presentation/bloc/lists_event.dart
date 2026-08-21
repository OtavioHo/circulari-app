sealed class ListsEvent {
  const ListsEvent();
}

final class ListsLoadRequested extends ListsEvent {
  const ListsLoadRequested();
}

final class ListsDeleteRequested extends ListsEvent {
  final String id;
  const ListsDeleteRequested(this.id);
}
