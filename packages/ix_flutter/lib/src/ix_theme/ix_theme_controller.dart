import 'dart:async';

import 'package:flutter/material.dart';

import '../ix_core/ix_typography.dart';
import 'ix_color_schema.dart';
import 'ix_custom_palette.dart';
import 'ix_theme_builder.dart';
import 'ix_theme_name.dart';

/// Payload of an [IxThemeController.themeChanged] event.
///
/// Mirrors the upstream `ThemeChangeEventDetail`
/// (`theme-switcher.ts:14-19`): the configured [theme] name and
/// [colorSchema], the resolved [mode], and whether the change came from the
/// platform (`isMediaChange`) rather than from an explicit call.
@immutable
class IxThemeChange {
  /// Creates a theme change event.
  const IxThemeChange({
    required this.theme,
    required this.colorSchema,
    required this.mode,
    required this.isMediaChange,
  });

  /// The configured theme identity.
  final IxThemeName theme;

  /// The configured color schema (may be [IxColorSchema.system]).
  final IxColorSchema colorSchema;

  /// The resolved brightness -- never ambiguous, even for
  /// [IxColorSchema.system].
  final Brightness mode;

  /// Whether the platform brightness triggered this change rather than an
  /// explicit [IxThemeController.setTheme]/[IxThemeController.setColorSchema]
  /// call.
  final bool isMediaChange;

  @override
  String toString() =>
      'IxThemeChange(theme: $theme, colorSchema: $colorSchema, '
      'mode: $mode, isMediaChange: $isMediaChange)';
}

/// Holds the configured Siemens iX theme and color schema and rebuilds the
/// matching light/dark [ThemeData].
///
/// This is the Flutter counterpart of the upstream `themeSwitcher` singleton:
/// theme identity ([theme]) and color schema ([colorSchema]) are configured
/// independently, [IxColorSchema.system] resolves against the platform
/// brightness, and every change is broadcast on [themeChanged] in addition to
/// the [ChangeNotifier] notification.
///
/// ```dart
/// class _AppState extends State<App> {
///   final _theme = IxThemeController();
///
///   @override
///   void dispose() {
///     _theme.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => AnimatedBuilder(
///         animation: _theme,
///         builder: (context, _) => MaterialApp(
///           theme: _theme.light,
///           darkTheme: _theme.dark,
///           themeMode: _theme.themeMode,
///           home: const Home(),
///         ),
///       );
/// }
/// ```
///
/// The controller registers a [WidgetsBindingObserver] so that
/// [IxColorSchema.system] follows the platform brightness on its own, which
/// means it must be constructed after the binding exists (inside
/// `State.initState`, or after `WidgetsFlutterBinding.ensureInitialized()`).
/// Apps that resolve the platform brightness themselves can drive the
/// controller with [updatePlatformBrightness] instead.
class IxThemeController extends ChangeNotifier {
  /// Creates a controller for [theme] and [colorSchema].
  ///
  /// [platformBrightness] seeds the value used to resolve
  /// [IxColorSchema.system]; it defaults to the binding's current platform
  /// brightness and is kept up to date from then on.
  IxThemeController({
    IxThemeName theme = IxThemeName.classic,
    IxColorSchema colorSchema = IxColorSchema.system,
    IxCustomPalette? customPalette,
    IxTypography? typography,
    Brightness? platformBrightness,
  }) : _theme = theme,
       _colorSchema = colorSchema,
       _customPalette = customPalette,
       _typography = typography,
       _platformBrightness =
           platformBrightness ??
           WidgetsBinding.instance.platformDispatcher.platformBrightness {
    WidgetsBinding.instance.addObserver(_observer);
    _rebuild();
  }

  IxThemeName _theme;
  IxColorSchema _colorSchema;
  final IxCustomPalette? _customPalette;
  final IxTypography? _typography;
  Brightness _platformBrightness;
  late ThemeData _light;
  late ThemeData _dark;
  final StreamController<IxThemeChange> _changes =
      StreamController<IxThemeChange>.broadcast();
  late final _PlatformBrightnessObserver _observer =
      _PlatformBrightnessObserver(_handlePlatformBrightnessChanged);

  /// The configured theme identity.
  IxThemeName get theme => _theme;

  /// The configured color schema, which may be [IxColorSchema.system].
  IxColorSchema get colorSchema => _colorSchema;

  /// The resolved brightness for [colorSchema] and the platform brightness.
  Brightness get mode => switch (_colorSchema) {
    IxColorSchema.light => Brightness.light,
    IxColorSchema.dark => Brightness.dark,
    IxColorSchema.system => _platformBrightness,
  };

  /// The [ThemeMode] to hand to `MaterialApp.themeMode`.
  ThemeMode get themeMode => switch (_colorSchema) {
    IxColorSchema.light => ThemeMode.light,
    IxColorSchema.dark => ThemeMode.dark,
    IxColorSchema.system => ThemeMode.system,
  };

  /// The light [ThemeData] for the configured theme.
  ThemeData get light => _light;

  /// The dark [ThemeData] for the configured theme.
  ThemeData get dark => _dark;

  /// Broadcasts every theme change, including platform-driven ones.
  Stream<IxThemeChange> get themeChanged => _changes.stream;

  /// Sets the theme identity and color schema, then emits a non-media
  /// [IxThemeChange] (upstream `themeSwitcher.setTheme`).
  void setTheme(IxThemeName theme, IxColorSchema colorSchema) {
    _theme = theme;
    _colorSchema = colorSchema;
    _rebuild();
    _emit(isMediaChange: false);
  }

  /// Sets the color schema, keeping the current [theme] (upstream
  /// `themeSwitcher.setColorSchema`).
  void setColorSchema(IxColorSchema schema) => setTheme(_theme, schema);

  /// Feeds a new platform brightness into the controller.
  ///
  /// Called automatically from the controller's own
  /// [WidgetsBindingObserver]; call it directly when the app resolves the
  /// platform brightness itself (or from a test). Emits a media
  /// [IxThemeChange] only while [colorSchema] is [IxColorSchema.system],
  /// because that is the only case in which [mode] can change.
  void updatePlatformBrightness(Brightness brightness) {
    if (brightness == _platformBrightness) {
      return;
    }
    _platformBrightness = brightness;
    if (_colorSchema == IxColorSchema.system) {
      _emit(isMediaChange: true);
    }
  }

  void _handlePlatformBrightnessChanged() => updatePlatformBrightness(
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );

  void _rebuild() {
    _light = IxThemeBuilder.light(
      theme: _theme,
      typography: _typography,
      customPalette: _customPalette,
    ).build();
    _dark = IxThemeBuilder.dark(
      theme: _theme,
      typography: _typography,
      customPalette: _customPalette,
    ).build();
  }

  void _emit({required bool isMediaChange}) {
    _changes.add(
      IxThemeChange(
        theme: _theme,
        colorSchema: _colorSchema,
        mode: mode,
        isMediaChange: isMediaChange,
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    _changes.close();
    super.dispose();
  }
}

/// Forwards the binding's platform brightness changes to the controller.
///
/// A dedicated observer keeps [IxThemeController]'s public surface free of
/// the ~20 no-op [WidgetsBindingObserver] members, and -- unlike overwriting
/// `PlatformDispatcher.onPlatformBrightnessChanged` -- leaves the framework's
/// own handler (which keeps `MediaQuery.platformBrightness` current) and any
/// other observer in place.
class _PlatformBrightnessObserver with WidgetsBindingObserver {
  _PlatformBrightnessObserver(this._onChanged);

  final VoidCallback _onChanged;

  @override
  void didChangePlatformBrightness() => _onChanged();
}
