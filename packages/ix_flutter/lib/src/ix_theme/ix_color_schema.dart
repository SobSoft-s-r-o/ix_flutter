/// Configured color schema of a Siemens iX theme, the Flutter counterpart of
/// the upstream `data-ix-color-schema` attribute.
///
/// This is the *configuration*, not the resolved appearance: [system] defers
/// to the platform brightness, which `IxThemeController.mode` resolves at
/// runtime. A `ThemeData` built by `IxThemeBuilder` always carries a resolved
/// [light] or [dark] schema on its `IxTheme` extension.
enum IxColorSchema {
  /// Always use the light palette.
  light,

  /// Always use the dark palette.
  dark,

  /// Follow the platform brightness (`prefers-color-scheme` upstream).
  system,
}
