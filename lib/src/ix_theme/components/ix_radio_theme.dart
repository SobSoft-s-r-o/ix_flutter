import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';

const _defaultCssFontSizePx = 16.0; // Browser default for 1rem.
const _radioBorderWidthRem = 0.0625; // --theme-border-width-default token.
const _radioFocusOffsetRem = 0.125; // --theme-focus-outline-offset token.

const _radioBorderWidthPx = _defaultCssFontSizePx * _radioBorderWidthRem;
const _radioFocusOffsetPx = _defaultCssFontSizePx * _radioFocusOffsetRem;

/// Enumerates Siemens IX radio semantic treatments.
enum IxRadioStatus { standard, info, warning, invalid }

/// Captures the resolved visual states for a radio treatment.
class IxRadioVisualState {
  const IxRadioVisualState({
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

  IxRadioVisualState copyWith({
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
    return IxRadioVisualState(
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

  static IxRadioVisualState lerp(
    IxRadioVisualState a,
    IxRadioVisualState b,
    double t,
  ) {
    Color lerp(Color ca, Color cb) => Color.lerp(ca, cb, t) ?? ca;

    return IxRadioVisualState(
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

/// Group of unchecked/checked visuals for a semantic status.
class IxRadioStateBundle {
  const IxRadioStateBundle({required this.unchecked, required this.checked});

  final IxRadioVisualState unchecked;
  final IxRadioVisualState checked;

  IxRadioStateBundle copyWith({
    IxRadioVisualState? unchecked,
    IxRadioVisualState? checked,
  }) {
    return IxRadioStateBundle(
      unchecked: unchecked ?? this.unchecked,
      checked: checked ?? this.checked,
    );
  }

  static IxRadioStateBundle lerp(
    IxRadioStateBundle a,
    IxRadioStateBundle b,
    double t,
  ) {
    return IxRadioStateBundle(
      unchecked: IxRadioVisualState.lerp(a.unchecked, b.unchecked, t),
      checked: IxRadioVisualState.lerp(a.checked, b.checked, t),
    );
  }
}

/// Theme extension that exposes Siemens IX radio styling primitives.
class IxRadioTheme extends ThemeExtension<IxRadioTheme> {
  const IxRadioTheme({
    required this.materialRadioTheme,
    required this.borderWidth,
    required this.focusOutlineOffset,
    required this.labelColor,
    required this.disabledLabelColor,
    required this.styles,
  });

  factory IxRadioTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    IxRadioVisualState buildState({
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
      return IxRadioVisualState(
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

    IxRadioStateBundle buildBundle({
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

      return IxRadioStateBundle(unchecked: unchecked, checked: checked);
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
    );

    final styles = Map<IxRadioStatus, IxRadioStateBundle>.unmodifiable({
      IxRadioStatus.standard: standard,
      IxRadioStatus.info: info,
      IxRadioStatus.warning: warning,
      IxRadioStatus.invalid: invalid,
    });

    IxRadioStateBundle defaultBundle = styles[IxRadioStatus.standard]!;

    Color resolveFill(Set<WidgetState> states) {
      final visuals = _radioVisualStateFor(defaultBundle, states);
      return _radioFillFor(visuals, states);
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

    final radioTheme = RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(resolveFill),
      overlayColor: overlay,
      splashRadius: 20,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );

    return IxRadioTheme(
      materialRadioTheme: radioTheme,
      borderWidth: _radioBorderWidthPx,
      focusOutlineOffset: _radioFocusOffsetPx,
      labelColor: color(IxThemeColorToken.stdText),
      disabledLabelColor: color(IxThemeColorToken.weakText),
      styles: styles,
    );
  }

  final RadioThemeData materialRadioTheme;
  final double borderWidth;
  final double focusOutlineOffset;
  final Color labelColor;
  final Color disabledLabelColor;
  final Map<IxRadioStatus, IxRadioStateBundle> styles;

  IxRadioStateBundle style(IxRadioStatus status) {
    return styles[status] ?? styles[IxRadioStatus.standard]!;
  }

  @override
  IxRadioTheme copyWith({
    RadioThemeData? materialRadioTheme,
    double? borderWidth,
    double? focusOutlineOffset,
    Color? labelColor,
    Color? disabledLabelColor,
    Map<IxRadioStatus, IxRadioStateBundle>? styles,
  }) {
    return IxRadioTheme(
      materialRadioTheme: materialRadioTheme ?? this.materialRadioTheme,
      borderWidth: borderWidth ?? this.borderWidth,
      focusOutlineOffset: focusOutlineOffset ?? this.focusOutlineOffset,
      labelColor: labelColor ?? this.labelColor,
      disabledLabelColor: disabledLabelColor ?? this.disabledLabelColor,
      styles: styles ?? this.styles,
    );
  }

  @override
  IxRadioTheme lerp(ThemeExtension<IxRadioTheme>? other, double t) {
    if (other is! IxRadioTheme) {
      return this;
    }

    Map<IxRadioStatus, IxRadioStateBundle> lerpMap(
      Map<IxRadioStatus, IxRadioStateBundle> a,
      Map<IxRadioStatus, IxRadioStateBundle> b,
    ) {
      final keys = <IxRadioStatus>{...a.keys, ...b.keys};
      return {
        for (final key in keys)
          key: IxRadioStateBundle.lerp(a[key] ?? b[key]!, b[key] ?? a[key]!, t),
      };
    }

    return IxRadioTheme(
      materialRadioTheme: RadioThemeData.lerp(
        materialRadioTheme,
        other.materialRadioTheme,
        t,
      ),
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

IxRadioVisualState _radioVisualStateFor(
  IxRadioStateBundle bundle,
  Set<WidgetState> states,
) {
  if (states.contains(WidgetState.selected)) {
    return bundle.checked;
  }
  return bundle.unchecked;
}

Color _radioFillFor(IxRadioVisualState state, Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return states.contains(WidgetState.selected)
        ? state.disabledBackground
        : state.disabledBorderColor;
  }
  if (states.contains(WidgetState.selected)) {
    if (states.contains(WidgetState.pressed)) {
      return state.activeBackground;
    }
    if (states.contains(WidgetState.hovered)) {
      return state.hoverBackground;
    }
    return state.background;
  }
  if (states.contains(WidgetState.pressed)) {
    return state.activeBorderColor;
  }
  if (states.contains(WidgetState.hovered)) {
    return state.hoverBorderColor;
  }
  return state.borderColor;
}
