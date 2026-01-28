import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';

const double _xxSmallDiameter = IxCommonGeometry.space2;
const double _xSmallDiameter = IxCommonGeometry.modularScale2;
const double _smallDiameter = IxCommonGeometry.space4;
const double _mediumDiameter = IxCommonGeometry.space6;
const double _largeDiameter = IxCommonGeometry.space8;
const double _ringInsetFraction = 0.0833; // 8.33% inset from SCSS.
const Duration _rotationDuration = Duration(seconds: 2);
const Duration _maskDuration = Duration(seconds: 3);

/// Available Siemens IX spinner sizes.
enum IxSpinnerSize { xxSmall, xSmall, small, medium, large }

/// Supported Siemens IX spinner color variants.
enum IxSpinnerVariant { standard, primary }

/// Captures the physical footprint and stroke width for a given spinner size.
class IxSpinnerSizeSpec {
  const IxSpinnerSizeSpec({required this.diameter, required this.trackWidth});

  final double diameter;
  final double trackWidth;

  IxSpinnerSizeSpec copyWith({double? diameter, double? trackWidth}) {
    return IxSpinnerSizeSpec(
      diameter: diameter ?? this.diameter,
      trackWidth: trackWidth ?? this.trackWidth,
    );
  }

  static IxSpinnerSizeSpec lerp(
    IxSpinnerSizeSpec a,
    IxSpinnerSizeSpec b,
    double t,
  ) {
    return IxSpinnerSizeSpec(
      diameter: lerpDouble(a.diameter, b.diameter, t) ?? a.diameter,
      trackWidth: lerpDouble(a.trackWidth, b.trackWidth, t) ?? a.trackWidth,
    );
  }
}

/// Color pairing for a spinner variant (indicator + optional track).
class IxSpinnerVariantStyle {
  const IxSpinnerVariantStyle({
    required this.indicatorColor,
    required this.trackColor,
  });

  final Color indicatorColor;
  final Color trackColor;

  IxSpinnerVariantStyle copyWith({Color? indicatorColor, Color? trackColor}) {
    return IxSpinnerVariantStyle(
      indicatorColor: indicatorColor ?? this.indicatorColor,
      trackColor: trackColor ?? this.trackColor,
    );
  }

  static IxSpinnerVariantStyle lerp(
    IxSpinnerVariantStyle a,
    IxSpinnerVariantStyle b,
    double t,
  ) {
    return IxSpinnerVariantStyle(
      indicatorColor:
          Color.lerp(a.indicatorColor, b.indicatorColor, t) ?? a.indicatorColor,
      trackColor: Color.lerp(a.trackColor, b.trackColor, t) ?? a.trackColor,
    );
  }
}

Duration _lerpDuration(Duration a, Duration b, double t) {
  final microseconds =
      (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t).round();
  return Duration(microseconds: microseconds);
}

/// Theme extension that exposes Siemens IX spinner dimensions and colors.
class IxSpinnerTheme extends ThemeExtension<IxSpinnerTheme> {
  const IxSpinnerTheme({
    required this.sizes,
    required this.variants,
    required this.ringInsetFraction,
    required this.rotationDuration,
    required this.maskDuration,
  });

  factory IxSpinnerTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final sizes = Map<IxSpinnerSize, IxSpinnerSizeSpec>.unmodifiable({
      IxSpinnerSize.xxSmall: IxSpinnerSizeSpec(
        diameter: _xxSmallDiameter,
        trackWidth: IxCommonGeometry.borderWidthDefault,
      ),
      IxSpinnerSize.xSmall: IxSpinnerSizeSpec(
        diameter: _xSmallDiameter,
        trackWidth: IxCommonGeometry.borderWidthThick,
      ),
      IxSpinnerSize.small: IxSpinnerSizeSpec(
        diameter: _smallDiameter,
        trackWidth: IxCommonGeometry.borderWidthThick,
      ),
      IxSpinnerSize.medium: IxSpinnerSizeSpec(
        diameter: _mediumDiameter,
        trackWidth: IxCommonGeometry.borderWidthThick,
      ),
      IxSpinnerSize.large: IxSpinnerSizeSpec(
        diameter: _largeDiameter,
        trackWidth: IxCommonGeometry.spaceNeg1,
      ),
    });

    final variants = Map<IxSpinnerVariant, IxSpinnerVariantStyle>.unmodifiable({
      IxSpinnerVariant.standard: IxSpinnerVariantStyle(
        indicatorColor: pick(IxThemeColorToken.softText),
        trackColor: pick(IxThemeColorToken.component3),
      ),
      IxSpinnerVariant.primary: IxSpinnerVariantStyle(
        indicatorColor: pick(IxThemeColorToken.dynamic),
        trackColor: pick(IxThemeColorToken.ghostHover),
      ),
    });

    return IxSpinnerTheme(
      sizes: sizes,
      variants: variants,
      ringInsetFraction: _ringInsetFraction,
      rotationDuration: _rotationDuration,
      maskDuration: _maskDuration,
    );
  }

  final Map<IxSpinnerSize, IxSpinnerSizeSpec> sizes;
  final Map<IxSpinnerVariant, IxSpinnerVariantStyle> variants;
  final double ringInsetFraction;
  final Duration rotationDuration;
  final Duration maskDuration;

  IxSpinnerSizeSpec size(IxSpinnerSize size) {
    return sizes[size] ?? sizes[IxSpinnerSize.medium]!;
  }

  IxSpinnerVariantStyle style(IxSpinnerVariant variant) {
    return variants[variant] ?? variants[IxSpinnerVariant.standard]!;
  }

  @override
  IxSpinnerTheme copyWith({
    Map<IxSpinnerSize, IxSpinnerSizeSpec>? sizes,
    Map<IxSpinnerVariant, IxSpinnerVariantStyle>? variants,
    double? ringInsetFraction,
    Duration? rotationDuration,
    Duration? maskDuration,
  }) {
    return IxSpinnerTheme(
      sizes: sizes ?? this.sizes,
      variants: variants ?? this.variants,
      ringInsetFraction: ringInsetFraction ?? this.ringInsetFraction,
      rotationDuration: rotationDuration ?? this.rotationDuration,
      maskDuration: maskDuration ?? this.maskDuration,
    );
  }

  @override
  IxSpinnerTheme lerp(ThemeExtension<IxSpinnerTheme>? other, double t) {
    if (other is! IxSpinnerTheme) {
      return this;
    }

    final blendedSizes = <IxSpinnerSize, IxSpinnerSizeSpec>{};
    final sizeKeys = <IxSpinnerSize>{...sizes.keys, ...other.sizes.keys};
    for (final sizeKey in sizeKeys) {
      final first = sizes[sizeKey] ?? other.sizes[sizeKey]!;
      final second = other.sizes[sizeKey] ?? sizes[sizeKey]!;
      blendedSizes[sizeKey] = IxSpinnerSizeSpec.lerp(first, second, t);
    }

    final blendedVariants = <IxSpinnerVariant, IxSpinnerVariantStyle>{};
    final variantKeys = <IxSpinnerVariant>{
      ...variants.keys,
      ...other.variants.keys,
    };
    for (final variantKey in variantKeys) {
      final first = variants[variantKey] ?? other.variants[variantKey]!;
      final second = other.variants[variantKey] ?? variants[variantKey]!;
      blendedVariants[variantKey] = IxSpinnerVariantStyle.lerp(
        first,
        second,
        t,
      );
    }

    return IxSpinnerTheme(
      sizes: Map.unmodifiable(blendedSizes),
      variants: Map.unmodifiable(blendedVariants),
      ringInsetFraction:
          lerpDouble(ringInsetFraction, other.ringInsetFraction, t) ??
          ringInsetFraction,
      rotationDuration: _lerpDuration(
        rotationDuration,
        other.rotationDuration,
        t,
      ),
      maskDuration: _lerpDuration(maskDuration, other.maskDuration, t),
    );
  }
}
