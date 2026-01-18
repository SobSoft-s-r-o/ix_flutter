import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';

/// Enumerates Siemens IX blind variants surfaced by the theme extension.
enum IxBlindVariant {
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

/// Captures the resolved states for a Siemens IX blind treatment.
class IxBlindStyle {
  const IxBlindStyle({
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

  IxBlindStyle copyWith({
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
    return IxBlindStyle(
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

  static IxBlindStyle lerp(IxBlindStyle a, IxBlindStyle b, double t) {
    return IxBlindStyle(
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

/// Theme extension that exposes Siemens IX blind styling primitives.
class IxBlindTheme extends ThemeExtension<IxBlindTheme> {
  const IxBlindTheme({
    required this.borderRadius,
    required this.borderWidth,
    required this.focusOutlineOffset,
    required this.variants,
  });

  factory IxBlindTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color resolve(IxThemeColorToken token) => palette[token]!;

    IxBlindStyle buildStyle({
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
      return IxBlindStyle(
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

    final variants = <IxBlindVariant, IxBlindStyle>{
      IxBlindVariant.filled: buildStyle(
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
      IxBlindVariant.outline: buildStyle(
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
      IxBlindVariant.primary: buildStyle(
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
      IxBlindVariant.alarm: buildStyle(
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
      IxBlindVariant.critical: buildStyle(
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
      IxBlindVariant.warning: buildStyle(
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
      IxBlindVariant.success: buildStyle(
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
      IxBlindVariant.info: buildStyle(
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
      IxBlindVariant.neutral: buildStyle(
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

    return IxBlindTheme(
      borderRadius: IxCommonGeometry.defaultBorderRadius,
      borderWidth: IxCommonGeometry.borderWidthDefault,
      focusOutlineOffset: IxCommonGeometry.focusOutlineOffset,
      variants: Map.unmodifiable(variants),
    );
  }

  factory IxBlindTheme.fallback(ThemeData theme) {
    // Fallback implementation using standard Material colors if IxTheme is not available
    // This is a simplified fallback and might not match exact iX specs

    IxBlindStyle buildFallbackStyle({
      required Color background,
      required Color foreground,
      Color? border,
    }) {
      return IxBlindStyle(
        background: background,
        hoverBackground: background.withValues(alpha: background.a * 0.9),
        activeBackground: background.withValues(alpha: background.a * 0.8),
        selectedBackground: background,
        borderColor: border ?? Colors.transparent,
        hoverBorderColor: border ?? Colors.transparent,
        activeBorderColor: border ?? Colors.transparent,
        selectedBorderColor: border ?? Colors.transparent,
        foreground: foreground,
      );
    }

    final variants = <IxBlindVariant, IxBlindStyle>{
      IxBlindVariant.filled: buildFallbackStyle(
        background: theme.cardColor,
        foreground: theme.textTheme.bodyMedium?.color ?? Colors.black,
      ),
      IxBlindVariant.outline: buildFallbackStyle(
        background: Colors.transparent,
        foreground: theme.textTheme.bodyMedium?.color ?? Colors.black,
        border: theme.dividerColor,
      ),
      IxBlindVariant.primary: buildFallbackStyle(
        background: theme.primaryColor,
        foreground: theme.colorScheme.onPrimary,
      ),
      IxBlindVariant.alarm: buildFallbackStyle(
        background: theme.colorScheme.error,
        foreground: theme.colorScheme.onError,
      ),
      IxBlindVariant.critical: buildFallbackStyle(
        background: Colors.red.shade900,
        foreground: Colors.white,
      ),
      IxBlindVariant.warning: buildFallbackStyle(
        background: Colors.orange,
        foreground: Colors.black,
      ),
      IxBlindVariant.success: buildFallbackStyle(
        background: Colors.green,
        foreground: Colors.white,
      ),
      IxBlindVariant.info: buildFallbackStyle(
        background: Colors.blue,
        foreground: Colors.white,
      ),
      IxBlindVariant.neutral: buildFallbackStyle(
        background: Colors.grey,
        foreground: Colors.black,
      ),
    };

    return IxBlindTheme(
      borderRadius: 4.0,
      borderWidth: 1.0,
      focusOutlineOffset: 2.0,
      variants: Map.unmodifiable(variants),
    );
  }

  final double borderRadius;
  final double borderWidth;
  final double focusOutlineOffset;
  final Map<IxBlindVariant, IxBlindStyle> variants;

  IxBlindStyle style(IxBlindVariant variant) =>
      variants[variant] ?? variants[IxBlindVariant.filled]!;

  @override
  IxBlindTheme copyWith({
    double? borderRadius,
    double? borderWidth,
    double? focusOutlineOffset,
    Map<IxBlindVariant, IxBlindStyle>? variants,
  }) {
    return IxBlindTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusOutlineOffset: focusOutlineOffset ?? this.focusOutlineOffset,
      variants: variants ?? this.variants,
    );
  }

  @override
  IxBlindTheme lerp(ThemeExtension<IxBlindTheme>? other, double t) {
    if (other is! IxBlindTheme) {
      return this;
    }

    final mergedVariants = <IxBlindVariant, IxBlindStyle>{};
    for (final variant in IxBlindVariant.values) {
      mergedVariants[variant] = IxBlindStyle.lerp(
        style(variant),
        other.style(variant),
        t,
      );
    }

    return IxBlindTheme(
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
