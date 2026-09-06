import 'package:flutter/widgets.dart';

/// The [TapRegion] group a dismissible surface belongs to.
///
/// A panel that closes on a tap outside itself -- the application scaffold's
/// menu fly-out, say -- puts its whole subtree in one [TapRegion] group. A
/// control inside it that opens an overlay of its own (an `IxDropdownButton`
/// menu) escapes that subtree: the overlay is mounted next to the panel, not
/// under it, so tapping a row of it reads as a tap *outside* the panel and
/// dismisses the panel mid-interaction.
///
/// This scope tells such a control which group it is nested in, so it can
/// register its overlay in that group as well as in its own. Tapping the
/// overlay is then inside the panel's group (the panel stays), while a tap
/// anywhere else in the panel is still outside the control's own group (the
/// control closes).
///
/// Internal: not exported from the package barrel.
class IxTapRegionGroupScope extends InheritedWidget {
  /// Declares [groupId] as the enclosing tap-region group for [child].
  const IxTapRegionGroupScope({
    super.key,
    required this.groupId,
    required super.child,
  });

  /// The enclosing group's identity, as passed to [TapRegion.groupId].
  final Object groupId;

  /// The enclosing tap-region group, or `null` outside any such panel.
  static Object? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<IxTapRegionGroupScope>()
      ?.groupId;

  @override
  bool updateShouldNotify(IxTapRegionGroupScope oldWidget) =>
      groupId != oldWidget.groupId;
}
