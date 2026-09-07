import 'package:flutter/widgets.dart';

import 'ix_motion.dart';

/// Requests focus for [node] and scrolls the nearest [Scrollable] just far
/// enough to bring it into view, resolving the scroll duration from
/// [IxMotion.of] (reduced-motion aware) at [node]'s own context.
///
/// Extracted from the near-identical machinery `IxApplicationScaffold`'s
/// `_focusTile` and `IxDropdownButton`'s `_revealFocusedRow` both built on
/// their own (B9): every row/tile in both menus is built eagerly (neither
/// uses a lazy list), so a focused one always has *a* context to reveal --
/// except a dropdown row asked to focus while its menu overlay is still
/// opening, which is what [retryUntilBuilt] is for.
///
/// [alignmentPolicy] set (the scaffold menu, which knows which direction --
/// [alignment] -- the focus travelled in) aligns to that one edge with a
/// single [Scrollable.ensureVisible] call. Left `null` (the dropdown menu,
/// which does not track a direction) instead makes two calls, one per
/// [ScrollPositionAlignmentPolicy.keepVisibleAtEnd]/
/// [ScrollPositionAlignmentPolicy.keepVisibleAtStart] -- upstream's
/// `element.scrollIntoView({block: 'nearest'})` (`dropdown-focus.ts:75-92`):
/// each policy only ever scrolls one way and is a no-op if its computed
/// target is already the current offset, so exactly one of the pair moves
/// the scrollable, whichever direction the row happens to be off screen in
/// -- covering wrap-around and "opens on a row far down the list" alike.
///
/// [retryUntilBuilt], when given, is polled from a post-frame callback
/// (and again after each subsequent frame) until it returns `true`, for a
/// node whose tile/row has no context *yet* -- typically because the menu
/// that will contain it is still being laid out for the first time. The
/// scroll is skipped (though the focus request above already went through)
/// once it does return `true` if [node] still has no context even then, or
/// if the callback itself is `null` and none was available immediately.
void revealFocused(
  FocusNode node, {
  double alignment = 0.0,
  ScrollPositionAlignmentPolicy? alignmentPolicy,
  bool Function()? retryUntilBuilt,
}) {
  node.requestFocus();

  void reveal() {
    final context = node.context;
    if (context == null || !context.mounted) {
      return;
    }
    final duration = IxMotion.of(context, IxMotion.defaultTime);
    if (alignmentPolicy != null) {
      Scrollable.ensureVisible(
        context,
        alignment: alignment,
        alignmentPolicy: alignmentPolicy,
        duration: duration,
      );
      return;
    }
    for (final policy in const [
      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    ]) {
      Scrollable.ensureVisible(
        context,
        alignmentPolicy: policy,
        duration: duration,
        curve: Curves.easeOut,
      );
    }
  }

  if (node.context == null && retryUntilBuilt != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!retryUntilBuilt()) {
        return;
      }
      reveal();
    });
    return;
  }
  reveal();
}
