import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

/// Theme definition for the Siemens IX application menu overlay.
class IxAppMenuTheme extends ThemeExtension<IxAppMenuTheme> {
  const IxAppMenuTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.dividerColor,
    required this.shadowColor,
    required this.focusOutlineColor,
    required this.sectionHeaderTextStyle,
    required this.itemTextStyle,
    required this.itemDescriptionTextStyle,
    required this.itemBackground,
    required this.itemForeground,
    required this.itemIconColor,
    required this.badgeBackgroundColor,
    required this.badgeForegroundColor,
    required this.borderRadius,
    required this.menuTheme,
  });

  /// Builds the menu theme from Siemens IX palette + typography tokens.
  factory IxAppMenuTheme.fromPalette({
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
    final shadow = color(IxThemeColorToken.shadow2);
    final focusOutline = color(IxThemeColorToken.focusBdr);
    const borderRadius = 12.0;

    final sectionHeaderStyle = typography.labelSm.copyWith(
      color: color(IxThemeColorToken.softText),
      letterSpacing: typography.labelSm.letterSpacing,
      fontWeight: FontWeight.w600,
    );

    final itemTextStyle = typography.body.copyWith(
      color: color(IxThemeColorToken.stdText),
      fontWeight: FontWeight.w500,
    );

    final itemDescriptionStyle = typography.labelSm.copyWith(
      color: color(IxThemeColorToken.softText),
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
      base: color(IxThemeColorToken.stdText),
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

    final badgeBackground = color(IxThemeColorToken.component9);
    final badgeForeground = color(IxThemeColorToken.primaryContrast);

    final menuTheme = MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color?>(background),
        surfaceTintColor: const WidgetStatePropertyAll<Color?>(
          Colors.transparent,
        ),
        shadowColor: WidgetStatePropertyAll<Color?>(shadow),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry?>(
          EdgeInsets.symmetric(vertical: 8),
        ),
        side: WidgetStatePropertyAll<BorderSide?>(
          BorderSide(color: border, width: 1),
        ),
        shape: WidgetStatePropertyAll<OutlinedBorder?>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: border, width: 1),
          ),
        ),
        elevation: const WidgetStatePropertyAll<double?>(8),
      ),
    );

    return IxAppMenuTheme(
      backgroundColor: background,
      borderColor: border,
      dividerColor: divider,
      shadowColor: shadow,
      focusOutlineColor: focusOutline,
      sectionHeaderTextStyle: sectionHeaderStyle,
      itemTextStyle: itemTextStyle,
      itemDescriptionTextStyle: itemDescriptionStyle,
      itemBackground: itemBackground,
      itemForeground: itemForeground,
      itemIconColor: itemIconColor,
      badgeBackgroundColor: badgeBackground,
      badgeForegroundColor: badgeForeground,
      borderRadius: borderRadius,
      menuTheme: menuTheme,
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final Color dividerColor;
  final Color shadowColor;
  final Color focusOutlineColor;
  final TextStyle sectionHeaderTextStyle;
  final TextStyle itemTextStyle;
  final TextStyle itemDescriptionTextStyle;
  final WidgetStateProperty<Color?> itemBackground;
  final WidgetStateProperty<Color?> itemForeground;
  final WidgetStateProperty<Color?> itemIconColor;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;
  final double borderRadius;
  final MenuThemeData menuTheme;

  @override
  IxAppMenuTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    Color? dividerColor,
    Color? shadowColor,
    Color? focusOutlineColor,
    TextStyle? sectionHeaderTextStyle,
    TextStyle? itemTextStyle,
    TextStyle? itemDescriptionTextStyle,
    WidgetStateProperty<Color?>? itemBackground,
    WidgetStateProperty<Color?>? itemForeground,
    WidgetStateProperty<Color?>? itemIconColor,
    Color? badgeBackgroundColor,
    Color? badgeForegroundColor,
    double? borderRadius,
    MenuThemeData? menuTheme,
  }) {
    return IxAppMenuTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      shadowColor: shadowColor ?? this.shadowColor,
      focusOutlineColor: focusOutlineColor ?? this.focusOutlineColor,
      sectionHeaderTextStyle:
          sectionHeaderTextStyle ?? this.sectionHeaderTextStyle,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      itemDescriptionTextStyle:
          itemDescriptionTextStyle ?? this.itemDescriptionTextStyle,
      itemBackground: itemBackground ?? this.itemBackground,
      itemForeground: itemForeground ?? this.itemForeground,
      itemIconColor: itemIconColor ?? this.itemIconColor,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeForegroundColor: badgeForegroundColor ?? this.badgeForegroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      menuTheme: menuTheme ?? this.menuTheme,
    );
  }

  @override
  IxAppMenuTheme lerp(ThemeExtension<IxAppMenuTheme>? other, double t) {
    if (other is! IxAppMenuTheme) {
      return this;
    }

    WidgetStateProperty<Color?> blendProperty(
      WidgetStateProperty<Color?> a,
      WidgetStateProperty<Color?> b,
    ) {
      return t < 0.5 ? a : b;
    }

    return IxAppMenuTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      dividerColor:
          Color.lerp(dividerColor, other.dividerColor, t) ?? dividerColor,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
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
      itemDescriptionTextStyle:
          TextStyle.lerp(
            itemDescriptionTextStyle,
            other.itemDescriptionTextStyle,
            t,
          ) ??
          itemDescriptionTextStyle,
      itemBackground: blendProperty(itemBackground, other.itemBackground),
      itemForeground: blendProperty(itemForeground, other.itemForeground),
      itemIconColor: blendProperty(itemIconColor, other.itemIconColor),
      badgeBackgroundColor:
          Color.lerp(badgeBackgroundColor, other.badgeBackgroundColor, t) ??
          badgeBackgroundColor,
      badgeForegroundColor:
          Color.lerp(badgeForegroundColor, other.badgeForegroundColor, t) ??
          badgeForegroundColor,
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      menuTheme: MenuThemeData.lerp(menuTheme, other.menuTheme, t) ?? menuTheme,
    );
  }
}
