import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';

const double _closeIconHoverBackgroundOpacity = 0.85;
const double _defaultMaxHeightFraction = 0.8;

enum IxModalSize { xs, sm, md, lg, xl, fullWidth, fullScreen }

const Map<IxModalSize, double> _modalFixedWidths = <IxModalSize, double>{
  IxModalSize.xs: IxCommonGeometry.container2,
  IxModalSize.sm: IxCommonGeometry.container3,
  IxModalSize.md: IxCommonGeometry.container4,
  IxModalSize.lg: IxCommonGeometry.container5,
  IxModalSize.xl: IxCommonGeometry.container6,
};

/// Captures layout hints for a concrete modal dialog size.
class IxModalSizeSpec {
  const IxModalSizeSpec({
    this.width,
    this.widthFactor,
    this.fullScreen = false,
    this.maxHeightFraction = _defaultMaxHeightFraction,
  }) : assert(
         width != null || widthFactor != null || fullScreen,
         'Provide a width, widthFactor, or mark the spec as fullScreen.',
       );

  final double? width;
  final double? widthFactor;
  final bool fullScreen;
  final double maxHeightFraction;

  IxModalSizeSpec copyWith({
    double? width,
    double? widthFactor,
    bool? fullScreen,
    double? maxHeightFraction,
  }) {
    return IxModalSizeSpec(
      width: width ?? this.width,
      widthFactor: widthFactor ?? this.widthFactor,
      fullScreen: fullScreen ?? this.fullScreen,
      maxHeightFraction: maxHeightFraction ?? this.maxHeightFraction,
    );
  }

  static IxModalSizeSpec lerp(IxModalSizeSpec a, IxModalSizeSpec b, double t) {
    return IxModalSizeSpec(
      width: lerpDouble(a.width, b.width, t),
      widthFactor: lerpDouble(a.widthFactor, b.widthFactor, t),
      fullScreen: t < 0.5 ? a.fullScreen : b.fullScreen,
      maxHeightFraction:
          lerpDouble(a.maxHeightFraction, b.maxHeightFraction, t) ??
          a.maxHeightFraction,
    );
  }
}

/// Theme extension that exposes Siemens IX modal dialog primitives.
class IxModalTheme extends ThemeExtension<IxModalTheme> {
  const IxModalTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.shadow,
    required this.backdropColor,
    required this.dialogPadding,
    required this.insetPadding,
    required this.headerPadding,
    required this.headerGap,
    required this.contentPadding,
    required this.footerPadding,
    required this.footerGap,
    required this.maxHeightFraction,
    required this.sizes,
    required this.elevation,
    required this.alignment,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.iconBackgroundColorHover,
    required this.closeIconBorderRadius,
    required this.titleTextStyle,
    required this.contentTextStyle,
    required this.barrierColor,
    required this.constraints,
  });

  factory IxModalTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final headerPadding = EdgeInsets.fromLTRB(
      IxCommonGeometry.space1,
      IxCommonGeometry.space1,
      0,
      IxCommonGeometry.space1,
    );
    final contentPadding = EdgeInsets.fromLTRB(
      IxCommonGeometry.space1,
      IxCommonGeometry.space1,
      IxCommonGeometry.space1,
      IxCommonGeometry.space1,
    );
    final footerPadding = EdgeInsets.all(IxCommonGeometry.space1);
    final dialogPadding = IxCommonGeometry.space3;
    final insetPadding = EdgeInsets.symmetric(
      horizontal: dialogPadding,
      vertical: dialogPadding,
    );
    final boxShadows = List<BoxShadow>.unmodifiable([
      BoxShadow(
        color: pick(IxThemeColorToken.shadow2).withValues(alpha: 0.9),
        blurRadius: 2,
        offset: Offset.zero,
      ),
      BoxShadow(
        color: pick(IxThemeColorToken.shadow1).withValues(alpha: 0.6),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: pick(IxThemeColorToken.shadow1).withValues(alpha: 0.6),
        blurRadius: 18,
        offset: const Offset(0, 12),
      ),
    ]);
    final constraints = BoxConstraints(
      minWidth: _modalFixedWidths[IxModalSize.xs]!,
      maxWidth: _modalFixedWidths[IxModalSize.xl]!,
    );
    final titleTextStyle = typography.h5.copyWith(
      color: pick(IxThemeColorToken.stdText),
    );
    final contentTextStyle = typography.body.copyWith(
      color: pick(IxThemeColorToken.stdText),
    );
    final closeIconBase = pick(IxThemeColorToken.shadow2);
    final closeIconBackground = pick(IxThemeColorToken.color0);
    final closeIconBackgroundHover = closeIconBase.withValues(
      alpha: _closeIconHoverBackgroundOpacity,
    );

    final sizes = <IxModalSize, IxModalSizeSpec>{
      for (final entry in _modalFixedWidths.entries)
        entry.key: IxModalSizeSpec(width: entry.value),
      IxModalSize.fullWidth: const IxModalSizeSpec(widthFactor: 0.95),
      IxModalSize.fullScreen: const IxModalSizeSpec(
        widthFactor: 1,
        fullScreen: true,
        maxHeightFraction: 1,
      ),
    };

    return IxModalTheme(
      backgroundColor: pick(IxThemeColorToken.color2),
      borderColor: pick(IxThemeColorToken.color0),
      borderWidth: IxCommonGeometry.borderWidthDefault,
      borderRadius: IxCommonGeometry.defaultBorderRadius,
      shadow: boxShadows,
      backdropColor: pick(IxThemeColorToken.lightbox),
      dialogPadding: dialogPadding,
      insetPadding: insetPadding,
      headerPadding: headerPadding,
      headerGap: IxCommonGeometry.space3,
      contentPadding: contentPadding,
      footerPadding: footerPadding,
      footerGap: IxCommonGeometry.space1,
      maxHeightFraction: _defaultMaxHeightFraction,
      sizes: Map<IxModalSize, IxModalSizeSpec>.unmodifiable(sizes),
      elevation: 24,
      alignment: Alignment.center,
      iconColor: pick(IxThemeColorToken.stdText),
      iconBackgroundColor: closeIconBackground,
      iconBackgroundColorHover: closeIconBackgroundHover,
      closeIconBorderRadius: IxCommonGeometry.defaultBorderRadius,
      titleTextStyle: titleTextStyle,
      contentTextStyle: contentTextStyle,
      barrierColor: pick(IxThemeColorToken.lightbox),
      constraints: constraints,
    );
  }

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final List<BoxShadow> shadow;
  final Color backdropColor;
  final double dialogPadding;
  final EdgeInsets insetPadding;
  final EdgeInsets headerPadding;
  final double headerGap;
  final EdgeInsets contentPadding;
  final EdgeInsets footerPadding;
  final double footerGap;
  final double maxHeightFraction;
  final Map<IxModalSize, IxModalSizeSpec> sizes;
  final double elevation;
  final AlignmentGeometry alignment;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color iconBackgroundColorHover;
  final double closeIconBorderRadius;
  final TextStyle titleTextStyle;
  final TextStyle contentTextStyle;
  final Color barrierColor;
  final BoxConstraints constraints;

  IxModalSizeSpec size(IxModalSize modalSize) {
    return sizes[modalSize] ?? sizes[IxModalSize.md]!;
  }

  @override
  IxModalTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    List<BoxShadow>? shadow,
    Color? backdropColor,
    double? dialogPadding,
    EdgeInsets? insetPadding,
    EdgeInsets? headerPadding,
    double? headerGap,
    EdgeInsets? contentPadding,
    EdgeInsets? footerPadding,
    double? footerGap,
    double? maxHeightFraction,
    Map<IxModalSize, IxModalSizeSpec>? sizes,
    double? elevation,
    AlignmentGeometry? alignment,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? iconBackgroundColorHover,
    double? closeIconBorderRadius,
    TextStyle? titleTextStyle,
    TextStyle? contentTextStyle,
    Color? barrierColor,
    BoxConstraints? constraints,
  }) {
    return IxModalTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
      backdropColor: backdropColor ?? this.backdropColor,
      dialogPadding: dialogPadding ?? this.dialogPadding,
      insetPadding: insetPadding ?? this.insetPadding,
      headerPadding: headerPadding ?? this.headerPadding,
      headerGap: headerGap ?? this.headerGap,
      contentPadding: contentPadding ?? this.contentPadding,
      footerPadding: footerPadding ?? this.footerPadding,
      footerGap: footerGap ?? this.footerGap,
      maxHeightFraction: maxHeightFraction ?? this.maxHeightFraction,
      sizes: sizes ?? this.sizes,
      elevation: elevation ?? this.elevation,
      alignment: alignment ?? this.alignment,
      iconColor: iconColor ?? this.iconColor,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconBackgroundColorHover:
          iconBackgroundColorHover ?? this.iconBackgroundColorHover,
      closeIconBorderRadius:
          closeIconBorderRadius ?? this.closeIconBorderRadius,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      contentTextStyle: contentTextStyle ?? this.contentTextStyle,
      barrierColor: barrierColor ?? this.barrierColor,
      constraints: constraints ?? this.constraints,
    );
  }

  @override
  IxModalTheme lerp(ThemeExtension<IxModalTheme>? other, double t) {
    if (other is! IxModalTheme) {
      return this;
    }

    final blendedSizes = <IxModalSize, IxModalSizeSpec>{};
    final keys = <IxModalSize>{...sizes.keys, ...other.sizes.keys};
    for (final key in keys) {
      final first = sizes[key] ?? other.sizes[key]!;
      final second = other.sizes[key] ?? sizes[key]!;
      blendedSizes[key] = IxModalSizeSpec.lerp(first, second, t);
    }

    return IxModalTheme(
      backgroundColor:
          Color.lerp(backgroundColor, other.backgroundColor, t) ??
          backgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      borderRadius:
          lerpDouble(borderRadius, other.borderRadius, t) ?? borderRadius,
      shadow: BoxShadow.lerpList(shadow, other.shadow, t) ?? shadow,
      backdropColor:
          Color.lerp(backdropColor, other.backdropColor, t) ?? backdropColor,
      dialogPadding:
          lerpDouble(dialogPadding, other.dialogPadding, t) ?? dialogPadding,
      insetPadding:
          EdgeInsets.lerp(insetPadding, other.insetPadding, t) ?? insetPadding,
      headerPadding:
          EdgeInsets.lerp(headerPadding, other.headerPadding, t) ??
          headerPadding,
      headerGap: lerpDouble(headerGap, other.headerGap, t) ?? headerGap,
      contentPadding:
          EdgeInsets.lerp(contentPadding, other.contentPadding, t) ??
          contentPadding,
      footerPadding:
          EdgeInsets.lerp(footerPadding, other.footerPadding, t) ??
          footerPadding,
      footerGap: lerpDouble(footerGap, other.footerGap, t) ?? footerGap,
      maxHeightFraction:
          lerpDouble(maxHeightFraction, other.maxHeightFraction, t) ??
          maxHeightFraction,
      sizes: Map<IxModalSize, IxModalSizeSpec>.unmodifiable(blendedSizes),
      elevation: lerpDouble(elevation, other.elevation, t) ?? elevation,
      alignment:
          AlignmentGeometry.lerp(alignment, other.alignment, t) ?? alignment,
      iconColor: Color.lerp(iconColor, other.iconColor, t) ?? iconColor,
      iconBackgroundColor:
          Color.lerp(iconBackgroundColor, other.iconBackgroundColor, t) ??
          iconBackgroundColor,
      iconBackgroundColorHover:
          Color.lerp(
            iconBackgroundColorHover,
            other.iconBackgroundColorHover,
            t,
          ) ??
          iconBackgroundColorHover,
      closeIconBorderRadius:
          lerpDouble(closeIconBorderRadius, other.closeIconBorderRadius, t) ??
          closeIconBorderRadius,
      titleTextStyle:
          TextStyle.lerp(titleTextStyle, other.titleTextStyle, t) ??
          titleTextStyle,
      contentTextStyle:
          TextStyle.lerp(contentTextStyle, other.contentTextStyle, t) ??
          contentTextStyle,
      barrierColor:
          Color.lerp(barrierColor, other.barrierColor, t) ?? barrierColor,
      constraints:
          BoxConstraints.lerp(constraints, other.constraints, t) ?? constraints,
    );
  }
}
