import 'package:flutter/foundation.dart';

/// Identity of a Siemens iX theme, the Flutter counterpart of the upstream
/// `data-ix-theme` attribute (`themeSwitcher.setTheme(themeName)`).
///
/// The theme name is deliberately an open value type rather than an enum:
/// upstream reads an arbitrary string from the document and Siemens ships
/// additional themes outside the open-source distribution. [classic] is the
/// only theme bundled with `ix_flutter`; any other name resolves to the
/// classic palette unless an `IxCustomPalette` supplies its colors.
///
/// ```dart
/// final theme = const IxThemeBuilder.light(theme: IxThemeName.classic).build();
/// ```
@immutable
final class IxThemeName {
  /// Creates a theme identity from its upstream `data-ix-theme` [value].
  const IxThemeName(this.value);

  /// The raw theme name, e.g. `classic`.
  final String value;

  /// The Siemens iX classic theme -- the only theme bundled with this
  /// package.
  static const IxThemeName classic = IxThemeName('classic');

  @override
  bool operator ==(Object other) =>
      other is IxThemeName && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'IxThemeName($value)';
}
