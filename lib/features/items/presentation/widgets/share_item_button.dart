import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:circulari/features/items/presentation/bloc/share_item_cubit.dart';

/// Share affordance for the item, matching the neighbouring delete button.
///
/// The request goes through [ShareItemCubit] rather than being awaited in the
/// tap handler, so the widget never calls the API itself, and the platform
/// sheet is opened from the listener once the link arrives.
class ShareItemButton extends StatelessWidget {
  final String itemId;
  final bool disabled;

  const ShareItemButton({
    super.key,
    required this.itemId,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShareItemCubit, ShareItemState>(
      listener: (context, state) {
        switch (state) {
          case ShareItemReady(:final url):
            _openShareSheet(context, url);
          case ShareItemFailure(:final message):
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          case ShareItemInitial() || ShareItemLoading():
            break;
        }
      },
      builder: (context, state) {
        final isSharing = state is ShareItemLoading;
        return IconButton(
          onPressed: disabled || isSharing
              ? null
              : () => context.read<ShareItemCubit>().share(itemId),
          // Progress replaces the glyph in place, so the item stays on screen
          // — the page-level loading state would blank the whole body.
          icon: isSharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share_outlined),
          color: CirculariColorsTokens.greyscale700,
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: CirculariColorsTokens.greyscale700),
            ),
          ),
          tooltip: 'Compartilhar',
        );
      },
    );
  }

  Future<void> _openShareSheet(BuildContext context, String url) async {
    final cubit = context.read<ShareItemCubit>();
    // iPad anchors the popover to the origin rect; without it the sheet
    // throws there.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    // Shared as text rather than via shareUri: chat apps are the target and
    // they expect a plain URL in the message body.
    await Share.share(url, sharePositionOrigin: origin);
    // Idle again, so a second tap re-emits Ready instead of being ignored as
    // a repeat of the same state.
    cubit.reset();
  }
}
