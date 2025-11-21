import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';

const _defaultCssFontSizePx = 16.0; // Browser default for 1rem.
const _checkboxBorderRadiusRem = 0.125; // --theme-small-border-radius token.
const _checkboxBorderWidthRem = 0.0625; // --theme-border-width-default token.
const _checkboxFocusOffsetRem = 0.125; // --theme-focus-outline-offset token.

const _checkboxBorderRadiusPx =
    _defaultCssFontSizePx * _checkboxBorderRadiusRem;
const _checkboxBorderWidthPx = _defaultCssFontSizePx * _checkboxBorderWidthRem;
const _checkboxFocusOffsetPx = _defaultCssFontSizePx * _checkboxFocusOffsetRem;

/// Enumerates Siemens IX checkbox semantic treatments.
enum IxCheckboxStatus { standard, info, warning, invalid }

/// Captures the resolved visual states for a checkbox treatment.
class IxCheckboxVisualState {
  const IxCheckboxVisualState({
    required this.background,
    required this.hoverBackground,
    required this.activeBackground,
    required this.disabledBackground,
    required this.borderColor,
    required this.hoverBorderColor,
    required this.activeBorderColor,
    required this.disabledBorderColor,
    required this.iconColor,
    required this.hoverIconColor,
    required this.activeIconColor,
    required this.disabledIconColor,
  });

  final Color background;
  final Color hoverBackground;
  final Color activeBackground;
  final Color disabledBackground;
  final Color borderColor;
  final Color hoverBorderColor;
  final Color activeBorderColor;
  final Color disabledBorderColor;
  final Color iconColor;
  final Color hoverIconColor;
  final Color activeIconColor;
  final Color disabledIconColor;

  IxCheckboxVisualState copyWith({
    Color? background,
    Color? hoverBackground,
    Color? activeBackground,
    Color? disabledBackground,
    Color? borderColor,
    Color? hoverBorderColor,
    Color? activeBorderColor,
    Color? disabledBorderColor,
    Color? iconColor,
    Color? hoverIconColor,
    Color? activeIconColor,
    Color? disabledIconColor,
  }) {
    return IxCheckboxVisualState(
      background: background ?? this.background,
      hoverBackground: hoverBackground ?? this.hoverBackground,
      activeBackground: activeBackground ?? this.activeBackground,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      borderColor: borderColor ?? this.borderColor,
      hoverBorderColor: hoverBorderColor ?? this.hoverBorderColor,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      iconColor: iconColor ?? this.iconColor,
      hoverIconColor: hoverIconColor ?? this.hoverIconColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
    );
  }

  static IxCheckboxVisualState lerp(
    IxCheckboxVisualState a,
    IxCheckboxVisualState b,
    double t,
  ) {
    Color lerp(Color ca, Color cb) => Color.lerp(ca, cb, t) ?? ca;

    return IxCheckboxVisualState(
      background: lerp(a.background, b.background),
      hoverBackground: lerp(a.hoverBackground, b.hoverBackground),
      activeBackground: lerp(a.activeBackground, b.activeBackground),
      disabledBackground: lerp(a.disabledBackground, b.disabledBackground),
      borderColor: lerp(a.borderColor, b.borderColor),
      hoverBorderColor: lerp(a.hoverBorderColor, b.hoverBorderColor),
      activeBorderColor: lerp(a.activeBorderColor, b.activeBorderColor),
      disabledBorderColor: lerp(a.disabledBorderColor, b.disabledBorderColor),
      iconColor: lerp(a.iconColor, b.iconColor),
      hoverIconColor: lerp(a.hoverIconColor, b.hoverIconColor),
      activeIconColor: lerp(a.activeIconColor, b.activeIconColor),
      disabledIconColor: lerp(a.disabledIconColor, b.disabledIconColor),
    );
  }
}

/// Group of unchecked/checked/mixed visuals for a semantic status.
class IxCheckboxStateBundle {
  const IxCheckboxStateBundle({
    required this.unchecked,
    required this.checked,
    required this.mixed,
  });

  final IxCheckboxVisualState unchecked;
  final IxCheckboxVisualState checked;
  final IxCheckboxVisualState mixed;

  IxCheckboxStateBundle copyWith({
    IxCheckboxVisualState? unchecked,
    IxCheckboxVisualState? checked,
    IxCheckboxVisualState? mixed,
  }) {
    return IxCheckboxStateBundle(
      unchecked: unchecked ?? this.unchecked,
      checked: checked ?? this.checked,
      mixed: mixed ?? this.mixed,
    );
  }

  static IxCheckboxStateBundle lerp(
    IxCheckboxStateBundle a,
    IxCheckboxStateBundle b,
    double t,
  ) {
    return IxCheckboxStateBundle(
      unchecked: IxCheckboxVisualState.lerp(a.unchecked, b.unchecked, t),
      checked: IxCheckboxVisualState.lerp(a.checked, b.checked, t),
      mixed: IxCheckboxVisualState.lerp(a.mixed, b.mixed, t),
    );
  }
}

/// Theme extension that exposes Siemens IX checkbox styling primitives.
class IxCheckboxTheme extends ThemeExtension<IxCheckboxTheme> {
  const IxCheckboxTheme({
    required this.materialCheckboxTheme,
    required this.borderRadius,
    required this.borderWidth,
    required this.focusOutlineOffset,
    required this.labelColor,
    required this.disabledLabelColor,
    required this.styles,
  });

  factory IxCheckboxTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    IxCheckboxVisualState buildState({
      required IxThemeColorToken background,
      required IxThemeColorToken hover,
      required IxThemeColorToken active,
      required IxThemeColorToken disabled,
      required IxThemeColorToken border,
      IxThemeColorToken? borderHover,
      IxThemeColorToken? borderActive,
      IxThemeColorToken? borderDisabled,
      required IxThemeColorToken icon,
      IxThemeColorToken? iconHover,
      IxThemeColorToken? iconActive,
      IxThemeColorToken? iconDisabled,
    }) {
      return IxCheckboxVisualState(
        background: color(background),
        hoverBackground: color(hover),
        activeBackground: color(active),
        disabledBackground: color(disabled),
        borderColor: color(border),
        hoverBorderColor: color(borderHover ?? border),
        activeBorderColor: color(borderActive ?? borderHover ?? border),
        disabledBorderColor: color(borderDisabled ?? border),
        iconColor: color(icon),
        hoverIconColor: color(iconHover ?? icon),
        activeIconColor: color(iconActive ?? iconHover ?? icon),
        disabledIconColor: color(iconDisabled ?? icon),
      );
    }

    IxCheckboxStateBundle buildBundle({
      required IxThemeColorToken uncheckedBackground,
      required IxThemeColorToken uncheckedHover,
      required IxThemeColorToken uncheckedActive,
      required IxThemeColorToken uncheckedDisabled,
      required IxThemeColorToken uncheckedBorder,
      IxThemeColorToken? uncheckedBorderHover,
      IxThemeColorToken? uncheckedBorderActive,
      IxThemeColorToken? uncheckedBorderDisabled,
      required IxThemeColorToken uncheckedIcon,
      IxThemeColorToken? uncheckedIconHover,
      IxThemeColorToken? uncheckedIconActive,
      IxThemeColorToken? uncheckedIconDisabled,
      required IxThemeColorToken checkedBackground,
      required IxThemeColorToken checkedHover,
      required IxThemeColorToken checkedActive,
      IxThemeColorToken checkedDisabled = IxThemeColorToken.component4,
      IxThemeColorToken checkedBorder = IxThemeColorToken.color0,
      IxThemeColorToken? checkedBorderHover,
      IxThemeColorToken? checkedBorderActive,
      IxThemeColorToken? checkedBorderDisabled,
      IxThemeColorToken checkedIcon = IxThemeColorToken.primaryContrast,
      IxThemeColorToken? checkedIconHover,
      IxThemeColorToken? checkedIconActive,
      IxThemeColorToken? checkedIconDisabled,
      IxThemeColorToken? mixedBackground,
      IxThemeColorToken? mixedHover,
      IxThemeColorToken? mixedActive,
      IxThemeColorToken mixedDisabled = IxThemeColorToken.component4,
      IxThemeColorToken mixedBorder = IxThemeColorToken.color0,
      IxThemeColorToken? mixedBorderHover,
      IxThemeColorToken? mixedBorderActive,
      IxThemeColorToken? mixedBorderDisabled,
      IxThemeColorToken mixedIcon = IxThemeColorToken.primaryContrast,
      IxThemeColorToken? mixedIconHover,
      IxThemeColorToken? mixedIconActive,
      IxThemeColorToken? mixedIconDisabled,
    }) {
      final unchecked = buildState(
        background: uncheckedBackground,
        hover: uncheckedHover,
        active: uncheckedActive,
        disabled: uncheckedDisabled,
        border: uncheckedBorder,
        borderHover: uncheckedBorderHover,
        borderActive: uncheckedBorderActive,
        borderDisabled: uncheckedBorderDisabled,
        icon: uncheckedIcon,
        iconHover: uncheckedIconHover,
        iconActive: uncheckedIconActive,
        iconDisabled: uncheckedIconDisabled,
      );

      final checked = buildState(
        background: checkedBackground,
        hover: checkedHover,
        active: checkedActive,
        disabled: checkedDisabled,
        border: checkedBorder,
        borderHover: checkedBorderHover,
        borderActive: checkedBorderActive,
        borderDisabled: checkedBorderDisabled,
        icon: checkedIcon,
        iconHover: checkedIconHover,
        iconActive: checkedIconActive,
        iconDisabled: checkedIconDisabled,
      );

      final mixed = buildState(
        background: mixedBackground ?? checkedBackground,
        hover: mixedHover ?? checkedHover,
        active: mixedActive ?? checkedActive,
        disabled: mixedDisabled,
        border: mixedBorder,
        borderHover: mixedBorderHover,
        borderActive: mixedBorderActive,
        borderDisabled: mixedBorderDisabled,
        icon: mixedIcon,
        iconHover: mixedIconHover,
        iconActive: mixedIconActive,
        iconDisabled: mixedIconDisabled,
      );

      return IxCheckboxStateBundle(
        unchecked: unchecked,
        checked: checked,
        mixed: mixed,
      );
    }

    final standard = buildBundle(
      uncheckedBackground: IxThemeColorToken.secondary,
      uncheckedHover: IxThemeColorToken.secondaryHover,
      uncheckedActive: IxThemeColorToken.secondaryActive,
      uncheckedDisabled: IxThemeColorToken.ghost,
      uncheckedBorder: IxThemeColorToken.contrastBdr,
      uncheckedBorderHover: IxThemeColorToken.dynamic,
      uncheckedBorderActive: IxThemeColorToken.dynamic,
      uncheckedBorderDisabled: IxThemeColorToken.component4,
      uncheckedIcon: IxThemeColorToken.stdText,
      uncheckedIconDisabled: IxThemeColorToken.weakText,
      checkedBackground: IxThemeColorToken.dynamic,
      checkedHover: IxThemeColorToken.dynamicHover,
      checkedActive: IxThemeColorToken.dynamicActive,
      checkedBorder: IxThemeColorToken.color0,
      checkedBorderDisabled: IxThemeColorToken.color0,
      checkedIcon: IxThemeColorToken.primaryContrast,
      checkedIconDisabled: IxThemeColorToken.primaryContrast,
      mixedBorder: IxThemeColorToken.color0,
      mixedIcon: IxThemeColorToken.primaryContrast,
    );

    final info = buildBundle(
      uncheckedBackground: IxThemeColorToken.secondary,
      uncheckedHover: IxThemeColorToken.ghostHover,
      uncheckedActive: IxThemeColorToken.ghostActive,
      uncheckedDisabled: IxThemeColorToken.ghost,
      uncheckedBorder: IxThemeColorToken.info,
      uncheckedBorderHover: IxThemeColorToken.infoHover,
      uncheckedBorderActive: IxThemeColorToken.infoActive,
      uncheckedBorderDisabled: IxThemeColorToken.info,
      uncheckedIcon: IxThemeColorToken.stdText,
      checkedBackground: IxThemeColorToken.info,
      checkedHover: IxThemeColorToken.infoHover,
      checkedActive: IxThemeColorToken.infoActive,
      checkedBorder: IxThemeColorToken.color0,
      checkedIcon: IxThemeColorToken.infoContrast,
      mixedBorder: IxThemeColorToken.color0,
      mixedIcon: IxThemeColorToken.infoContrast,
    );

    final warning = buildBundle(
      uncheckedBackground: IxThemeColorToken.componentWarning,
      uncheckedHover: IxThemeColorToken.ghostHover,
      uncheckedActive: IxThemeColorToken.ghostActive,
      uncheckedDisabled: IxThemeColorToken.ghost,
      uncheckedBorder: IxThemeColorToken.warningBdr,
      uncheckedBorderHover: IxThemeColorToken.warningBdr,
      uncheckedBorderActive: IxThemeColorToken.warningBdr,
      uncheckedBorderDisabled: IxThemeColorToken.warningBdr,
      uncheckedIcon: IxThemeColorToken.stdText,
      checkedBackground: IxThemeColorToken.warning,
      checkedHover: IxThemeColorToken.warningHover,
      checkedActive: IxThemeColorToken.warningActive,
      checkedBorder: IxThemeColorToken.warningBdr,
      checkedIcon: IxThemeColorToken.warningContrast,
      mixedBorder: IxThemeColorToken.warningBdr,
      mixedIcon: IxThemeColorToken.warningContrast,
    );

    final invalid = buildBundle(
      uncheckedBackground: IxThemeColorToken.componentError,
      uncheckedHover: IxThemeColorToken.ghostHover,
      uncheckedActive: IxThemeColorToken.ghostActive,
      uncheckedDisabled: IxThemeColorToken.ghost,
      uncheckedBorder: IxThemeColorToken.alarmBdr,
      uncheckedBorderHover: IxThemeColorToken.alarmBdr,
      uncheckedBorderActive: IxThemeColorToken.alarmBdr,
      uncheckedBorderDisabled: IxThemeColorToken.alarmBdr,
      uncheckedIcon: IxThemeColorToken.stdText,
      checkedBackground: IxThemeColorToken.alarm,
      checkedHover: IxThemeColorToken.alarmHover,
      checkedActive: IxThemeColorToken.alarmActive,
      checkedBorder: IxThemeColorToken.alarmBdr,
      checkedIcon: IxThemeColorToken.alarmContrast,
      mixedBorder: IxThemeColorToken.alarmBdr,
      mixedIcon: IxThemeColorToken.alarmContrast,
    );

    final styles = Map<IxCheckboxStatus, IxCheckboxStateBundle>.unmodifiable({
      IxCheckboxStatus.standard: standard,
      IxCheckboxStatus.info: info,
      IxCheckboxStatus.warning: warning,
      IxCheckboxStatus.invalid: invalid,
    });

    IxCheckboxStateBundle defaultBundle = styles[IxCheckboxStatus.standard]!;

    Color resolveBackground(Set<WidgetState> states) {
      final palette = _visualStateFor(defaultBundle, states);
      return _backgroundFor(palette, states);
    }

    Color resolveIcon(Set<WidgetState> states) {
      final palette = _visualStateFor(defaultBundle, states);
      return _iconFor(palette, states);
    }

    final overlay = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return color(IxThemeColorToken.component1Active);
      }
      if (states.contains(WidgetState.hovered)) {
        return color(IxThemeColorToken.component1Hover);
      }
      return Colors.transparent;
    });

    final checkboxTheme = CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_checkboxBorderRadiusPx),
        side: BorderSide(
          color: standard.unchecked.borderColor,
          width: _checkboxBorderWidthPx,
        ),
      ),
      side: BorderSide(
        color: standard.unchecked.borderColor,
        width: _checkboxBorderWidthPx,
      ),
      fillColor: WidgetStateProperty.resolveWith(resolveBackground),
      checkColor: WidgetStateProperty.resolveWith(resolveIcon),
      overlayColor: overlay,
      splashRadius: 20,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );

    return IxCheckboxTheme(
      materialCheckboxTheme: checkboxTheme,
      borderRadius: _checkboxBorderRadiusPx,
      borderWidth: _checkboxBorderWidthPx,
      focusOutlineOffset: _checkboxFocusOffsetPx,
      labelColor: color(IxThemeColorToken.stdText),
      disabledLabelColor: color(IxThemeColorToken.weakText),
      styles: styles,
    );
  }

  final CheckboxThemeData materialCheckboxTheme;
  final double borderRadius;
  final double borderWidth;
  final double focusOutlineOffset;
  final Color labelColor;
  final Color disabledLabelColor;
  final Map<IxCheckboxStatus, IxCheckboxStateBundle> styles;

  IxCheckboxStateBundle style(IxCheckboxStatus status) {
    return styles[status] ?? styles[IxCheckboxStatus.standard]!;
  }

  @override
  IxCheckboxTheme copyWith({
    CheckboxThemeData? materialCheckboxTheme,
    double? borderRadius,
    double? borderWidth,
    double? focusOutlineOffset,
    Color? labelColor,
    Color? disabledLabelColor,
    Map<IxCheckboxStatus, IxCheckboxStateBundle>? styles,
  }) {
    return IxCheckboxTheme(
      materialCheckboxTheme:
          materialCheckboxTheme ?? this.materialCheckboxTheme,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusOutlineOffset: focusOutlineOffset ?? this.focusOutlineOffset,
      labelColor: labelColor ?? this.labelColor,
      disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
      styles: styles ?? this.styles,
    );
  }

  @override
  IxCheckboxTheme lerp(ThemeExtension<IxCheckboxTheme>? other, double t) {
    if (other is! IxCheckboxTheme) {
      return this;
    }

    Map<IxCheckboxStatus, IxCheckboxStateBundle> lerpMap(
      Map<IxCheckboxStatus, IxCheckboxStateBundle> a,
      Map<IxCheckboxStatus, IxCheckboxStateBundle> b,
    ) {
      final keys = <IxCheckboxStatus>{...a.keys, ...b.keys};
      return {
        for (final key in keys)
          key: IxCheckboxStateBundle.lerp(
            a[key] ?? b[key]!,
            b[key] ?? a[key]!,
            t,
          ),
      };
    }

    return IxCheckboxTheme(
      materialCheckboxTheme: CheckboxThemeData.lerp(
        materialCheckboxTheme,
        other.materialCheckboxTheme,
        t,
      ),
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      focusOutlineOffset:
          lerpDouble(focusOutlineOffset, other.focusOutlineOffset, t) ??
          focusOutlineOffset,
      labelColor: Color.lerp(labelColor, other.labelColor, t) ?? labelColor,
      disabledLabelColor:
          Color.lerp(disabledLabelColor, other.disabledLabelColor, t) ??
          disabledLabelColor,
      styles: lerpMap(styles, other.styles),
    );
  }
}

IxCheckboxVisualState _visualStateFor(
  IxCheckboxStateBundle bundle,
  Set<WidgetState> states,
) {
  if (states.contains(WidgetState.selected)) {
    return bundle.checked;
  }
  return bundle.unchecked;
}

Color _backgroundFor(IxCheckboxVisualState state, Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return state.disabledBackground;
  }
  if (states.contains(WidgetState.pressed)) {
    return state.activeBackground;
  }
  if (states.contains(WidgetState.hovered)) {
    return state.hoverBackground;
  }
  return state.background;
}

Color _iconFor(IxCheckboxVisualState state, Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return state.disabledIconColor;
  }
  if (states.contains(WidgetState.pressed)) {
    return state.activeIconColor;
  }
  if (states.contains(WidgetState.hovered)) {
    return state.hoverIconColor;
  }
  return state.iconColor;
}
