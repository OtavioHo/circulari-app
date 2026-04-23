class PaginatedResult<T> {
  final List<T> data;
  final String? nextCursor;

  const PaginatedResult({required this.data, this.nextCursor});

  bool get hasMore => nextCursor != null;
}
