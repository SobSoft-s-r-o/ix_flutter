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
/// Right-aligned per [position] and safe-area aware (upstream
/// `toast-container.scss:25-33`); its content sits inside a
/// [FocusTraversalGroup] using [ReadingOrderTraversalPolicy] so Tab visits
/// every toast's controls in on-screen order.
class IxToastOverlay extends StatefulWidget {
  const IxToastOverlay({
    super.key,
    required this.service,
    this.position = IxToastPosition.topRight,
    @Deprecated('Use position') this.alignment,
    this.strings = const IxToastStrings(),
    this.width = 280,
  });

  final IxToastService service;

  /// Which corner the toast stack anchors to.
  ///
  /// Defaults to [IxToastPosition.topRight] (1.x-compatible behaviour);
  /// 2.0 changes this default to [IxToastPosition.bottomRight].
  final IxToastPosition position;

  /// Superseded by [position]. When set, its `y` axis (top vs bottom) is
  /// still honoured for 1.x callers -- toasts are always right-aligned
  /// regardless of `alignment`'s `x` axis, matching [IxToastPosition]'s
  /// narrower (right-edge only) scope.
  @Deprecated('Use position')
  final Alignment? alignment;

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

  /// Resolves the vertical anchor: [alignment] (when set, for 1.x callers)
  /// takes precedence over [IxToastOverlay.position].
  bool get _isTopAligned {
    // ignore: deprecated_member_use_from_same_package
    final legacyAlignment = widget.alignment;
    if (legacyAlignment != null) {
      return legacyAlignment.y <= 0;
    }
    return widget.position == IxToastPosition.topRight;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final effectiveWidth = math.min(widget.width, screenSize.width - 32);
    final isTop = _isTopAligned;

    return Positioned(
      top: isTop ? 32 : null,
      bottom: isTop ? null : 32,
      right: 16,
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
