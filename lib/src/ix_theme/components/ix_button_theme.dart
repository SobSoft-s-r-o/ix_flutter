import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';

/// Enumerates the Siemens IX button variants.
enum IxButtonVariant {
  primary,
  secondary,
  tertiary,
  subtlePrimary,
  subtleSecondary,
  subtleTertiary,
  dangerPrimary,
  dangerSecondary,
  dangerTertiary,
  warningPrimary,
  warningSecondary,
  warningTertiary,
  infoPrimary,
  infoSecondary,
  infoTertiary,
  successPrimary,
  successSecondary,
  successTertiary,
}

/// Theme extension that surfaces Siemens IX button styles.
class IxButtonTheme extends ThemeExtension<IxButtonTheme> {
  const IxButtonTheme({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.subtlePrimary,
    required this.subtleSecondary,
    required this.subtleTertiary,
    required this.dangerPrimary,
    required this.dangerSecondary,
    required this.dangerTertiary,
    required this.warningPrimary,
    required this.warningSecondary,
    required this.warningTertiary,
    required this.infoPrimary,
    required this.infoSecondary,
    required this.infoTertiary,
    required this.successPrimary,
    required this.successSecondary,
    required this.successTertiary,
  });

  /// Generates Siemens IX button styles from the resolved color palette.
  factory IxButtonTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
    required IxTypography typography,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    const basePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    const baseShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
    final labelStyle = typography.label;

    ButtonStyle baseStyle({
      required WidgetStateProperty<Color?> background,
      required WidgetStateProperty<Color?> foreground,
      WidgetStateProperty<Color?>? overlay,
      WidgetStateProperty<BorderSide?>? side,
      WidgetStateProperty<Color?>? shadow,
    }) {
      return ButtonStyle(
        textStyle: WidgetStatePropertyAll<TextStyle?>(labelStyle),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry?>(basePadding),
        minimumSize: const WidgetStatePropertyAll<Size?>(Size(64, 40)),
        shape: const WidgetStatePropertyAll<OutlinedBorder?>(baseShape),
        backgroundColor: background,
        foregroundColor: foreground,
        iconColor: foreground,
        overlayColor: overlay,
        side: side,
        surfaceTintColor: const WidgetStatePropertyAll<Color?>(
          Colors.transparent,
        ),
        shadowColor:
            shadow ??
            WidgetStatePropertyAll<Color?>(color(IxThemeColorToken.shadow1)),
        elevation: const WidgetStatePropertyAll<double?>(0),
        animationDuration: kThemeAnimationDuration,
      );
    }

    WidgetStateProperty<Color?> colorStates({
      required Color base,
      Color? hovered,
      Color? focused,
      Color? pressed,
      Color? disabled,
    }) {
      return WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabled ?? base;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressed ?? hovered ?? base;
        }
        if (states.contains(WidgetState.hovered)) {
          return hovered ?? base;
        }
        if (states.contains(WidgetState.focused)) {
          return focused ?? base;
        }
        return base;
      });
    }

    WidgetStateProperty<BorderSide?> borderStates({
      BorderSide? base,
      BorderSide? hovered,
      BorderSide? focused,
      BorderSide? pressed,
      BorderSide? disabled,
    }) {
      return WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabled ?? base;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressed ?? hovered ?? base;
        }
        if (states.contains(WidgetState.hovered)) {
          return hovered ?? base;
        }
        if (states.contains(WidgetState.focused)) {
          return focused ?? base;
        }
        return base;
      });
    }

    WidgetStateProperty<Color?> overlayStates({
      Color base = Colors.transparent,
      Color? hovered,
      Color? focused,
      Color? pressed,
    }) {
      return WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressed ?? hovered ?? base;
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

    BorderSide transparentSide() => const BorderSide(color: Colors.transparent);

    BorderSide border(Color value, {double width = 1}) =>
        BorderSide(color: value, width: width);

    final hoverOverlay = overlayStates(
      hovered: color(IxThemeColorToken.component1Hover),
      focused: color(IxThemeColorToken.component1Active),
      pressed: color(IxThemeColorToken.component1Active),
    );

    final primary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.primary),
        hovered: color(IxThemeColorToken.primaryHover),
        focused: color(IxThemeColorToken.primaryActive),
        pressed: color(IxThemeColorToken.dynamic),
        disabled: color(IxThemeColorToken.component4),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.primaryContrast),
        disabled: color(IxThemeColorToken.primaryContrast),
      ),
      overlay: hoverOverlay,
      side: borderStates(base: transparentSide()),
    );

    final secondary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.secondary),
        hovered: color(IxThemeColorToken.secondaryHover),
        focused: color(IxThemeColorToken.secondaryActive),
        pressed: color(IxThemeColorToken.component7),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.primary),
        hovered: color(IxThemeColorToken.dynamic),
        focused: color(IxThemeColorToken.dynamicActive),
        pressed: color(IxThemeColorToken.dynamic),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: hoverOverlay,
      side: borderStates(
        base: border(color(IxThemeColorToken.primary)),
        hovered: border(color(IxThemeColorToken.dynamic)),
        focused: border(color(IxThemeColorToken.dynamicActive)),
        pressed: border(color(IxThemeColorToken.dynamic)),
        disabled: border(color(IxThemeColorToken.component4)),
      ),
    );

    final tertiary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.secondaryHover),
        focused: color(IxThemeColorToken.secondaryActive),
        pressed: color(IxThemeColorToken.component7),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.primary),
        hovered: color(IxThemeColorToken.dynamic),
        focused: color(IxThemeColorToken.dynamicActive),
        pressed: color(IxThemeColorToken.dynamic),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: hoverOverlay,
      side: borderStates(base: transparentSide()),
    );

    final subtlePrimary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.component2),
        hovered: color(IxThemeColorToken.component1Hover),
        focused: color(IxThemeColorToken.component1Active),
        pressed: color(IxThemeColorToken.component7),
        disabled: color(IxThemeColorToken.component2),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.stdText),
        hovered: color(IxThemeColorToken.stdText),
        pressed: color(IxThemeColorToken.dynamic),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: hoverOverlay,
      side: borderStates(base: transparentSide()),
    );

    final subtleSecondary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.ghostHover),
        focused: color(IxThemeColorToken.ghostActive),
        pressed: color(IxThemeColorToken.component7),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.stdText),
        hovered: color(IxThemeColorToken.stdText),
        pressed: color(IxThemeColorToken.dynamic),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: hoverOverlay,
      side: borderStates(
        base: border(color(IxThemeColorToken.component4)),
        hovered: border(color(IxThemeColorToken.component4)),
        pressed: border(color(IxThemeColorToken.stdBdr)),
        disabled: border(color(IxThemeColorToken.component4)),
      ),
    );

    final subtleTertiary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.ghostHover),
        focused: color(IxThemeColorToken.ghostActive),
        pressed: color(IxThemeColorToken.component7),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.stdText),
        hovered: color(IxThemeColorToken.stdText),
        pressed: color(IxThemeColorToken.dynamic),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: hoverOverlay,
      side: borderStates(base: transparentSide()),
    );

    final dangerOverlay = overlayStates(
      hovered: color(IxThemeColorToken.componentError),
      pressed: color(IxThemeColorToken.componentError),
    );

    final dangerPrimary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.alarm),
        hovered: color(IxThemeColorToken.alarmHover),
        focused: color(IxThemeColorToken.alarmActive),
        pressed: color(IxThemeColorToken.alarmActive),
        disabled: color(IxThemeColorToken.component4),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.alarmContrast),
        disabled: color(IxThemeColorToken.primaryContrast),
      ),
      overlay: dangerOverlay,
      side: borderStates(base: transparentSide()),
    );

    final dangerSecondary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.color0),
        hovered: color(IxThemeColorToken.componentError),
        focused: color(IxThemeColorToken.componentError),
        pressed: color(IxThemeColorToken.componentError),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.alarmText),
        hovered: color(IxThemeColorToken.alarmText),
        pressed: color(IxThemeColorToken.alarmText),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: dangerOverlay,
      side: borderStates(
        base: border(color(IxThemeColorToken.alarmText)),
        hovered: border(color(IxThemeColorToken.alarmText)),
        focused: border(color(IxThemeColorToken.alarmText)),
        pressed: border(color(IxThemeColorToken.alarmText)),
        disabled: border(color(IxThemeColorToken.component4)),
      ),
    );

    final dangerTertiary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.componentError),
        focused: color(IxThemeColorToken.color0),
        pressed: color(IxThemeColorToken.componentError),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.alarmText),
        hovered: color(IxThemeColorToken.alarmText),
        pressed: color(IxThemeColorToken.alarmText),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: dangerOverlay,
      side: borderStates(base: transparentSide()),
    );

    final warningOverlay = overlayStates(
      hovered: color(IxThemeColorToken.warning40),
      pressed: color(IxThemeColorToken.warning40),
    );

    final warningPrimary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.warning),
        hovered: color(IxThemeColorToken.warningHover),
        focused: color(IxThemeColorToken.warningActive),
        pressed: color(IxThemeColorToken.warningActive),
        disabled: color(IxThemeColorToken.component4),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.warningContrast),
        disabled: color(IxThemeColorToken.primaryContrast),
      ),
      overlay: warningOverlay,
      side: borderStates(base: transparentSide()),
    );

    final warningSecondary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.color0),
        hovered: color(IxThemeColorToken.warning40),
        focused: color(IxThemeColorToken.warning40),
        pressed: color(IxThemeColorToken.warning40),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.warningText),
        hovered: color(IxThemeColorToken.warningText),
        pressed: color(IxThemeColorToken.warningText),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: warningOverlay,
      side: borderStates(
        base: border(color(IxThemeColorToken.warningBdr)),
        hovered: border(color(IxThemeColorToken.warningText)),
        focused: border(color(IxThemeColorToken.warningText)),
        pressed: border(color(IxThemeColorToken.warningText)),
        disabled: border(color(IxThemeColorToken.component4)),
      ),
    );

    final warningTertiary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.warning10),
        focused: color(IxThemeColorToken.warning10),
        pressed: color(IxThemeColorToken.warning40),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.warningText),
        hovered: color(IxThemeColorToken.warningText),
        pressed: color(IxThemeColorToken.warningText),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: warningOverlay,
      side: borderStates(base: transparentSide()),
    );

    final infoOverlay = overlayStates(
      hovered: color(IxThemeColorToken.info40),
      pressed: color(IxThemeColorToken.info40),
    );

    final infoPrimary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.info),
        hovered: color(IxThemeColorToken.infoHover),
        focused: color(IxThemeColorToken.infoActive),
        pressed: color(IxThemeColorToken.infoActive),
        disabled: color(IxThemeColorToken.component4),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.infoContrast),
        disabled: color(IxThemeColorToken.primaryContrast),
      ),
      overlay: infoOverlay,
      side: borderStates(base: transparentSide()),
    );

    final infoSecondary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.color0),
        hovered: color(IxThemeColorToken.info40),
        focused: color(IxThemeColorToken.info40),
        pressed: color(IxThemeColorToken.info40),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.info),
        hovered: color(IxThemeColorToken.info),
        pressed: color(IxThemeColorToken.info),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: infoOverlay,
      side: borderStates(
        base: border(color(IxThemeColorToken.info)),
        hovered: border(color(IxThemeColorToken.info)),
        focused: border(color(IxThemeColorToken.info)),
        pressed: border(color(IxThemeColorToken.info)),
        disabled: border(color(IxThemeColorToken.component4)),
      ),
    );

    final infoTertiary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.info40),
        focused: color(IxThemeColorToken.info40),
        pressed: color(IxThemeColorToken.info40),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.info),
        hovered: color(IxThemeColorToken.info),
        pressed: color(IxThemeColorToken.info),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: infoOverlay,
      side: borderStates(base: transparentSide()),
    );

    final successOverlay = overlayStates(
      hovered: color(IxThemeColorToken.success40),
      pressed: color(IxThemeColorToken.success40),
    );

    final successPrimary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.success),
        hovered: color(IxThemeColorToken.successHover),
        focused: color(IxThemeColorToken.successActive),
        pressed: color(IxThemeColorToken.successActive),
        disabled: color(IxThemeColorToken.component4),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.successContrast),
        disabled: color(IxThemeColorToken.primaryContrast),
      ),
      overlay: successOverlay,
      side: borderStates(base: transparentSide()),
    );

    final successSecondary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.color0),
        hovered: color(IxThemeColorToken.success40),
        focused: color(IxThemeColorToken.success40),
        pressed: color(IxThemeColorToken.success40),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.success),
        hovered: color(IxThemeColorToken.success),
        pressed: color(IxThemeColorToken.success),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: successOverlay,
      side: borderStates(
        base: border(color(IxThemeColorToken.success)),
        hovered: border(color(IxThemeColorToken.success)),
        focused: border(color(IxThemeColorToken.success)),
        pressed: border(color(IxThemeColorToken.success)),
        disabled: border(color(IxThemeColorToken.component4)),
      ),
    );

    final successTertiary = baseStyle(
      background: colorStates(
        base: color(IxThemeColorToken.ghost),
        hovered: color(IxThemeColorToken.success40),
        focused: color(IxThemeColorToken.success40),
        pressed: color(IxThemeColorToken.success40),
        disabled: color(IxThemeColorToken.ghost),
      ),
      foreground: colorStates(
        base: color(IxThemeColorToken.success),
        hovered: color(IxThemeColorToken.success),
        pressed: color(IxThemeColorToken.success),
        disabled: color(IxThemeColorToken.weakText),
      ),
      overlay: successOverlay,
      side: borderStates(base: transparentSide()),
    );

    return IxButtonTheme(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      subtlePrimary: subtlePrimary,
      subtleSecondary: subtleSecondary,
      subtleTertiary: subtleTertiary,
      dangerPrimary: dangerPrimary,
      dangerSecondary: dangerSecondary,
      dangerTertiary: dangerTertiary,
      warningPrimary: warningPrimary,
      warningSecondary: warningSecondary,
      warningTertiary: warningTertiary,
      infoPrimary: infoPrimary,
      infoSecondary: infoSecondary,
      infoTertiary: infoTertiary,
      successPrimary: successPrimary,
      successSecondary: successSecondary,
      successTertiary: successTertiary,
    );
  }

  final ButtonStyle primary;
  final ButtonStyle secondary;
  final ButtonStyle tertiary;
  final ButtonStyle subtlePrimary;
  final ButtonStyle subtleSecondary;
  final ButtonStyle subtleTertiary;
  final ButtonStyle dangerPrimary;
  final ButtonStyle dangerSecondary;
  final ButtonStyle dangerTertiary;
  final ButtonStyle warningPrimary;
  final ButtonStyle warningSecondary;
  final ButtonStyle warningTertiary;
  final ButtonStyle infoPrimary;
  final ButtonStyle infoSecondary;
  final ButtonStyle infoTertiary;
  final ButtonStyle successPrimary;
  final ButtonStyle successSecondary;
  final ButtonStyle successTertiary;

  /// Returns the [ButtonStyle] for a given [variant].
  ButtonStyle style(IxButtonVariant variant) {
    switch (variant) {
      case IxButtonVariant.primary:
        return primary;
      case IxButtonVariant.secondary:
        return secondary;
      case IxButtonVariant.tertiary:
        return tertiary;
      case IxButtonVariant.subtlePrimary:
        return subtlePrimary;
      case IxButtonVariant.subtleSecondary:
        return subtleSecondary;
      case IxButtonVariant.subtleTertiary:
        return subtleTertiary;
      case IxButtonVariant.dangerPrimary:
        return dangerPrimary;
      case IxButtonVariant.dangerSecondary:
        return dangerSecondary;
      case IxButtonVariant.dangerTertiary:
        return dangerTertiary;
      case IxButtonVariant.warningPrimary:
        return warningPrimary;
      case IxButtonVariant.warningSecondary:
        return warningSecondary;
      case IxButtonVariant.warningTertiary:
        return warningTertiary;
      case IxButtonVariant.infoPrimary:
        return infoPrimary;
      case IxButtonVariant.infoSecondary:
        return infoSecondary;
      case IxButtonVariant.infoTertiary:
        return infoTertiary;
      case IxButtonVariant.successPrimary:
        return successPrimary;
      case IxButtonVariant.successSecondary:
        return successSecondary;
      case IxButtonVariant.successTertiary:
        return successTertiary;
    }
  }

  @override
  IxButtonTheme copyWith({
    ButtonStyle? primary,
    ButtonStyle? secondary,
    ButtonStyle? tertiary,
    ButtonStyle? subtlePrimary,
    ButtonStyle? subtleSecondary,
    ButtonStyle? subtleTertiary,
    ButtonStyle? dangerPrimary,
    ButtonStyle? dangerSecondary,
    ButtonStyle? dangerTertiary,
    ButtonStyle? warningPrimary,
    ButtonStyle? warningSecondary,
    ButtonStyle? warningTertiary,
    ButtonStyle? infoPrimary,
    ButtonStyle? infoSecondary,
    ButtonStyle? infoTertiary,
    ButtonStyle? successPrimary,
    ButtonStyle? successSecondary,
    ButtonStyle? successTertiary,
  }) {
    return IxButtonTheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      subtlePrimary: subtlePrimary ?? this.subtlePrimary,
      subtleSecondary: subtleSecondary ?? this.subtleSecondary,
      subtleTertiary: subtleTertiary ?? this.subtleTertiary,
      dangerPrimary: dangerPrimary ?? this.dangerPrimary,
      dangerSecondary: dangerSecondary ?? this.dangerSecondary,
      dangerTertiary: dangerTertiary ?? this.dangerTertiary,
      warningPrimary: warningPrimary ?? this.warningPrimary,
      warningSecondary: warningSecondary ?? this.warningSecondary,
      warningTertiary: warningTertiary ?? this.warningTertiary,
      infoPrimary: infoPrimary ?? this.infoPrimary,
      infoSecondary: infoSecondary ?? this.infoSecondary,
      infoTertiary: infoTertiary ?? this.infoTertiary,
      successPrimary: successPrimary ?? this.successPrimary,
      successSecondary: successSecondary ?? this.successSecondary,
      successTertiary: successTertiary ?? this.successTertiary,
    );
  }

  @override
  IxButtonTheme lerp(ThemeExtension<IxButtonTheme>? other, double t) {
    if (other is! IxButtonTheme) {
      return this;
    }

    ButtonStyle lerpStyle(ButtonStyle a, ButtonStyle b) =>
        ButtonStyle.lerp(a, b, t) ?? a;

    return IxButtonTheme(
      primary: lerpStyle(primary, other.primary),
      secondary: lerpStyle(secondary, other.secondary),
      tertiary: lerpStyle(tertiary, other.tertiary),
      subtlePrimary: lerpStyle(subtlePrimary, other.subtlePrimary),
      subtleSecondary: lerpStyle(subtleSecondary, other.subtleSecondary),
      subtleTertiary: lerpStyle(subtleTertiary, other.subtleTertiary),
      dangerPrimary: lerpStyle(dangerPrimary, other.dangerPrimary),
      dangerSecondary: lerpStyle(dangerSecondary, other.dangerSecondary),
      dangerTertiary: lerpStyle(dangerTertiary, other.dangerTertiary),
      warningPrimary: lerpStyle(warningPrimary, other.warningPrimary),
      warningSecondary: lerpStyle(warningSecondary, other.warningSecondary),
      warningTertiary: lerpStyle(warningTertiary, other.warningTertiary),
      infoPrimary: lerpStyle(infoPrimary, other.infoPrimary),
      infoSecondary: lerpStyle(infoSecondary, other.infoSecondary),
      infoTertiary: lerpStyle(infoTertiary, other.infoTertiary),
      successPrimary: lerpStyle(successPrimary, other.successPrimary),
      successSecondary: lerpStyle(successSecondary, other.successSecondary),
      successTertiary: lerpStyle(successTertiary, other.successTertiary),
    );
  }
}
