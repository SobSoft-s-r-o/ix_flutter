import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_theme/ix_theme_builder.dart';

/// Paints a 1px outline in [IxThemeColorToken.focusBdr] around [child] while
/// [focused] is `true`.
///
/// Siemens IX custom tiles (blind headers, sidebar/menu items, dropdown
/// items) don't have a Material `side`/`shape` slot to resolve per
/// [WidgetState], so they use this widget instead: it draws the ring as a
/// separate layer offset outside the child's bounds, matching the outline
/// treatment applied natively to checkboxes, radios and buttons.
///
/// See also the upstream `button-mixin.scss`/`checkbox.scss`/`blind.scss`
/// `focus-visible` outline rules this mirrors (WCAG 2.4.7).
class IxFocusRing extends StatelessWidget {
  /// Creates a Siemens IX focus ring.
  const IxFocusRing({
    super.key,
    required this.focused,
    required this.child,
    this.offset = IxCommonGeometry.focusOutlineOffset,
    this.borderRadius,
  });

  /// Whether the ring is currently visible.
  final bool focused;

  /// The widget the ring is painted around.
  final Widget child;

  /// Distance in logical pixels between [child]'s edge and the ring.
  final double offset;

  /// Corner radius of the ring. Defaults to square corners.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(
          context,
        ).extension<IxTheme>()?.color(IxThemeColorToken.focusBdr) ??
        Theme.of(context).colorScheme.primary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (focused)
          Positioned.fill(
            left: -offset,
            top: -offset,
            right: -offset,
            bottom: -offset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                    width: IxCommonGeometry.focusBorderThickness,
                  ),
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
