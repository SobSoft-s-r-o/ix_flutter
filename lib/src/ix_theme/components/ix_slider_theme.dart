import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';

const _defaultCssFontSizePx = 16.0; // Browser default for 1rem.
const _sliderTrackHeightRem = 0.25; // --theme-border-radius token proxy.
const _sliderThumbDiameterRem = 0.75; // Matches IX thumb size.
const _sliderOverlayRadiusRem = 1.25; // Hover/press halo radius.

const _sliderTrackHeightPx = _defaultCssFontSizePx * _sliderTrackHeightRem;
const _sliderThumbRadiusPx =
    (_defaultCssFontSizePx * _sliderThumbDiameterRem) / 2;
const _sliderOverlayRadiusPx = _defaultCssFontSizePx * _sliderOverlayRadiusRem;

/// Enumerates Siemens IX slider semantic variants.
enum IxSliderStatus { standard, info, warning, invalid }

/// Captures the color roles used across thumb, trace, and track.
class IxSliderColors {
  const IxSliderColors({
    required this.thumb,
    required this.thumbHover,
    required this.thumbActive,
    required this.thumbDisabled,
    required this.track,
    required this.trackDisabled,
    required this.trace,
    required this.traceDisabled,
    required this.marker,
    required this.markerDisabled,
  });

  final Color thumb;
  final Color thumbHover;
  final Color thumbActive;
  final Color thumbDisabled;
  final Color track;
  final Color trackDisabled;
  final Color trace;
  final Color traceDisabled;
  final Color marker;
  final Color markerDisabled;

  IxSliderColors copyWith({
    Color? thumb,
    Color? thumbHover,
    Color? thumbActive,
    Color? thumbDisabled,
    Color? track,
    Color? trackDisabled,
    Color? trace,
    Color? traceDisabled,
    Color? marker,
    Color? markerDisabled,
  }) {
    return IxSliderColors(
      thumb: thumb ?? this.thumb,
      thumbHover: thumbHover ?? this.thumbHover,
      thumbActive: thumbActive ?? this.thumbActive,
      thumbDisabled: thumbDisabled ?? this.thumbDisabled,
      track: track ?? this.track,
      trackDisabled: trackDisabled ?? this.trackDisabled,
      trace: trace ?? this.trace,
      traceDisabled: traceDisabled ?? this.traceDisabled,
      marker: marker ?? this.marker,
      markerDisabled: markerDisabled ?? this.markerDisabled,
    );
  }

  static IxSliderColors lerp(IxSliderColors a, IxSliderColors b, double t) {
    Color lerp(Color ca, Color cb) => Color.lerp(ca, cb, t) ?? ca;
    return IxSliderColors(
      thumb: lerp(a.thumb, b.thumb),
      thumbHover: lerp(a.thumbHover, b.thumbHover),
      thumbActive: lerp(a.thumbActive, b.thumbActive),
      thumbDisabled: lerp(a.thumbDisabled, b.thumbDisabled),
      track: lerp(a.track, b.track),
      trackDisabled: lerp(a.trackDisabled, b.trackDisabled),
      trace: lerp(a.trace, b.trace),
      traceDisabled: lerp(a.traceDisabled, b.traceDisabled),
      marker: lerp(a.marker, b.marker),
      markerDisabled: lerp(a.markerDisabled, b.markerDisabled),
    );
  }
}

/// Theme extension surfacing slider theming primitives.
class IxSliderTheme extends ThemeExtension<IxSliderTheme> {
  const IxSliderTheme({
    required this.materialSliderTheme,
    required this.trackHeight,
    required this.thumbRadius,
    required this.overlayRadius,
    required this.styles,
  });

  factory IxSliderTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color color(IxThemeColorToken token) => palette[token]!;

    IxSliderColors style({
      required IxThemeColorToken thumb,
      required IxThemeColorToken thumbHover,
      required IxThemeColorToken thumbActive,
      required IxThemeColorToken thumbDisabled,
      required IxThemeColorToken track,
      required IxThemeColorToken trackDisabled,
      required IxThemeColorToken trace,
      required IxThemeColorToken traceDisabled,
      required IxThemeColorToken marker,
      required IxThemeColorToken markerDisabled,
    }) {
      return IxSliderColors(
        thumb: color(thumb),
        thumbHover: color(thumbHover),
        thumbActive: color(thumbActive),
        thumbDisabled: color(thumbDisabled),
        track: color(track),
        trackDisabled: color(trackDisabled),
        trace: color(trace),
        traceDisabled: color(traceDisabled),
        marker: color(marker),
        markerDisabled: color(markerDisabled),
      );
    }

    final standard = style(
      thumb: IxThemeColorToken.dynamic,
      thumbHover: IxThemeColorToken.dynamicHover,
      thumbActive: IxThemeColorToken.dynamicActive,
      thumbDisabled: IxThemeColorToken.color7,
      track: IxThemeColorToken.component4,
      trackDisabled: IxThemeColorToken.component2,
      trace: IxThemeColorToken.dynamic,
      traceDisabled: IxThemeColorToken.component3,
      marker: IxThemeColorToken.color8,
      markerDisabled: IxThemeColorToken.color5,
    );

    final info = style(
      thumb: IxThemeColorToken.info,
      thumbHover: IxThemeColorToken.infoHover,
      thumbActive: IxThemeColorToken.infoActive,
      thumbDisabled: IxThemeColorToken.color7,
      track: IxThemeColorToken.component4,
      trackDisabled: IxThemeColorToken.component2,
      trace: IxThemeColorToken.info,
      traceDisabled: IxThemeColorToken.component3,
      marker: IxThemeColorToken.info,
      markerDisabled: IxThemeColorToken.color5,
    );

    final warning = style(
      thumb: IxThemeColorToken.warning,
      thumbHover: IxThemeColorToken.warningHover,
      thumbActive: IxThemeColorToken.warningActive,
      thumbDisabled: IxThemeColorToken.color7,
      track: IxThemeColorToken.component4,
      trackDisabled: IxThemeColorToken.component2,
      trace: IxThemeColorToken.warningBdr,
      traceDisabled: IxThemeColorToken.component3,
      marker: IxThemeColorToken.warning,
      markerDisabled: IxThemeColorToken.color5,
    );

    final invalid = style(
      thumb: IxThemeColorToken.alarm,
      thumbHover: IxThemeColorToken.alarmHover,
      thumbActive: IxThemeColorToken.alarmActive,
      thumbDisabled: IxThemeColorToken.color7,
      track: IxThemeColorToken.component4,
      trackDisabled: IxThemeColorToken.component2,
      trace: IxThemeColorToken.alarm,
      traceDisabled: IxThemeColorToken.component3,
      marker: IxThemeColorToken.alarm,
      markerDisabled: IxThemeColorToken.color5,
    );

    final styles = Map<IxSliderStatus, IxSliderColors>.unmodifiable({
      IxSliderStatus.standard: standard,
      IxSliderStatus.info: info,
      IxSliderStatus.warning: warning,
      IxSliderStatus.invalid: invalid,
    });

    final overlayColor = color(
      IxThemeColorToken.component1Hover,
    ).withOpacity(0.25);

    final sliderTheme = SliderThemeData(
      trackHeight: _sliderTrackHeightPx,
      activeTrackColor: standard.trace,
      inactiveTrackColor: standard.track,
      disabledActiveTrackColor: standard.traceDisabled,
      disabledInactiveTrackColor: standard.trackDisabled,
      thumbColor: standard.thumb,
      disabledThumbColor: standard.thumbDisabled,
      activeTickMarkColor: standard.marker,
      inactiveTickMarkColor: standard.marker,
      disabledActiveTickMarkColor: standard.markerDisabled,
      disabledInactiveTickMarkColor: standard.markerDisabled,
      overlayColor: overlayColor,
      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: _sliderThumbRadiusPx,
        disabledThumbRadius: _sliderThumbRadiusPx,
      ),
      overlayShape: RoundSliderOverlayShape(
        overlayRadius: _sliderOverlayRadiusPx,
      ),
      valueIndicatorTextStyle: TextStyle(
        color: color(IxThemeColorToken.primaryContrast),
      ),
    );

    return IxSliderTheme(
      materialSliderTheme: sliderTheme,
      trackHeight: _sliderTrackHeightPx,
      thumbRadius: _sliderThumbRadiusPx,
      overlayRadius: _sliderOverlayRadiusPx,
      styles: styles,
    );
  }

  final SliderThemeData materialSliderTheme;
  final double trackHeight;
  final double thumbRadius;
  final double overlayRadius;
  final Map<IxSliderStatus, IxSliderColors> styles;

  IxSliderColors style(IxSliderStatus status) {
    return styles[status] ?? styles[IxSliderStatus.standard]!;
  }

  @override
  IxSliderTheme copyWith({
    SliderThemeData? materialSliderTheme,
    double? trackHeight,
    double? thumbRadius,
    double? overlayRadius,
    Map<IxSliderStatus, IxSliderColors>? styles,
  }) {
    return IxSliderTheme(
      materialSliderTheme: materialSliderTheme ?? this.materialSliderTheme,
      trackHeight: trackHeight ?? this.trackHeight,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      overlayRadius: overlayRadius ?? this.overlayRadius,
      styles: styles ?? this.styles,
    );
  }

  @override
  IxSliderTheme lerp(ThemeExtension<IxSliderTheme>? other, double t) {
    if (other is! IxSliderTheme) {
      return this;
    }

    Map<IxSliderStatus, IxSliderColors> lerpMap(
      Map<IxSliderStatus, IxSliderColors> a,
      Map<IxSliderStatus, IxSliderColors> b,
    ) {
      final keys = <IxSliderStatus>{...a.keys, ...b.keys};
      return {
        for (final key in keys)
          key: IxSliderColors.lerp(a[key] ?? b[key]!, b[key] ?? a[key]!, t),
      };
    }

    return IxSliderTheme(
      materialSliderTheme: SliderThemeData.lerp(
        materialSliderTheme,
        other.materialSliderTheme,
        t,
      ),
      trackHeight: lerpDouble(trackHeight, other.trackHeight, t) ?? trackHeight,
      thumbRadius: lerpDouble(thumbRadius, other.thumbRadius, t) ?? thumbRadius,
      overlayRadius:
          lerpDouble(overlayRadius, other.overlayRadius, t) ?? overlayRadius,
      styles: lerpMap(styles, other.styles),
    );
  }
}
