import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';

/// Siemens IX color roles specific to scrollbar states.
class IxScrollbarColors extends ThemeExtension<IxScrollbarColors> {
  const IxScrollbarColors({
    required this.thumb,
    required this.thumbHover,
    required this.thumbActive,
    required this.thumbDisabled,
    required this.track,
    required this.trackHover,
    required this.trackActive,
    required this.trackDisabled,
    required this.trackBorder,
    required this.trackBorderHover,
    required this.trackBorderActive,
    required this.trackBorderDisabled,
  });

  final Color thumb;
  final Color thumbHover;
  final Color thumbActive;
  final Color thumbDisabled;
  final Color track;
  final Color trackHover;
  final Color trackActive;
  final Color trackDisabled;
  final Color trackBorder;
  final Color trackBorderHover;
  final Color trackBorderActive;
  final Color trackBorderDisabled;

  @override
  IxScrollbarColors copyWith({
    Color? thumb,
    Color? thumbHover,
    Color? thumbActive,
    Color? thumbDisabled,
    Color? track,
    Color? trackHover,
    Color? trackActive,
    Color? trackDisabled,
    Color? trackBorder,
    Color? trackBorderHover,
    Color? trackBorderActive,
    Color? trackBorderDisabled,
  }) {
    return IxScrollbarColors(
      thumb: thumb ?? this.thumb,
      thumbHover: thumbHover ?? this.thumbHover,
      thumbActive: thumbActive ?? this.thumbActive,
      thumbDisabled: thumbDisabled ?? this.thumbDisabled,
      track: track ?? this.track,
      trackHover: trackHover ?? this.trackHover,
      trackActive: trackActive ?? this.trackActive,
      trackDisabled: trackDisabled ?? this.trackDisabled,
      trackBorder: trackBorder ?? this.trackBorder,
      trackBorderHover: trackBorderHover ?? this.trackBorderHover,
      trackBorderActive: trackBorderActive ?? this.trackBorderActive,
      trackBorderDisabled: trackBorderDisabled ?? this.trackBorderDisabled,
    );
  }

  @override
  IxScrollbarColors lerp(ThemeExtension<IxScrollbarColors>? other, double t) {
    if (other is! IxScrollbarColors) {
      return this;
    }

    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return IxScrollbarColors(
      thumb: mix(thumb, other.thumb),
      thumbHover: mix(thumbHover, other.thumbHover),
      thumbActive: mix(thumbActive, other.thumbActive),
      thumbDisabled: mix(thumbDisabled, other.thumbDisabled),
      track: mix(track, other.track),
      trackHover: mix(trackHover, other.trackHover),
      trackActive: mix(trackActive, other.trackActive),
      trackDisabled: mix(trackDisabled, other.trackDisabled),
      trackBorder: mix(trackBorder, other.trackBorder),
      trackBorderHover: mix(trackBorderHover, other.trackBorderHover),
      trackBorderActive: mix(trackBorderActive, other.trackBorderActive),
      trackBorderDisabled: mix(trackBorderDisabled, other.trackBorderDisabled),
    );
  }
}

/// Theme extension that exposes Siemens IX scrollbar metrics and colors.
class IxScrollbarTheme extends ThemeExtension<IxScrollbarTheme> {
  const IxScrollbarTheme({
    required this.materialScrollbarTheme,
    required this.colors,
    required this.baseThickness,
    required this.hoverThickness,
    required this.activeThickness,
    required this.minThumbLength,
    required this.radius,
    required this.crossAxisMargin,
    required this.mainAxisMargin,
  });

  factory IxScrollbarTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final colors = IxScrollbarColors(
      thumb: pick(IxThemeColorToken.component4),
      thumbHover: pick(IxThemeColorToken.component5),
      thumbActive: pick(IxThemeColorToken.component6),
      thumbDisabled: pick(IxThemeColorToken.component2),
      track: pick(IxThemeColorToken.color2),
      trackHover: pick(IxThemeColorToken.color3),
      trackActive: pick(IxThemeColorToken.color3),
      trackDisabled: pick(IxThemeColorToken.color1),
      trackBorder: pick(IxThemeColorToken.weakBdr),
      trackBorderHover: pick(IxThemeColorToken.softBdr),
      trackBorderActive: pick(IxThemeColorToken.stdBdr),
      trackBorderDisabled: pick(IxThemeColorToken.xWeakBdr),
    );

    const baseThickness = IxCommonGeometry.scrollbarBaseThickness;
    const hoverThickness = IxCommonGeometry.scrollbarHoverThickness;
    const activeThickness = IxCommonGeometry.scrollbarActiveThickness;
    const minThumbLength = IxCommonGeometry.scrollbarMinThumbLength;
    const margin = IxCommonGeometry.scrollbarMargin;
    const radius = Radius.circular(IxCommonGeometry.scrollbarRadius);

    ScrollbarThemeData resolveTheme() {
      return ScrollbarThemeData(
        radius: radius,
        crossAxisMargin: margin,
        mainAxisMargin: margin,
        minThumbLength: minThumbLength,
        interactive: true,
        thumbVisibility: const WidgetStatePropertyAll<bool?>(true),
        trackVisibility: const WidgetStatePropertyAll<bool?>(true),
        thickness: WidgetStateProperty.resolveWith((states) {
          return _resolveThickness(
            states,
            baseThickness: baseThickness,
            hoverThickness: hoverThickness,
            activeThickness: activeThickness,
          );
        }),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => _resolveThumbColor(states, colors),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => _resolveTrackColor(states, colors),
        ),
        trackBorderColor: WidgetStateProperty.resolveWith(
          (states) => _resolveTrackBorderColor(states, colors),
        ),
      );
    }

    return IxScrollbarTheme(
      materialScrollbarTheme: resolveTheme(),
      colors: colors,
      baseThickness: baseThickness,
      hoverThickness: hoverThickness,
      activeThickness: activeThickness,
      minThumbLength: minThumbLength,
      radius: radius,
      crossAxisMargin: margin,
      mainAxisMargin: margin,
    );
  }

  final ScrollbarThemeData materialScrollbarTheme;
  final IxScrollbarColors colors;
  final double baseThickness;
  final double hoverThickness;
  final double activeThickness;
  final double minThumbLength;
  final Radius radius;
  final double crossAxisMargin;
  final double mainAxisMargin;

  @override
  IxScrollbarTheme copyWith({
    ScrollbarThemeData? materialScrollbarTheme,
    IxScrollbarColors? colors,
    double? baseThickness,
    double? hoverThickness,
    double? activeThickness,
    double? minThumbLength,
    Radius? radius,
    double? crossAxisMargin,
    double? mainAxisMargin,
  }) {
    return IxScrollbarTheme(
      materialScrollbarTheme:
          materialScrollbarTheme ?? this.materialScrollbarTheme,
      colors: colors ?? this.colors,
      baseThickness: baseThickness ?? this.baseThickness,
      hoverThickness: hoverThickness ?? this.hoverThickness,
      activeThickness: activeThickness ?? this.activeThickness,
      minThumbLength: minThumbLength ?? this.minThumbLength,
      radius: radius ?? this.radius,
      crossAxisMargin: crossAxisMargin ?? this.crossAxisMargin,
      mainAxisMargin: mainAxisMargin ?? this.mainAxisMargin,
    );
  }

  @override
  IxScrollbarTheme lerp(ThemeExtension<IxScrollbarTheme>? other, double t) {
    if (other is! IxScrollbarTheme) {
      return this;
    }

    return IxScrollbarTheme(
      materialScrollbarTheme: ScrollbarThemeData.lerp(
        materialScrollbarTheme,
        other.materialScrollbarTheme,
        t,
      ),
      colors: colors.lerp(other.colors, t),
      baseThickness:
          lerpDouble(baseThickness, other.baseThickness, t) ?? baseThickness,
      hoverThickness:
          lerpDouble(hoverThickness, other.hoverThickness, t) ?? hoverThickness,
      activeThickness:
          lerpDouble(activeThickness, other.activeThickness, t) ??
          activeThickness,
      minThumbLength:
          lerpDouble(minThumbLength, other.minThumbLength, t) ?? minThumbLength,
      radius: Radius.lerp(radius, other.radius, t) ?? radius,
      crossAxisMargin:
          lerpDouble(crossAxisMargin, other.crossAxisMargin, t) ??
          crossAxisMargin,
      mainAxisMargin:
          lerpDouble(mainAxisMargin, other.mainAxisMargin, t) ?? mainAxisMargin,
    );
  }
}

bool _isDisabled(Set<WidgetState> states) =>
    states.contains(WidgetState.disabled);

bool _isActive(Set<WidgetState> states) =>
    states.contains(WidgetState.dragged) ||
    states.contains(WidgetState.pressed);

bool _isHovering(Set<WidgetState> states) =>
    states.contains(WidgetState.hovered) ||
    states.contains(WidgetState.focused);

Color _resolveThumbColor(Set<WidgetState> states, IxScrollbarColors colors) {
  if (_isDisabled(states)) {
    return colors.thumbDisabled;
  }
  if (_isActive(states)) {
    return colors.thumbActive;
  }
  if (_isHovering(states)) {
    return colors.thumbHover;
  }
  return colors.thumb;
}

Color _resolveTrackColor(Set<WidgetState> states, IxScrollbarColors colors) {
  if (_isDisabled(states)) {
    return colors.trackDisabled;
  }
  if (_isActive(states)) {
    return colors.trackActive;
  }
  if (_isHovering(states)) {
    return colors.trackHover;
  }
  return colors.track;
}

Color _resolveTrackBorderColor(
  Set<WidgetState> states,
  IxScrollbarColors colors,
) {
  if (_isDisabled(states)) {
    return colors.trackBorderDisabled;
  }
  if (_isActive(states)) {
    return colors.trackBorderActive;
  }
  if (_isHovering(states)) {
    return colors.trackBorderHover;
  }
  return colors.trackBorder;
}

double _resolveThickness(
  Set<WidgetState> states, {
  required double baseThickness,
  required double hoverThickness,
  required double activeThickness,
}) {
  if (_isDisabled(states)) {
    return baseThickness;
  }
  if (_isActive(states)) {
    return activeThickness;
  }
  if (_isHovering(states)) {
    return hoverThickness;
  }
  return baseThickness;
}
