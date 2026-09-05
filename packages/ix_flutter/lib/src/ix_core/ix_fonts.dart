/// Exposes Siemens IX font family identifiers for Flutter widgets.
class IxFonts {
  IxFonts._();

  /// The package name to pass as `TextStyle.package` for the fonts this
  /// library bundles, so their family names resolve package-prefixed.
  static const String packageName = 'ix_flutter';

  /// Work Sans, the SIL Open Font License substitute for the proprietary
  /// Siemens Sans. Bundled as a static asset; pass
  /// `package: IxFonts.packageName` to `IxTypography`'s `package`
  /// parameter to resolve it via the package-prefixed family name. It is
  /// opt-in in 1.x and becomes the 2.0 default UI font.
  static const String workSans = 'Work Sans';

  /// Fallback chain for UI typefaces, used once a family such as
  /// [workSans] or the (separately licensed) Siemens Sans is in use.
  static const List<String> uiFontFamilyFallback = [
    'Siemens Sans',
    'Arial',
    'Helvetica',
    'sans-serif',
  ];

  @Deprecated(
    'Roboto Mono stops being the default UI font in 2.0; use '
    'IxFonts.workSans or IxTypography(fontFamily:). Removed in 2.0.',
  )
  static const String robotoMono = 'Roboto Mono';

  @Deprecated(
    'Roboto Mono stops being the default UI font in 2.0; use '
    'IxFonts.workSans or IxTypography(fontFamily:). Removed in 2.0.',
  )
  static const List<String> robotoMonoFallback = ['Arial', 'Helvetica'];

  static const String jetBrainsMono = 'JetBrains Mono';
  static const List<String> jetBrainsMonoFallback = [
    'Courier New',
    'monospace',
  ];
}
