import 'package:circulari/features/items/domain/entities/item.dart';

sealed class SearchItemsState {
  const SearchItemsState();
}

final class SearchItemsInitial extends SearchItemsState {
  const SearchItemsInitial();
}

final class SearchItemsLoading extends SearchItemsState {
  const SearchItemsLoading();
}

final class SearchItemsSuccess extends SearchItemsState {
  final List<Item> items;
  final String? nextCursor;
  final bool isLoadingMore;

  const SearchItemsSuccess({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null;

  SearchItemsSuccess copyWith({
    List<Item>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) =>
      SearchItemsSuccess(
        items: items ?? this.items,
        nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

final class SearchItemsFailure extends SearchItemsState {
  final String message;
  const SearchItemsFailure(this.message);
}
