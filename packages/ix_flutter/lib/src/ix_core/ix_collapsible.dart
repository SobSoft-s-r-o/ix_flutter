import 'package:flutter/widgets.dart';

/// Drives a controlled expand/collapse transition with an
/// [AnimationController] and a [SizeTransition], excluding the collapsing
/// content from focus and semantics for the whole transition and rescuing
/// the keyboard focus out of it first if needed.
///
/// Extracted from the near-identical machinery `IxBlind` and
/// `IxApplicationScaffold`'s menu category both built on their own (B9):
///
/// * An explicit controller rather than an `AnimatedSize`: under reduced
///   motion [duration] is [Duration.zero], and a zero-duration
///   `RenderAnimatedSize` re-dirties itself from inside its own
///   `performLayout()` whenever the size it is asked to animate changes (`A
///   RenderObject must not re-dirty itself while still being laid out`).
///   This controller instead snaps synchronously *outside* layout, and the
///   widget tree below keeps the same shape whatever the duration is -- so
///   flipping `MediaQuery.disableAnimations` while [child] is showing does
///   not remount its subtree either.
/// * [child] stays mounted (it is what the transition shrinks) until the
///   collapse animation actually finishes, not just until [expanded] turns
///   false -- otherwise there would be nothing left to shrink.
/// * A *collapsing* subtree is still mounted and painted, clipped, until
///   the last frame, so it must not be announced or reachable by Tab in the
///   meantime, or the focus could land on (or a screen reader could
///   announce) something about to be unmounted.
/// * If the keyboard focus is inside [child] when it starts collapsing, it
///   is moved to [returnFocusTo] first rather than letting the framework
///   drop it into the enclosing scope, so the next Tab continues from
///   there instead of restarting at the top of the page (WCAG 2.4.3).
///
/// Purely controlled: [expanded] is the only signal driving the
/// transition, exactly like `_CategoryChildren` was and `IxBlind`'s own
/// uncontrolled/controlled dual contract now feeds into from above.
///
/// Internal: not exported from the package barrel.
class IxCollapsible extends StatefulWidget {
  const IxCollapsible({
    super.key,
    required this.expanded,
    required this.duration,
    required this.returnFocusTo,
    required this.child,
  });

  /// Whether [child] is currently shown (or showing).
  final bool expanded;

  /// The transition's duration, already resolved against the ambient
  /// reduced-motion preference by the caller (e.g. via `IxMotion.of`).
  final Duration duration;

  /// Focus node requested when collapsing moves the keyboard focus out of
  /// [child].
  final FocusNode returnFocusTo;

  /// The content shown while expanded, built unconditionally by the
  /// caller: this widget decides when it is actually in the tree.
  final Widget child;

  @override
  State<IxCollapsible> createState() => _IxCollapsibleState();
}

class _IxCollapsibleState extends State<IxCollapsible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expansion;
  late final CurvedAnimation _heightFactor;

  /// A non-focusable, non-traversable ancestor of [IxCollapsible.child]: the
  /// `Focus` that keeps traversal out of a collapsed (or still collapsing)
  /// subtree, held as a node so [didUpdateWidget] can also ask whether the
  /// focus is inside it.
  final FocusNode _contentFocus = FocusNode(
    debugLabel: 'IxCollapsible.content',
    skipTraversal: true,
    canRequestFocus: false,
  );

  @override
  void initState() {
    super.initState();
    _expansion = AnimationController(
      vsync: this,
      value: widget.expanded ? 1.0 : 0.0,
      duration: widget.duration,
    );
    _heightFactor = CurvedAnimation(
      parent: _expansion,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant IxCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _expansion.duration = widget.duration;
    }
    if (widget.expanded == oldWidget.expanded) {
      return;
    }
    if (widget.expanded) {
      _expansion.forward();
      return;
    }
    // The content is about to stop being focusable (and, once the
    // transition ends, to leave the tree). Move the focus to the caller's
    // anchor *before* that rather than letting the framework drop it.
    if (_contentFocus.hasFocus) {
      widget.returnFocusTo.requestFocus();
    }
    _expansion.reverse().whenComplete(() {
      if (!mounted) {
        return;
      }
      // Rebuild so the now fully collapsed content leaves the tree; the
      // controller alone only repaints the transition, it does not rebuild
      // this widget.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _heightFactor.dispose();
    _expansion.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.expanded || !_expansion.isDismissed;
    return SizeTransition(
      sizeFactor: _heightFactor,
      alignment: Alignment.topCenter,
      child: Focus(
        focusNode: _contentFocus,
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: widget.expanded,
        child: ExcludeSemantics(
          excluding: !widget.expanded,
          child: hasContent
              ? widget.child
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ),
    );
  }
}
