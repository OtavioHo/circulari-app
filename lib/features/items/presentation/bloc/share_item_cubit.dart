import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/bloc/safe_emit_mixin.dart';
import 'package:circulari/core/error/app_exception.dart';
import 'package:circulari/features/items/domain/usecases/share_item_usecase.dart';

sealed class ShareItemState {
  const ShareItemState();
}

final class ShareItemInitial extends ShareItemState {
  const ShareItemInitial();
}

final class ShareItemLoading extends ShareItemState {
  const ShareItemLoading();
}

/// The link is ready to hand to the platform share sheet.
final class ShareItemReady extends ShareItemState {
  final String url;
  const ShareItemReady(this.url);
}

final class ShareItemFailure extends ShareItemState {
  final String message;
  const ShareItemFailure(this.message);
}

/// Fetching an item's public share link.
///
/// Kept out of [ItemDetailBloc] deliberately: that bloc's loading state
/// replaces the whole page body with a spinner, which would blank the item
/// mid-share. A cubit scoped to the action leaves the page rendered — the
/// same split already used for revalue and AI analysis.
class ShareItemCubit extends Cubit<ShareItemState>
    with SafeEmitMixin<ShareItemState> {
  final ShareItemUsecase _shareItem;

  ShareItemCubit(this._shareItem) : super(const ShareItemInitial());

  Future<void> share(String itemId) async {
    // Guard against a double tap opening two share sheets.
    if (state is ShareItemLoading) return;
    emit(const ShareItemLoading());
    try {
      safeEmit(ShareItemReady(await _shareItem(itemId)));
    } on AppException catch (e) {
      safeEmit(ShareItemFailure(e.message));
    }
  }

  /// Back to idle once the share sheet has been handed the link, so the next
  /// tap emits [ShareItemReady] again instead of being swallowed as a repeat.
  void reset() => safeEmit(const ShareItemInitial());
}
