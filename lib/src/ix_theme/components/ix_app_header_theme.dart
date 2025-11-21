import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';

/// Theme definition for the Siemens IX top navigation (application header).
class IxAppHeaderTheme extends ThemeExtension<IxAppHeaderTheme> {
  const IxAppHeaderTheme({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.iconOutlineColor,
    required this.logoColor,
    required this.nameSuffixColor,
    required this.titleTextStyle,
    required this.appBarTheme,
  });

  /// Builds the theme from Siemens IX color + typography tokens.
  factory IxAppHeaderTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    final background = color(IxThemeColorToken.color2);
    final foreground = color(IxThemeColorToken.stdText);
    final borderColor = color(IxThemeColorToken.weakBdr);
    const borderWidth = 1.0;
    final iconOutlineColor = color(IxThemeColorToken.color8);
    final logoColor = color(IxThemeColorToken.logo);
    final nameSuffixColor = color(IxThemeColorToken.softText);
    final titleTextStyle = typography.body.copyWith(
      color: foreground,
      fontWeight: FontWeight.w600,
    );

    final appBarTheme = AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: foreground),
      actionsIconTheme: IconThemeData(color: foreground),
      titleTextStyle: titleTextStyle,
      toolbarHeight: 56,
      shape: Border(
        bottom: BorderSide(color: borderColor, width: borderWidth),
      ),
    );

    return IxAppHeaderTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      borderColor: borderColor,
      borderWidth: borderWidth,
      iconOutlineColor: iconOutlineColor,
      logoColor: logoColor,
      nameSuffixColor: nameSuffixColor,
      titleTextStyle: titleTextStyle,
      appBarTheme: appBarTheme,
    );
  }

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color iconOutlineColor;
  final Color logoColor;
  final Color nameSuffixColor;
  final TextStyle titleTextStyle;
  final AppBarTheme appBarTheme;

  @override
  IxAppHeaderTheme copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? borderWidth,
    Color? iconOutlineColor,
    Color? logoColor,
    Color? nameSuffixColor,
    TextStyle? titleTextStyle,
    AppBarTheme? appBarTheme,
  }) {
    return IxAppHeaderTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      iconOutlineColor: iconOutlineColor ?? this.iconOutlineColor,
      logoColor: logoColor ?? this.logoColor,
      nameSuffixColor: nameSuffixColor ?? this.nameSuffixColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      appBarTheme: appBarTheme ?? this.appBarTheme,
    );
  }

  @override
  IxAppHeaderTheme lerp(ThemeExtension<IxAppHeaderTheme>? other, double t) {
    if (other is! IxAppHeaderTheme) {
      return this;
    }

    return IxAppHeaderTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      foregroundColor:
          Color.lerp(foregroundColor, other.foregroundColor, t) ??
          foregroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      iconOutlineColor:
          Color.lerp(iconOutlineColor, other.iconOutlineColor, t) ??
          iconOutlineColor,
      logoColor: Color.lerp(logoColor, other.logoColor, t) ?? logoColor,
      nameSuffixColor:
          Color.lerp(nameSuffixColor, other.nameSuffixColor, t) ??
          nameSuffixColor,
      titleTextStyle:
          TextStyle.lerp(titleTextStyle, other.titleTextStyle, t) ??
          titleTextStyle,
      appBarTheme: AppBarTheme.lerp(appBarTheme, other.appBarTheme, t),
    );
  }
}
