import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

/// Enumerates Siemens IX label interaction states.
enum IxLabelState { standard, active, hover, focus, disabled, invalid }

/// Theme extension surfacing Siemens IX label tokens and helpers.
class IxLabelTheme extends ThemeExtension<IxLabelTheme> {
  const IxLabelTheme({
    required this.textStyle,
    required this.color,
    required this.activeColor,
    required this.hoverColor,
    required this.focusColor,
    required this.disabledColor,
    required this.invalidColor,
    required this.stateColor,
  });

  factory IxLabelTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final baseColor = pick(IxThemeColorToken.softText);
    final active = pick(IxThemeColorToken.stdText);
    final disabled = pick(IxThemeColorToken.weakText);
    final focus = pick(IxThemeColorToken.dynamic);
    final hover = pick(IxThemeColorToken.stdText);
    final invalid = pick(IxThemeColorToken.alarmText);

    final style = typography.label.copyWith(
      fontWeight: FontWeight.w600,
      color: baseColor,
    );

    final resolver = WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return disabled;
      }
      if (states.contains(WidgetState.error)) {
        return invalid;
      }
      if (states.contains(WidgetState.focused)) {
        return focus;
      }
      if (states.contains(WidgetState.hovered)) {
        return hover;
      }
      if (states.contains(WidgetState.pressed)) {
        return active;
      }
      return baseColor;
    });

    return IxLabelTheme(
      textStyle: style,
      color: baseColor,
      activeColor: active,
      hoverColor: hover,
      focusColor: focus,
      disabledColor: disabled,
      invalidColor: invalid,
      stateColor: resolver,
    );
  }

  final TextStyle textStyle;
  final Color color;
  final Color activeColor;
  final Color hoverColor;
  final Color focusColor;
  final Color disabledColor;
  final Color invalidColor;
  final WidgetStateColor stateColor;

  /// Returns a Siemens IX label style tinted for the requested state.
  TextStyle style([IxLabelState state = IxLabelState.standard]) {
    return textStyle.copyWith(color: _colorFor(state));
  }

  /// Resolves a color given a set of [WidgetState]s.
  Color resolveColor(Set<WidgetState> states) => stateColor.resolve(states);

  Color _colorFor(IxLabelState state) {
    switch (state) {
      case IxLabelState.standard:
        return color;
      case IxLabelState.active:
        return activeColor;
      case IxLabelState.hover:
        return hoverColor;
      case IxLabelState.focus:
        return focusColor;
      case IxLabelState.disabled:
        return disabledColor;
      case IxLabelState.invalid:
        return invalidColor;
    }
  }

  @override
  IxLabelTheme copyWith({
    TextStyle? textStyle,
    Color? color,
    Color? activeColor,
    Color? hoverColor,
    Color? focusColor,
    Color? disabledColor,
    Color? invalidColor,
    WidgetStateColor? stateColor,
  }) {
    return IxLabelTheme(
      textStyle: textStyle ?? this.textStyle,
      color: color ?? this.color,
      activeColor: activeColor ?? this.activeColor,
      hoverColor: hoverColor ?? this.hoverColor,
      focusColor: focusColor ?? this.focusColor,
      disabledColor: disabledColor ?? this.disabledColor,
      invalidColor: invalidColor ?? this.invalidColor,
      stateColor: stateColor ?? this.stateColor,
    );
  }

  @override
  IxLabelTheme lerp(ThemeExtension<IxLabelTheme>? other, double t) {
    if (other is! IxLabelTheme) {
      return this;
    }

    return IxLabelTheme(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t) ?? textStyle,
      color: Color.lerp(color, other.color, t) ?? color,
      activeColor: Color.lerp(activeColor, other.activeColor, t) ?? activeColor,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t) ?? hoverColor,
      focusColor: Color.lerp(focusColor, other.focusColor, t) ?? focusColor,
      disabledColor:
          Color.lerp(disabledColor, other.disabledColor, t) ?? disabledColor,
      invalidColor:
          Color.lerp(invalidColor, other.invalidColor, t) ?? invalidColor,
      stateColor: t < 0.5 ? stateColor : other.stateColor,
    );
  }
}
