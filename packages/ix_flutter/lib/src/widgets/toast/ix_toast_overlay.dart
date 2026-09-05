import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:ix_flutter/src/ix_core/ix_motion.dart';

import 'ix_toast.dart';
import 'ix_toast_data.dart';
import 'ix_toast_position.dart';
import 'ix_toast_service.dart';
import 'ix_toast_strings.dart';

/// Overlay widget that renders the stack of active toasts.
///
/// Safe-area aware (upstream `toast-container.scss:25-33`); its content
/// sits inside a [FocusTraversalGroup] using [ReadingOrderTraversalPolicy]
/// so Tab visits every toast's controls in on-screen order.
class IxToastOverlay extends StatefulWidget {
  const IxToastOverlay({
    super.key,
    required this.service,
    @Deprecated('Use placement') this.position = Alignment.topRight,
    this.placement = IxToastPosition.topRight,
    this.strings = const IxToastStrings(),
    this.width = 280,
  });

  final IxToastService service;

  /// Superseded by [placement]. Kept, and still fully functional (both
  /// axes honoured, exactly as before [placement] existed), for 1.x
  /// callers -- when set to anything other than its own default
  /// ([Alignment.topRight]), it takes precedence over [placement].
  @Deprecated('Use placement')
  final Alignment position;

  /// Which corner the toast stack anchors to (always right-edge; upstream
  /// only defines a top/bottom axis).
  ///
  /// Defaults to [IxToastPosition.topRight] (1.x-compatible behaviour);
  /// 2.0 changes this default to [IxToastPosition.bottomRight]. Ignored
  /// when [position] is set to anything other than its own default.
  final IxToastPosition placement;

  /// Localizable chrome strings, forwarded to every [IxToast].
  final IxToastStrings strings;

  /// Target card width in logical pixels; shrinks to fit narrower
  /// viewports instead of overflowing past a 16px screen margin.
  final double width;

  @override
  State<IxToastOverlay> createState() => _IxToastOverlayState();
}

class _IxToastOverlayState extends State<IxToastOverlay> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<IxToastData> _displayedToasts = [];

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onServiceChanged);
    _displayedToasts.addAll(widget.service.toasts);
  }

  @override
  void didUpdateWidget(covariant IxToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service == widget.service) {
      return;
    }
    oldWidget.service.removeListener(_onServiceChanged);
    widget.service.addListener(_onServiceChanged);

    // A service identity swap is a rare reconfiguration, not a user-facing
    // toast transition -- there's nothing worth animating here. Instantly
    // clear whatever the old service had on screen and reseed with the new
    // service's current toasts, keeping the AnimatedList's own item count
    // in sync with _displayedToasts.
    for (var i = _displayedToasts.length - 1; i >= 0; i--) {
      final toast = _displayedToasts.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) => _buildItem(toast, animation),
        duration: Duration.zero,
      );
    }
    _displayedToasts.addAll(widget.service.toasts);
    for (var i = 0; i < _displayedToasts.length; i++) {
      _listKey.currentState?.insertItem(i, duration: Duration.zero);
    }
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    final newToasts = widget.service.toasts;

    // Find items to remove
    for (var i = _displayedToasts.length - 1; i >= 0; i--) {
      final toast = _displayedToasts[i];
      if (!newToasts.contains(toast)) {
        final removedItem = _displayedToasts.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildItem(removedItem, animation),
          duration: IxMotion.of(context, IxMotion.medium),
        );
      }
    }

    // Find items to add
    for (var i = 0; i < newToasts.length; i++) {
      final toast = newToasts[i];
      if (!_displayedToasts.contains(toast)) {
        _displayedToasts.insert(i, toast);
        _listKey.currentState?.insertItem(
          i,
          duration: IxMotion.of(context, IxMotion.medium),
        );
        // toast.tsx:231-238 -- announce new toasts imperatively too, so
        // assistive technology picks the change up even where structural
        // live-region diffing might not (a brand new subtree rather than a
        // text update inside an existing node). Guards against a literal
        // `null` in the announcement when there's no title.
        //
        // SemanticsService.announce(message, textDirection) -- the plain
        // two-argument form -- is deprecated in this Flutter version
        // ("incompatible with multiple windows"; verified via `flutter
        // analyze`); sendAnnouncement is its View-scoped replacement.
        SemanticsService.sendAnnouncement(
          View.of(context),
          toast.title == null
              ? toast.message
              : '${toast.title} ${toast.message}',
          Directionality.of(context),
        );
      }
    }
  }

  Widget _buildItem(IxToastData toast, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0), // Slide from right
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: IxToast(
            data: toast,
            strings: widget.strings,
            onDismiss: () => widget.service.dismiss(toast.id),
            onEnter: () => widget.service.pauseTimer(toast.id),
            onExit: () => widget.service.resumeTimer(toast.id),
          ),
        ),
      ),
    );
  }

  /// Resolves the four [Positioned] edge offsets.
  ///
  /// [IxToastOverlay.position] (when set to anything other than its own
  /// [Alignment.topRight] default) takes precedence and is honoured on
  /// both axes exactly as it was before [IxToastOverlay.placement]
  /// existed; otherwise [IxToastOverlay.placement] anchors the (always
  /// right-edge) top/bottom corner.
  ({double? top, double? bottom, double? left, double? right}) get _edges {
    // ignore: deprecated_member_use_from_same_package
    final legacyPosition = widget.position;
    if (legacyPosition != Alignment.topRight) {
      return (
        top: legacyPosition.y == -1.0 ? 16 : null,
        bottom: legacyPosition.y == 1.0 ? 16 : null,
        left: legacyPosition.x == -1.0 ? 16 : null,
        right: legacyPosition.x == 1.0 ? 16 : null,
      );
    }
    final isTop = widget.placement == IxToastPosition.topRight;
    return (
      top: isTop ? 32 : null,
      bottom: isTop ? null : 32,
      left: null,
      right: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final effectiveWidth = math.min(widget.width, screenSize.width - 32);
    final edges = _edges;

    return Positioned(
      top: edges.top,
      bottom: edges.bottom,
      left: edges.left,
      right: edges.right,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenSize.height),
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: SizedBox(
              width: effectiveWidth,
              child: AnimatedList(
                shrinkWrap: true,
                key: _listKey,
                initialItemCount: _displayedToasts.length,
                itemBuilder: (context, index, animation) {
                  if (index >= _displayedToasts.length) {
                    return const SizedBox.shrink();
                  }
                  return _buildItem(_displayedToasts[index], animation);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
