import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_colors.dart';
import 'package:ix_flutter/src/ix_core/ix_color_palette.dart';
import 'package:ix_flutter/src/ix_core/ix_density.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_app_header_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_app_menu_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_badge_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_button_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_card_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_bottom_sheet_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_checkbox_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_chip_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_breadcrumb_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_dropdown_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_form_field_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_label_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_modal_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_radio_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_scrollbar_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_sidebar_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_slider_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_spinner_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_toggle_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_tabs_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_upload_theme.dart';
import 'package:ix_flutter/src/ix_theme/ix_color_schema.dart';
import 'package:ix_flutter/src/ix_theme/ix_custom_palette.dart';
import 'package:ix_flutter/src/ix_theme/ix_theme_name.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_resolver.dart';

/// Builds `ThemeData` instances that comply with the Siemens IX color and type
/// scale guidance.
///
/// The builder only wires up global colors (color scheme, surfaces, text,
/// etc.). Component-specific theming will be layered on top later. Most apps
/// place the builder inside `main()` so the resulting theme can be passed to a
/// `MaterialApp` (or `WidgetsApp`).
///
/// ```dart
/// void main() {
///   final lightTheme = const IxThemeBuilder.light().build();
///   final darkTheme = const IxThemeBuilder.dark().build();
///
///   runApp(
///     MaterialApp(
///       theme: lightTheme,
///       darkTheme: darkTheme,
///       home: const MyDashboard(),
///     ),
///   );
/// }
/// ```
///
/// Use `IxThemeController` instead when the app has to resolve
/// [IxColorSchema.system] at runtime.
class IxThemeBuilder {
  /// Creates a builder for a single [ThemeData] variant.
  ///
  /// Set [theme] and [brightness] (or use [IxThemeBuilder.light] /
  /// [IxThemeBuilder.dark]); [family], [mode] and [systemBrightness] are the
  /// deprecated 1.x spelling of the same configuration and stay functional
  /// until 2.0.
  const IxThemeBuilder({
    @Deprecated('Use theme: IxThemeName; brand is a classic alias')
    this.family = IxThemeFamily.classic,
    @Deprecated('Use brightness: or IxThemeController')
    this.mode = ThemeMode.system,
    @Deprecated('Use IxThemeController for system resolution')
    this.systemBrightness = Brightness.light,
    this.theme,
    this.brightness,
    this.typography,
    this.customPalette,
    this.icons,
    this.density = IxDensity.adaptive,
  });

  /// Creates a builder for the light variant of [theme].
  const IxThemeBuilder.light({
    IxThemeName theme = IxThemeName.classic,
    IxTypography? typography,
    IxCustomPalette? customPalette,
    IxIconResolver? icons,
    IxDensity density = IxDensity.adaptive,
  }) : this(
         theme: theme,
         brightness: Brightness.light,
         typography: typography,
         customPalette: customPalette,
         icons: icons,
         density: density,
       );

  /// Creates a builder for the dark variant of [theme].
  const IxThemeBuilder.dark({
    IxThemeName theme = IxThemeName.classic,
    IxTypography? typography,
    IxCustomPalette? customPalette,
    IxIconResolver? icons,
    IxDensity density = IxDensity.adaptive,
  }) : this(
         theme: theme,
         brightness: Brightness.dark,
         typography: typography,
         customPalette: customPalette,
         icons: icons,
         density: density,
       );

  /// Siemens IX visual family (classic vs. custom overrides).
  @Deprecated('Use theme: IxThemeName; brand is a classic alias')
  final IxThemeFamily family;

  /// Material theme mode to resolve light/dark variants.
  @Deprecated('Use brightness: or IxThemeController')
  final ThemeMode mode;

  /// Platform brightness hint used when [mode] is [ThemeMode.system].
  @Deprecated('Use IxThemeController for system resolution')
  final Brightness systemBrightness;

  /// Siemens iX theme identity (upstream `data-ix-theme`).
  ///
  /// Defaults to [IxThemeName.classic]; the deprecated [family] fills it in
  /// when it is unset.
  final IxThemeName? theme;

  /// Brightness of the built [ThemeData].
  ///
  /// Takes precedence over the deprecated [mode]/[systemBrightness] pair.
  final Brightness? brightness;

  /// Optional override for the Siemens IX type scale.
  final IxTypography? typography;

  /// Optional custom palette that replaces the built-in family colors.
  final IxCustomPalette? customPalette;

  /// Optional icon resolver registered as the [IxIconResolver] theme
  /// extension. Defaults to [IxIconResolver.material] when unset.
  final IxIconResolver? icons;

  /// The adaptive density policy for interactive control hit areas.
  ///
  /// Defaults to [IxDensity.adaptive]. [build] always bakes a static
  /// [IxDensity.comfortable] tap-target sizing into the returned
  /// [ThemeData] when this is [IxDensity.adaptive] (a touch-safe default
  /// with no [BuildContext] to resolve modality from); wrap the app in an
  /// [IxDensityScope] to resolve [IxDensity.adaptive] live instead.
  final IxDensity density;

  /// Returns [ThemeData] configured with Siemens IX global colors and fonts.
  ///
  /// The resulting theme exports both Material defaults (color scheme,
  /// typographic scale, component theme data) and custom Siemens IX extensions
  /// such as [IxTheme], [IxButtonTheme], and component-specific tokens.
  ThemeData build() {
    assert(
      // ignore: deprecated_member_use_from_same_package
      family != IxThemeFamily.custom || customPalette != null,
      'IxThemeFamily.custom requires customPalette',
    );
    final resolvedBrightness =
        brightness ??
        // ignore: deprecated_member_use_from_same_package
        _resolveBrightness(mode, systemBrightness);
    final resolvedTheme =
        theme ??
        // ignore: deprecated_member_use_from_same_package
        (family == IxThemeFamily.classic
            ? IxThemeName.classic
            // ignore: deprecated_member_use_from_same_package
            : IxThemeName(family.name));
    // Every bundled family resolves to the classic palette (`brand` is a
    // deprecated alias, `custom` is served by `customPalette`), so the
    // palette only depends on the resolved brightness.
    final Map<IxThemeColorToken, Color> palette = Map.unmodifiable(
      customPalette?.resolve(resolvedBrightness) ??
          IxColorPalette.resolve(
            family: IxThemeFamily.classic,
            mode: resolvedBrightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
          ),
    );

    final typeScale = typography ?? IxTypography();
    final colorScheme = _buildColorScheme(palette, resolvedBrightness);
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
    final bottomSheetTheme = IxBottomSheetTheme.fromPalette(
      palette: palette,
      cardTheme: cardTheme,
    );
    final checkboxTheme = IxCheckboxTheme.fromPalette(palette: palette);
    final radioTheme = IxRadioTheme.fromPalette(palette: palette);
    final sliderTheme = IxSliderTheme.fromPalette(palette: palette);
    final spinnerTheme = IxSpinnerTheme.fromPalette(palette: palette);
    final toggleTheme = IxToggleTheme.fromPalette(palette: palette);
    final modalTheme = IxModalTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final uploadTheme = IxUploadTheme.fromPalette(palette: palette);
    final labelTheme = IxLabelTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final tabsTheme = IxTabsTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final breadcrumbTheme = IxBreadcrumbTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final dropdownTheme = IxDropdownTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final formFieldTheme = IxFormFieldTheme.fromPalette(
      palette: palette,
      typography: typeScale,
      labelTheme: labelTheme,
    );
    final badgeTheme = IxBadgeTheme.fromPalette(
      palette: palette,
      typography: typeScale,
    );
    final scrollbarTheme = IxScrollbarTheme.fromPalette(palette: palette);
    final ixThemeExtension = IxTheme(
      themeName: resolvedTheme,
      colorSchema: resolvedBrightness == Brightness.dark
          ? IxColorSchema.dark
          : IxColorSchema.light,
      // ignore: deprecated_member_use_from_same_package
      family: family,
      // ignore: deprecated_member_use_from_same_package
      mode: mode,
      brightness: resolvedBrightness,
      palette: palette,
      typography: typeScale,
      density: density,
    );
    final iconResolver = icons ?? IxIconResolver.material();

    // NOTE: named `themeData`, not `theme` -- `theme` is a field of this
    // class and a local of that name would shadow it for the whole method
    // body (including the `resolvedTheme` line above).
    final themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: resolvedBrightness,
      scaffoldBackgroundColor: palette[IxThemeColorToken.color1],
      canvasColor: palette[IxThemeColorToken.color1],
      dialogTheme: DialogThemeData(
        backgroundColor: modalTheme.backgroundColor,
        elevation: modalTheme.elevation,
        shadowColor: palette[IxThemeColorToken.shadow2],
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(modalTheme.borderRadius),
          side: BorderSide(
            color: modalTheme.borderColor,
            width: modalTheme.borderWidth,
          ),
        ),
        alignment: modalTheme.alignment,
        iconColor: modalTheme.iconColor,
        titleTextStyle: modalTheme.titleTextStyle,
        contentTextStyle: modalTheme.contentTextStyle,
        barrierColor: modalTheme.barrierColor,
        insetPadding: modalTheme.insetPadding,
        constraints: modalTheme.constraints,
      ),
      cardColor: palette[IxThemeColorToken.color3],
      dividerColor: palette[IxThemeColorToken.softBdr],
      // Material's built-in focus overlay is an opaque tint; the visible
      // focus affordance is the 1px `focusBdr` outline painted by
      // IxFocusRing and the state-based borders on checkbox/radio/button
      // instead (WCAG 2.4.7), so this stays transparent.
      focusColor: Colors.transparent,
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
      sliderTheme: sliderTheme.materialSliderTheme,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: spinnerTheme.style(IxSpinnerVariant.secondary).indicatorColor,
        circularTrackColor: spinnerTheme
            .style(IxSpinnerVariant.secondary)
            .trackColor,
      ),
      switchTheme: toggleTheme.materialSwitchTheme,
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
      bottomSheetTheme: bottomSheetTheme.materialBottomSheetTheme,
      badgeTheme: badgeTheme.materialBadgeTheme,
      textTheme: textTheme,
      fontFamily: typeScale.fontFamily,
      visualDensity: VisualDensity.standard,
      applyElevationOverlayColor: resolvedBrightness == Brightness.dark,
      scrollbarTheme: scrollbarTheme.materialScrollbarTheme,
      extensions: [
        ixThemeExtension,
        iconResolver,
        buttonTheme,
        appHeaderTheme,
        appMenuTheme,
        sidebarTheme,
        chipTheme,
        cardTheme,
        bottomSheetTheme,
        tabsTheme,
        formFieldTheme,
        checkboxTheme,
        radioTheme,
        sliderTheme,
        spinnerTheme,
        toggleTheme,
        uploadTheme,
        modalTheme,
        labelTheme,
        badgeTheme,
        scrollbarTheme,
        breadcrumbTheme,
        dropdownTheme,
      ],
    );

    // No BuildContext is available here, so `adaptive` cannot be resolved
    // to a real input modality yet: bake in `comfortable` (touch-safe) as
    // the static Material component tap-target sizing. `IxDensityScope`
    // re-adapts this live once a BuildContext exists.
    final adapted = IxDensityAdapter.apply(
      themeData,
      density == IxDensity.adaptive ? IxDensity.comfortable : density,
    );
    if (density != IxDensity.adaptive) {
      return adapted;
    }
    // IxDensityAdapter.apply() stamps the density it was given onto
    // IxTheme.density, which would otherwise leave `comfortable` (the
    // static default above) baked into the theme. Restore the original,
    // still-adaptive extension so IxDensity.effectiveOf can resolve it
    // live from a BuildContext when no IxDensityScope is present.
    return adapted.copyWith(
      extensions: [
        ...adapted.extensions.values.where((e) => e is! IxTheme),
        ixThemeExtension,
      ],
    );
  }

  /// Copies the builder with selective overrides.
  ///
  /// Useful when you want to flip between light/dark or supply a custom
  /// [IxTypography] while reusing the remaining configuration.
  IxThemeBuilder copyWith({
    @Deprecated('Use theme: IxThemeName; brand is a classic alias')
    IxThemeFamily? family,
    @Deprecated('Use brightness: or IxThemeController') ThemeMode? mode,
    @Deprecated('Use IxThemeController for system resolution')
    Brightness? systemBrightness,
    IxThemeName? theme,
    Brightness? brightness,
    IxTypography? typography,
    IxCustomPalette? customPalette,
    IxIconResolver? icons,
    IxDensity? density,
  }) {
    return IxThemeBuilder(
      // ignore: deprecated_member_use_from_same_package
      family: family ?? this.family,
      // ignore: deprecated_member_use_from_same_package
      mode: mode ?? this.mode,
      // ignore: deprecated_member_use_from_same_package
      systemBrightness: systemBrightness ?? this.systemBrightness,
      theme: theme ?? this.theme,
      brightness: brightness ?? this.brightness,
      typography: typography ?? this.typography,
      customPalette: customPalette ?? this.customPalette,
      icons: icons ?? this.icons,
      density: density ?? this.density,
    );
  }

  /// Resolves the effective [Brightness] that should drive palette selection.
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

/// Builds a Material [ColorScheme] from the resolved Siemens IX palette.
ColorScheme _buildColorScheme(
  Map<IxThemeColorToken, Color> palette,
  Brightness brightness,
) {
  Color pick(IxThemeColorToken token) => palette[token]!;

  /// Translates the Siemens IX palette into Flutter's [ColorScheme] so
  /// downstream Material widgets can share the same ink and surface values.
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

/// Generates a Material [TextTheme] using the Siemens IX typography scale and
/// palette tones.
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
  /// Creates the Siemens iX theme extension.
  ///
  /// [colorSchema] defaults to the schema matching [brightness]; the
  /// deprecated [family]/[mode] pair stays required so that 1.x call sites
  /// keep compiling.
  const IxTheme({
    this.themeName = IxThemeName.classic,
    IxColorSchema? colorSchema,
    required this.family,
    required this.mode,
    required this.brightness,
    required this.palette,
    required this.typography,
    this.density = IxDensity.adaptive,
  }) : colorSchema =
           colorSchema ??
           (brightness == Brightness.dark
               ? IxColorSchema.dark
               : IxColorSchema.light);

  /// Resolves the [IxTheme] registered on the closest [Theme], or `null` if
  /// the [ThemeData] wasn't built by [IxThemeBuilder].
  static IxTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<IxTheme>();

  /// Resolves the [IxTheme] registered on the closest [Theme].
  ///
  /// Throws a [FlutterError] with guidance if the context's [Theme] was not
  /// built by [IxThemeBuilder]; wrap the app with
  /// `MaterialApp(theme: IxThemeBuilder(...).build())`.
  static IxTheme of(BuildContext context) {
    final theme = maybeOf(context);
    if (theme == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'IxTheme.of() called with a context that does not contain an '
          'IxThemeBuilder theme.',
        ),
        ErrorDescription(
          'Build your ThemeData with IxThemeBuilder(...).build() and pass '
          'it to MaterialApp(theme: ...).',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return theme;
  }

  /// The Siemens iX theme identity this [ThemeData] was built for (upstream
  /// `data-ix-theme`).
  final IxThemeName themeName;

  /// The color schema this [ThemeData] was built for.
  ///
  /// Always [IxColorSchema.light] or [IxColorSchema.dark] -- a built theme
  /// has a resolved appearance. [IxColorSchema.system] only exists as the
  /// *configured* schema on `IxThemeController`.
  final IxColorSchema colorSchema;

  /// The visual family this theme was built for.
  @Deprecated('Use themeName')
  final IxThemeFamily family;

  /// The [ThemeMode] this theme was built for.
  @Deprecated('Use colorSchema / brightness')
  final ThemeMode mode;

  /// The resolved brightness of this theme.
  final Brightness brightness;

  /// The resolved Siemens iX color palette, keyed by token.
  final Map<IxThemeColorToken, Color> palette;

  /// The Siemens iX type scale in effect for this theme.
  final IxTypography typography;

  /// The adaptive density policy in effect for this theme.
  ///
  /// Set from `IxThemeBuilder(density:)`. Read via [IxDensity.effectiveOf]
  /// rather than directly: an ambient [IxDensityScope] always takes
  /// precedence over this value.
  final IxDensity density;

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
    IxThemeName? themeName,
    IxColorSchema? colorSchema,
    @Deprecated('Use themeName') IxThemeFamily? family,
    @Deprecated('Use colorSchema / brightness') ThemeMode? mode,
    Brightness? brightness,
    Map<IxThemeColorToken, Color>? palette,
    IxTypography? typography,
    IxDensity? density,
  }) {
    return IxTheme(
      themeName: themeName ?? this.themeName,
      colorSchema: colorSchema ?? this.colorSchema,
      // ignore: deprecated_member_use_from_same_package
      family: family ?? this.family,
      // ignore: deprecated_member_use_from_same_package
      mode: mode ?? this.mode,
      brightness: brightness ?? this.brightness,
      palette: palette ?? this.palette,
      typography: typography ?? this.typography,
      density: density ?? this.density,
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
      themeName: t < 0.5 ? themeName : other.themeName,
      colorSchema: t < 0.5 ? colorSchema : other.colorSchema,
      // ignore: deprecated_member_use_from_same_package
      family: t < 0.5 ? family : other.family,
      // ignore: deprecated_member_use_from_same_package
      mode: t < 0.5 ? mode : other.mode,
      brightness: t < 0.5 ? brightness : other.brightness,
      palette: Map.unmodifiable(blended),
      typography: t < 0.5 ? typography : other.typography,
      density: t < 0.5 ? density : other.density,
    );
  }

  /// Maps a semantic [IxThemeTextTone] to its backing palette token.
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
