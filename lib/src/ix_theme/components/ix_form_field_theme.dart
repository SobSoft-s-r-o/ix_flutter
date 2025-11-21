import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';

const _defaultCssFontSizePx = 16.0;
const _smallBorderRadiusRem = 0.125;
const _inputVerticalPaddingRem = 0.75;
const _inputHorizontalPaddingRem = 1.0;
const _iconSlotRem = 2.5;

const double _borderRadiusPx = _defaultCssFontSizePx * _smallBorderRadiusRem;
const double _verticalPaddingPx =
    _defaultCssFontSizePx * _inputVerticalPaddingRem;
const double _horizontalPaddingPx =
    _defaultCssFontSizePx * _inputHorizontalPaddingRem;
const double _inputMinHeight = 40.0;
const double _iconSlotPx = _defaultCssFontSizePx * _iconSlotRem;

const BoxConstraints _iconConstraints = BoxConstraints.tightFor(
  width: _iconSlotPx,
  height: _iconSlotPx,
);

WidgetStateColor _stateColor({
  required Color base,
  Color? hover,
  Color? focus,
  Color? disabled,
  Color? error,
}) {
  return WidgetStateColor.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) {
      return disabled ?? base;
    }
    if (states.contains(WidgetState.error)) {
      return error ?? base;
    }
    if (states.contains(WidgetState.focused)) {
      return focus ?? hover ?? base;
    }
    if (states.contains(WidgetState.hovered)) {
      return hover ?? base;
    }
    return base;
  });
}

OutlineInputBorder _outline({
  required BorderRadius borderRadius,
  required Color color,
  double width = 1,
}) {
  return OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Semantic color bundle for decorated form fields.
class IxFormFieldSemanticColors {
  const IxFormFieldSemanticColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color icon;

  IxFormFieldSemanticColors copyWith({
    Color? background,
    Color? border,
    Color? foreground,
    Color? icon,
  }) {
    return IxFormFieldSemanticColors(
      background: background ?? this.background,
      border: border ?? this.border,
      foreground: foreground ?? this.foreground,
      icon: icon ?? this.icon,
    );
  }

  static IxFormFieldSemanticColors lerp(
    IxFormFieldSemanticColors a,
    IxFormFieldSemanticColors b,
    double t,
  ) {
    return IxFormFieldSemanticColors(
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      border: Color.lerp(a.border, b.border, t) ?? a.border,
      foreground: Color.lerp(a.foreground, b.foreground, t) ?? a.foreground,
      icon: Color.lerp(a.icon, b.icon, t) ?? a.icon,
    );
  }
}

/// Theme extension exposing Siemens IX input/dropdown tokens.
class IxFormFieldTheme extends ThemeExtension<IxFormFieldTheme> {
  const IxFormFieldTheme({
    required this.inputDecorationTheme,
    required this.dropdownMenuTheme,
    required this.datePickerTheme,
    required this.info,
    required this.warning,
    required this.error,
    required this.shape,
  });

  factory IxFormFieldTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    IxFormFieldSemanticColors semantic({
      required IxThemeColorToken background,
      required IxThemeColorToken border,
      required IxThemeColorToken foreground,
      required IxThemeColorToken icon,
    }) {
      return IxFormFieldSemanticColors(
        background: pick(background),
        border: pick(border),
        foreground: pick(foreground),
        icon: pick(icon),
      );
    }

    final borderRadius = BorderRadius.circular(_borderRadiusPx);
    final fieldShape = RoundedRectangleBorder(borderRadius: borderRadius);

    final fillBase = pick(IxThemeColorToken.component8);
    final fillHover = pick(IxThemeColorToken.component8Hover);
    final fillFocus = fillHover;
    final fillDisabled = pick(IxThemeColorToken.color0);

    final iconColor = _stateColor(
      base: pick(IxThemeColorToken.softText),
      hover: pick(IxThemeColorToken.dynamic),
      focus: pick(IxThemeColorToken.dynamicActive),
      disabled: pick(IxThemeColorToken.weakText),
      error: pick(IxThemeColorToken.alarmText),
    );

    final labelStyle = typography.label.copyWith(
      fontWeight: FontWeight.w600,
      color: pick(IxThemeColorToken.stdText),
    );
    final floatingLabelStyle = labelStyle.copyWith(
      color: pick(IxThemeColorToken.dynamic),
    );
    final hintStyle = typography.body.copyWith(
      color: pick(IxThemeColorToken.softText),
    );
    final helperStyle = typography.bodySm.copyWith(
      color: pick(IxThemeColorToken.softText),
    );
    final errorStyle = typography.bodySm.copyWith(
      color: pick(IxThemeColorToken.alarmText),
    );

    final inputTheme = InputDecorationTheme(
      filled: true,
      fillColor: _stateColor(
        base: fillBase,
        hover: fillHover,
        focus: fillFocus,
        disabled: fillDisabled,
        error: pick(IxThemeColorToken.componentError),
      ),
      focusColor: fillFocus,
      hoverColor: fillHover,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _horizontalPaddingPx,
        vertical: _verticalPaddingPx,
      ),
      constraints: const BoxConstraints(minHeight: _inputMinHeight),
      labelStyle: labelStyle,
      floatingLabelStyle: floatingLabelStyle,
      hintStyle: hintStyle,
      helperStyle: helperStyle,
      errorStyle: errorStyle,
      counterStyle: helperStyle,
      prefixStyle: typography.body.copyWith(
        color: pick(IxThemeColorToken.stdText),
      ),
      suffixStyle: typography.body.copyWith(
        color: pick(IxThemeColorToken.softText),
      ),
      iconColor: iconColor,
      prefixIconColor: iconColor,
      suffixIconColor: iconColor,
      prefixIconConstraints: _iconConstraints,
      suffixIconConstraints: _iconConstraints,
      border: _outline(
        borderRadius: borderRadius,
        color: pick(IxThemeColorToken.stdBdr),
      ),
      enabledBorder: _outline(
        borderRadius: borderRadius,
        color: pick(IxThemeColorToken.stdBdr),
      ),
      focusedBorder: _outline(
        borderRadius: borderRadius,
        color: pick(IxThemeColorToken.dynamic),
        width: 2,
      ),
      disabledBorder: _outline(
        borderRadius: borderRadius,
        color: pick(IxThemeColorToken.weakBdr),
      ),
      errorBorder: _outline(
        borderRadius: borderRadius,
        color: pick(IxThemeColorToken.alarmBdr),
      ),
      focusedErrorBorder: _outline(
        borderRadius: borderRadius,
        color: pick(IxThemeColorToken.alarmBdr),
        width: 2,
      ),
    );

    final dropdownMenuTheme = DropdownMenuThemeData(
      textStyle: typography.body.copyWith(
        color: pick(IxThemeColorToken.stdText),
      ),
      inputDecorationTheme: inputTheme,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(pick(IxThemeColorToken.color2)),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: WidgetStatePropertyAll(pick(IxThemeColorToken.shadow1)),
        elevation: const WidgetStatePropertyAll(4),
        side: WidgetStatePropertyAll(
          BorderSide(color: pick(IxThemeColorToken.softBdr)),
        ),
        shape: WidgetStatePropertyAll(fieldShape),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8),
        ),
        alignment: AlignmentDirectional.bottomStart,
      ),
    );

    final dayBackgroundColor = WidgetStateProperty.resolveWith<Color?>((
      states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return pick(IxThemeColorToken.dynamic);
      }
      if (states.contains(WidgetState.hovered)) {
        return pick(IxThemeColorToken.component8Hover);
      }
      return pick(IxThemeColorToken.color0);
    });

    final dayForegroundColor = WidgetStateProperty.resolveWith<Color?>((
      states,
    ) {
      if (states.contains(WidgetState.disabled)) {
        return pick(IxThemeColorToken.weakText);
      }
      if (states.contains(WidgetState.selected)) {
        return pick(IxThemeColorToken.primaryContrast);
      }
      return pick(IxThemeColorToken.stdText);
    });

    final dayOverlayColor = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return pick(IxThemeColorToken.component1Active);
      }
      if (states.contains(WidgetState.hovered)) {
        return pick(IxThemeColorToken.component1Hover);
      }
      return Colors.transparent;
    });

    final datePickerTheme = DatePickerThemeData(
      backgroundColor: pick(IxThemeColorToken.color2),
      surfaceTintColor: Colors.transparent,
      shadowColor: pick(IxThemeColorToken.shadow1),
      shape: fieldShape,
      headerBackgroundColor: pick(IxThemeColorToken.component8),
      headerForegroundColor: pick(IxThemeColorToken.stdText),
      dividerColor: pick(IxThemeColorToken.softBdr),
      dayBackgroundColor: dayBackgroundColor,
      dayForegroundColor: dayForegroundColor,
      dayOverlayColor: dayOverlayColor,
      dayShape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      todayBackgroundColor: WidgetStatePropertyAll(
        pick(IxThemeColorToken.component8),
      ),
      todayForegroundColor: WidgetStatePropertyAll(
        pick(IxThemeColorToken.dynamic),
      ),
    );

    return IxFormFieldTheme(
      inputDecorationTheme: inputTheme,
      dropdownMenuTheme: dropdownMenuTheme,
      datePickerTheme: datePickerTheme,
      info: semantic(
        background: IxThemeColorToken.componentInfo,
        border: IxThemeColorToken.info,
        foreground: IxThemeColorToken.infoContrast,
        icon: IxThemeColorToken.info,
      ),
      warning: semantic(
        background: IxThemeColorToken.componentWarning,
        border: IxThemeColorToken.warningBdr,
        foreground: IxThemeColorToken.warningText,
        icon: IxThemeColorToken.warning,
      ),
      error: semantic(
        background: IxThemeColorToken.componentError,
        border: IxThemeColorToken.alarmBdr,
        foreground: IxThemeColorToken.alarmText,
        icon: IxThemeColorToken.alarm,
      ),
      shape: fieldShape,
    );
  }

  final InputDecorationTheme inputDecorationTheme;
  final DropdownMenuThemeData dropdownMenuTheme;
  final DatePickerThemeData datePickerTheme;
  final IxFormFieldSemanticColors info;
  final IxFormFieldSemanticColors warning;
  final IxFormFieldSemanticColors error;
  final ShapeBorder shape;

  @override
  IxFormFieldTheme copyWith({
    InputDecorationTheme? inputDecorationTheme,
    DropdownMenuThemeData? dropdownMenuTheme,
    DatePickerThemeData? datePickerTheme,
    IxFormFieldSemanticColors? info,
    IxFormFieldSemanticColors? warning,
    IxFormFieldSemanticColors? error,
    ShapeBorder? shape,
  }) {
    return IxFormFieldTheme(
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      dropdownMenuTheme: dropdownMenuTheme ?? this.dropdownMenuTheme,
      datePickerTheme: datePickerTheme ?? this.datePickerTheme,
      info: info ?? this.info,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      shape: shape ?? this.shape,
    );
  }

  @override
  IxFormFieldTheme lerp(ThemeExtension<IxFormFieldTheme>? other, double t) {
    if (other is! IxFormFieldTheme) {
      return this;
    }

    return IxFormFieldTheme(
      inputDecorationTheme: t < 0.5
          ? inputDecorationTheme
          : other.inputDecorationTheme,
      dropdownMenuTheme: t < 0.5 ? dropdownMenuTheme : other.dropdownMenuTheme,
      datePickerTheme: t < 0.5 ? datePickerTheme : other.datePickerTheme,
      info: IxFormFieldSemanticColors.lerp(info, other.info, t),
      warning: IxFormFieldSemanticColors.lerp(warning, other.warning, t),
      error: IxFormFieldSemanticColors.lerp(error, other.error, t),
      shape: ShapeBorder.lerp(shape, other.shape, t) ?? shape,
    );
  }
}
