# Theming

Siemens iX describes a theme with two independent values, and `ix_flutter`
mirrors them one to one:

| iX concept | DOM attribute | `ix_flutter` |
|---|---|---|
| Theme identity | `data-ix-theme` | `IxThemeName` (`IxThemeName.classic`) |
| Color schema | `data-ix-color-schema` | `IxColorSchema` (`light`, `dark`, `system`) |

`classic` is the only theme bundled with this package. Any other name keeps
the classic palette unless you supply your own colors through
`IxCustomPalette`.

## Building a theme

`IxThemeBuilder` builds one `ThemeData` for one resolved brightness:

```dart
final light = const IxThemeBuilder.light().build();
final dark = const IxThemeBuilder.dark().build();
```

Both named constructors accept `theme:`, `typography:`, `customPalette:`,
`icons:` and `density:`. The generic constructor takes an explicit
`brightness:` instead:

```dart
final theme = IxThemeBuilder(
  theme: IxThemeName.classic,
  brightness: Brightness.dark,
  typography: IxTypography(fontFamily: IxFonts.workSans, package: IxFonts.packageName),
).build();
```

Every built theme carries an `IxTheme` extension; read it with
`IxTheme.of(context)`. It reports the configuration it was built from
(`themeName`, `colorSchema`, `brightness`), the resolved `palette` and the
`typography`. `colorSchema` on a built theme is always `light` or `dark` --
a `ThemeData` has a resolved appearance; `IxColorSchema.system` only exists
as the *configured* schema on `IxThemeController`.

## Switching themes at runtime

`IxThemeController` is the Flutter counterpart of the upstream
`themeSwitcher` singleton. It holds the configuration, keeps a light and a
dark `ThemeData` ready, resolves `IxColorSchema.system` against the platform
brightness, and notifies both as a `ChangeNotifier` and on the
`themeChanged` stream:

```dart
class _AppState extends State<App> {
  final _theme = IxThemeController(); // defaults to classic + system

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _theme,
        builder: (context, _) => MaterialApp(
          theme: _theme.light,
          darkTheme: _theme.dark,
          themeMode: _theme.themeMode,
          home: const Home(),
        ),
      );
}
```

| Member | Purpose |
|---|---|
| `theme` / `colorSchema` | The configuration, as set |
| `mode` | The resolved `Brightness` (never ambiguous, even for `system`) |
| `themeMode` | The `ThemeMode` for `MaterialApp.themeMode` |
| `light` / `dark` | The two `ThemeData` variants for `theme` |
| `setTheme(name, schema)` / `setColorSchema(schema)` | Change the configuration (setting the current values is a no-op) |
| `updatePlatformBrightness(brightness)` | Feed in a new platform brightness |
| `themeChanged` | `Stream<IxThemeChange>` of every change |

The constructor also takes `customPalette:`, `typography:`, `icons:` and
`density:` and hands them to every `IxThemeBuilder` it runs, so a controller
can do everything the builder can.

`IxThemeChange` carries the same payload as the upstream
`themeChanged` event: `theme`, `colorSchema`, `mode` and `isMediaChange`.
`isMediaChange` is `true` only when the platform (not the app) triggered the
change, i.e. while the schema is `system` and the device switched between
light and dark.

Always `dispose()` the controller: it closes the `themeChanged` stream and
removes its binding observer.

### Platform brightness

The controller registers its own `WidgetsBindingObserver`, so
`IxColorSchema.system` follows the device without any extra wiring, several
controllers can coexist, and the framework's own handling (for example
`MediaQuery.platformBrightnessOf`) is untouched. Two consequences:

- Construct the controller after the binding exists -- inside
  `State.initState`, or after `WidgetsFlutterBinding.ensureInitialized()`.
- If your app resolves the platform brightness itself (a custom observer, a
  test, or a stored user preference that shadows the device), pass
  `platformBrightness:` to the constructor and call
  `updatePlatformBrightness(...)` on every change.

## Custom palettes

`IxCustomPalette.partial` overrides a handful of tokens and fills the rest
in from the classic palette:

```dart
final palette = IxCustomPalette.partial(
  light: {IxThemeColorToken.primary: const Color(0xFF0050F5)},
  dark: {IxThemeColorToken.primary: const Color(0xFF82A0FF)},
);

final controller = IxThemeController(customPalette: palette);
```

`copyWith` merges further overrides on top of an existing palette, token by
token. `IxCustomPalette.new` still requires a complete map of all
`IxThemeColorToken` values, and `IxCustomPalette.override` remains available
for patching a specific base family.

## Migration from the 1.x `family`/`mode` API

The old API keeps working until 2.0 and only produces deprecation warnings,
with one exception: `IxThemeBuilder(family: IxThemeFamily.custom)` *without* a
`customPalette` now trips an assertion in debug builds (it used to fall back
to the classic palette silently). Either pass the palette the family promises,
or drop the family -- `customPalette:` alone is enough. Building with
`IxThemeFamily.brand` also logs a one-time debug notice, since it has always
resolved to the classic palette.

| Deprecated (1.x) | Replacement |
|---|---|
| `IxThemeBuilder(mode: ThemeMode.light)` | `IxThemeBuilder.light()` (or `brightness: Brightness.light`) |
| `IxThemeBuilder(mode: ThemeMode.dark)` | `IxThemeBuilder.dark()` (or `brightness: Brightness.dark`) |
| `IxThemeBuilder(mode: ThemeMode.system, systemBrightness: ...)` | `IxThemeController(colorSchema: IxColorSchema.system)` |
| `IxThemeBuilder(family: IxThemeFamily.classic)` | `theme: IxThemeName.classic` |
| `IxThemeBuilder(family: IxThemeFamily.brand)` | `theme: IxThemeName.classic` (brand resolved to classic already) |
| `IxThemeBuilder(family: IxThemeFamily.custom, customPalette: p)` | `customPalette: p` (the family is implied) |
| `IxTheme.family` | `IxTheme.themeName` |
| `IxTheme.mode` | `IxTheme.colorSchema` / `IxTheme.brightness` |

`IxThemeFamily.brand` was never a real palette in the open-source build (it
always resolved to classic); it is deprecated in 1.x and removed in 2.0.
