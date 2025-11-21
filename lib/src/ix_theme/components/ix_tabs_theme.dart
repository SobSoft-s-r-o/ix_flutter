import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';

const _defaultCssFontSizePx = 16.0;
const _indicatorHeightRem = 0.125;
const _circleDiameterRem = 3.0;
const _largeSpaceRem = 1.5;
const _smallSpaceRem = 0.5;
const _defaultSpaceRem = 1.0;
const _tinySpaceRem = 0.25;
const _defaultVerticalPaddingPx = 10.0;
const _circleBorderWidthPx = 2.0;

const double _indicatorHeightPx = _indicatorHeightRem * _defaultCssFontSizePx;
const double _circleDiameterPx = _circleDiameterRem * _defaultCssFontSizePx;
const double _tabHorizontalPaddingPx = _largeSpaceRem * _defaultCssFontSizePx;
const double _iconVerticalPaddingPx = _largeSpaceRem * _defaultCssFontSizePx;
const double _iconHorizontalPaddingPx = _smallSpaceRem * _defaultCssFontSizePx;
const double _smallPaddingPx = _defaultSpaceRem * _defaultCssFontSizePx;
const double _smallIconHorizontalPaddingPx =
    _tinySpaceRem * _defaultCssFontSizePx;

/// Captures Siemens IX tab states for foreground/background colors.
class IxTabStateColors {
  const IxTabStateColors({
    required this.base,
    required this.hover,
    required this.active,
    required this.selected,
    required this.disabled,
  });

  final Color base;
  final Color hover;
  final Color active;
  final Color selected;
  final Color disabled;

  IxTabStateColors copyWith({
    Color? base,
    Color? hover,
    Color? active,
    Color? selected,
    Color? disabled,
  }) {
    return IxTabStateColors(
      base: base ?? this.base,
      hover: hover ?? this.hover,
      active: active ?? this.active,
      selected: selected ?? this.selected,
      disabled: disabled ?? this.disabled,
    );
  }

  static IxTabStateColors lerp(
    IxTabStateColors a,
    IxTabStateColors b,
    double t,
  ) {
    return IxTabStateColors(
      base: Color.lerp(a.base, b.base, t) ?? a.base,
      hover: Color.lerp(a.hover, b.hover, t) ?? a.hover,
      active: Color.lerp(a.active, b.active, t) ?? a.active,
      selected: Color.lerp(a.selected, b.selected, t) ?? a.selected,
      disabled: Color.lerp(a.disabled, b.disabled, t) ?? a.disabled,
    );
  }
}

/// Describes the Siemens IX default tab treatment.
class IxTabStyle {
  const IxTabStyle({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.indicator,
  });

  final IxTabStateColors background;
  final IxTabStateColors foreground;
  final IxTabStateColors icon;
  final IxTabStateColors indicator;

  IxTabStyle copyWith({
    IxTabStateColors? background,
    IxTabStateColors? foreground,
    IxTabStateColors? icon,
    IxTabStateColors? indicator,
  }) {
    return IxTabStyle(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      icon: icon ?? this.icon,
      indicator: indicator ?? this.indicator,
    );
  }

  static IxTabStyle lerp(IxTabStyle a, IxTabStyle b, double t) {
    return IxTabStyle(
      background: IxTabStateColors.lerp(a.background, b.background, t),
      foreground: IxTabStateColors.lerp(a.foreground, b.foreground, t),
      icon: IxTabStateColors.lerp(a.icon, b.icon, t),
      indicator: IxTabStateColors.lerp(a.indicator, b.indicator, t),
    );
  }
}

/// Token representation for circular/animated tab variants.
class IxTabCircleStyle {
  const IxTabCircleStyle({
    required this.background,
    required this.border,
    required this.icon,
    required this.indicator,
  });

  final IxTabStateColors background;
  final IxTabStateColors border;
  final IxTabStateColors icon;
  final IxTabStateColors indicator;

  IxTabCircleStyle copyWith({
    IxTabStateColors? background,
    IxTabStateColors? border,
    IxTabStateColors? icon,
    IxTabStateColors? indicator,
  }) {
    return IxTabCircleStyle(
      background: background ?? this.background,
      border: border ?? this.border,
      icon: icon ?? this.icon,
      indicator: indicator ?? this.indicator,
    );
  }

  static IxTabCircleStyle lerp(
    IxTabCircleStyle a,
    IxTabCircleStyle b,
    double t,
  ) {
    return IxTabCircleStyle(
      background: IxTabStateColors.lerp(a.background, b.background, t),
      border: IxTabStateColors.lerp(a.border, b.border, t),
      icon: IxTabStateColors.lerp(a.icon, b.icon, t),
      indicator: IxTabStateColors.lerp(a.indicator, b.indicator, t),
    );
  }
}

/// Tab counter/pill tokens for Siemens IX tabs.
class IxTabPillStyle {
  const IxTabPillStyle({required this.border});

  final IxTabStateColors border;

  IxTabPillStyle copyWith({IxTabStateColors? border}) {
    return IxTabPillStyle(border: border ?? this.border);
  }

  static IxTabPillStyle lerp(IxTabPillStyle a, IxTabPillStyle b, double t) {
    return IxTabPillStyle(border: IxTabStateColors.lerp(a.border, b.border, t));
  }
}

/// Theme extension exposing Siemens IX tokens for tabs and tab bars.
class IxTabsTheme extends ThemeExtension<IxTabsTheme> {
  const IxTabsTheme({
    required this.materialTabTheme,
    required this.tab,
    required this.circle,
    required this.pill,
    required this.tabPadding,
    required this.iconPadding,
    required this.smallPadding,
    required this.smallIconPadding,
    required this.circleDiameter,
    required this.circleBorderWidth,
    required this.indicatorHeight,
  });

  factory IxTabsTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color resolve(IxThemeColorToken token) => palette[token]!;

    IxTabStateColors states({
      required IxThemeColorToken base,
      IxThemeColorToken? hover,
      IxThemeColorToken? active,
      IxThemeColorToken? selected,
      IxThemeColorToken? disabled,
    }) {
      return IxTabStateColors(
        base: resolve(base),
        hover: resolve(hover ?? base),
        active: resolve(active ?? hover ?? base),
        selected: resolve(selected ?? base),
        disabled: resolve(disabled ?? base),
      );
    }

    final tabStyle = IxTabStyle(
      background: states(
        base: IxThemeColorToken.ghost,
        hover: IxThemeColorToken.ghostPrimaryHover,
        active: IxThemeColorToken.ghostPrimaryActive,
        selected: IxThemeColorToken.ghost,
        disabled: IxThemeColorToken.ghost,
      ),
      foreground: states(
        base: IxThemeColorToken.stdText,
        hover: IxThemeColorToken.stdText,
        active: IxThemeColorToken.stdText,
        selected: IxThemeColorToken.stdText,
        disabled: IxThemeColorToken.weakText,
      ),
      icon: states(
        base: IxThemeColorToken.stdText,
        hover: IxThemeColorToken.stdText,
        active: IxThemeColorToken.stdText,
        selected: IxThemeColorToken.stdText,
        disabled: IxThemeColorToken.weakText,
      ),
      indicator: states(
        base: IxThemeColorToken.softBdr,
        hover: IxThemeColorToken.softBdr,
        active: IxThemeColorToken.softBdr,
        selected: IxThemeColorToken.dynamic,
        disabled: IxThemeColorToken.softBdr,
      ),
    );

    final circleStyle = IxTabCircleStyle(
      background: states(
        base: IxThemeColorToken.component1,
        hover: IxThemeColorToken.ghostPrimaryHover,
        active: IxThemeColorToken.ghostPrimaryActive,
        selected: IxThemeColorToken.ghost,
        disabled: IxThemeColorToken.ghost,
      ),
      border: states(
        base: IxThemeColorToken.color0,
        hover: IxThemeColorToken.color0,
        active: IxThemeColorToken.color0,
        selected: IxThemeColorToken.dynamic,
        disabled: IxThemeColorToken.ghost,
      ),
      icon: states(
        base: IxThemeColorToken.stdText,
        hover: IxThemeColorToken.stdText,
        active: IxThemeColorToken.stdText,
        selected: IxThemeColorToken.stdText,
        disabled: IxThemeColorToken.weakText,
      ),
      indicator: states(
        base: IxThemeColorToken.softBdr,
        hover: IxThemeColorToken.softBdr,
        active: IxThemeColorToken.softBdr,
        selected: IxThemeColorToken.dynamic,
        disabled: IxThemeColorToken.softBdr,
      ),
    );

    final pillStyle = IxTabPillStyle(
      border: states(
        base: IxThemeColorToken.neutral,
        hover: IxThemeColorToken.neutral,
        active: IxThemeColorToken.neutral,
        selected: IxThemeColorToken.dynamic,
        disabled: IxThemeColorToken.neutral,
      ),
    );

    final tabLabelStyle = typography.label.copyWith(
      fontWeight: FontWeight.w700,
    );
    final indicatorColor = tabStyle.indicator.selected;

    Color? overlayResolver(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return tabStyle.background.disabled;
      }
      if (states.contains(WidgetState.pressed)) {
        return tabStyle.background.active;
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return tabStyle.background.hover;
      }
      if (states.contains(WidgetState.selected)) {
        return tabStyle.background.selected;
      }
      return tabStyle.background.base;
    }

    final tabBarTheme = TabBarThemeData(
      labelColor: tabStyle.foreground.selected,
      unselectedLabelColor: tabStyle.foreground.base,
      labelStyle: tabLabelStyle,
      unselectedLabelStyle: tabLabelStyle,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: indicatorColor,
          width: _indicatorHeightPx,
        ),
      ),
      indicatorColor: indicatorColor,
      indicatorSize: TabBarIndicatorSize.tab,
      overlayColor: WidgetStateProperty.resolveWith(overlayResolver),
      dividerColor: tabStyle.indicator.base,
      labelPadding: const EdgeInsets.symmetric(
        horizontal: _tabHorizontalPaddingPx,
        vertical: _defaultVerticalPaddingPx,
      ),
      splashFactory: NoSplash.splashFactory,
    );

    return IxTabsTheme(
      materialTabTheme: tabBarTheme,
      tab: tabStyle,
      circle: circleStyle,
      pill: pillStyle,
      tabPadding: const EdgeInsets.symmetric(
        horizontal: _tabHorizontalPaddingPx,
        vertical: _defaultVerticalPaddingPx,
      ),
      iconPadding: const EdgeInsets.symmetric(
        horizontal: _iconHorizontalPaddingPx,
        vertical: _iconVerticalPaddingPx,
      ),
      smallPadding: const EdgeInsets.all(_smallPaddingPx),
      smallIconPadding: const EdgeInsets.symmetric(
        horizontal: _smallIconHorizontalPaddingPx,
        vertical: _smallPaddingPx,
      ),
      circleDiameter: _circleDiameterPx,
      circleBorderWidth: _circleBorderWidthPx,
      indicatorHeight: _indicatorHeightPx,
    );
  }

  final TabBarThemeData materialTabTheme;
  final IxTabStyle tab;
  final IxTabCircleStyle circle;
  final IxTabPillStyle pill;
  final EdgeInsets tabPadding;
  final EdgeInsets iconPadding;
  final EdgeInsets smallPadding;
  final EdgeInsets smallIconPadding;
  final double circleDiameter;
  final double circleBorderWidth;
  final double indicatorHeight;

  @override
  IxTabsTheme copyWith({
    TabBarThemeData? materialTabTheme,
    IxTabStyle? tab,
    IxTabCircleStyle? circle,
    IxTabPillStyle? pill,
    EdgeInsets? tabPadding,
    EdgeInsets? iconPadding,
    EdgeInsets? smallPadding,
    EdgeInsets? smallIconPadding,
    double? circleDiameter,
    double? circleBorderWidth,
    double? indicatorHeight,
  }) {
    return IxTabsTheme(
      materialTabTheme: materialTabTheme ?? this.materialTabTheme,
      tab: tab ?? this.tab,
      circle: circle ?? this.circle,
      pill: pill ?? this.pill,
      tabPadding: tabPadding ?? this.tabPadding,
      iconPadding: iconPadding ?? this.iconPadding,
      smallPadding: smallPadding ?? this.smallPadding,
      smallIconPadding: smallIconPadding ?? this.smallIconPadding,
      circleDiameter: circleDiameter ?? this.circleDiameter,
      circleBorderWidth: circleBorderWidth ?? this.circleBorderWidth,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
    );
  }

  @override
  IxTabsTheme lerp(ThemeExtension<IxTabsTheme>? other, double t) {
    if (other is! IxTabsTheme) {
      return this;
    }

    return IxTabsTheme(
      materialTabTheme: TabBarThemeData.lerp(
        materialTabTheme,
        other.materialTabTheme,
        t,
      ),
      tab: IxTabStyle.lerp(tab, other.tab, t),
      circle: IxTabCircleStyle.lerp(circle, other.circle, t),
      pill: IxTabPillStyle.lerp(pill, other.pill, t),
      tabPadding:
          EdgeInsets.lerp(tabPadding, other.tabPadding, t) ?? tabPadding,
      iconPadding:
          EdgeInsets.lerp(iconPadding, other.iconPadding, t) ?? iconPadding,
      smallPadding:
          EdgeInsets.lerp(smallPadding, other.smallPadding, t) ?? smallPadding,
      smallIconPadding:
          EdgeInsets.lerp(smallIconPadding, other.smallIconPadding, t) ??
          smallIconPadding,
      circleDiameter:
          lerpDouble(circleDiameter, other.circleDiameter, t) ?? circleDiameter,
      circleBorderWidth:
          lerpDouble(circleBorderWidth, other.circleBorderWidth, t) ??
          circleBorderWidth,
      indicatorHeight:
          lerpDouble(indicatorHeight, other.indicatorHeight, t) ??
          indicatorHeight,
    );
  }
}
