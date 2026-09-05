import 'package:flutter/material.dart';

import '../ix_core/ix_density.dart';
import '../ix_icons/ix_icon_size.dart';
import '../ix_theme/components/ix_button_theme.dart';

/// Fixed visual/icon size pairs an [IxIconButton] can render at.
///
/// The visual button size ([px]) is always a plain square; [iconSize] is
/// the glyph size shown inside it (via [IconTheme]), one step down the
/// [IxIconSize] scale from [px].
enum IxIconButtonSize {
  /// 32x32 visual size with a 24px icon.
  s32(32, IxIconSize.s24),

  /// 24x24 visual size with a 16px icon.
  s24(24, IxIconSize.s16),

  /// 16x16 visual size with a 12px icon.
  s16(16, IxIconSize.s12);

  const IxIconButtonSize(this.px, this.iconSize);

  /// The button's visual edge length, in logical pixels.
  final double px;

  /// The icon size shown inside the button.
  final IxIconSize iconSize;
}

/// A square, icon-only Siemens IX button.
///
/// Always renders at its fixed [IxIconButtonSize.px] visual size. In
/// [IxDensity.comfortable] (touch), the button is centered inside a
/// `minTapTarget`x`minTapTarget` (48x48) hit area without growing
/// visually; in [IxDensity.compact] (pointer/keyboard), the hit area
/// equals the visual size. See `doc/density.md`.
///
/// [icon] is any widget (typically an [Icon] or `IxIcon`) -- [IxIconButton]
/// only controls its size via [IconTheme], not its source.
class IxIconButton extends StatelessWidget {
  const IxIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = IxIconButtonSize.s32,
    this.variant = IxButtonVariant.subtleTertiary,
    this.tooltip,
    this.semanticLabel,
    this.oval = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// The icon shown inside the button. Its size is controlled by [size]'s
  /// [IxIconButtonSize.iconSize] via a merged [IconTheme]; the widget's own
  /// size (if any) is ignored.
  final Widget icon;

  /// Called when the button is tapped; the button is disabled when `null`.
  final VoidCallback? onPressed;

  /// The button's fixed visual/icon size.
  final IxIconButtonSize size;

  /// The Siemens IX button style applied to this icon button.
  final IxButtonVariant variant;

  /// A tooltip shown on hover/long-press. Also used as the button's
  /// accessible label unless [semanticLabel] overrides it -- a visible
  /// tooltip does not by itself supply a spoken label (it populates a
  /// separate semantics field), so [IxIconButton] always merges one in.
  final String? tooltip;

  /// An explicit accessible label, taking precedence over [tooltip] when
  /// both are set.
  final String? semanticLabel;

  /// Whether the button's shape is a circle instead of the variant's
  /// default (rounded-rectangle) shape.
  final bool oval;

  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final density = IxDensity.effectiveOf(context);
    final base =
        Theme.of(context).extension<IxButtonTheme>()?.style(variant) ??
        const ButtonStyle();
    final style = base.copyWith(
      fixedSize: WidgetStatePropertyAll(Size.square(size.px)),
      minimumSize: WidgetStatePropertyAll(Size.square(size.px)),
      maximumSize: WidgetStatePropertyAll(Size.square(size.px)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      // IconButton is a ButtonStyleButton under the hood, so this alone
      // grows its hit area to 48x48 in IxDensity.comfortable -- centered
      // around the unchanged 32/24/16px visual size -- exactly like
      // FilledButton/OutlinedButton/TextButton; no extra wrapping needed.
      tapTargetSize: density.tapTargetSize,
      shape: oval ? const WidgetStatePropertyAll(CircleBorder()) : base.shape,
      iconSize: WidgetStatePropertyAll(size.iconSize.px),
    );
    final label = semanticLabel ?? tooltip;
    return IconButton(
      style: style,
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: tooltip,
      iconSize: size.iconSize.px,
      // A Tooltip contributes to a SemanticsNode's `tooltip` field, not its
      // `label` -- so a visible [tooltip] alone would leave this button
      // without a spoken label. Merging an explicit `label` into the icon
      // (a non-boundary descendant of IconButton's own semantics node)
      // covers both cases uniformly, with or without a visible tooltip.
      icon: Semantics(
        label: label,
        excludeSemantics: true,
        child: IconTheme.merge(
          data: IconThemeData(size: size.iconSize.px),
          child: icon,
        ),
      ),
    );
  }
}
