part of 'ix_dropdown_button.dart';

/// Gap in logical pixels between the trigger and the menu.
const double _kMenuGap = IxCommonGeometry.spaceNeg1;

/// Minimum distance in logical pixels between the menu and the viewport edge.
const double _kViewportMargin = IxCommonGeometry.space1;

/// Subtracted from half the viewport height to derive the default menu
/// height budget.
const double _kMaxHeightInset = 48.0;

/// Identifies the menu surface so widget tests can measure and scroll it.
const Key _kMenuKey = Key('ix-dropdown-menu');

/// Positions the dropdown menu relative to its trigger.
///
/// Works in the target `Overlay`'s coordinate space: [triggerOrigin],
/// [viewport] and the returned offset are all measured from the overlay's
/// top-left corner. The delegate flips the menu to the opposite side when the
/// preferred one has no room, and always shifts it back inside [viewport],
/// leaving a [_kViewportMargin] gap.
class _IxDropdownMenuLayout extends SingleChildLayoutDelegate {
  const _IxDropdownMenuLayout({
    required this.triggerSize,
    required this.triggerOrigin,
    required this.viewport,
    required this.textDirection,
    required this.placement,
    required this.maxHeight,
  });

  final Size triggerSize;
  final Offset triggerOrigin;

  /// The area the menu may occupy, safe area already removed.
  final Rect viewport;

  /// Resolves the `start`/`end` half of a vertical [placement]: `start` is
  /// the reading start, so it is the trigger's right edge in RTL.
  final TextDirection textDirection;

  final IxDropdownPlacement placement;
  final double maxHeight;

  bool get _isVertical => switch (placement) {
    IxDropdownPlacement.bottomStart ||
    IxDropdownPlacement.bottomEnd ||
    IxDropdownPlacement.topStart ||
    IxDropdownPlacement.topEnd => true,
    _ => false,
  };

  bool get _prefersAfter => switch (placement) {
    IxDropdownPlacement.bottomStart ||
    IxDropdownPlacement.bottomEnd ||
    IxDropdownPlacement.rightStart ||
    IxDropdownPlacement.rightEnd => true,
    _ => false,
  };

  bool get _alignsToStart => switch (placement) {
    IxDropdownPlacement.bottomStart ||
    IxDropdownPlacement.topStart ||
    IxDropdownPlacement.leftStart ||
    IxDropdownPlacement.rightStart => true,
    _ => false,
  };

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      Size(
        math.max(0.0, viewport.width - 2 * _kViewportMargin),
        math.max(0.0, maxHeight),
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double main;
    double cross;
    if (_isVertical) {
      main = _resolveMain(
        extent: childSize.height,
        triggerStart: triggerOrigin.dy,
        triggerExtent: triggerSize.height,
        viewportStart: viewport.top,
        viewportEnd: viewport.bottom,
      );
      cross = _resolveCross(
        extent: childSize.width,
        triggerStart: triggerOrigin.dx,
        triggerExtent: triggerSize.width,
        // `start` is the reading start on the horizontal cross axis, so RTL
        // pins the menu's right edge to the trigger's right edge.
        alignsToStart: _alignsToStart == (textDirection == TextDirection.ltr),
      );
      return Offset(
        _clamp(cross, childSize.width, viewport.left, viewport.right),
        _clamp(main, childSize.height, viewport.top, viewport.bottom),
      );
    }
    main = _resolveMain(
      extent: childSize.width,
      triggerStart: triggerOrigin.dx,
      triggerExtent: triggerSize.width,
      viewportStart: viewport.left,
      viewportEnd: viewport.right,
    );
    cross = _resolveCross(
      extent: childSize.height,
      triggerStart: triggerOrigin.dy,
      triggerExtent: triggerSize.height,
      // The cross axis of a left/right placement is vertical, which the
      // reading direction does not mirror.
      alignsToStart: _alignsToStart,
    );
    return Offset(
      _clamp(main, childSize.width, viewport.left, viewport.right),
      _clamp(cross, childSize.height, viewport.top, viewport.bottom),
    );
  }

  /// Resolves the position along the placement axis, flipping to the other
  /// side of the trigger when the preferred side cannot fit the menu.
  ///
  /// Both candidates are compared by the slack they leave against the
  /// viewport margin — how much room is left over *after* the menu's own
  /// [extent] is placed there. A non-negative slack means the menu fits on
  /// that side; when neither side fits, the roomier one wins and [_clamp]
  /// pushes the menu back into the viewport.
  double _resolveMain({
    required double extent,
    required double triggerStart,
    required double triggerExtent,
    required double viewportStart,
    required double viewportEnd,
  }) {
    final after = triggerStart + triggerExtent + _kMenuGap;
    final before = triggerStart - _kMenuGap - extent;
    final slackAfter = viewportEnd - _kViewportMargin - after - extent;
    final slackBefore = before - viewportStart - _kViewportMargin;
    if (_prefersAfter) {
      return slackAfter >= 0 || slackBefore <= slackAfter ? after : before;
    }
    return slackBefore >= 0 || slackAfter <= slackBefore ? before : after;
  }

  /// Resolves the position along the cross axis (`start`/`end` alignment).
  double _resolveCross({
    required double extent,
    required double triggerStart,
    required double triggerExtent,
    required bool alignsToStart,
  }) {
    return alignsToStart ? triggerStart : triggerStart + triggerExtent - extent;
  }

  /// Keeps [position] inside the viewport with a [_kViewportMargin] gap.
  double _clamp(
    double position,
    double extent,
    double viewportStart,
    double viewportEnd,
  ) {
    final minPosition = viewportStart + _kViewportMargin;
    final maxPosition = math.max(
      minPosition,
      viewportEnd - _kViewportMargin - extent,
    );
    return position.clamp(minPosition, maxPosition);
  }

  @override
  bool shouldRelayout(covariant _IxDropdownMenuLayout oldDelegate) {
    return triggerSize != oldDelegate.triggerSize ||
        triggerOrigin != oldDelegate.triggerOrigin ||
        viewport != oldDelegate.viewport ||
        textDirection != oldDelegate.textDirection ||
        placement != oldDelegate.placement ||
        maxHeight != oldDelegate.maxHeight;
  }
}

/// The menu surface: a content-sized, scrollable card with `menu` semantics.
class _IxDropdownMenu extends StatefulWidget {
  const _IxDropdownMenu({
    required this.theme,
    required this.label,
    required this.children,
  });

  final IxDropdownTheme theme;
  final String label;
  final List<Widget> children;

  @override
  State<_IxDropdownMenu> createState() => _IxDropdownMenuState();
}

class _IxDropdownMenuState extends State<_IxDropdownMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late final CurvedAnimation _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  bool _forwardStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The reduced-motion-aware duration depends on MediaQuery, which is only
    // safe to read from didChangeDependencies (not initState).
    _controller.duration = IxMotion.of(context, IxMotion.defaultTime);
    if (!_forwardStarted) {
      _forwardStarted = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Semantics(
      // The framework asserts that a `menu` node has at least one child, so
      // a menu without items stays role-less rather than crashing.
      role: widget.children.isEmpty ? null : SemanticsRole.menu,
      explicitChildNodes: true,
      label: widget.label,
      child: FadeTransition(
        opacity: _opacity,
        // The menu is open from the first frame of the fade; a screen reader
        // must see its rows then, not once the animation has finished. It
        // also keeps the `menu` role above legal: a fully transparent
        // `FadeTransition` drops its child's semantics, which would leave
        // this node child-less and trip the framework's "a menu cannot be
        // empty" assertion on the opening frame.
        alwaysIncludeSemantics: true,
        child: DecoratedBox(
          key: _kMenuKey,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.borderRadius),
            boxShadow: theme.shadow,
          ),
          child: Material(
            type: MaterialType.card,
            color: theme.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(theme.borderRadius),
              side: BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicWidth(
              child: SingleChildScrollView(
                padding: theme.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single dropdown menu row.
///
/// Carries `menuItem` semantics, a 1px `focusBdr` [IxFocusRing] drawn inside
/// the row (upstream `dropdown-item.scss:106-131` uses a negative outline
/// offset, so the ring never overlaps the neighbouring rows or the menu's
/// rounded corners) and the Siemens IX hover/active row backgrounds.
class _IxDropdownMenuItemTile<T> extends StatefulWidget {
  const _IxDropdownMenuItemTile({
    required this.item,
    required this.theme,
    required this.focusNode,
    required this.reserveCheckColumn,
    required this.onTap,
  });

  final IxDropdownMenuItem<T> item;
  final IxDropdownTheme theme;
  final FocusNode? focusNode;
  final bool reserveCheckColumn;
  final VoidCallback? onTap;

  @override
  State<_IxDropdownMenuItemTile<T>> createState() =>
      _IxDropdownMenuItemTileState<T>();
}

class _IxDropdownMenuItemTileState<T>
    extends State<_IxDropdownMenuItemTile<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = widget.theme;
    final style = theme.itemTextStyle.copyWith(
      color: item.disabled ? theme.itemDisabledText : theme.itemText,
    );

    return Semantics(
      role: SemanticsRole.menuItem,
      button: !item.disabled,
      enabled: !item.disabled,
      checked: item.checked ? true : null,
      label: item.label,
      child: IxFocusRing(
        focused: _focused,
        // A negative offset keeps the 1px ring inside the row's own bounds.
        offset: -IxCommonGeometry.focusBorderThickness,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        child: InkWell(
          focusNode: widget.focusNode,
          onTap: widget.onTap,
          focusColor: Colors.transparent,
          hoverColor: theme.itemHover,
          highlightColor: theme.itemActive,
          splashColor: theme.itemActive,
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: theme.itemHeight),
              child: Padding(
                padding: theme.itemPadding,
                child: Row(
                  children: [
                    if (widget.reserveCheckColumn)
                      SizedBox(
                        width: theme.checkColumnWidth,
                        // `IxIconKey` has no plain checkmark entry, so the
                        // Material glyph is passed as explicit icon data
                        // rather than widening the resolver contract.
                        child: item.checked
                            ? IxIcon(
                                const IxMaterialIconData(Icons.check),
                                size: IxIconSize.s16,
                                color: style.color,
                                excludeFromSemantics: true,
                              )
                            : null,
                      ),
                    if (item.icon != null) ...[
                      item.icon!,
                      const SizedBox(width: IxCommonGeometry.space1),
                    ],
                    Flexible(
                      child: Text(
                        item.label,
                        style: style,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
