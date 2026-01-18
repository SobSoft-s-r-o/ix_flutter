import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';

const _badgeSmallSize = 16.0;
const _badgeLargeSize = 22.0;
const _badgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);
const _subtleBorderOpacity = 0.4;

/// Siemens IX semantic badge tones.
enum IxBadgeTone { neutral, info, success, warning, critical, alarm }

/// Resolved colors for a Siemens IX badge treatment.
class IxBadgeStyle {
  const IxBadgeStyle({
    required this.background,
    required this.foreground,
    required this.borderColor,
  });

  final Color background;
  final Color foreground;
  final Color borderColor;

  IxBadgeStyle copyWith({
    Color? background,
    Color? foreground,
    Color? borderColor,
  }) {
    return IxBadgeStyle(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  static IxBadgeStyle lerp(IxBadgeStyle a, IxBadgeStyle b, double t) {
    return IxBadgeStyle(
      background: Color.lerp(a.background, b.background, t) ?? a.background,
      foreground: Color.lerp(a.foreground, b.foreground, t) ?? a.foreground,
      borderColor: Color.lerp(a.borderColor, b.borderColor, t) ?? a.borderColor,
    );
  }
}

/// Theme extension that exposes Siemens IX badge primitives.
class IxBadgeTheme extends ThemeExtension<IxBadgeTheme> {
  const IxBadgeTheme({
    required this.materialBadgeTheme,
    required this.solid,
    required this.subtle,
  });

  factory IxBadgeTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    const toneTokens = <IxBadgeTone, _IxBadgeSemanticTokens>{
      IxBadgeTone.neutral: _IxBadgeSemanticTokens(
        solid: IxThemeColorToken.neutral,
        subtle: IxThemeColorToken.neutral40,
        contrast: IxThemeColorToken.neutralContrast,
      ),
      IxBadgeTone.info: _IxBadgeSemanticTokens(
        solid: IxThemeColorToken.info,
        subtle: IxThemeColorToken.info40,
        contrast: IxThemeColorToken.infoContrast,
      ),
      IxBadgeTone.success: _IxBadgeSemanticTokens(
        solid: IxThemeColorToken.success,
        subtle: IxThemeColorToken.success40,
        contrast: IxThemeColorToken.successContrast,
      ),
      IxBadgeTone.warning: _IxBadgeSemanticTokens(
        solid: IxThemeColorToken.warning,
        subtle: IxThemeColorToken.warning40,
        contrast: IxThemeColorToken.warningContrast,
      ),
      IxBadgeTone.critical: _IxBadgeSemanticTokens(
        solid: IxThemeColorToken.critical,
        subtle: IxThemeColorToken.critical40,
        contrast: IxThemeColorToken.criticalContrast,
      ),
      IxBadgeTone.alarm: _IxBadgeSemanticTokens(
        solid: IxThemeColorToken.alarm,
        subtle: IxThemeColorToken.alarm40,
        contrast: IxThemeColorToken.alarmContrast,
      ),
    };

    Map<IxBadgeTone, IxBadgeStyle> buildSolid() {
      return Map<IxBadgeTone, IxBadgeStyle>.unmodifiable({
        for (final entry in toneTokens.entries)
          entry.key: IxBadgeStyle(
            background: color(entry.value.solid),
            foreground: color(entry.value.contrast),
            borderColor: Colors.transparent,
          ),
      });
    }

    Map<IxBadgeTone, IxBadgeStyle> buildSubtle() {
      return Map<IxBadgeTone, IxBadgeStyle>.unmodifiable({
        for (final entry in toneTokens.entries)
          entry.key: IxBadgeStyle(
            background: color(entry.value.subtle),
            foreground: color(entry.value.solid),
            borderColor: color(
              entry.value.solid,
            ).withValues(alpha: _subtleBorderOpacity),
          ),
      });
    }

    final solidStyles = buildSolid();
    final subtleStyles = buildSubtle();
    final defaultStyle = solidStyles[IxBadgeTone.neutral]!;

    final badgeTheme = BadgeThemeData(
      backgroundColor: defaultStyle.background,
      textColor: defaultStyle.foreground,
      padding: _badgePadding,
      largeSize: _badgeLargeSize,
      smallSize: _badgeSmallSize,
      textStyle: typography.labelSm.copyWith(fontWeight: FontWeight.w600),
    );

    return IxBadgeTheme(
      materialBadgeTheme: badgeTheme,
      solid: solidStyles,
      subtle: subtleStyles,
    );
  }

  final BadgeThemeData materialBadgeTheme;
  final Map<IxBadgeTone, IxBadgeStyle> solid;
  final Map<IxBadgeTone, IxBadgeStyle> subtle;

  IxBadgeStyle style(IxBadgeTone tone, {bool subtle = false}) {
    if (subtle) {
      return this.subtle[tone] ?? solid[tone] ?? solid.values.first;
    }
    return solid[tone] ?? this.subtle[tone] ?? solid.values.first;
  }

  @override
  IxBadgeTheme copyWith({
    BadgeThemeData? materialBadgeTheme,
    Map<IxBadgeTone, IxBadgeStyle>? solid,
    Map<IxBadgeTone, IxBadgeStyle>? subtle,
  }) {
    return IxBadgeTheme(
      materialBadgeTheme: materialBadgeTheme ?? this.materialBadgeTheme,
      solid: solid ?? this.solid,
      subtle: subtle ?? this.subtle,
    );
  }

  @override
  IxBadgeTheme lerp(ThemeExtension<IxBadgeTheme>? other, double t) {
    if (other is! IxBadgeTheme) {
      return this;
    }

    Map<IxBadgeTone, IxBadgeStyle> lerpMap(
      Map<IxBadgeTone, IxBadgeStyle> a,
      Map<IxBadgeTone, IxBadgeStyle> b,
    ) {
      final keys = <IxBadgeTone>{...a.keys, ...b.keys};
      return {
        for (final key in keys)
          key: IxBadgeStyle.lerp(a[key] ?? b[key]!, b[key] ?? a[key]!, t),
      };
    }

    return IxBadgeTheme(
      materialBadgeTheme: BadgeThemeData.lerp(
        materialBadgeTheme,
        other.materialBadgeTheme,
        t,
      ),
      solid: lerpMap(solid, other.solid),
      subtle: lerpMap(subtle, other.subtle),
    );
  }
}

class _IxBadgeSemanticTokens {
  const _IxBadgeSemanticTokens({
    required this.solid,
    required this.subtle,
    required this.contrast,
  });

  final IxThemeColorToken solid;
  final IxThemeColorToken subtle;
  final IxThemeColorToken contrast;
}
