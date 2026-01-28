import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_colors.dart';

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
        // Brand palettes are proprietary and not bundled with the OSS build.
        // Consumers can supply a custom palette via IxThemeBuilder instead.
        return _classicPalette(variant);
      case IxThemeFamily.custom:
        // Custom relies on user-supplied palettes; fall back to classic when
        // none is provided.
        return _classicPalette(variant);
    }
  }

  static Map<IxThemeColorToken, Color> _classicPalette(_ThemeVariant variant) {
    return variant == _ThemeVariant.dark
        ? IxClassicDarkColors.palette
        : IxClassicLightColors.palette;
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
