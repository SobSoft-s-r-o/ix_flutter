import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_colors.dart';

/// Resolves theme color palettes keyed by [IxThemeColorToken].
class IxColorPalette {
  const IxColorPalette._();

  /// Returns the palette for the requested [family] and [mode]. For
  /// [ThemeMode.system], pass the current [systemBrightness].
  static Map<IxThemeColorToken, Color> resolve({
    required IxThemeFamily family,
    required ThemeMode mode,
    Brightness systemBrightness = Brightness.light,
  }) {
    final variant = _variantFromMode(mode, systemBrightness);

    switch (family) {
      case IxThemeFamily.classic:
        return _classicPalette(variant);
      case IxThemeFamily.brand:
        return _brandPalette(variant);
    }
  }

  static Map<IxThemeColorToken, Color> _classicPalette(_ThemeVariant variant) {
    return variant == _ThemeVariant.dark
        ? IxClassicDarkColors.palette
        : IxClassicLightColors.palette;
  }

  static final Map<_ThemeVariant, Map<IxThemeColorToken, Color>>
  _brandPaletteCache = {
    _ThemeVariant.light: _buildBrandPalette(_ThemeVariant.light),
    _ThemeVariant.dark: _buildBrandPalette(_ThemeVariant.dark),
  };

  static Map<IxThemeColorToken, Color> _brandPalette(_ThemeVariant variant) {
    return _brandPaletteCache[variant]!;
  }

  static Map<IxThemeColorToken, Color> _buildBrandPalette(
    _ThemeVariant variant,
  ) {
    final brand = variant == _ThemeVariant.dark
        ? IxBrandDarkColors.palette
        : IxBrandLightColors.palette;

    if (brand.length == IxThemeColorToken.values.length) {
      return brand;
    }

    // Fill missing brand tokens from their classic counterparts.
    final fallback = _classicPalette(variant);
    final merged = Map<IxThemeColorToken, Color>.from(fallback)..addAll(brand);
    return Map.unmodifiable(merged);
  }

  static _ThemeVariant _variantFromMode(
    ThemeMode mode,
    Brightness systemBrightness,
  ) {
    switch (mode) {
      case ThemeMode.dark:
        return _ThemeVariant.dark;
      case ThemeMode.light:
        return _ThemeVariant.light;
      case ThemeMode.system:
        return systemBrightness == Brightness.dark
            ? _ThemeVariant.dark
            : _ThemeVariant.light;
    }
  }
}

enum _ThemeVariant { light, dark }
