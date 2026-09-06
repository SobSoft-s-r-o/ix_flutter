import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

// This class's own `copyWith` and `lerp` still populate and read
// `dropdownBackground`/`dropdownBorderRadius` below (so an explicit
// override keeps taking effect at the one remaining read site, in
// `IxBreadcrumb`'s overflow menu, which falls back to `IxDropdownTheme`
// when neither is set -- see that read site -- until both fields are
// removed in 2.0), so the same-package deprecation notice is suppressed
// file-wide instead of at each site individually (mirrors
// `ix_button_theme.dart`).
// ignore_for_file: deprecated_member_use_from_same_package

/// Theme extension that exposes Siemens IX breadcrumb metrics and tokens.
class IxBreadcrumbTheme extends ThemeExtension<IxBreadcrumbTheme> {
  const IxBreadcrumbTheme({
    required this.height,
    required this.itemPadding,
    required this.itemSpacing,
    required this.maxItemWidth,
    required this.labelStyle,
    required this.currentItemStyle,
    required this.separatorColor,
    required this.iconColor,
    required this.ellipsisFontWeight,
    this.dropdownBackground,
    required this.dropdownTextStyle,
    required this.dropdownElevation,
    required this.focusOutlineColor,
    required this.dropdownPadding,
    this.dropdownBorderRadius,
  });

  factory IxBreadcrumbTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final labelStyle = typography.label.copyWith(
      fontWeight: FontWeight.w600,
      color: pick(IxThemeColorToken.primary),
    );

    return IxBreadcrumbTheme(
      height: IxCommonGeometry.rem(2.5),
      itemPadding: const EdgeInsets.symmetric(
        horizontal: IxCommonGeometry.spaceNeg1,
      ),
      itemSpacing: IxCommonGeometry.spaceNeg1,
      maxItemWidth: IxCommonGeometry.rem(15),
      labelStyle: labelStyle,
      currentItemStyle: typography.label.copyWith(
        fontWeight: FontWeight.w600,
        color: pick(IxThemeColorToken.softText),
      ),
      separatorColor: pick(IxThemeColorToken.softText),
      iconColor: pick(IxThemeColorToken.primary),
      ellipsisFontWeight: FontWeight.w700,
      // dropdownBackground/dropdownBorderRadius are left null: the overflow
      // menu's read site falls back to IxDropdownTheme.background/
      // borderRadius, which this factory's caller (IxThemeBuilder.build)
      // always builds from the same palette -- pick(color2) and
      // IxCommonGeometry.defaultBorderRadius, identically -- so leaving
      // them unset here is not a visible change from hard-coding the same
      // values twice.
      dropdownTextStyle: typography.bodySm.copyWith(
        color: pick(IxThemeColorToken.stdText),
      ),
      dropdownElevation: IxCommonGeometry.borderWidthThick,
      focusOutlineColor: pick(IxThemeColorToken.focusBdr),
      dropdownPadding: EdgeInsets.symmetric(
        horizontal: IxCommonGeometry.space(2),
        vertical: IxCommonGeometry.space(1),
      ),
    );
  }

  factory IxBreadcrumbTheme.fallback(ThemeData theme) {
    final labelStyle =
        theme.textTheme.labelLarge ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    final currentColor =
        theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant;

    return IxBreadcrumbTheme(
      height: IxCommonGeometry.rem(2.5),
      itemPadding: const EdgeInsets.symmetric(
        horizontal: IxCommonGeometry.spaceNeg1,
      ),
      itemSpacing: IxCommonGeometry.spaceNeg1,
      maxItemWidth: IxCommonGeometry.rem(15),
      labelStyle: labelStyle.copyWith(color: theme.colorScheme.primary),
      currentItemStyle: labelStyle.copyWith(color: currentColor),
      separatorColor: theme.colorScheme.onSurfaceVariant,
      iconColor: theme.colorScheme.primary,
      ellipsisFontWeight: FontWeight.w700,
      // dropdownBackground/dropdownBorderRadius left null: same reasoning
      // as IxBreadcrumbTheme.fromPalette above -- IxBreadcrumb builds this
      // and IxDropdownTheme.fallback from the same ThemeData, and that
      // factory's background/borderRadius already resolve to
      // theme.colorScheme.surface / IxCommonGeometry.defaultBorderRadius.
      dropdownTextStyle:
          theme.textTheme.bodyMedium ?? TextStyle(color: currentColor),
      dropdownElevation: 4,
      focusOutlineColor: theme.colorScheme.primary,
      dropdownPadding: EdgeInsets.symmetric(
        horizontal: IxCommonGeometry.space(2),
        vertical: IxCommonGeometry.space(1),
      ),
    );
  }

  final double height;
  final EdgeInsets itemPadding;
  final double itemSpacing;
  final double maxItemWidth;
  final TextStyle labelStyle;
  final TextStyle currentItemStyle;
  final Color separatorColor;
  final Color iconColor;
  final FontWeight ellipsisFontWeight;

  /// Background of the overflow/next-items popup surface, or `null` (the
  /// default) to use `IxDropdownTheme.background` instead.
  @Deprecated(
    'Overflow menus are styled by IxDropdownTheme.background unless this is '
    'explicitly set. Removed in 2.0.',
  )
  final Color? dropdownBackground;
  final TextStyle dropdownTextStyle;
  final double dropdownElevation;
  final Color focusOutlineColor;
  final EdgeInsets dropdownPadding;

  /// Corner radius of the overflow/next-items popup surface, or `null` (the
  /// default) to use `IxDropdownTheme.borderRadius` instead.
  @Deprecated(
    'Overflow menus are styled by IxDropdownTheme.borderRadius unless this '
    'is explicitly set. Removed in 2.0.',
  )
  final BorderRadius? dropdownBorderRadius;

  @override
  IxBreadcrumbTheme copyWith({
    double? height,
    EdgeInsets? itemPadding,
    double? itemSpacing,
    double? maxItemWidth,
    TextStyle? labelStyle,
    TextStyle? currentItemStyle,
    Color? separatorColor,
    Color? iconColor,
    FontWeight? ellipsisFontWeight,
    Color? dropdownBackground,
    TextStyle? dropdownTextStyle,
    double? dropdownElevation,
    Color? focusOutlineColor,
    EdgeInsets? dropdownPadding,
    BorderRadius? dropdownBorderRadius,
  }) {
    return IxBreadcrumbTheme(
      height: height ?? this.height,
      itemPadding: itemPadding ?? this.itemPadding,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      maxItemWidth: maxItemWidth ?? this.maxItemWidth,
      labelStyle: labelStyle ?? this.labelStyle,
      currentItemStyle: currentItemStyle ?? this.currentItemStyle,
      separatorColor: separatorColor ?? this.separatorColor,
      iconColor: iconColor ?? this.iconColor,
      ellipsisFontWeight: ellipsisFontWeight ?? this.ellipsisFontWeight,
      dropdownBackground: dropdownBackground ?? this.dropdownBackground,
      dropdownTextStyle: dropdownTextStyle ?? this.dropdownTextStyle,
      dropdownElevation: dropdownElevation ?? this.dropdownElevation,
      focusOutlineColor: focusOutlineColor ?? this.focusOutlineColor,
      dropdownPadding: dropdownPadding ?? this.dropdownPadding,
      dropdownBorderRadius: dropdownBorderRadius ?? this.dropdownBorderRadius,
    );
  }

  @override
  IxBreadcrumbTheme lerp(
    covariant ThemeExtension<IxBreadcrumbTheme>? other,
    double t,
  ) {
    if (other is! IxBreadcrumbTheme) {
      return this;
    }

    return IxBreadcrumbTheme(
      height: lerpDouble(height, other.height, t) ?? height,
      itemPadding:
          EdgeInsets.lerp(itemPadding, other.itemPadding, t) ?? itemPadding,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t) ?? itemSpacing,
      maxItemWidth:
          lerpDouble(maxItemWidth, other.maxItemWidth, t) ?? maxItemWidth,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t) ?? labelStyle,
      currentItemStyle:
          TextStyle.lerp(currentItemStyle, other.currentItemStyle, t) ??
          currentItemStyle,
      separatorColor:
          Color.lerp(separatorColor, other.separatorColor, t) ?? separatorColor,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      ellipsisFontWeight: t < 0.5
          ? ellipsisFontWeight
          : other.ellipsisFontWeight,
      // Discrete switch, not a smooth Color.lerp: null means "deferred to
      // IxDropdownTheme", which is not a colour Color.lerp could blend
      // toward/from without treating the deferral as transparent.
      dropdownBackground: t < 0.5
          ? dropdownBackground
          : other.dropdownBackground,
      dropdownTextStyle:
          TextStyle.lerp(dropdownTextStyle, other.dropdownTextStyle, t) ??
          dropdownTextStyle,
      dropdownElevation:
          lerpDouble(dropdownElevation, other.dropdownElevation, t) ??
          dropdownElevation,
      focusOutlineColor:
          Color.lerp(focusOutlineColor, other.focusOutlineColor, t) ??
          focusOutlineColor,
      dropdownPadding:
          EdgeInsets.lerp(dropdownPadding, other.dropdownPadding, t) ??
          dropdownPadding,
      // Same reasoning as dropdownBackground above.
      dropdownBorderRadius: t < 0.5
          ? dropdownBorderRadius
          : other.dropdownBorderRadius,
    );
  }
}
