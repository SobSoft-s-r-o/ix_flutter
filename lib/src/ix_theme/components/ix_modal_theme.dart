import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';

const double _defaultCssFontSizePx = 16.0;
const double _defaultBorderRadiusRem = 0.25;
const double _defaultBorderWidthRem = 0.0625;
const double _headerPaddingLeftRem = 0.5;
const double _headerPaddingTopBottomRem = 0.5;
const double _headerGapRem = 1.0;
const double _contentPaddingLeftRem = 0.5;
const double _contentPaddingTopRem = 0.5;
const double _contentPaddingRightRem = 0.5;
const double _contentPaddingBottomRem = 0.5;
const double _footerPaddingRem = 0.5;
const double _footerGapRem = 0.5;
const double _dialogPaddingRem = 1.0;
const double _defaultMaxHeightFraction = 0.8;

double _rem(double value) => value * _defaultCssFontSizePx;

enum IxModalSize { xs, sm, md, lg, xl, fullWidth, fullScreen }

const Map<IxModalSize, double> _modalFixedWidths = <IxModalSize, double>{
  IxModalSize.xs: 360,
  IxModalSize.sm: 480,
  IxModalSize.md: 600,
  IxModalSize.lg: 720,
  IxModalSize.xl: 840,
};

/// Captures layout hints for a concrete modal dialog size.
class IxModalSizeSpec {
  const IxModalSizeSpec({
    this.width,
    this.widthFactor,
    this.fullScreen = false,
    this.maxHeightFraction = _defaultMaxHeightFraction,
  }) : assert(
         width != null || widthFactor != null || fullScreen,
         'Provide a width, widthFactor, or mark the spec as fullScreen.',
       );

  final double? width;
  final double? widthFactor;
  final bool fullScreen;
  final double maxHeightFraction;

  IxModalSizeSpec copyWith({
    double? width,
    double? widthFactor,
    bool? fullScreen,
    double? maxHeightFraction,
  }) {
    return IxModalSizeSpec(
      width: width ?? this.width,
      widthFactor: widthFactor ?? this.widthFactor,
      fullScreen: fullScreen ?? this.fullScreen,
      maxHeightFraction: maxHeightFraction ?? this.maxHeightFraction,
    );
  }

  static IxModalSizeSpec lerp(IxModalSizeSpec a, IxModalSizeSpec b, double t) {
    return IxModalSizeSpec(
      width: lerpDouble(a.width, b.width, t),
      widthFactor: lerpDouble(a.widthFactor, b.widthFactor, t),
      fullScreen: t < 0.5 ? a.fullScreen : b.fullScreen,
      maxHeightFraction:
          lerpDouble(a.maxHeightFraction, b.maxHeightFraction, t) ??
          a.maxHeightFraction,
    );
  }
}

/// Theme extension that exposes Siemens IX modal dialog primitives.
class IxModalTheme extends ThemeExtension<IxModalTheme> {
  const IxModalTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.shadow,
    required this.backdropColor,
    required this.dialogPadding,
    required this.headerPadding,
    required this.headerGap,
    required this.contentPadding,
    required this.footerPadding,
    required this.footerGap,
    required this.maxHeightFraction,
    required this.sizes,
  });

  factory IxModalTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final headerPadding = EdgeInsets.fromLTRB(
      _rem(_headerPaddingLeftRem),
      _rem(_headerPaddingTopBottomRem),
      0,
      _rem(_headerPaddingTopBottomRem),
    );
    final contentPadding = EdgeInsets.fromLTRB(
      _rem(_contentPaddingLeftRem),
      _rem(_contentPaddingTopRem),
      _rem(_contentPaddingRightRem),
      _rem(_contentPaddingBottomRem),
    );
    final footerPadding = EdgeInsets.all(_rem(_footerPaddingRem));

    final boxShadows = List<BoxShadow>.unmodifiable([
      BoxShadow(
        color: pick(IxThemeColorToken.shadow1).withValues(alpha: 0.25),
        blurRadius: 2,
        offset: Offset.zero,
      ),
      BoxShadow(
        color: pick(IxThemeColorToken.shadow2).withValues(alpha: 0.14),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: pick(IxThemeColorToken.shadow3).withValues(alpha: 0.12),
        blurRadius: 18,
        offset: const Offset(0, 12),
      ),
    ]);

    final sizes = <IxModalSize, IxModalSizeSpec>{
      for (final entry in _modalFixedWidths.entries)
        entry.key: IxModalSizeSpec(width: entry.value),
      IxModalSize.fullWidth: const IxModalSizeSpec(widthFactor: 0.95),
      IxModalSize.fullScreen: const IxModalSizeSpec(
        widthFactor: 1,
        fullScreen: true,
        maxHeightFraction: 1,
      ),
    };

    return IxModalTheme(
      backgroundColor: pick(IxThemeColorToken.color2),
      borderColor: pick(IxThemeColorToken.color0),
      borderWidth: _rem(_defaultBorderWidthRem),
      borderRadius: _rem(_defaultBorderRadiusRem),
      shadow: boxShadows,
      backdropColor: pick(IxThemeColorToken.lightbox),
      dialogPadding: _rem(_dialogPaddingRem),
      headerPadding: headerPadding,
      headerGap: _rem(_headerGapRem),
      contentPadding: contentPadding,
      footerPadding: footerPadding,
      footerGap: _rem(_footerGapRem),
      maxHeightFraction: _defaultMaxHeightFraction,
      sizes: Map<IxModalSize, IxModalSizeSpec>.unmodifiable(sizes),
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final List<BoxShadow> shadow;
  final Color backdropColor;
  final double dialogPadding;
  final EdgeInsets headerPadding;
  final double headerGap;
  final EdgeInsets contentPadding;
  final EdgeInsets footerPadding;
  final double footerGap;
  final double maxHeightFraction;
  final Map<IxModalSize, IxModalSizeSpec> sizes;

  IxModalSizeSpec size(IxModalSize modalSize) {
    return sizes[modalSize] ?? sizes[IxModalSize.md]!;
  }

  @override
  IxModalTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    List<BoxShadow>? shadow,
    Color? backdropColor,
    double? dialogPadding,
    EdgeInsets? headerPadding,
    double? headerGap,
    EdgeInsets? contentPadding,
    EdgeInsets? footerPadding,
    double? footerGap,
    double? maxHeightFraction,
    Map<IxModalSize, IxModalSizeSpec>? sizes,
  }) {
    return IxModalTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
      backdropColor: backdropColor ?? this.backdropColor,
      dialogPadding: dialogPadding ?? this.dialogPadding,
      headerPadding: headerPadding ?? this.headerPadding,
      headerGap: headerGap ?? this.headerGap,
      contentPadding: contentPadding ?? this.contentPadding,
      footerPadding: footerPadding ?? this.footerPadding,
      footerGap: footerGap ?? this.footerGap,
      maxHeightFraction: maxHeightFraction ?? this.maxHeightFraction,
      sizes: sizes ?? this.sizes,
    );
  }

  @override
  IxModalTheme lerp(ThemeExtension<IxModalTheme>? other, double t) {
    if (other is! IxModalTheme) {
      return this;
    }

    final blendedSizes = <IxModalSize, IxModalSizeSpec>{};
    final keys = <IxModalSize>{...sizes.keys, ...other.sizes.keys};
    for (final key in keys) {
      final first = sizes[key] ?? other.sizes[key]!;
      final second = other.sizes[key] ?? sizes[key]!;
      blendedSizes[key] = IxModalSizeSpec.lerp(first, second, t);
    }

    return IxModalTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      shadow: BoxShadow.lerpList(shadow, other.shadow, t) ?? shadow,
      backdropColor:
          Color.lerp(backdropColor, other.backdropColor, t) ?? backdropColor,
      dialogPadding:
          lerpDouble(dialogPadding, other.dialogPadding, t) ?? dialogPadding,
      headerPadding:
          EdgeInsets.lerp(headerPadding, other.headerPadding, t) ??
          headerPadding,
      headerGap: lerpDouble(headerGap, other.headerGap, t) ?? headerGap,
      contentPadding:
          EdgeInsets.lerp(contentPadding, other.contentPadding, t) ??
          contentPadding,
      footerPadding:
          EdgeInsets.lerp(footerPadding, other.footerPadding, t) ??
          footerPadding,
      footerGap: lerpDouble(footerGap, other.footerGap, t) ?? footerGap,
      maxHeightFraction:
          lerpDouble(maxHeightFraction, other.maxHeightFraction, t) ??
          maxHeightFraction,
      sizes: Map<IxModalSize, IxModalSizeSpec>.unmodifiable(blendedSizes),
    );
  }
}
