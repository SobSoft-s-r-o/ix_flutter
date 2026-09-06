import 'package:flutter/material.dart';

import 'ix_fonts.dart';

/// Enumerates all Siemens IX typography variants.
enum IxTypographyVariant {
  label,
  labelXs,
  labelSm,
  labelLg,
  body,
  bodyXs,
  bodySm,
  bodyLg,
  display,
  displayXs,
  displaySm,
  displayLg,
  displayXl,
  displayXxl,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  code,
  codeSm,
  codeLg,
  buttonLabel,
  caption,
  textDefault,
}

/// Sentinel default for [IxTypography.new]'s and [IxTypography.copyWith]'s
/// `monospacePackage` parameter, distinguishing "caller didn't pass this
/// argument" (auto-resolve from the effective monospace font family) from an
/// explicit `monospacePackage: null` (force-disable the package prefix).
const Object _defaultMonospacePackage = Object();

/// Sentinel default for [IxTypography.copyWith]'s `package` parameter,
/// distinguishing "caller didn't pass this argument" (keep the current one,
/// unless the family it belonged to is changing) from an explicit
/// `package: null` (force-disable the package prefix).
const Object _defaultPackage = Object();

/// Precomputed Siemens IX typography scale for Flutter widgets.
///
/// Provide a custom [fontFamily] (and optionally [monospaceFontFamily]) to
/// switch away from Siemens Sans without rewriting component code.
class IxTypography {
  factory IxTypography({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? monospaceFontFamily,
    List<String>? monospaceFontFamilyFallback,
    String? package,
    Object? monospacePackage = _defaultMonospacePackage,
  }) {
    // ignore: deprecated_member_use_from_same_package
    final resolvedFontFamily = fontFamily ?? IxFonts.robotoMono;
    final resolvedSansFallback =
        fontFamilyFallback ??
        // ignore: deprecated_member_use_from_same_package
        IxFonts.robotoMonoFallback;
    final resolvedMonospaceFontFamily =
        monospaceFontFamily ?? IxFonts.jetBrainsMono;
    final resolvedMonospaceFallback =
        monospaceFontFamilyFallback ?? IxFonts.jetBrainsMonoFallback;
    final resolvedMonospacePackage =
        identical(monospacePackage, _defaultMonospacePackage)
        ? (resolvedMonospaceFontFamily == IxFonts.jetBrainsMono
              ? IxFonts.packageName
              : null)
        : monospacePackage as String?;

    return IxTypography._(
      fontFamily: resolvedFontFamily,
      fontFamilyFallback: resolvedSansFallback,
      monospaceFontFamily: resolvedMonospaceFontFamily,
      monospaceFontFamilyFallback: resolvedMonospaceFallback,
      package: package,
      monospacePackage: resolvedMonospacePackage,
    );
  }

  IxTypography._({
    required this.fontFamily,
    required this.fontFamilyFallback,
    required this.monospaceFontFamily,
    required this.monospaceFontFamilyFallback,
    required this.package,
    required this.monospacePackage,
  }) : label = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms0,
         lineHeight: _lineHeightSm,
       ),
       labelXs = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _msMinus2,
         lineHeight: _lineHeightSm,
         letterSpacingEm: _letterSpacingXxl,
       ),
       labelSm = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _msMinus1,
         lineHeight: _lineHeightSm,
       ),
       labelLg = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms1,
         lineHeight: _lineHeightSm,
         letterSpacingEm: _letterSpacingLg,
       ),
       body = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms0,
         lineHeight: _lineHeightMd,
       ),
       bodyXs = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _msMinus2,
         letterSpacingEm: _letterSpacingXxl,
       ),
       bodySm = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _msMinus1,
       ),
       bodyLg = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms1,
         letterSpacingEm: _letterSpacingLg,
       ),
       display = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms3,
         lineHeight: _lineHeightXs,
         letterSpacingEm: _letterSpacingMd,
       ),
       displayXs = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms1,
         lineHeight: _lineHeightXs,
         letterSpacingEm: _letterSpacingSm,
       ),
       displaySm = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms2,
         lineHeight: _lineHeightXs,
         letterSpacingEm: _letterSpacingLg,
       ),
       displayLg = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms4,
         lineHeight: _lineHeightXs,
         letterSpacingEm: _letterSpacingMd,
       ),
       displayXl = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms5,
         lineHeight: _lineHeightXs,
         letterSpacingEm: _letterSpacingSm,
         fontWeight: FontWeight.w700,
       ),
       displayXxl = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms6,
         lineHeight: _lineHeightXs,
         letterSpacingEm: _letterSpacingSm,
         fontWeight: FontWeight.w700,
       ),
       h6 = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _msMinus1,
         fontWeight: FontWeight.w700,
       ),
       h5 = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms0,
         fontWeight: FontWeight.w700,
       ),
       h4 = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms1,
         letterSpacingEm: _letterSpacingLg,
         fontWeight: FontWeight.w700,
       ),
       h3 = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms2,
         letterSpacingEm: _letterSpacingLg,
         fontWeight: FontWeight.w700,
       ),
       h2 = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms3,
         lineHeight: _lineHeightMd,
         letterSpacingEm: _letterSpacingMd,
         fontWeight: FontWeight.w700,
       ),
       h1 = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms4,
         lineHeight: _lineHeightSm,
         letterSpacingEm: _letterSpacingMd,
         fontWeight: FontWeight.w700,
       ),
       code = _style(
         fontFamily: monospaceFontFamily,
         fontFamilyFallback: monospaceFontFamilyFallback,
         package: monospacePackage,
         fontSize: _ms0,
         letterSpacingEm: _letterSpacingMd,
       ),
       codeSm = _style(
         fontFamily: monospaceFontFamily,
         fontFamilyFallback: monospaceFontFamilyFallback,
         package: monospacePackage,
         fontSize: _msMinus1,
       ),
       codeLg = _style(
         fontFamily: monospaceFontFamily,
         fontFamilyFallback: monospaceFontFamilyFallback,
         package: monospacePackage,
         fontSize: _ms1,
         letterSpacingEm: _letterSpacingMd,
       ),
       buttonLabel = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms0,
         lineHeight: _lineHeightLegacyDefault,
         fontWeight: FontWeight.w700,
       ),
       caption = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _msMinus1,
         lineHeight: _lineHeightLg,
         fontWeight: FontWeight.w700,
       ),
       textDefault = _style(
         fontFamily: fontFamily,
         fontFamilyFallback: fontFamilyFallback,
         package: package,
         fontSize: _ms0,
         lineHeight: _lineHeightLegacyDefault,
       );

  final String fontFamily;
  final List<String> fontFamilyFallback;
  final String monospaceFontFamily;
  final List<String> monospaceFontFamilyFallback;

  /// Package prefix applied to [fontFamily] via `TextStyle.package`, or
  /// `null` when [fontFamily] is not shipped as a bundled asset (the 1.x
  /// default, `IxFonts.robotoMono`, is never prefixed).
  final String? package;

  /// Package prefix applied to [monospaceFontFamily] via `TextStyle.package`.
  /// Defaults to [IxFonts.packageName] when [monospaceFontFamily] resolves to
  /// [IxFonts.jetBrainsMono] (the bundled asset), and to `null` otherwise.
  final String? monospacePackage;

  final TextStyle label;
  final TextStyle labelXs;
  final TextStyle labelSm;
  final TextStyle labelLg;
  final TextStyle body;
  final TextStyle bodyXs;
  final TextStyle bodySm;
  final TextStyle bodyLg;
  final TextStyle display;
  final TextStyle displayXs;
  final TextStyle displaySm;
  final TextStyle displayLg;
  final TextStyle displayXl;
  final TextStyle displayXxl;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle code;
  final TextStyle codeSm;
  final TextStyle codeLg;

  /// Legacy iX `text-default-title` format (14/700/1.429), used for button
  /// labels.
  final TextStyle buttonLabel;

  /// Legacy iX caption format (12/700/1.5).
  final TextStyle caption;

  /// Legacy iX `text-default` format (14/400/1.429).
  final TextStyle textDefault;

  /// Returns the [TextStyle] for a given [variant].
  TextStyle resolve(IxTypographyVariant variant) {
    switch (variant) {
      case IxTypographyVariant.label:
        return label;
      case IxTypographyVariant.labelXs:
        return labelXs;
      case IxTypographyVariant.labelSm:
        return labelSm;
      case IxTypographyVariant.labelLg:
        return labelLg;
      case IxTypographyVariant.body:
        return body;
      case IxTypographyVariant.bodyXs:
        return bodyXs;
      case IxTypographyVariant.bodySm:
        return bodySm;
      case IxTypographyVariant.bodyLg:
        return bodyLg;
      case IxTypographyVariant.display:
        return display;
      case IxTypographyVariant.displayXs:
        return displayXs;
      case IxTypographyVariant.displaySm:
        return displaySm;
      case IxTypographyVariant.displayLg:
        return displayLg;
      case IxTypographyVariant.displayXl:
        return displayXl;
      case IxTypographyVariant.displayXxl:
        return displayXxl;
      case IxTypographyVariant.h1:
        return h1;
      case IxTypographyVariant.h2:
        return h2;
      case IxTypographyVariant.h3:
        return h3;
      case IxTypographyVariant.h4:
        return h4;
      case IxTypographyVariant.h5:
        return h5;
      case IxTypographyVariant.h6:
        return h6;
      case IxTypographyVariant.code:
        return code;
      case IxTypographyVariant.codeSm:
        return codeSm;
      case IxTypographyVariant.codeLg:
        return codeLg;
      case IxTypographyVariant.buttonLabel:
        return buttonLabel;
      case IxTypographyVariant.caption:
        return caption;
      case IxTypographyVariant.textDefault:
        return textDefault;
    }
  }

  /// Convenience mapping to Flutter's [TextTheme].
  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayXxl,
      displayMedium: displayXl,
      displaySmall: displayLg,
      headlineLarge: h1,
      headlineMedium: h2,
      headlineSmall: h3,
      titleLarge: h4,
      titleMedium: h5,
      titleSmall: h6,
      bodyLarge: bodyLg,
      bodyMedium: body,
      bodySmall: bodySm,
      labelLarge: labelLg,
      labelMedium: label,
      labelSmall: labelSm,
    );
  }

  /// Returns a new instance with overridden typefaces.
  IxTypography copyWith({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? monospaceFontFamily,
    List<String>? monospaceFontFamilyFallback,
    Object? package = _defaultPackage,
    Object? monospacePackage = _defaultMonospacePackage,
  }) {
    return IxTypography(
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      monospaceFontFamily: monospaceFontFamily ?? this.monospaceFontFamily,
      monospaceFontFamilyFallback:
          monospaceFontFamilyFallback ?? this.monospaceFontFamilyFallback,
      // `package` names the package that ships `this.fontFamily`. When the
      // family changes and the caller says nothing about the package, the
      // old one no longer applies, so it is dropped rather than pointing a
      // new family at the wrong asset bundle. An explicit value (including
      // `null`, which clears it) always wins -- the same rule
      // `monospacePackage` follows below.
      package: identical(package, _defaultPackage)
          ? (fontFamily != null ? null : this.package)
          : package as String?,
      // When the caller omits `monospacePackage` (it is still the shared
      // `_defaultMonospacePackage` sentinel), preserve `this.monospacePackage`
      // verbatim — UNLESS `monospaceFontFamily` is also changing in this same
      // call, in which case forward the sentinel through so the factory
      // re-derives the package from the new effective family. When the
      // caller passes `monospacePackage` explicitly (including `null`), that
      // value always wins.
      monospacePackage: identical(monospacePackage, _defaultMonospacePackage)
          ? (monospaceFontFamily != null
                ? _defaultMonospacePackage
                : this.monospacePackage)
          : monospacePackage,
    );
  }
}

const double _msMinus2 = 10;
const double _msMinus1 = 12;
const double _ms0 = 14;
const double _ms1 = 16;
const double _ms2 = 20;
const double _ms3 = 24;
const double _ms4 = 29;
const double _ms5 = 35;
const double _ms6 = 42;

const double _lineHeightXs = 1;
const double _lineHeightSm = 1.2;
const double _lineHeightMd = 1.43;
const double _lineHeightLg = 1.5;

/// Legacy iX `--theme-line-height-default` (`scss/theme/core/_common.scss`),
/// used by [IxTypography.buttonLabel] and [IxTypography.textDefault].
const double _lineHeightLegacyDefault = 1.429;

const double _letterSpacingLg = 0.006;
const double _letterSpacingMd = 0;
const double _letterSpacingSm = -0.006;
const double _letterSpacingXl = 0.012;
const double _letterSpacingXxl = 0.02;

TextStyle _style({
  required double fontSize,
  double lineHeight = _lineHeightLg,
  double letterSpacingEm = _letterSpacingXl,
  FontWeight fontWeight = FontWeight.w400,
  required String fontFamily,
  required List<String> fontFamilyFallback,
  String? package,
}) {
  return TextStyle(
    // `TextStyle.package` would prefix every entry of [fontFamilyFallback]
    // with `packages/<package>/` too, which is wrong: the fallback families
    // (e.g. Arial, Helvetica, Courier New, monospace) are system fonts, not
    // assets bundled by this package. So the `packages/<package>/` prefix
    // is applied to [fontFamily] here directly, and `package` is left
    // unset on the [TextStyle] itself so [fontFamilyFallback] passes
    // through unprefixed.
    fontFamily: package == null ? fontFamily : 'packages/$package/$fontFamily',
    fontFamilyFallback: fontFamilyFallback,
    fontSize: fontSize,
    height: lineHeight,
    fontWeight: fontWeight,
    letterSpacing: letterSpacingEm == 0 ? 0 : letterSpacingEm * fontSize,
    // Upstream `scss/mixins/_fonts.scss:22` disables ligatures and
    // contextual ligatures on every Siemens IX typography variant.
    fontFeatures: const [
      FontFeature.disable('liga'),
      FontFeature.disable('clig'),
    ],
  );
}
