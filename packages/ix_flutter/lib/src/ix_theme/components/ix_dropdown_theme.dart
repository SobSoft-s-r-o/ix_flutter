import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

/// Theme extension that exposes the Siemens IX dropdown menu surface and
/// menu-item metrics used by `IxDropdownButton`.
///
/// Mirrors the upstream `dropdown.scss` (surface, radius, padding, shadow)
/// and `dropdown-item.scss` (row height, padding, hover/active/disabled and
/// focus treatment) rules.
class IxDropdownTheme extends ThemeExtension<IxDropdownTheme> {
  /// Creates a fully specified dropdown theme.
  const IxDropdownTheme({
    required this.background,
    required this.borderRadius,
    required this.shadow,
    required this.padding,
    required this.itemHeight,
    required this.itemPadding,
    required this.checkColumnWidth,
    required this.itemHover,
    required this.itemActive,
    required this.itemDisabledText,
    required this.itemFocusBorder,
    required this.itemText,
    required this.itemTextStyle,
  });

  /// Builds the dropdown theme from a resolved Siemens IX [palette].
  factory IxDropdownTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    return IxDropdownTheme(
      background: pick(IxThemeColorToken.color2),
      borderRadius: IxCommonGeometry.defaultBorderRadius,
      shadow: _shadow(pick(IxThemeColorToken.shadow2)),
      padding: const EdgeInsets.symmetric(vertical: IxCommonGeometry.spaceNeg1),
      itemHeight: IxCommonGeometry.controlHeightLarge,
      itemPadding: const EdgeInsets.only(
        left: IxCommonGeometry.space1,
        right: IxCommonGeometry.space4,
      ),
      checkColumnWidth: IxCommonGeometry.space4,
      itemHover: pick(IxThemeColorToken.ghostHover),
      itemActive: pick(IxThemeColorToken.ghostActive),
      itemDisabledText: pick(IxThemeColorToken.weakText),
      itemFocusBorder: pick(IxThemeColorToken.focusBdr),
      itemText: pick(IxThemeColorToken.stdText),
      itemTextStyle: typography.body.copyWith(
        color: pick(IxThemeColorToken.stdText),
      ),
    );
  }

  /// Builds a best-effort dropdown theme from a plain Material [theme].
  ///
  /// Used when the surrounding `ThemeData` was not produced by
  /// `IxThemeBuilder`, so the widget still renders with sane colors.
  factory IxDropdownTheme.fallback(ThemeData theme) {
    final scheme = theme.colorScheme;
    return IxDropdownTheme(
      background: scheme.surface,
      borderRadius: IxCommonGeometry.defaultBorderRadius,
      shadow: _shadow(scheme.shadow),
      padding: const EdgeInsets.symmetric(vertical: IxCommonGeometry.spaceNeg1),
      itemHeight: IxCommonGeometry.controlHeightLarge,
      itemPadding: const EdgeInsets.only(
        left: IxCommonGeometry.space1,
        right: IxCommonGeometry.space4,
      ),
      checkColumnWidth: IxCommonGeometry.space4,
      itemHover: scheme.onSurface.withValues(alpha: 0.08),
      itemActive: scheme.onSurface.withValues(alpha: 0.12),
      itemDisabledText: theme.disabledColor,
      itemFocusBorder: scheme.primary,
      itemText: scheme.onSurface,
      itemTextStyle:
          theme.textTheme.bodyMedium ?? TextStyle(color: scheme.onSurface),
    );
  }

  /// Approximates the upstream `--theme-shadow-4` elevation
  /// (`_variables.scss:225`) with three stacked [BoxShadow] layers.
  static List<BoxShadow> _shadow(Color shadowColor) => [
    BoxShadow(color: shadowColor.withValues(alpha: 0.2), blurRadius: 2),
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.1),
      blurRadius: 18,
      offset: const Offset(0, 12),
    ),
  ];

  /// Background of the menu surface (`color-2`).
  final Color background;

  /// Corner radius of the menu surface, in logical pixels.
  final double borderRadius;

  /// Drop shadow painted behind the menu surface.
  final List<BoxShadow> shadow;

  /// Padding between the menu surface and its first/last item.
  final EdgeInsets padding;

  /// Minimum height of a single menu row, in logical pixels.
  final double itemHeight;

  /// Horizontal padding inside a menu row.
  final EdgeInsets itemPadding;

  /// Width reserved for the leading checkmark column of checkable menus.
  final double checkColumnWidth;

  /// Row background while the pointer hovers it.
  final Color itemHover;

  /// Row background while the row is pressed.
  final Color itemActive;

  /// Label color of a disabled row.
  final Color itemDisabledText;

  /// Color of the 1px keyboard focus outline drawn inside a row.
  final Color itemFocusBorder;

  /// Label color of an enabled row.
  final Color itemText;

  /// Text style of a row label.
  final TextStyle itemTextStyle;

  @override
  IxDropdownTheme copyWith({
    Color? background,
    double? borderRadius,
    List<BoxShadow>? shadow,
    EdgeInsets? padding,
    double? itemHeight,
    EdgeInsets? itemPadding,
    double? checkColumnWidth,
    Color? itemHover,
    Color? itemActive,
    Color? itemDisabledText,
    Color? itemFocusBorder,
    Color? itemText,
    TextStyle? itemTextStyle,
  }) {
    return IxDropdownTheme(
      background: background ?? this.background,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
      padding: padding ?? this.padding,
      itemHeight: itemHeight ?? this.itemHeight,
      itemPadding: itemPadding ?? this.itemPadding,
      checkColumnWidth: checkColumnWidth ?? this.checkColumnWidth,
      itemHover: itemHover ?? this.itemHover,
      itemActive: itemActive ?? this.itemActive,
      itemDisabledText: itemDisabledText ?? this.itemDisabledText,
      itemFocusBorder: itemFocusBorder ?? this.itemFocusBorder,
      itemText: itemText ?? this.itemText,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
    );
  }

  @override
  IxDropdownTheme lerp(
    covariant ThemeExtension<IxDropdownTheme>? other,
    double t,
  ) {
    if (other is! IxDropdownTheme) {
      return this;
    }

    return IxDropdownTheme(
      background: Color.lerp(background, other.background, t) ?? background,
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      shadow: BoxShadow.lerpList(shadow, other.shadow, t) ?? shadow,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      itemHeight: lerpDouble(itemHeight, other.itemHeight, t) ?? itemHeight,
      itemPadding:
          EdgeInsets.lerp(itemPadding, other.itemPadding, t) ?? itemPadding,
      checkColumnWidth:
          lerpDouble(checkColumnWidth, other.checkColumnWidth, t) ??
          checkColumnWidth,
      itemHover: Color.lerp(itemHover, other.itemHover, t) ?? itemHover,
      itemActive: Color.lerp(itemActive, other.itemActive, t) ?? itemActive,
      itemDisabledText:
          Color.lerp(itemDisabledText, other.itemDisabledText, t) ??
          itemDisabledText,
      itemFocusBorder:
          Color.lerp(itemFocusBorder, other.itemFocusBorder, t) ??
          itemFocusBorder,
      itemText: Color.lerp(itemText, other.itemText, t) ?? itemText,
      itemTextStyle:
          TextStyle.lerp(itemTextStyle, other.itemTextStyle, t) ??
          itemTextStyle,
    );
  }
}
