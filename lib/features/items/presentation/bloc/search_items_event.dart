sealed class SearchItemsEvent {
  const SearchItemsEvent();
}

final class SearchItemsLoadRequested extends SearchItemsEvent {
  final String? search;
  const SearchItemsLoadRequested({this.search});
}

final class SearchItemsLoadMoreRequested extends SearchItemsEvent {
  const SearchItemsLoadMoreRequested();
}
