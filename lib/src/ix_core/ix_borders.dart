import 'package:flutter/material.dart';

/// Collection of raw border colors required to reproduce the Siemens IX
/// border tokens for any theme + mode combination.
class IxBorderColors {
  const IxBorderColors({
    required this.std,
    required this.soft,
    required this.weak,
    required this.xWeak,
    required this.hard,
    required this.contrast,
    required this.focus,
    required this.primary,
    required this.dynamic,
    required this.alarm,
    required this.critical,
    required this.warning,
    required this.success,
    required this.info,
    required this.neutral,
  });

  /// Maps raw colors into an [IxBorderColors] instance.
  ///
  /// Provide colors from the generated theme classes (e.g.
  /// `IxClassicLightColors.stdBdr`) to keep the palette decoupled from any
  /// specific Ix theme version.
  factory IxBorderColors.fromMap(Map<IxBorderColorToken, Color> tokens) {
    Color _resolve(IxBorderColorToken token) {
      final value = tokens[token];
      if (value == null) {
        throw ArgumentError('Missing color for border token "$token"');
      }
      return value;
    }

    return IxBorderColors(
      std: _resolve(IxBorderColorToken.std),
      soft: _resolve(IxBorderColorToken.soft),
      weak: _resolve(IxBorderColorToken.weak),
      xWeak: _resolve(IxBorderColorToken.xWeak),
      hard: _resolve(IxBorderColorToken.hard),
      contrast: _resolve(IxBorderColorToken.contrast),
      focus: _resolve(IxBorderColorToken.focus),
      primary: _resolve(IxBorderColorToken.primary),
      dynamic: _resolve(IxBorderColorToken.dynamic),
      alarm: _resolve(IxBorderColorToken.alarm),
      critical: _resolve(IxBorderColorToken.critical),
      warning: _resolve(IxBorderColorToken.warning),
      success: _resolve(IxBorderColorToken.success),
      info: _resolve(IxBorderColorToken.info),
      neutral: _resolve(IxBorderColorToken.neutral),
    );
  }

  final Color std;
  final Color soft;
  final Color weak;
  final Color xWeak;
  final Color hard;
  final Color contrast;
  final Color focus;
  final Color primary;
  final Color dynamic;
  final Color alarm;
  final Color critical;
  final Color warning;
  final Color success;
  final Color info;
  final Color neutral;
}

/// Keeps width definitions aligned with the Siemens IX border tokens.
class IxBorderWidths {
  const IxBorderWidths({this.thin = 1.0, this.thick = 2.0});

  final double thin;
  final double thick;

  IxBorderWidths copyWith({double? thin, double? thick}) {
    return IxBorderWidths(thin: thin ?? this.thin, thick: thick ?? this.thick);
  }
}

/// Runtime representation of Siemens IX border tokens.
///
/// Provide [IxBorderColors] built from the current theme (classic/brand,
/// light/dark, etc.) to obtain Flutter [BorderSide] instances.
class IxBorders {
  const IxBorders({required this.colors, this.widths = const IxBorderWidths()});

  final IxBorderColors colors;
  final IxBorderWidths widths;

  BorderSide get std1 => _border(colors.std, widths.thin);
  BorderSide get std2 => _border(colors.std, widths.thick);

  BorderSide get soft => _border(colors.soft, widths.thin);
  BorderSide get weak => _border(colors.weak, widths.thin);
  BorderSide get xWeak => _border(colors.xWeak, widths.thin);
  BorderSide get hard => _border(colors.hard, widths.thin);

  BorderSide get contrast1 => _border(colors.contrast, widths.thin);
  BorderSide get contrast2 => _border(colors.contrast, widths.thick);

  BorderSide get focus => _border(colors.focus, widths.thin);

  BorderSide get primary1 => _border(colors.primary, widths.thin);
  BorderSide get primary2 => _border(colors.primary, widths.thick);

  BorderSide get dynamic1 => _border(colors.dynamic, widths.thin);
  BorderSide get dynamic2 => _border(colors.dynamic, widths.thick);

  BorderSide get alarm1 => _border(colors.alarm, widths.thin);
  BorderSide get alarm2 => _border(colors.alarm, widths.thick);

  BorderSide get critical1 => _border(colors.critical, widths.thin);
  BorderSide get critical2 => _border(colors.critical, widths.thick);

  BorderSide get warning1 => _border(colors.warning, widths.thin);
  BorderSide get warning2 => _border(colors.warning, widths.thick);

  BorderSide get success1 => _border(colors.success, widths.thin);
  BorderSide get success2 => _border(colors.success, widths.thick);

  BorderSide get info1 => _border(colors.info, widths.thin);
  BorderSide get info2 => _border(colors.info, widths.thick);

  BorderSide get neutral1 => _border(colors.neutral, widths.thin);
  BorderSide get neutral2 => _border(colors.neutral, widths.thick);

  IxBorders copyWith({IxBorderColors? colors, IxBorderWidths? widths}) {
    return IxBorders(
      colors: colors ?? this.colors,
      widths: widths ?? this.widths,
    );
  }

  BorderSide _border(Color color, double width) {
    return BorderSide(color: color, width: width);
  }
}

/// Tokens listed in the Siemens IX border guide.
enum IxBorderColorToken {
  std,
  soft,
  weak,
  xWeak,
  hard,
  contrast,
  focus,
  primary,
  dynamic,
  alarm,
  critical,
  warning,
  success,
  info,
  neutral,
}
