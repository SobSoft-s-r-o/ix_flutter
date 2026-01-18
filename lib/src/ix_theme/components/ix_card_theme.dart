import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';

/// Enumerates Siemens IX card variants surfaced by the theme extension.
enum IxCardVariant {
  filled,
  outline,
  primary,
  alarm,
  critical,
  warning,
  success,
  info,
  neutral,
}

/// Captures the resolved states for a Siemens IX card treatment.
class IxCardStyle {
  const IxCardStyle({
    required this.background,
    required this.hoverBackground,
    required this.activeBackground,
    required this.selectedBackground,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.activeBorderColor,
    required this.selectedBorderColor,
    required this.foreground,
  });

  final Color background;
  final Color hoverBackground;
  final Color activeBackground;
  final Color selectedBackground;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color activeBorderColor;
  final Color selectedBorderColor;
  final Color foreground;

  IxCardStyle copyWith({
    Color? background,
    Color? hoverBackground,
    Color? activeBackground,
    Color? selectedBackground,
    Color? borderColor,
    Color? hoverBorderColor,
    Color? activeBorderColor,
    Color? selectedBorderColor,
    Color? foreground,
  }) {
    return IxCardStyle(
      background: background ?? this.background,
      hoverBackground: hoverBackground ?? this.hoverBackground,
      activeBackground: activeBackground ?? this.activeBackground,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      borderColor: borderColor ?? this.borderColor,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      foreground: foreground ?? this.foreground,
    );
  }

  static IxCardStyle lerp(IxCardStyle a, IxCardStyle b, double t) {
    return IxCardStyle(
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      hoverBackground:
          Color.lerp(a.hoverBackground, b.hoverBackground, t) ??
          a.hoverBackground,
      activeBackground:
          Color.lerp(a.activeBackground, b.activeBackground, t) ??
          a.activeBackground,
      selectedBackground:
          Color.lerp(a.selectedBackground, b.selectedBackground, t) ??
          a.selectedBackground,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t) ?? a.borderColor,
      hoverBorderColor:
          Color.lerp(a.hoverBorderColor, b.hoverBorderColor, t) ??
          a.hoverBorderColor,
      activeBorderColor:
          Color.lerp(a.activeBorderColor, b.activeBorderColor, t) ??
          a.activeBorderColor,
      selectedBorderColor:
          Color.lerp(a.selectedBorderColor, b.selectedBorderColor, t) ??
          a.selectedBorderColor,
      foreground: Color.lerp(a.foreground, b.foreground, t) ?? a.foreground,
    );
  }
}

/// Theme extension that exposes Siemens IX card styling primitives.
class IxCardTheme extends ThemeExtension<IxCardTheme> {
  const IxCardTheme({
    required this.materialCardTheme,
    required this.borderRadius,
    required this.borderWidth,
    required this.focusOutlineOffset,
    required this.variants,
  });

  factory IxCardTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color resolve(IxThemeColorToken token) => palette[token]!;

    IxCardStyle buildStyle({
      required IxThemeColorToken background,
      required IxThemeColorToken hover,
      required IxThemeColorToken active,
      required IxThemeColorToken selected,
      required IxThemeColorToken border,
      required IxThemeColorToken borderHover,
      required IxThemeColorToken borderActive,
      required IxThemeColorToken borderSelected,
      required IxThemeColorToken foreground,
    }) {
      return IxCardStyle(
        background: resolve(background),
        hoverBackground: resolve(hover),
        activeBackground: resolve(active),
        selectedBackground: resolve(selected),
        borderColor: resolve(border),
        hoverBorderColor: resolve(borderHover),
        activeBorderColor: resolve(borderActive),
        selectedBorderColor: resolve(borderSelected),
        foreground: resolve(foreground),
      );
    }

    final variants = <IxCardVariant, IxCardStyle>{
      IxCardVariant.filled: buildStyle(
        background: IxThemeColorToken.component1,
        hover: IxThemeColorToken.component1Hover,
        active: IxThemeColorToken.component1Active,
        selected: IxThemeColorToken.ghostSelected,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.stdText,
      ),
      IxCardVariant.outline: buildStyle(
        background: IxThemeColorToken.ghost,
        hover: IxThemeColorToken.ghostHover,
        active: IxThemeColorToken.ghostActive,
        selected: IxThemeColorToken.ghostSelected,
        border: IxThemeColorToken.softBdr,
        borderHover: IxThemeColorToken.softBdr,
        borderActive: IxThemeColorToken.softBdr,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.stdText,
      ),
      IxCardVariant.primary: buildStyle(
        background: IxThemeColorToken.primary,
        hover: IxThemeColorToken.primaryHover,
        active: IxThemeColorToken.primaryActive,
        selected: IxThemeColorToken.primary,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.primaryContrast,
      ),
      IxCardVariant.alarm: buildStyle(
        background: IxThemeColorToken.alarm,
        hover: IxThemeColorToken.alarmHover,
        active: IxThemeColorToken.alarmActive,
        selected: IxThemeColorToken.alarm,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.alarmContrast,
      ),
      IxCardVariant.critical: buildStyle(
        background: IxThemeColorToken.critical,
        hover: IxThemeColorToken.criticalHover,
        active: IxThemeColorToken.criticalActive,
        selected: IxThemeColorToken.critical,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.criticalContrast,
      ),
      IxCardVariant.warning: buildStyle(
        background: IxThemeColorToken.warning,
        hover: IxThemeColorToken.warningHover,
        active: IxThemeColorToken.warningActive,
        selected: IxThemeColorToken.warning,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.warningContrast,
      ),
      IxCardVariant.success: buildStyle(
        background: IxThemeColorToken.success,
        hover: IxThemeColorToken.successHover,
        active: IxThemeColorToken.successActive,
        selected: IxThemeColorToken.success,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.successContrast,
      ),
      IxCardVariant.info: buildStyle(
        background: IxThemeColorToken.info,
        hover: IxThemeColorToken.infoHover,
        active: IxThemeColorToken.infoActive,
        selected: IxThemeColorToken.info,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.infoContrast,
      ),
      IxCardVariant.neutral: buildStyle(
        background: IxThemeColorToken.neutral,
        hover: IxThemeColorToken.neutralHover,
        active: IxThemeColorToken.neutralActive,
        selected: IxThemeColorToken.neutral,
        border: IxThemeColorToken.color0,
        borderHover: IxThemeColorToken.color0,
        borderActive: IxThemeColorToken.color0,
        borderSelected: IxThemeColorToken.dynamic,
        foreground: IxThemeColorToken.neutralContrast,
      ),
    };

    final materialCardTheme = CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: resolve(IxThemeColorToken.component1),
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: resolve(IxThemeColorToken.shadow1),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          IxCommonGeometry.defaultBorderRadius,
        ),
        side: BorderSide(
          color: Colors.transparent,
          width: IxCommonGeometry.borderWidthDefault,
        ),
      ),
    );

    return IxCardTheme(
      materialCardTheme: materialCardTheme,
      borderRadius: IxCommonGeometry.defaultBorderRadius,
      borderWidth: IxCommonGeometry.borderWidthDefault,
      focusOutlineOffset: IxCommonGeometry.focusOutlineOffset,
      variants: Map.unmodifiable(variants),
    );
  }

  final CardThemeData materialCardTheme;
  final double borderRadius;
  final double borderWidth;
  final double focusOutlineOffset;
  final Map<IxCardVariant, IxCardStyle> variants;

  IxCardStyle style(IxCardVariant variant) =>
      variants[variant] ?? variants[IxCardVariant.filled]!;

  @override
  IxCardTheme copyWith({
    CardThemeData? materialCardTheme,
    double? borderRadius,
    double? borderWidth,
    double? focusOutlineOffset,
    Map<IxCardVariant, IxCardStyle>? variants,
  }) {
    return IxCardTheme(
      materialCardTheme: materialCardTheme ?? this.materialCardTheme,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusOutlineOffset: focusOutlineOffset ?? this.focusOutlineOffset,
      variants: variants ?? this.variants,
    );
  }

  @override
  IxCardTheme lerp(ThemeExtension<IxCardTheme>? other, double t) {
    if (other is! IxCardTheme) {
      return this;
    }

    final mergedVariants = <IxCardVariant, IxCardStyle>{};
    for (final variant in IxCardVariant.values) {
      mergedVariants[variant] = IxCardStyle.lerp(
        style(variant),
        other.style(variant),
        t,
      );
    }

    return IxCardTheme(
      materialCardTheme: CardThemeData.lerp(
        materialCardTheme,
        other.materialCardTheme,
        t,
      ),
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      focusOutlineOffset:
          lerpDouble(focusOutlineOffset, other.focusOutlineOffset, t) ??
          focusOutlineOffset,
      variants: Map.unmodifiable(mergedVariants),
    );
  }
}
