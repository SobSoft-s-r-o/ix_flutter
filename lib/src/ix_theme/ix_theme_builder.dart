import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_colors.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_color_palette.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_app_header_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_app_menu_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_button_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_card_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_checkbox_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_chip_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_form_field_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_radio_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_sidebar_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_tabs_theme.dart';

/// Builds `ThemeData` instances that comply with the Siemens IX color and type
/// scale guidance.
///
/// The builder only wires up global colors (color scheme, surfaces, text,
/// etc.). Component-specific theming will be layered on top later.
class IxThemeBuilder {
  const IxThemeBuilder({
    this.family = IxThemeFamily.brand,
    this.mode = ThemeMode.system,
    this.systemBrightness = Brightness.light,
    this.typography,
  });

  /// Siemens IX visual family (classic vs. brand).
  final IxThemeFamily family;

  /// Material theme mode to resolve light/dark variants.
  final ThemeMode mode;

  /// Platform brightness hint used when [mode] is [ThemeMode.system].
  final Brightness systemBrightness;

  /// Optional override for the Siemens IX type scale.
  final IxTypography? typography;

  /// Returns [ThemeData] configured with Siemens IX global colors and fonts.
  ThemeData build() {
    final Map<IxThemeColorToken, Color> palette = Map.unmodifiable(
      IxColorPalette.resolve(
        family: family,
        mode: mode,
        systemBrightness: systemBrightness,
      ),
    );

    final brightness = _resolveBrightness(mode, systemBrightness);
    final typeScale = typography ?? IxTypography();
    final colorScheme = _buildColorScheme(palette, brightness);
    final textTheme = _buildTextTheme(typeScale, palette);
    final buttonTheme = IxButtonTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final appHeaderTheme = IxAppHeaderTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final appMenuTheme = IxAppMenuTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final sidebarTheme = IxSidebarTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final chipTheme = IxChipTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final cardTheme = IxCardTheme.fromPalette(palette: palette);
    final checkboxTheme = IxCheckboxTheme.fromPalette(palette: palette);
    final radioTheme = IxRadioTheme.fromPalette(palette: palette);
    final tabsTheme = IxTabsTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final formFieldTheme = IxFormFieldTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final ixThemeExtension = IxTheme(
      family: family,
      mode: mode,
      brightness: brightness,
      palette: palette,
      typography: typeScale,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: palette[IxThemeColorToken.color1],
      canvasColor: palette[IxThemeColorToken.color1],
      dialogTheme: DialogThemeData(
        backgroundColor: palette[IxThemeColorToken.color2],
      ),
      cardColor: palette[IxThemeColorToken.color3],
      dividerColor: palette[IxThemeColorToken.softBdr],
      focusColor: palette[IxThemeColorToken.focusBdr],
      hoverColor: palette[IxThemeColorToken.color1Hover],
      highlightColor: palette[IxThemeColorToken.component1Hover],
      splashColor: palette[IxThemeColorToken.component1],
      disabledColor: palette[IxThemeColorToken.weakText],
      shadowColor: palette[IxThemeColorToken.shadow1],
      tabBarTheme: tabsTheme.materialTabTheme,
      inputDecorationTheme: formFieldTheme.inputDecorationTheme,
      dropdownMenuTheme: formFieldTheme.dropdownMenuTheme,
      datePickerTheme: formFieldTheme.datePickerTheme,
      checkboxTheme: checkboxTheme.materialCheckboxTheme,
      radioTheme: radioTheme.materialRadioTheme,
      filledButtonTheme: FilledButtonThemeData(style: buttonTheme.primary),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: buttonTheme.secondary,
      ),
      textButtonTheme: TextButtonThemeData(style: buttonTheme.tertiary),
      iconTheme: IconThemeData(
        color: palette[IxThemeColorToken.stdText],
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: palette[IxThemeColorToken.contrastText],
        size: 24,
      ),
      appBarTheme: appHeaderTheme.appBarTheme,
      menuTheme: appMenuTheme.menuTheme,
      navigationRailTheme: sidebarTheme.navigationRailTheme,
      chipTheme: chipTheme.materialChipTheme,
      cardTheme: cardTheme.materialCardTheme,
      textTheme: textTheme,
      fontFamily: typeScale.fontFamily,
      visualDensity: VisualDensity.standard,
      applyElevationOverlayColor: brightness == Brightness.dark,
      extensions: [
        ixThemeExtension,
        buttonTheme,
        appHeaderTheme,
        appMenuTheme,
        sidebarTheme,
        chipTheme,
        cardTheme,
        tabsTheme,
        formFieldTheme,
        checkboxTheme,
        radioTheme,
      ],
    );
  }

  /// Copies the builder with new parameters.
  IxThemeBuilder copyWith({
    IxThemeFamily? family,
    ThemeMode? mode,
    Brightness? systemBrightness,
    IxTypography? typography,
  }) {
    return IxThemeBuilder(
      family: family ?? this.family,
      mode: mode ?? this.mode,
      systemBrightness: systemBrightness ?? this.systemBrightness,
      typography: typography ?? this.typography,
    );
  }

  static Brightness _resolveBrightness(
    ThemeMode mode,
    Brightness systemBrightness,
  ) {
    switch (mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return systemBrightness;
    }
  }
}

ColorScheme _buildColorScheme(
  Map<IxThemeColorToken, Color> palette,
  Brightness brightness,
) {
  Color pick(IxThemeColorToken token) => palette[token]!;

  return ColorScheme(
    brightness: brightness,
    primary: pick(IxThemeColorToken.primary),
    onPrimary: pick(IxThemeColorToken.primaryContrast),
    primaryContainer: pick(IxThemeColorToken.component8),
    onPrimaryContainer: pick(IxThemeColorToken.stdText),
    secondary: pick(IxThemeColorToken.dynamic),
    onSecondary: pick(IxThemeColorToken.primaryContrast),
    secondaryContainer: pick(IxThemeColorToken.component7),
    onSecondaryContainer: pick(IxThemeColorToken.primaryContrast),
    tertiary: pick(IxThemeColorToken.dynamicAlt),
    onTertiary: pick(IxThemeColorToken.contrastText),
    tertiaryContainer: pick(IxThemeColorToken.component9),
    onTertiaryContainer: pick(IxThemeColorToken.primaryContrast),
    error: pick(IxThemeColorToken.alarm),
    onError: pick(IxThemeColorToken.alarmContrast),
    errorContainer: pick(IxThemeColorToken.componentError),
    onErrorContainer: pick(IxThemeColorToken.alarmText),
    surface: pick(IxThemeColorToken.color2),
    onSurface: pick(IxThemeColorToken.stdText),
    surfaceDim: pick(IxThemeColorToken.color1Active),
    surfaceBright: pick(IxThemeColorToken.color2),
    surfaceContainerLowest: pick(IxThemeColorToken.color1),
    surfaceContainerLow: pick(IxThemeColorToken.color2),
    surfaceContainer: pick(IxThemeColorToken.color3),
    surfaceContainerHigh: pick(IxThemeColorToken.color4),
    surfaceContainerHighest: pick(IxThemeColorToken.color5),
    onSurfaceVariant: pick(IxThemeColorToken.softText),
    outline: pick(IxThemeColorToken.stdBdr),
    outlineVariant: pick(IxThemeColorToken.softBdr),
    shadow: pick(IxThemeColorToken.shadow2),
    scrim: pick(IxThemeColorToken.backdrop),
    inverseSurface: pick(IxThemeColorToken.color8),
    onInverseSurface: pick(IxThemeColorToken.invStdText),
    inversePrimary: pick(IxThemeColorToken.invContrastText),
    surfaceTint: pick(IxThemeColorToken.primary),
  );
}

TextTheme _buildTextTheme(
  IxTypography typography,
  Map<IxThemeColorToken, Color> palette,
) {
  final std = palette[IxThemeColorToken.stdText]!;
  final soft = palette[IxThemeColorToken.softText]!;
  final weak = palette[IxThemeColorToken.weakText]!;

  final base = typography.toTextTheme().apply(
    bodyColor: std,
    displayColor: std,
    decorationColor: std,
  );

  return base.copyWith(
    bodyLarge: base.bodyLarge?.copyWith(color: std),
    bodyMedium: base.bodyMedium?.copyWith(color: std),
    bodySmall: base.bodySmall?.copyWith(color: soft),
    labelLarge: base.labelLarge?.copyWith(color: std),
    labelMedium: base.labelMedium?.copyWith(color: soft),
    labelSmall: base.labelSmall?.copyWith(color: weak),
  );
}

/// Theme extension that surfaces Siemens IX tokens and typography helpers from
/// the widget tree.
class IxTheme extends ThemeExtension<IxTheme> {
  const IxTheme({
    required this.family,
    required this.mode,
    required this.brightness,
    required this.palette,
    required this.typography,
  });

  final IxThemeFamily family;
  final ThemeMode mode;
  final Brightness brightness;
  final Map<IxThemeColorToken, Color> palette;
  final IxTypography typography;

  /// Resolves a tokenized Siemens IX color.
  Color color(IxThemeColorToken token) => palette[token]!;

  /// Returns a typed Siemens IX text style tinted with the requested tone.
  TextStyle textStyle(
    IxTypographyVariant variant, {
    IxThemeTextTone tone = IxThemeTextTone.standard,
  }) {
    return typography
        .resolve(variant)
        .copyWith(color: color(_toneToToken(tone)));
  }

  /// Convenience accessor for common Siemens IX text colors.
  Color textColor(IxThemeTextTone tone) => color(_toneToToken(tone));

  @override
  IxTheme copyWith({
    IxThemeFamily? family,
    ThemeMode? mode,
    Brightness? brightness,
    Map<IxThemeColorToken, Color>? palette,
    IxTypography? typography,
  }) {
    return IxTheme(
      family: family ?? this.family,
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
      palette: palette ?? this.palette,
      typography: typography ?? this.typography,
    );
  }

  @override
  IxTheme lerp(ThemeExtension<IxTheme>? other, double t) {
    if (other is! IxTheme) {
      return this;
    }

    final blended = <IxThemeColorToken, Color>{};
    for (final token in IxThemeColorToken.values) {
      blended[token] =
          Color.lerp(palette[token], other.palette[token], t) ??
          palette[token]!;
    }

    return IxTheme(
      family: t < 0.5 ? family : other.family,
      mode: t < 0.5 ? mode : other.mode,
      brightness: t < 0.5 ? brightness : other.brightness,
      palette: Map.unmodifiable(blended),
      typography: t < 0.5 ? typography : other.typography,
    );
  }

  IxThemeColorToken _toneToToken(IxThemeTextTone tone) {
    switch (tone) {
      case IxThemeTextTone.standard:
        return IxThemeColorToken.stdText;
      case IxThemeTextTone.soft:
        return IxThemeColorToken.softText;
      case IxThemeTextTone.weak:
        return IxThemeColorToken.weakText;
      case IxThemeTextTone.contrast:
        return IxThemeColorToken.contrastText;
      case IxThemeTextTone.inverseStandard:
        return IxThemeColorToken.invStdText;
      case IxThemeTextTone.inverseSoft:
        return IxThemeColorToken.invSoftText;
      case IxThemeTextTone.inverseWeak:
        return IxThemeColorToken.invWeakText;
      case IxThemeTextTone.alarm:
        return IxThemeColorToken.alarmText;
    }
  }
}

/// Enumerates preset text tones backed by Siemens IX color tokens.
enum IxThemeTextTone {
  standard,
  soft,
  weak,
  contrast,
  inverseStandard,
  inverseSoft,
  inverseWeak,
  alarm,
}
