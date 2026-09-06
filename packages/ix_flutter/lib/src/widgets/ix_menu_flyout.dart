import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ix_colors/ix_theme_color_tokens.dart';
import '../ix_core/ix_common_geometry.dart';
import '../ix_core/ix_tap_region_group.dart';
import '../ix_core/ix_typography.dart';
import '../ix_icons/ix_icon.dart';
import '../ix_icons/ix_icon_key.dart';
import '../ix_theme/ix_theme_builder.dart';
import 'i18n/ix_application_strings.dart';
import 'ix_icon_button.dart';

/// Identifies the fly-out surface so widget tests can measure it.
const Key kIxMenuFlyoutKey = Key('ix-menu-flyout');

/// Internal overlay panel anchored to the trailing edge of the application
/// menu, used for the fly-out of a category in a collapsed menu and for the
/// built-in settings/about panels.
///
/// Not exported from `package:ix_flutter/ix_flutter.dart`: it is an
/// implementation detail of `IxApplicationScaffold`, whose `settings:`,
/// `about:` and collapsed-rail categories drive it.
///
/// The panel owns its own [FocusScope] and dismisses on `Escape` or a tap
/// outside, returning focus to [returnFocusTo] (the menu tile that opened
/// it) so keyboard users never lose their place.
class IxMenuFlyout extends StatefulWidget {
  /// Creates a fly-out panel.
  ///
  /// The owner positions it; this widget only sizes and decorates itself.
  const IxMenuFlyout({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
    this.width = 320,
    this.maxHeight,
    this.returnFocusTo,
    this.strings = const IxApplicationStrings(),
    this.groupId,
  });

  /// Heading rendered above [child].
  final String title;

  /// Called when the panel asks to be dismissed (close button, `Escape`, or
  /// a tap outside its [groupId]).
  final VoidCallback onClose;

  /// The panel's content.
  final Widget child;

  /// Fixed width of the panel in logical pixels.
  ///
  /// The owner clamps this to the room left beside the menu, so the panel
  /// never runs off the viewport.
  final double width;

  /// Upper bound for the panel's height; the content scrolls beyond it.
  final double? maxHeight;

  /// Focus node that regains focus once the panel closes.
  final FocusNode? returnFocusTo;

  /// Localizable strings; only [IxApplicationStrings.closePanel] is used.
  final IxApplicationStrings strings;

  /// Shared [TapRegion] group of the menu that owns this panel, so tapping
  /// the menu itself is not treated as a tap outside.
  final Object? groupId;

  @override
  State<IxMenuFlyout> createState() => _IxMenuFlyoutState();
}

class _IxMenuFlyoutState extends State<IxMenuFlyout> {
  final _scope = FocusScopeNode(debugLabel: 'IxMenuFlyout');

  /// Stands in for [IxMenuFlyout.groupId] when the owner declared none, so
  /// the subtree always has one group to attach an overlay to.
  final Object _fallbackGroupId = Object();

  @override
  void initState() {
    super.initState();
    // The panel takes focus so its rows are reachable by keyboard and
    // `Escape` reaches this scope. `autofocus:` alone is not enough -- an
    // autofocus request is dropped whenever the surrounding scope already
    // has a focused child, and the menu tile that opened this panel is
    // exactly that -- so the request is repeated once the scope is attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scope.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ix = IxTheme.maybeOf(context);
    final bg =
        ix?.color(IxThemeColorToken.color1) ??
        Theme.of(context).colorScheme.surface;

    // Positioned by the owner, not by a `CompositedTransformFollower`: a
    // follower layer makes the paint transform of everything under it
    // incomputable, and `OverlayPortal.overlayChildLayoutBuilder` needs
    // exactly that -- so an `IxDropdownButton` placed in a panel used to
    // throw "The paint transform cannot be reliably computed because of
    // RenderFollowerLayer(s)" the moment it was opened.
    return TapRegion(
      groupId: widget.groupId,
      onTapOutside: (_) => _close(),
      // Announced to the subtree so a control that opens an overlay of
      // its own -- an `IxDropdownButton` in a `settings:` panel -- can
      // register that overlay in this group too. Without it the overlay
      // is mounted outside this `TapRegion`, and tapping one of its rows
      // reads as a tap outside the panel and dismisses it mid-selection.
      child: IxTapRegionGroupScope(
        groupId: widget.groupId ?? _fallbackGroupId,
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          },
          child: Actions(
            actions: {
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) {
                  _close();
                  return null;
                },
              ),
            },
            child: FocusScope(
              node: _scope,
              autofocus: true,
              child: Material(
                key: kIxMenuFlyoutKey,
                color: bg,
                elevation: 8,
                borderRadius: BorderRadius.circular(
                  IxCommonGeometry.defaultBorderRadius,
                ),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: widget.maxHeight ?? double.infinity,
                  ),
                  child: SizedBox(
                    width: widget.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            IxCommonGeometry.space3,
                            IxCommonGeometry.space1,
                            IxCommonGeometry.space1,
                            IxCommonGeometry.space1,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: ix?.textStyle(
                                    IxTypographyVariant.labelLg,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IxIconButton(
                                icon: const IxIcon.key(IxIconKey.close),
                                tooltip:
                                    widget.strings.closePanel ??
                                    MaterialLocalizations.of(
                                      context,
                                    ).closeButtonTooltip,
                                onPressed: _close,
                              ),
                            ],
                          ),
                        ),
                        Flexible(child: widget.child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _close() {
    final returnTo = widget.returnFocusTo;
    widget.onClose();
    if (returnTo == null) {
      return;
    }
    // Requesting focus synchronously would be undone while this panel's own
    // focus scope is torn down in the same frame, so the request is made
    // once the panel is actually gone.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (returnTo.context != null) {
        returnTo.requestFocus();
      }
    });
  }
}
