/// Legacy Siemens iX visual family selector.
///
/// Superseded by `IxThemeName` (upstream `data-ix-theme`) plus an explicit
/// brightness; `IxThemeBuilder(family:)` is deprecated accordingly.
@Deprecated('Use IxThemeName with an explicit brightness. Removed in 2.0.')
enum IxThemeFamily {
  /// The Siemens iX classic theme -- the only theme bundled with this
  /// package.
  classic,

  /// Siemens brand theme; resolves to [classic] in the open-source build.
  @Deprecated(
    'brand palette is not part of the OSS build; resolves to classic. '
    'Removed in 2.0.',
  )
  brand,

  /// A palette supplied through `IxThemeBuilder(customPalette:)`.
  custom,
}
