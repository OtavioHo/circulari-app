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

  /// Cursor for the next page, or null when every page has been loaded.
  final String? nextCursor;

  /// True while a load-more request is in flight (small trailing indicator).
  final bool isLoadingMore;

  /// Server-computed sum of `user_defined_value` for ALL items in the list
  /// (all pages) — lets the header show a live total while later pages are
  /// still unloaded. Null when the server didn't send it.
  final double? totalValue;

  /// One-shot load-more failure message: set when a load-more request fails,
  /// cleared on the next attempt. While set, the page must not auto-dispatch
  /// further load-mores — retry happens via the snackbar action.
  final String? loadMoreError;

  const ItemsSuccess(
    this.items, {
    this.nextCursor,
    this.isLoadingMore = false,
    this.totalValue,
    this.loadMoreError,
  });

  bool get hasMore => nextCursor != null;

  /// Returns a base [ItemsSuccess] even when called on a subtype — the
  /// create-flow subtypes ([ItemsCreateInProgress]/[ItemsCreateSuccess]) are
  /// one-emit signals and must not persist across later transitions.
  ItemsSuccess copyWith({
    List<Item>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
    double? totalValue,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) => ItemsSuccess(
    items ?? this.items,
    nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    totalValue: totalValue ?? this.totalValue,
    loadMoreError: clearLoadMoreError
        ? null
        : (loadMoreError ?? this.loadMoreError),
  );
}

/// Emitted while a create request is in flight. Subtype of [ItemsSuccess] so
/// list views keep rendering the current items instead of blanking to a
/// spinner (update/delete already preserve items; create must too). The add
/// form watches this type to disable its submit button.
///
/// [isLoadingMore] and [loadMoreError] must be forwarded like every other
/// pagination field: list views gate load-more dispatch on them for ANY
/// [ItemsSuccess], so dropping them here would reopen the gate mid-flight and
/// fetch the same cursor twice, appending the page in duplicate.
final class ItemsCreateInProgress extends ItemsSuccess {
  const ItemsCreateInProgress(
    super.items, {
    super.nextCursor,
    super.isLoadingMore,
    super.totalValue,
    super.loadMoreError,
  });
}

/// Emitted when an item was just created. Subtype of [ItemsSuccess] so existing
/// listeners that observe successful state transitions still match.
final class ItemsCreateSuccess extends ItemsSuccess {
  final Item created;
  const ItemsCreateSuccess(
    super.items,
    this.created, {
    super.nextCursor,
    super.isLoadingMore,
    super.totalValue,
    super.loadMoreError,
  });
}

final class ItemsFailure extends ItemsState {
  final String message;
  const ItemsFailure(this.message);
}

/// Emitted when a create/update/delete/upload operation fails.
/// The [items] from before the operation are preserved so the UI stays
/// interactive, [nextCursor] so pagination survives the failure, and
/// [totalValue] so the header total doesn't flicker.
final class ItemsActionFailure extends ItemsState {
  final List<Item> items;
  final String message;
  final String? nextCursor;
  final double? totalValue;
  const ItemsActionFailure(
    this.items,
    this.message, {
    this.nextCursor,
    this.totalValue,
  });
}

/// Emitted when item creation is blocked by a plan limit.
/// The [items] from before the attempt are preserved so the UI stays
/// interactive, and [nextCursor]/[totalValue] so pagination and the header
/// total survive the block.
final class ItemsQuotaExceeded extends ItemsState {
  final List<Item> items;
  final String? nextCursor;
  final double? totalValue;
  const ItemsQuotaExceeded(this.items, {this.nextCursor, this.totalValue});
}
