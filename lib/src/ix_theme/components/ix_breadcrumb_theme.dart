import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';

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
    required this.dropdownBackground,
    required this.dropdownTextStyle,
    required this.dropdownElevation,
    required this.focusOutlineColor,
    required this.dropdownPadding,
    required this.dropdownBorderRadius,
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
      dropdownBackground: pick(IxThemeColorToken.color2),
      dropdownTextStyle: typography.bodySm.copyWith(
        color: pick(IxThemeColorToken.stdText),
      ),
      dropdownElevation: IxCommonGeometry.borderWidthThick,
      focusOutlineColor: pick(IxThemeColorToken.focusBdr),
      dropdownPadding: EdgeInsets.symmetric(
        horizontal: IxCommonGeometry.space(2),
        vertical: IxCommonGeometry.space(1),
      ),
      dropdownBorderRadius: const BorderRadius.all(
        Radius.circular(IxCommonGeometry.smallBorderRadius),
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
      dropdownBackground: theme.colorScheme.surface,
      dropdownTextStyle:
          theme.textTheme.bodyMedium ?? TextStyle(color: currentColor),
      dropdownElevation: 4,
      focusOutlineColor: theme.colorScheme.primary,
      dropdownPadding: EdgeInsets.symmetric(
        horizontal: IxCommonGeometry.space(2),
        vertical: IxCommonGeometry.space(1),
      ),
      dropdownBorderRadius: const BorderRadius.all(
        Radius.circular(IxCommonGeometry.smallBorderRadius),
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
  final Color dropdownBackground;
  final TextStyle dropdownTextStyle;
  final double dropdownElevation;
  final Color focusOutlineColor;
  final EdgeInsets dropdownPadding;
  final BorderRadius dropdownBorderRadius;

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
      dropdownBackground:
          Color.lerp(dropdownBackground, other.dropdownBackground, t) ??
          dropdownBackground,
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
      dropdownBorderRadius:
          BorderRadius.lerp(
            dropdownBorderRadius,
            other.dropdownBorderRadius,
            t,
          ) ??
          dropdownBorderRadius,
    );
  }
}
