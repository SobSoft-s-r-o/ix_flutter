import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_family.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_dark_colors.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_light_colors.dart';
import 'package:ix_flutter/src/ix_core/ix_color_palette.dart';

/// Declarative palette that can override Siemens IX brand/classic colors.
///
/// Use [IxCustomPalette.partial] to override a few tokens on top of the
/// classic palette, [IxCustomPalette.override] to start from a specific IX
/// family, or the default constructor to supply complete `light`/`dark` maps.
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

  /// Creates a palette from a handful of tokens, filling the rest in from
  /// the Siemens iX classic palette.
  ///
  /// The token-complete alternative to [IxCustomPalette.new]: pass only the
  /// tokens you want to change.
  ///
  /// ```dart
  /// final palette = IxCustomPalette.partial(
  ///   light: {IxThemeColorToken.primary: const Color(0xFF0050F5)},
  /// );
  /// ```
  factory IxCustomPalette.partial({
    Map<IxThemeColorToken, Color> light = const {},
    Map<IxThemeColorToken, Color> dark = const {},
  }) {
    return IxCustomPalette(
      light: {...IxClassicLightColors.palette, ...light},
      dark: {...IxClassicDarkColors.palette, ...dark},
    );
  }

  final Map<IxThemeColorToken, Color> _light;
  final Map<IxThemeColorToken, Color> _dark;

  /// Resolves the palette for the given [brightness].
  Map<IxThemeColorToken, Color> resolve(Brightness brightness) {
    return brightness == Brightness.dark ? _dark : _light;
  }

  /// Returns a copy with [light]/[dark] merged on top of this palette.
  ///
  /// Unlike a regular `copyWith`, the maps are merged token by token rather
  /// than replaced wholesale, so a partial map is enough.
  IxCustomPalette copyWith({
    Map<IxThemeColorToken, Color>? light,
    Map<IxThemeColorToken, Color>? dark,
  }) {
    return IxCustomPalette(
      light: {..._light, ...?light},
      dark: {..._dark, ...?dark},
    );
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
