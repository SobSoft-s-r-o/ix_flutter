import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';

const _defaultCssFontSizePx = 16.0; // Browser default for 1rem.
const double _uploadMinHeightRem = 4.0; // Dropzone height from ix-upload.
const double _uploadPaddingRem = 1.0; // vars.$default-space in SCSS.
const double _defaultBorderRadiusRem = 0.25; // --theme-default-border-radius.
const double _defaultBorderWidthRem = 0.0625; // --theme-border-width-default.

const double _uploadMinHeightPx = _uploadMinHeightRem * _defaultCssFontSizePx;
const double _uploadPaddingPx = _uploadPaddingRem * _defaultCssFontSizePx;
const double _uploadBorderRadiusPx =
    _defaultBorderRadiusRem * _defaultCssFontSizePx;
const double _uploadBorderWidthPx =
    _defaultBorderWidthRem * _defaultCssFontSizePx;

/// Visual states surfaced by Siemens IX upload dropzones.
enum IxUploadSurfaceState { idle, dragOver, checking, disabled }

/// Border styles used by the IX upload component.
enum IxUploadBorderStyle { dashed, solid }

/// Captures the resolved colors for a specific upload surface state.
class IxUploadStateStyle {
  const IxUploadStateStyle({
    required this.background,
    required this.borderColor,
    required this.textColor,
    required this.borderStyle,
  });

  final Color background;
  final Color borderColor;
  final Color textColor;
  final IxUploadBorderStyle borderStyle;

  IxUploadStateStyle copyWith({
    Color? background,
    Color? borderColor,
    Color? textColor,
    IxUploadBorderStyle? borderStyle,
  }) {
    return IxUploadStateStyle(
      background: background ?? this.background,
      borderColor: borderColor ?? this.borderColor,
      textColor: textColor ?? this.textColor,
      borderStyle: borderStyle ?? this.borderStyle,
    );
  }

  static IxUploadStateStyle lerp(
    IxUploadStateStyle a,
    IxUploadStateStyle b,
    double t,
  ) {
    return IxUploadStateStyle(
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t) ?? a.borderColor,
      textColor: Color.lerp(a.textColor, b.textColor, t) ?? a.textColor,
      borderStyle: t < 0.5 ? a.borderStyle : b.borderStyle,
    );
  }
}

/// Theme extension that exposes IX upload colors, typography, and spacing.
class IxUploadTheme extends ThemeExtension<IxUploadTheme> {
  const IxUploadTheme({
    required this.states,
    required this.minHeight,
    required this.padding,
    required this.borderRadius,
    required this.borderWidth,
  });

  factory IxUploadTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    IxUploadStateStyle style({
      required IxThemeColorToken background,
      required IxThemeColorToken border,
      required IxThemeColorToken text,
      required IxUploadBorderStyle borderStyle,
    }) {
      return IxUploadStateStyle(
        background: pick(background),
        borderColor: pick(border),
        textColor: pick(text),
        borderStyle: borderStyle,
      );
    }

    final states = Map<IxUploadSurfaceState, IxUploadStateStyle>.unmodifiable({
      IxUploadSurfaceState.idle: style(
        background: IxThemeColorToken.color1,
        border: IxThemeColorToken.softBdr,
        text: IxThemeColorToken.stdText,
        borderStyle: IxUploadBorderStyle.dashed,
      ),
      IxUploadSurfaceState.dragOver: style(
        background: IxThemeColorToken.color1,
        border: IxThemeColorToken.dynamic,
        text: IxThemeColorToken.stdText,
        borderStyle: IxUploadBorderStyle.solid,
      ),
      IxUploadSurfaceState.checking: style(
        background: IxThemeColorToken.color1,
        border: IxThemeColorToken.softBdr,
        text: IxThemeColorToken.stdText,
        borderStyle: IxUploadBorderStyle.solid,
      ),
      IxUploadSurfaceState.disabled: style(
        background: IxThemeColorToken.color0,
        border: IxThemeColorToken.softBdr,
        text: IxThemeColorToken.weakText,
        borderStyle: IxUploadBorderStyle.solid,
      ),
    });

    return IxUploadTheme(
      states: states,
      minHeight: _uploadMinHeightPx,
      padding: const EdgeInsets.all(_uploadPaddingPx),
      borderRadius: _uploadBorderRadiusPx,
      borderWidth: _uploadBorderWidthPx,
    );
  }

  final Map<IxUploadSurfaceState, IxUploadStateStyle> states;
  final double minHeight;
  final EdgeInsets padding;
  final double borderRadius;
  final double borderWidth;

  IxUploadStateStyle style(IxUploadSurfaceState state) {
    return states[state] ?? states[IxUploadSurfaceState.idle]!;
  }

  @override
  IxUploadTheme copyWith({
    Map<IxUploadSurfaceState, IxUploadStateStyle>? states,
    double? minHeight,
    EdgeInsets? padding,
    double? borderRadius,
    double? borderWidth,
  }) {
    return IxUploadTheme(
      states: states ?? this.states,
      minHeight: minHeight ?? this.minHeight,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  IxUploadTheme lerp(ThemeExtension<IxUploadTheme>? other, double t) {
    if (other is! IxUploadTheme) {
      return this;
    }

    final mergedStates = <IxUploadSurfaceState, IxUploadStateStyle>{};
    final statesToBlend = <IxUploadSurfaceState>{
      ...states.keys,
      ...other.states.keys,
    };

    for (final state in statesToBlend) {
      final first = states[state] ?? other.states[state]!;
      final second = other.states[state] ?? states[state]!;
      mergedStates[state] = IxUploadStateStyle.lerp(first, second, t);
    }

    return IxUploadTheme(
      states: Map.unmodifiable(mergedStates),
      minHeight: lerpDouble(minHeight, other.minHeight, t) ?? minHeight,
      padding: EdgeInsets.lerp(padding, other.padding, t) ?? padding,
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
    );
  }
}
