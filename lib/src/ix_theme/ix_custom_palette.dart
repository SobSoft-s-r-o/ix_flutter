import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_family.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_color_palette.dart';

/// Declarative palette that can override Siemens IX brand/classic colors.
///
/// Provide explicit [light] and [dark] maps or use [IxCustomPalette.override]
/// to start from a base IX family and override selected tokens.
class IxCustomPalette {
  IxCustomPalette({
    required Map<IxThemeColorToken, Color> light,
    Map<IxThemeColorToken, Color>? dark,
  }) : _light = _lock(light),
       _dark = _lock(dark ?? light);

  /// Creates a palette by patching selected tokens on top of an IX base.
  factory IxCustomPalette.override({
    IxThemeFamily baseFamily = IxThemeFamily.classic,
    Map<IxThemeColorToken, Color> lightOverrides = const {},
    Map<IxThemeColorToken, Color> darkOverrides = const {},
  }) {
    final baseLight = IxColorPalette.resolve(
      family: baseFamily,
      mode: ThemeMode.light,
      systemBrightness: Brightness.light,
    );
    final baseDark = IxColorPalette.resolve(
      family: baseFamily,
      mode: ThemeMode.dark,
      systemBrightness: Brightness.dark,
    );

    return IxCustomPalette(
      light: {...baseLight, ...lightOverrides},
      dark: {...baseDark, ...darkOverrides},
    );
  }

  final Map<IxThemeColorToken, Color> _light;
  final Map<IxThemeColorToken, Color> _dark;

  /// Resolves the palette for the given [brightness].
  Map<IxThemeColorToken, Color> resolve(Brightness brightness) {
    return brightness == Brightness.dark ? _dark : _light;
  }

  static Map<IxThemeColorToken, Color> _lock(
    Map<IxThemeColorToken, Color> palette,
  ) {
    if (palette.length != IxThemeColorToken.values.length) {
      throw ArgumentError(
        'Custom palettes must specify all '
        '${IxThemeColorToken.values.length} theme tokens. '
        'Received ${palette.length}.',
      );
    }
    return Map.unmodifiable(palette);
  }
}
