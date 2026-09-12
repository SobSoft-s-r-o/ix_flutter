import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_light_colors.dart';
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
enum IxSpinnerVariant {
  /// The published value for the muted spinner style; use [secondary].
  @Deprecated('Use secondary. Removed in 2.0.')
  standard,

  /// Uses the primary brand color for emphasized loading states.
  primary;

  /// Uses muted UI colors for subtle loading indicators.
  ///
  /// In 1.x this aliases [standard], preserving published enum values and
  /// indices. Its [name] remains `standard` until 2.0.
  // ignore: deprecated_member_use_from_same_package
  static const IxSpinnerVariant secondary = standard;
}

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
      IxSpinnerVariant.secondary: IxSpinnerVariantStyle(
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

  /// The built-in theme, used as the last-resort source of a size spec or
  /// variant style a consumer-supplied map does not carry.
  ///
  /// Built once from the classic light palette -- the same palette
  /// `IxSpinner` already falls back to when no [IxSpinnerTheme] is
  /// registered at all -- so the geometry is always the upstream one and
  /// only the colors can differ from the active theme.
  static final IxSpinnerTheme _builtIn = IxSpinnerTheme.fromPalette(
    palette: IxClassicLightColors.palette,
  );

  static IxSpinnerVariantStyle _resolveVariant(
    Map<IxSpinnerVariant, IxSpinnerVariantStyle> variants,
    IxSpinnerVariant variant,
  ) {
    // The secondary spelling is the same enum value as standard, so maps
    // written with either spelling answer the same lookup.
    return variants[variant] ??
        _builtIn.variants[variant] ??
        _builtIn.variants[IxSpinnerVariant.secondary]!;
  }

  static IxSpinnerSizeSpec _resolveSize(
    Map<IxSpinnerSize, IxSpinnerSizeSpec> sizes,
    IxSpinnerSize size,
  ) {
    return sizes[size] ??
        _builtIn.sizes[size] ??
        _builtIn.sizes[IxSpinnerSize.medium]!;
  }

  final Map<IxSpinnerSize, IxSpinnerSizeSpec> sizes;
  final Map<IxSpinnerVariant, IxSpinnerVariantStyle> variants;
  final double ringInsetFraction;
  final Duration rotationDuration;
  final Duration maskDuration;

  /// The size spec for [size], falling back to the built-in spec when a
  /// consumer-supplied [sizes] map does not carry that key.
  IxSpinnerSizeSpec size(IxSpinnerSize size) {
    return _resolveSize(sizes, size);
  }

  /// The variant style for [variant].
  ///
  /// Resolution order: the requested key, then the built-in style.
  /// ([IxSpinnerVariant.standard] and [IxSpinnerVariant.secondary] name the
  /// same enum value by definition).
  /// A [variants] map supplied by a consumer therefore never has to be
  /// exhaustive -- in particular a map written before
  /// [IxSpinnerVariant.secondary] existed keeps rendering every spinner.
  IxSpinnerVariantStyle style(IxSpinnerVariant variant) {
    return _resolveVariant(variants, variant);
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

    // Both loops resolve each key through the same fallback chain `size()`
    // and `style()` use, so a key only one side declares still interpolates
    // from a real style on the other side (its alias, or the built-in one)
    // instead of snapping -- and neither loop can trip a `!` on a
    // consumer-supplied map that is missing a key entirely.
    final blendedSizes = <IxSpinnerSize, IxSpinnerSizeSpec>{};
    final sizeKeys = <IxSpinnerSize>{...sizes.keys, ...other.sizes.keys};
    for (final sizeKey in sizeKeys) {
      blendedSizes[sizeKey] = IxSpinnerSizeSpec.lerp(
        _resolveSize(sizes, sizeKey),
        _resolveSize(other.sizes, sizeKey),
        t,
      );
    }

    final blendedVariants = <IxSpinnerVariant, IxSpinnerVariantStyle>{};
    final variantKeys = <IxSpinnerVariant>{
      ...variants.keys,
      ...other.variants.keys,
    };
    for (final variantKey in variantKeys) {
      blendedVariants[variantKey] = IxSpinnerVariantStyle.lerp(
        _resolveVariant(variants, variantKey),
        _resolveVariant(other.variants, variantKey),
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
