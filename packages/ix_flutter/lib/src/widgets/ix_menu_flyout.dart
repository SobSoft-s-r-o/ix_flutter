import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ix_colors/ix_theme_color_tokens.dart';
import '../ix_core/ix_common_geometry.dart';
import '../ix_core/ix_typography.dart';
import '../ix_icons/ix_icon.dart';
import '../ix_icons/ix_icon_key.dart';
import '../ix_theme/ix_theme_builder.dart';
import 'i18n/ix_application_strings.dart';
import 'ix_icon_button.dart';

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
  /// Creates a fly-out panel following [link].
  const IxMenuFlyout({
    super.key,
    required this.link,
    required this.title,
    required this.onClose,
    required this.child,
    this.width = 320,
    this.returnFocusTo,
    this.strings = const IxApplicationStrings(),
    this.groupId,
  });

  /// The link to the menu rail this panel is anchored to; the panel is
  /// placed at the rail's trailing (top-start-of-the-content) corner.
  final LayerLink link;

  /// Heading rendered above [child].
  final String title;

  /// Called when the panel asks to be dismissed (close button, `Escape`, or
  /// a tap outside its [groupId]).
  final VoidCallback onClose;

  /// The panel's content.
  final Widget child;

  /// Fixed width of the panel in logical pixels.
  final double width;

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
    // `CompositedTransformFollower` takes physical `Alignment`s, so the
    // start/end anchors are resolved against the ambient text direction by
    // hand: the panel always opens away from the menu rail.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return CompositedTransformFollower(
      link: widget.link,
      targetAnchor: isRtl ? Alignment.topLeft : Alignment.topRight,
      followerAnchor: isRtl ? Alignment.topRight : Alignment.topLeft,
      child: TapRegion(
        groupId: widget.groupId,
        onTapOutside: (_) => _close(),
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
                color: bg,
                elevation: 8,
                borderRadius: BorderRadius.circular(
                  IxCommonGeometry.defaultBorderRadius,
                ),
                clipBehavior: Clip.antiAlias,
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
                              tooltip: widget.strings.closePanel,
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
