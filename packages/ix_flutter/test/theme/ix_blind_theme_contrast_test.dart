import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_dark_colors.dart';

/// Manual-testing regression (Android, dark theme, Blind example page): the
/// `warning` and `success` variants rendered with the same bright cyan
/// background and white text, unreadable, instead of upstream's amber and
/// green (each with its own dark, high-contrast text); `info` and
/// `critical` were off too. Root cause: `IxBlindTheme.fromPalette` was
/// never added to `IxThemeBuilder.build()`'s `extensions:` list (see
/// `test/theme/theme_wiring_test.dart`'s "IxBlindTheme is wired into
/// ThemeData"), so every blind silently used `IxBlindTheme.fallback`'s
/// generic Material-role approximation (`ColorScheme.secondary`/`.tertiary`,
/// which the dark classic palette's `_buildColorScheme` both derive from the
/// iX "dynamic"/"dynamic-alt" accent tokens -- themselves defined as the
/// *same* color upstream, `--theme-color-dynamic` ==
/// `--theme-color-dynamic-alt` in `test/fixtures/upstream_classic_dark.json`
/// -- which is why `warning` and `success` looked identical).
///
/// This file checks the *wired* result: every [IxBlindVariant]'s resolved
/// [IxBlindStyle] (background, foreground) against the upstream mapping in
/// `blind.scss` -- each status variant's header background comes from
/// `--theme-color-{variant}` and its title/subtitle color from
/// `--theme-color-{variant}--contrast`, while `filled`/`outline` use
/// `std-text`/`soft-text` instead -- for WCAG AA contrast and for using the
/// exact tokens upstream does.
///
/// `IxBlindStyle` has one `foreground` used for both the header title and
/// subtitle (see `_IxBlindHeader.build` in `lib/src/widgets/ix_blind.dart`);
/// it does not, and cannot, govern a `child`'s own content text, which is
/// arbitrary consumer-supplied `Widget` content (unlike upstream's HTML
/// slot, nothing here cascades a color onto it). The contrast check below
/// therefore covers the header title/subtitle pairing -- the only
/// foreground/background pair this component actually controls.
void main() {
  final lightTheme = const IxThemeBuilder.light().build();
  final darkTheme = const IxThemeBuilder.dark().build();

  group('IxBlindTheme.fromPalette header contrast (WCAG AA, >= 4.5:1)', () {
    for (final entry in {'light': lightTheme, 'dark': darkTheme}.entries) {
      final brightnessName = entry.key;
      final theme = entry.value;
      final blindTheme = theme.extension<IxBlindTheme>();
      final pageBackground = theme.scaffoldBackgroundColor;

      for (final variant in IxBlindVariant.values) {
        test('$brightnessName ${variant.name}', () {
          expect(
            blindTheme,
            isNotNull,
            reason:
                'IxBlindTheme must be wired into IxThemeBuilder.build() '
                '(extensions: list) for a blind to use the correct, '
                'upstream-aligned per-variant colors instead of '
                'IxBlindTheme.fallback\'s generic approximation.',
          );
          final style = blindTheme!.style(variant);

          // Both `background` and `foreground` tokens can carry alpha (e.g.
          // `outline`'s `ghost` background is fully transparent, `stdText`
          // is ~90% opaque), so composite each on top of what is actually
          // behind it -- the scaffold background, then the (now opaque)
          // resolved background -- before measuring contrast, the same way
          // the engine paints them.
          final effectiveBackground = _over(style.background, pageBackground);
          final effectiveForeground = _over(
            style.foreground,
            effectiveBackground,
          );
          final ratio = _contrastRatio(
            effectiveForeground,
            effectiveBackground,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                '$brightnessName ${variant.name}: header foreground '
                '${style.foreground} on background ${style.background} '
                '(effective $effectiveForeground on $effectiveBackground) '
                'is only ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }
  });

  test('dark warning and success backgrounds differ from each other and from '
      'info (they collided under the fallback: both resolved to the '
      '"dynamic"/"dynamic-alt" cyan accent, which upstream defines as the '
      'same color)', () {
    final blindTheme = darkTheme.extension<IxBlindTheme>();
    expect(blindTheme, isNotNull);
    final warningBg = blindTheme!.style(IxBlindVariant.warning).background;
    final successBg = blindTheme.style(IxBlindVariant.success).background;
    final infoBg = blindTheme.style(IxBlindVariant.info).background;

    expect(warningBg, isNot(successBg));
    expect(warningBg, isNot(infoBg));
    expect(successBg, isNot(infoBg));
  });

  test(
    'dark warning/success/info/critical resolve to the exact upstream '
    'tokens (background + --contrast foreground), not an approximation -- '
    'the token *values* themselves are covered exhaustively by '
    'palette_parity_test.dart against test/fixtures/upstream_classic_dark.json',
    () {
      final blindTheme = darkTheme.extension<IxBlindTheme>();
      expect(blindTheme, isNotNull);

      void expectVariant(
        IxBlindVariant variant,
        Color background,
        Color foreground,
      ) {
        final style = blindTheme!.style(variant);
        expect(style.background, background, reason: '${variant.name} bg');
        expect(style.foreground, foreground, reason: '${variant.name} fg');
      }

      expectVariant(
        IxBlindVariant.warning,
        IxClassicDarkColors.warning,
        IxClassicDarkColors.warningContrast,
      );
      expectVariant(
        IxBlindVariant.success,
        IxClassicDarkColors.success,
        IxClassicDarkColors.successContrast,
      );
      expectVariant(
        IxBlindVariant.info,
        IxClassicDarkColors.info,
        IxClassicDarkColors.infoContrast,
      );
      expectVariant(
        IxBlindVariant.critical,
        IxClassicDarkColors.critical,
        IxClassicDarkColors.criticalContrast,
      );
    },
  );
}

/// Alpha-composites [top] over an opaque [base] ("source-over" blending),
/// the same operation the engine performs when painting a translucent color
/// over whatever is already on screen. [base] is assumed fully opaque
/// (true of every page/scaffold background token this file uses as a base).
Color _over(Color top, Color base) {
  final a = top.a;
  double mix(double t, double b) => t * a + b * (1 - a);
  return Color.from(
    alpha: 1.0,
    red: mix(top.r, base.r),
    green: mix(top.g, base.g),
    blue: mix(top.b, base.b),
  );
}

/// WCAG 2.x relative luminance of an opaque sRGB color.
/// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
double _relativeLuminance(Color color) {
  double linearize(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}

/// WCAG 2.x contrast ratio between two opaque colors, from 1:1 to 21:1.
/// https://www.w3.org/TR/WCAG21/#dfn-contrast-ratio
double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a) + 0.05;
  final lb = _relativeLuminance(b) + 0.05;
  return la > lb ? la / lb : lb / la;
}
