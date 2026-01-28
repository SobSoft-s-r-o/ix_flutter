import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_card_theme.dart';

/// Theme extension that exposes Siemens IX styling for bottom sheets.
class IxBottomSheetTheme extends ThemeExtension<IxBottomSheetTheme> {
  const IxBottomSheetTheme({
    required this.materialBottomSheetTheme,
    required this.dragHandleColor,
    required this.elevation,
    required this.modalElevation,
  });

  factory IxBottomSheetTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxCardTheme cardTheme,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(cardTheme.borderRadius),
        topRight: Radius.circular(cardTheme.borderRadius),
      ),
      side: BorderSide.none,
    );

    final theme = BottomSheetThemeData(
      backgroundColor: pick(IxThemeColorToken.color3),
      modalBackgroundColor: pick(IxThemeColorToken.color3),
      surfaceTintColor: Colors.transparent,
      shadowColor: pick(IxThemeColorToken.shadow2),
      showDragHandle: false,
      dragHandleColor: pick(IxThemeColorToken.softBdr),
      elevation: 24,
      modalElevation: 28,
      clipBehavior: Clip.antiAlias,
      shape: shape,
    );

    return IxBottomSheetTheme(
      materialBottomSheetTheme: theme,
      dragHandleColor: pick(IxThemeColorToken.softBdr),
      elevation: 24,
      modalElevation: 28,
    );
  }

  final BottomSheetThemeData materialBottomSheetTheme;
  final Color dragHandleColor;
  final double elevation;
  final double modalElevation;

  @override
  IxBottomSheetTheme copyWith({
    BottomSheetThemeData? materialBottomSheetTheme,
    Color? dragHandleColor,
    double? elevation,
    double? modalElevation,
  }) {
    return IxBottomSheetTheme(
      materialBottomSheetTheme:
          materialBottomSheetTheme ?? this.materialBottomSheetTheme,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      elevation: elevation ?? this.elevation,
      modalElevation: modalElevation ?? this.modalElevation,
    );
  }

  @override
  IxBottomSheetTheme lerp(ThemeExtension<IxBottomSheetTheme>? other, double t) {
    if (other is! IxBottomSheetTheme) {
      return this;
    }

    return IxBottomSheetTheme(
      materialBottomSheetTheme:
          BottomSheetThemeData.lerp(
            materialBottomSheetTheme,
            other.materialBottomSheetTheme,
            t,
          ) ??
          materialBottomSheetTheme,
      dragHandleColor:
          Color.lerp(dragHandleColor, other.dragHandleColor, t) ??
          dragHandleColor,
      elevation: lerpDouble(elevation, other.elevation, t) ?? elevation,
      modalElevation:
          lerpDouble(modalElevation, other.modalElevation, t) ?? modalElevation,
    );
  }
}
