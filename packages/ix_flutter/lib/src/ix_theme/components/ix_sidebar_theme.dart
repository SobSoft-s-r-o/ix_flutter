import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

/// Theme definition for Siemens IX application sidebars/navigation panels.
class IxSidebarTheme extends ThemeExtension<IxSidebarTheme> {
  const IxSidebarTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.dividerColor,
    required this.focusOutlineColor,
    required this.sectionHeaderTextStyle,
    required this.itemTextStyle,
    required this.itemBackground,
    required this.itemForeground,
    required this.itemIconColor,
    required this.width,
    required this.navigationRailTheme,
  });

  /// Builds the sidebar theme from Siemens IX palette + typography tokens.
  factory IxSidebarTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    WidgetStateProperty<Color?> stateColor({
      required Color base,
      Color? hovered,
      Color? focused,
      Color? pressed,
      Color? selected,
      Color? disabled,
    }) {
      return WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabled ?? base;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressed ?? hovered ?? base;
        }
        if (states.contains(WidgetState.selected)) {
          return selected ?? base;
        }
        if (states.contains(WidgetState.hovered)) {
          return hovered ?? base;
        }
        if (states.contains(WidgetState.focused)) {
          return focused ?? hovered ?? base;
        }
        return base;
      });
    }

    final background = color(IxThemeColorToken.color2);
    final border = color(IxThemeColorToken.softBdr);
    final divider = color(IxThemeColorToken.weakBdr);
    final focusOutline = color(IxThemeColorToken.focusBdr);
    const width = 280.0;

    final sectionHeaderStyle = typography.labelSm.copyWith(
      color: color(IxThemeColorToken.softText),
      fontWeight: FontWeight.w600,
    );

    final itemTextStyle = typography.body.copyWith(
      color: color(IxThemeColorToken.softText),
      fontWeight: FontWeight.w500,
    );

    final itemBackground = stateColor(
      base: color(IxThemeColorToken.color0),
      hovered: color(IxThemeColorToken.component1Hover),
      focused: color(IxThemeColorToken.component1Active),
      pressed: color(IxThemeColorToken.component7),
      selected: color(IxThemeColorToken.ghostSelected),
      disabled: color(IxThemeColorToken.color0),
    );

    final itemForeground = stateColor(
      base: color(IxThemeColorToken.softText),
      hovered: color(IxThemeColorToken.stdText),
      focused: color(IxThemeColorToken.stdText),
      selected: color(IxThemeColorToken.primary),
      disabled: color(IxThemeColorToken.weakText),
    );

    final itemIconColor = stateColor(
      base: color(IxThemeColorToken.softText),
      hovered: color(IxThemeColorToken.stdText),
      selected: color(IxThemeColorToken.primary),
      disabled: color(IxThemeColorToken.weakText),
    );

    final navigationRailTheme = NavigationRailThemeData(
      backgroundColor: background,
      elevation: 0,
      indicatorColor: color(IxThemeColorToken.ghostSelected),
      indicatorShape: const StadiumBorder(),
      useIndicator: true,
      selectedIconTheme: IconThemeData(
        color: color(IxThemeColorToken.primary),
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: color(IxThemeColorToken.softText),
        size: 24,
      ),
      selectedLabelTextStyle: typography.label.copyWith(
        color: color(IxThemeColorToken.primary),
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: typography.label.copyWith(
        color: color(IxThemeColorToken.softText),
      ),
      groupAlignment: -1,
      minExtendedWidth: 240,
    );

    return IxSidebarTheme(
      backgroundColor: background,
      borderColor: border,
      dividerColor: divider,
      focusOutlineColor: focusOutline,
      sectionHeaderTextStyle: sectionHeaderStyle,
      itemTextStyle: itemTextStyle,
      itemBackground: itemBackground,
      itemForeground: itemForeground,
      itemIconColor: itemIconColor,
      width: width,
      navigationRailTheme: navigationRailTheme,
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final Color dividerColor;
  final Color focusOutlineColor;
  final TextStyle sectionHeaderTextStyle;
  final TextStyle itemTextStyle;
  final WidgetStateProperty<Color?> itemBackground;
  final WidgetStateProperty<Color?> itemForeground;
  final WidgetStateProperty<Color?> itemIconColor;
  final double width;
  final NavigationRailThemeData navigationRailTheme;

  @override
  IxSidebarTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? dividerColor,
    Color? focusOutlineColor,
    TextStyle? sectionHeaderTextStyle,
    TextStyle? itemTextStyle,
    WidgetStateProperty<Color?>? itemBackground,
    WidgetStateProperty<Color?>? itemForeground,
    WidgetStateProperty<Color?>? itemIconColor,
    double? width,
    NavigationRailThemeData? navigationRailTheme,
  }) {
    return IxSidebarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      focusOutlineColor: focusOutlineColor ?? this.focusOutlineColor,
      sectionHeaderTextStyle:
          sectionHeaderTextStyle ?? this.sectionHeaderTextStyle,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemBackground: itemBackground ?? this.itemBackground,
      itemForeground: itemForeground ?? this.itemForeground,
      itemIconColor: itemIconColor ?? this.itemIconColor,
      width: width ?? this.width,
      navigationRailTheme: navigationRailTheme ?? this.navigationRailTheme,
    );
  }

  @override
  IxSidebarTheme lerp(ThemeExtension<IxSidebarTheme>? other, double t) {
    if (other is! IxSidebarTheme) {
      return this;
    }

    WidgetStateProperty<Color?> blendProperty(
      WidgetStateProperty<Color?> a,
      WidgetStateProperty<Color?> b,
    ) {
      return t < 0.5 ? a : b;
    }

    return IxSidebarTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      dividerColor:
          Color.lerp(dividerColor, other.dividerColor, t) ?? dividerColor,
      focusOutlineColor:
          Color.lerp(focusOutlineColor, other.focusOutlineColor, t) ??
          focusOutlineColor,
      sectionHeaderTextStyle:
          TextStyle.lerp(
            sectionHeaderTextStyle,
            other.sectionHeaderTextStyle,
            t,
          ) ??
          sectionHeaderTextStyle,
      itemTextStyle:
          TextStyle.lerp(itemTextStyle, other.itemTextStyle, t) ??
          itemTextStyle,
      itemBackground: blendProperty(itemBackground, other.itemBackground),
      itemForeground: blendProperty(itemForeground, other.itemForeground),
      itemIconColor: blendProperty(itemIconColor, other.itemIconColor),
      width: lerpDouble(width, other.width, t) ?? width,
      navigationRailTheme:
          NavigationRailThemeData.lerp(
            navigationRailTheme,
            other.navigationRailTheme,
            t,
          ) ??
          navigationRailTheme,
    );
  }
}
