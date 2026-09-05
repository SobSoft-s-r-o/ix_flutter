import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:ix_flutter/ix_flutter.dart';

part 'ix_dropdown_menu.dart';

/// Visual variants of [IxDropdownButton]'s trigger.
///
/// Superseded by [IxButtonVariant]; pass it through
/// [IxDropdownButton.buttonVariant] instead. Removed in 2.0.
@Deprecated(
  'Use IxDropdownButton.buttonVariant with an IxButtonVariant instead. '
  'Removed in 2.0.',
)
enum IxDropdownButtonVariant {
  primary,
  secondary,
  tertiary,
  subtlePrimary,
  subtleSecondary,
  subtleTertiary,
  danger,
  subtleDanger,
}

/// Preferred position of the dropdown menu relative to its trigger.
///
/// `start`/`end` align the menu with the trigger's leading/trailing edge on
/// the cross axis. The menu flips to the opposite side when the preferred
/// side has no room, and is always shifted back inside the viewport.
enum IxDropdownPlacement {
  bottomStart,
  bottomEnd,
  topStart,
  topEnd,
  leftStart,
  leftEnd,
  rightStart,
  rightEnd,
}

/// Governs which interactions dismiss an open [IxDropdownButton] menu.
///
/// Mirrors the upstream `closeBehavior` property
/// (`dropdown-controller.ts:154-158`). `Escape` and `Tab` always close the
/// menu regardless of this setting, because a keyboard user must always be
/// able to leave the menu (WCAG 2.1.2 No Keyboard Trap).
enum IxDropdownCloseBehavior {
  /// Only selecting an item closes the menu.
  inside,

  /// Only a tap outside the trigger and the menu closes it.
  outside,

  /// Both an item selection and an outside tap close the menu.
  both,

  /// Neither closes the menu; the owner drives it via
  /// [IxDropdownButton.isOpen].
  none,
}

/// A single row of an [IxDropdownButton] menu.
class IxDropdownMenuItem<T> {
  /// Creates a dropdown menu row.
  const IxDropdownMenuItem({
    required this.label,
    required this.value,
    this.icon,
    this.disabled = false,
    this.checked = false,
  });

  /// The text rendered in the row, and the row's accessible name.
  final String label;

  /// The value reported to [IxDropdownButton.onItemSelected].
  final T value;

  /// An optional leading icon.
  final Widget? icon;

  /// Whether the row is inert: it cannot be focused, activated or reached by
  /// the arrow keys.
  final bool disabled;

  /// Whether the row is currently checked.
  ///
  /// A menu that contains at least one checked row reserves a leading
  /// checkmark column for every row, so the labels stay aligned.
  final bool checked;
}

/// A button that reveals a menu of actions, mirroring the Siemens IX
/// `<ix-dropdown-button>` web component.
///
/// ## Keyboard model
///
/// Mirrors upstream `dropdown.tsx` / `dropdown-focus.ts`:
///
/// | Key | On the trigger | In the menu |
/// | --- | --- | --- |
/// | `ArrowDown`, `Home`, `Enter`, `Space` | opens on the first item | — |
/// | `ArrowUp`, `End` | opens on the last item | — |
/// | `ArrowDown` / `ArrowUp` | — | cycles, skipping disabled rows |
/// | `Home` / `End` | — | first / last enabled row |
/// | `Enter` / `Space` | — | activates the focused row |
/// | `Escape` | closes an open menu, focus stays put | closes, focus returns to the trigger |
/// | `Tab` | — | closes, focus continues past the trigger |
///
/// `Escape` is handled on the trigger too: a menu whose rows are all
/// disabled (or that has none) leaves the focus on the trigger, so nothing
/// inside the menu would ever see the key (WCAG 2.1.2 No Keyboard Trap).
///
/// Every key that moves the focus also scrolls the menu by the smallest
/// amount that brings the focused row fully into view.
///
/// ## Open state
///
/// The widget is uncontrolled by default. Passing [isOpen] makes it
/// controlled: it then only ever *requests* a state change through
/// [onOpenChanged] and renders whatever [isOpen] says.
///
/// ```dart
/// IxDropdownButton<String>(
///   label: 'Actions',
///   items: const [IxDropdownMenuItem(label: 'Edit', value: 'edit')],
///   onItemSelected: (value) => debugPrint(value),
/// )
/// ```
class IxDropdownButton<T> extends StatefulWidget {
  /// Creates a Siemens IX dropdown button.
  const IxDropdownButton({
    super.key,
    required this.label,
    required this.items,
    @Deprecated(
      'Use buttonVariant with an IxButtonVariant instead. Removed in 2.0.',
    )
    // ignore: deprecated_member_use_from_same_package
    this.variant = IxDropdownButtonVariant.primary,
    this.buttonVariant,
    this.placement = IxDropdownPlacement.bottomStart,
    this.disabled = false,
    this.icon,
    this.onItemSelected,
    this.isOpen,
    this.onOpenChanged,
    this.onWillOpen,
    this.closeBehavior = IxDropdownCloseBehavior.both,
    this.maxHeight,
    this.semanticLabel,
  });

  /// The text label rendered on the trigger.
  final String label;

  /// The rows of the menu.
  final List<IxDropdownMenuItem<T>> items;

  /// The trigger's visual style.
  ///
  /// Ignored when [buttonVariant] is set.
  @Deprecated(
    'Use buttonVariant with an IxButtonVariant instead. Removed in 2.0.',
  )
  // ignore: deprecated_member_use_from_same_package
  final IxDropdownButtonVariant variant;

  /// The trigger's visual style, taking precedence over [variant].
  final IxButtonVariant? buttonVariant;

  /// The preferred position of the menu relative to the trigger.
  final IxDropdownPlacement placement;

  /// Whether the trigger is disabled.
  final bool disabled;

  /// An optional icon rendered before [label].
  final Widget? icon;

  /// Called with the selected row's value.
  final ValueChanged<T>? onItemSelected;

  /// When non-null, the menu's visibility is owned by the caller.
  ///
  /// The widget then never opens or closes on its own: it reports the
  /// requested state through [onOpenChanged] and renders [isOpen].
  final bool? isOpen;

  /// Called whenever the menu wants to open (`true`) or close (`false`).
  final ValueChanged<bool>? onOpenChanged;

  /// Consulted before the menu opens; returning `false` vetoes the request.
  ///
  /// [onOpenChanged] is not called for a vetoed request.
  final bool Function()? onWillOpen;

  /// Which interactions dismiss the open menu.
  final IxDropdownCloseBehavior closeBehavior;

  /// Maximum height of the menu, in logical pixels.
  ///
  /// Defaults to half the viewport height minus 48px; the menu scrolls
  /// vertically once its rows exceed it.
  final double? maxHeight;

  /// Accessible name of the trigger, replacing [label] for screen readers.
  final String? semanticLabel;

  @override
  State<IxDropdownButton<T>> createState() => _IxDropdownButtonState<T>();
}

class _IxDropdownButtonState<T> extends State<IxDropdownButton<T>> {
  final FocusNode _triggerFocus = FocusNode(
    debugLabel: 'IxDropdownButton.trigger',
  );
  final FocusScopeNode _menuFocusScope = FocusScopeNode(
    debugLabel: 'IxDropdownButton.menu',
  );
  final Map<int, FocusNode> _itemFocus = <int, FocusNode>{};
  final OverlayPortalController _portal = OverlayPortalController(
    debugLabel: 'IxDropdownButton.menu',
  );
  final Object _tapRegionGroupId = Object();

  bool _internalOpen = false;
  int? _focusedIndex;

  /// Whether the menu is currently open, honouring the controlled
  /// [IxDropdownButton.isOpen] property when it is set.
  bool get _isOpen => widget.isOpen ?? _internalOpen;

  @override
  void initState() {
    super.initState();
    // The overlay child is always mounted and renders nothing while the menu
    // is closed. Toggling the controller instead would have to happen from
    // `didUpdateWidget` in controlled mode, where `show()`/`hide()` are
    // forbidden (they run inside the build phase).
    _portal.show();
  }

  @override
  void didUpdateWidget(covariant IxDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusedIndex != null && _focusedIndex! >= widget.items.length) {
      _focusedIndex = null;
    }
  }

  @override
  void dispose() {
    _disposeItemFocusNodes();
    _menuFocusScope.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  void _disposeItemFocusNodes() {
    for (final node in _itemFocus.values) {
      node.dispose();
    }
    _itemFocus.clear();
  }

  /// Returns the focus node of row [index], creating it on first use.
  FocusNode _focusNodeFor(int index) => _itemFocus.putIfAbsent(
    index,
    () => FocusNode(debugLabel: 'IxDropdownButton.item[$index]'),
  );

  int? _firstEnabled() {
    for (var i = 0; i < widget.items.length; i++) {
      if (!widget.items[i].disabled) {
        return i;
      }
    }
    return null;
  }

  int? _lastEnabled() {
    for (var i = widget.items.length - 1; i >= 0; i--) {
      if (!widget.items[i].disabled) {
        return i;
      }
    }
    return null;
  }

  /// Requests focus for row [index] and scrolls it into view; the request is
  /// honoured as soon as the overlay attaches the node, so it is safe to call
  /// while opening.
  void _focusIndex(int? index) {
    if (index == null) {
      return;
    }
    _focusedIndex = index;
    final node = _focusNodeFor(index);
    node.requestFocus();
    _revealFocusedRow(node);
  }

  /// Scrolls the menu by the smallest amount that brings the row owning
  /// [node] fully into view, mirroring upstream's
  /// `element.scrollIntoView({block: 'nearest'})`
  /// (`dropdown-focus.ts:75-92`).
  ///
  /// The rows are all built eagerly, so focusing one that is scrolled out of
  /// sight would otherwise leave it focused but invisible (WCAG 2.4.7).
  ///
  /// The two `ensureVisible` calls are the "nearest" part: each of these
  /// policies only ever scrolls one way (`keepVisibleAtEnd` never scrolls
  /// backwards, `keepVisibleAtStart` never forwards) and a call whose
  /// computed target equals the current offset returns without touching the
  /// position, so exactly one of the pair moves the menu -- whichever
  /// direction the row happens to be off screen in. A single
  /// direction-of-travel policy would miss the cases where focus wraps
  /// (ArrowDown from the last row to the first) or opens on a row far down
  /// the list.
  void _revealFocusedRow(FocusNode node) {
    void reveal() {
      final nodeContext = node.context;
      if (nodeContext == null || !nodeContext.mounted) {
        return;
      }
      final duration = IxMotion.of(nodeContext, IxMotion.defaultTime);
      for (final policy in const [
        ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      ]) {
        Scrollable.ensureVisible(
          nodeContext,
          alignmentPolicy: policy,
          duration: duration,
          curve: Curves.easeOut,
        );
      }
    }

    if (node.context == null) {
      // The menu is still opening: this row has no element yet, so there is
      // nothing to scroll to until the overlay has been built and laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_isOpen) {
          return;
        }
        reveal();
      });
      return;
    }
    reveal();
  }

  /// Moves focus [delta] rows, cycling and skipping disabled rows.
  void _focusRelative(int delta) {
    final count = widget.items.length;
    if (count == 0) {
      return;
    }
    final start = _focusedIndex ?? (delta > 0 ? -1 : 0);
    for (var step = 1; step <= count; step++) {
      // Dart's `%` is Euclidean, so a negative dividend still wraps to a
      // valid index.
      final index = (start + delta * step) % count;
      if (!widget.items[index].disabled) {
        _focusIndex(index);
        return;
      }
    }
  }

  /// Opens or closes the menu.
  ///
  /// In controlled mode ([IxDropdownButton.isOpen] set) this only reports the
  /// request through [IxDropdownButton.onOpenChanged]; the overlay follows
  /// once the owner rebuilds with the new value.
  void _setOpen(bool open, {int? focusIndex}) {
    if (open == _isOpen) {
      return;
    }
    if (open && widget.onWillOpen?.call() == false) {
      return;
    }
    if (open) {
      _focusIndex(focusIndex);
    } else {
      _focusedIndex = null;
    }
    if (widget.isOpen == null) {
      setState(() => _internalOpen = open);
    }
    widget.onOpenChanged?.call(open);
    if (!open) {
      _triggerFocus.requestFocus();
    }
  }

  void _toggle() {
    if (widget.disabled) {
      return;
    }
    _setOpen(!_isOpen, focusIndex: _isOpen ? null : _firstEnabled());
  }

  void _selectItem(IxDropdownMenuItem<T> item) {
    widget.onItemSelected?.call(item.value);
    if (widget.closeBehavior == IxDropdownCloseBehavior.inside ||
        widget.closeBehavior == IxDropdownCloseBehavior.both) {
      _setOpen(false);
    }
  }

  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.disabled) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (_isOpen) {
      // Every row can be disabled (or there may be none at all), in which
      // case opening from the keyboard leaves the focus on the trigger and
      // the menu's own FocusScope never sees a key event. Escape must still
      // close the menu -- a keyboard user has to be able to leave it
      // (WCAG 2.1.2 No Keyboard Trap). Focus is already here, so it stays.
      if (key == LogicalKeyboardKey.escape) {
        _setOpen(false);
        return KeyEventResult.handled;
      }
      // Anything else while open belongs to the menu scope.
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.home ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _setOpen(true, focusIndex: _firstEnabled());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.end) {
      _setOpen(true, focusIndex: _lastEnabled());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onMenuKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _setOpen(false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      final forward = !HardwareKeyboard.instance.isShiftPressed;
      _setOpen(false);
      // The focused row is about to leave the tree, so traversal is resumed
      // from the trigger once the close has been applied.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (forward) {
          _triggerFocus.nextFocus();
        } else {
          _triggerFocus.previousFocus();
        }
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _focusRelative(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _focusRelative(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _focusIndex(_firstEnabled());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _focusIndex(_lastEnabled());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onTapOutside(PointerDownEvent event) {
    if (!_isOpen) {
      return;
    }
    if (widget.closeBehavior == IxDropdownCloseBehavior.outside ||
        widget.closeBehavior == IxDropdownCloseBehavior.both) {
      _setOpen(false);
    }
  }

  // ignore: deprecated_member_use_from_same_package
  IxButtonVariant _mapVariant(IxDropdownButtonVariant variant) {
    switch (variant) {
      case IxDropdownButtonVariant.primary:
        return IxButtonVariant.primary;
      case IxDropdownButtonVariant.secondary:
        return IxButtonVariant.secondary;
      case IxDropdownButtonVariant.tertiary:
        return IxButtonVariant.tertiary;
      case IxDropdownButtonVariant.subtlePrimary:
        return IxButtonVariant.subtlePrimary;
      case IxDropdownButtonVariant.subtleSecondary:
        return IxButtonVariant.subtleSecondary;
      case IxDropdownButtonVariant.subtleTertiary:
        return IxButtonVariant.subtleTertiary;
      case IxDropdownButtonVariant.danger:
        return IxButtonVariant.dangerPrimary;
      case IxDropdownButtonVariant.subtleDanger:
        return IxButtonVariant.dangerTertiary;
    }
  }

  /// Builds the overlay contents.
  ///
  /// Runs in the host's element tree, so the ambient `Theme`,
  /// `Directionality` and `MediaQuery` are the ones surrounding the trigger.
  /// [info] is recomputed on every layout, so the menu keeps following the
  /// trigger when the page around it scrolls or resizes.
  Widget _buildMenu(BuildContext context, OverlayChildLayoutInfo info) {
    if (!_isOpen) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final dropdownTheme =
        theme.extension<IxDropdownTheme>() ?? IxDropdownTheme.fallback(theme);
    final viewport = info.overlaySize;
    final triggerSize = info.childSize;
    final triggerOrigin = MatrixUtils.transformPoint(
      info.childPaintTransform,
      Offset.zero,
    );
    final maxHeight =
        widget.maxHeight ??
        math.max(0.0, viewport.height / 2 - _kMaxHeightInset);
    final reserveCheckColumn = widget.items.any((item) => item.checked);

    return CustomSingleChildLayout(
      delegate: _IxDropdownMenuLayout(
        triggerSize: triggerSize,
        triggerOrigin: triggerOrigin,
        viewport: viewport,
        placement: widget.placement,
        maxHeight: maxHeight,
      ),
      child: TapRegion(
        groupId: _tapRegionGroupId,
        child: FocusScope(
          node: _menuFocusScope,
          onKeyEvent: _onMenuKey,
          child: _IxDropdownMenu(
            theme: dropdownTheme,
            label: widget.semanticLabel ?? widget.label,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                _IxDropdownMenuItemTile<T>(
                  item: widget.items[i],
                  theme: dropdownTheme,
                  focusNode: widget.items[i].disabled ? null : _focusNodeFor(i),
                  reserveCheckColumn: reserveCheckColumn,
                  onFocused: () => _focusedIndex = i,
                  onTap: widget.items[i].disabled
                      ? null
                      : () => _selectItem(widget.items[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonTheme = Theme.of(context).extension<IxButtonTheme>();
    final variant =
        // ignore: deprecated_member_use_from_same_package
        widget.buttonVariant ?? _mapVariant(widget.variant);
    final buttonStyle = buttonTheme?.style(variant);

    return TapRegion(
      groupId: _tapRegionGroupId,
      onTapOutside: _onTapOutside,
      child: OverlayPortal.overlayChildLayoutBuilder(
        controller: _portal,
        overlayChildBuilder: _buildMenu,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _onTriggerKey,
          child: ElevatedButton(
            onPressed: widget.disabled ? null : _toggle,
            style: buttonStyle,
            focusNode: _triggerFocus,
            child: Semantics(
              expanded: _isOpen,
              label: widget.semanticLabel,
              child: ExcludeSemantics(
                excluding: widget.semanticLabel != null,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final label = Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: IxCommonGeometry.space1),
                        ],
                        // A `Flexible` label would assert inside a row with
                        // unbounded width (a trigger placed directly in
                        // another `Row`), so it only flexes when there is a
                        // width to shrink into.
                        if (constraints.maxWidth.isFinite)
                          Flexible(child: label)
                        else
                          label,
                        const SizedBox(width: IxCommonGeometry.space1),
                        // 16px, the size 1.x rendered this glyph at: a
                        // larger icon box would grow the trigger on every
                        // existing call site.
                        IxIcon.key(
                          _isOpen
                              ? IxIconKey.chevronUpSmall
                              : IxIconKey.chevronDownSmall,
                          size: IxIconSize.s16,
                          excludeFromSemantics: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
