import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

/// Enumerates supported Siemens IX chip variants.
enum IxChipVariant { standard, outline, primary, primaryOutline }

/// Enumerates semantic Siemens IX chip statuses.
enum IxChipStatus { alarm, critical, warning, info, neutral, success }

/// Describes the resolved colors for a Siemens IX chip treatment.
class IxChipStyle {
  const IxChipStyle({
    required this.background,
    required this.hoverBackground,
    required this.activeBackground,
    required this.foreground,
    required this.borderColor,
    required this.closeBackground,
    required this.closeForeground,
    required this.closeHoverBackground,
    required this.closeActiveBackground,
  });

  final Color background;
  final Color hoverBackground;
  final Color activeBackground;
  final Color foreground;
  final Color borderColor;
  final Color closeBackground;
  final Color closeForeground;
  final Color closeHoverBackground;
  final Color closeActiveBackground;

  IxChipStyle copyWith({
    Color? background,
    Color? hoverBackground,
    Color? activeBackground,
    Color? foreground,
    Color? borderColor,
    Color? closeBackground,
    Color? closeForeground,
    Color? closeHoverBackground,
    Color? closeActiveBackground,
  }) {
    return IxChipStyle(
      background: background ?? this.background,
      hoverBackground: hoverBackground ?? this.hoverBackground,
      activeBackground: activeBackground ?? this.activeBackground,
      foreground: foreground ?? this.foreground,
      borderColor: borderColor ?? this.borderColor,
      closeBackground: closeBackground ?? this.closeBackground,
      closeForeground: closeForeground ?? this.closeForeground,
      closeHoverBackground: closeHoverBackground ?? this.closeHoverBackground,
      closeActiveBackground:
          closeActiveBackground ?? this.closeActiveBackground,
    );
  }

  static IxChipStyle lerp(IxChipStyle a, IxChipStyle b, double t) {
    return IxChipStyle(
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      hoverBackground:
          Color.lerp(a.hoverBackground, b.hoverBackground, t) ??
          a.hoverBackground,
      activeBackground:
          Color.lerp(a.activeBackground, b.activeBackground, t) ??
          a.activeBackground,
      foreground: Color.lerp(a.foreground, b.foreground, t) ?? a.foreground,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t) ?? a.borderColor,
      closeBackground:
          Color.lerp(a.closeBackground, b.closeBackground, t) ??
          a.closeBackground,
      closeForeground:
          Color.lerp(a.closeForeground, b.closeForeground, t) ??
          a.closeForeground,
      closeHoverBackground:
          Color.lerp(a.closeHoverBackground, b.closeHoverBackground, t) ??
          a.closeHoverBackground,
      closeActiveBackground:
          Color.lerp(a.closeActiveBackground, b.closeActiveBackground, t) ??
          a.closeActiveBackground,
    );
  }
}

/// Theme extension that exposes Siemens IX chip styling primitives.
class IxChipTheme extends ThemeExtension<IxChipTheme> {
  const IxChipTheme({
    required this.materialChipTheme,
    required this.standard,
    required this.outline,
    required this.primary,
    required this.primaryOutline,
    required this.status,
    required this.statusOutline,
  });

  factory IxChipTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color resolve(IxThemeColorToken token) => palette[token]!;

    IxChipStyle baseStyle({
      required IxThemeColorToken background,
      required IxThemeColorToken hover,
      required IxThemeColorToken active,
      required IxThemeColorToken foreground,
      IxThemeColorToken? border,
      IxThemeColorToken? closeBackground,
      IxThemeColorToken? closeForeground,
      IxThemeColorToken? closeHoverBackground,
      IxThemeColorToken? closeActiveBackground,
    }) {
      return IxChipStyle(
        background: resolve(background),
        hoverBackground: resolve(hover),
        activeBackground: resolve(active),
        foreground: resolve(foreground),
        borderColor: border == null ? Colors.transparent : resolve(border),
        closeBackground: resolve(closeBackground ?? IxThemeColorToken.ghost),
        closeForeground: resolve(closeForeground ?? IxThemeColorToken.softText),
        closeHoverBackground: resolve(
          closeHoverBackground ?? IxThemeColorToken.ghostHover,
        ),
        closeActiveBackground: resolve(
          closeActiveBackground ?? IxThemeColorToken.ghostActive,
        ),
      );
    }

    const pillShape = StadiumBorder();
    final labelStyle = typography.label;

    final chipTheme = ChipThemeData(
      backgroundColor: resolve(IxThemeColorToken.component1),
      disabledColor: resolve(IxThemeColorToken.component4),
      selectedColor: resolve(IxThemeColorToken.component1Active),
      secondarySelectedColor: resolve(IxThemeColorToken.component1Hover),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: pillShape,
      side: const BorderSide(color: Colors.transparent, width: 0),
      labelStyle: labelStyle.copyWith(
        color: resolve(IxThemeColorToken.stdText),
      ),
      secondaryLabelStyle: labelStyle.copyWith(
        color: resolve(IxThemeColorToken.stdText),
      ),
      deleteIconColor: resolve(IxThemeColorToken.softText),
      brightness: Brightness.light,
      showCheckmark: false,
    );

    final standard = baseStyle(
      background: IxThemeColorToken.component1,
      hover: IxThemeColorToken.component1Hover,
      active: IxThemeColorToken.component1Active,
      foreground: IxThemeColorToken.stdText,
    );

    final outline = baseStyle(
      background: IxThemeColorToken.secondary,
      hover: IxThemeColorToken.color1Hover,
      active: IxThemeColorToken.color1Active,
      foreground: IxThemeColorToken.stdText,
      border: IxThemeColorToken.stdBdr,
    );

    final primary = baseStyle(
      background: IxThemeColorToken.primary,
      hover: IxThemeColorToken.primaryHover,
      active: IxThemeColorToken.primaryActive,
      foreground: IxThemeColorToken.primaryContrast,
      closeForeground: IxThemeColorToken.primaryContrast,
    );

    final primaryOutline = baseStyle(
      background: IxThemeColorToken.secondary,
      hover: IxThemeColorToken.secondaryHover,
      active: IxThemeColorToken.secondaryActive,
      foreground: IxThemeColorToken.primary,
      border: IxThemeColorToken.primary,
      closeForeground: IxThemeColorToken.primary,
    );

    const statusTokens = <IxChipStatus, _IxChipStatusTokens>{
      IxChipStatus.alarm: _IxChipStatusTokens(
        fill: IxThemeColorToken.alarm,
        hover: IxThemeColorToken.alarmHover,
        active: IxThemeColorToken.alarmActive,
        contrast: IxThemeColorToken.alarmContrast,
      ),
      IxChipStatus.critical: _IxChipStatusTokens(
        fill: IxThemeColorToken.critical,
        hover: IxThemeColorToken.criticalHover,
        active: IxThemeColorToken.criticalActive,
        contrast: IxThemeColorToken.criticalContrast,
      ),
      IxChipStatus.warning: _IxChipStatusTokens(
        fill: IxThemeColorToken.warning,
        hover: IxThemeColorToken.warningHover,
        active: IxThemeColorToken.warningActive,
        contrast: IxThemeColorToken.warningContrast,
      ),
      IxChipStatus.info: _IxChipStatusTokens(
        fill: IxThemeColorToken.info,
        hover: IxThemeColorToken.infoHover,
        active: IxThemeColorToken.infoActive,
        contrast: IxThemeColorToken.infoContrast,
      ),
      IxChipStatus.neutral: _IxChipStatusTokens(
        fill: IxThemeColorToken.neutral,
        hover: IxThemeColorToken.neutralHover,
        active: IxThemeColorToken.neutralActive,
        contrast: IxThemeColorToken.neutralContrast,
      ),
      IxChipStatus.success: _IxChipStatusTokens(
        fill: IxThemeColorToken.success,
        hover: IxThemeColorToken.successHover,
        active: IxThemeColorToken.successActive,
        contrast: IxThemeColorToken.successContrast,
      ),
    };

    IxChipStyle buildStatusStyle(_IxChipStatusTokens tokens) {
      return IxChipStyle(
        background: resolve(tokens.fill),
        hoverBackground: resolve(tokens.hover),
        activeBackground: resolve(tokens.active),
        foreground: resolve(tokens.contrast),
        borderColor: Colors.transparent,
        closeBackground: resolve(IxThemeColorToken.ghost),
        closeForeground: resolve(tokens.contrast),
        closeHoverBackground: resolve(IxThemeColorToken.ghostHover),
        closeActiveBackground: resolve(IxThemeColorToken.ghostActive),
      );
    }

    IxChipStyle buildStatusOutline(_IxChipStatusTokens tokens) {
      return IxChipStyle(
        background: resolve(IxThemeColorToken.secondary),
        hoverBackground: resolve(IxThemeColorToken.color1Hover),
        activeBackground: resolve(IxThemeColorToken.color1Active),
        foreground: resolve(IxThemeColorToken.stdText),
        borderColor: resolve(tokens.fill),
        closeBackground: resolve(IxThemeColorToken.ghost),
        closeForeground: resolve(IxThemeColorToken.stdText),
        closeHoverBackground: resolve(IxThemeColorToken.ghostHover),
        closeActiveBackground: resolve(IxThemeColorToken.ghostActive),
      );
    }

    final status = Map<IxChipStatus, IxChipStyle>.unmodifiable({
      for (final entry in statusTokens.entries)
        entry.key: buildStatusStyle(entry.value),
    });

    final statusOutline = Map<IxChipStatus, IxChipStyle>.unmodifiable({
      for (final entry in statusTokens.entries)
        entry.key: buildStatusOutline(entry.value),
    });

    return IxChipTheme(
      materialChipTheme: chipTheme,
      standard: standard,
      outline: outline,
      primary: primary,
      primaryOutline: primaryOutline,
      status: status,
      statusOutline: statusOutline,
    );
  }

  final ChipThemeData materialChipTheme;
  final IxChipStyle standard;
  final IxChipStyle outline;
  final IxChipStyle primary;
  final IxChipStyle primaryOutline;
  final Map<IxChipStatus, IxChipStyle> status;
  final Map<IxChipStatus, IxChipStyle> statusOutline;

  IxChipStyle variant(IxChipVariant variant) {
    switch (variant) {
      case IxChipVariant.standard:
        return standard;
      case IxChipVariant.outline:
        return outline;
      case IxChipVariant.primary:
        return primary;
      case IxChipVariant.primaryOutline:
        return primaryOutline;
    }
  }

  IxChipStyle statusStyle(IxChipStatus chipStatus, {bool outline = false}) {
    return outline
        ? statusOutline[chipStatus] ?? standard
        : status[chipStatus] ?? standard;
  }

  @override
  IxChipTheme copyWith({
    ChipThemeData? materialChipTheme,
    IxChipStyle? standard,
    IxChipStyle? outline,
    IxChipStyle? primary,
    IxChipStyle? primaryOutline,
    Map<IxChipStatus, IxChipStyle>? status,
    Map<IxChipStatus, IxChipStyle>? statusOutline,
  }) {
    return IxChipTheme(
      materialChipTheme: materialChipTheme ?? this.materialChipTheme,
      standard: standard ?? this.standard,
      outline: outline ?? this.outline,
      primary: primary ?? this.primary,
      primaryOutline: primaryOutline ?? this.primaryOutline,
      status: status ?? this.status,
      statusOutline: statusOutline ?? this.statusOutline,
    );
  }

  @override
  IxChipTheme lerp(ThemeExtension<IxChipTheme>? other, double t) {
    if (other is! IxChipTheme) {
      return this;
    }

    Map<IxChipStatus, IxChipStyle> lerpMap(
      Map<IxChipStatus, IxChipStyle> a,
      Map<IxChipStatus, IxChipStyle> b,
    ) {
      final keys = <IxChipStatus>{...a.keys, ...b.keys};
      return {
        for (final key in keys)
          key: IxChipStyle.lerp(a[key] ?? b[key]!, b[key] ?? a[key]!, t),
      };
    }

    return IxChipTheme(
      materialChipTheme:
          ChipThemeData.lerp(materialChipTheme, other.materialChipTheme, t) ??
          materialChipTheme,
      standard: IxChipStyle.lerp(standard, other.standard, t),
      outline: IxChipStyle.lerp(outline, other.outline, t),
      primary: IxChipStyle.lerp(primary, other.primary, t),
      primaryOutline: IxChipStyle.lerp(primaryOutline, other.primaryOutline, t),
      status: lerpMap(status, other.status),
      statusOutline: lerpMap(statusOutline, other.statusOutline),
    );
  }
}

class _IxChipStatusTokens {
  const _IxChipStatusTokens({
    required this.fill,
    required this.hover,
    required this.active,
    required this.contrast,
  });

  final IxThemeColorToken fill;
  final IxThemeColorToken hover;
  final IxThemeColorToken active;
  final IxThemeColorToken contrast;
}
