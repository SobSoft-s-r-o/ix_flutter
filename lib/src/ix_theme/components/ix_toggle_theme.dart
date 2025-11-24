import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_colors/ix_theme_color_tokens.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_common_geometry.dart';

/// Siemens IX toggle semantic variants.
enum IxToggleStatus { standard, info, warning, invalid }

/// Captures the thumb/track visuals for a toggle state (on/off).
class IxToggleVisualState {
  const IxToggleVisualState({
    required this.track,
    required this.trackHover,
    required this.trackActive,
    required this.trackDisabled,
    required this.outline,
    required this.outlineHover,
    required this.outlineActive,
    required this.outlineDisabled,
    required this.thumb,
    required this.thumbHover,
    required this.thumbActive,
    required this.thumbDisabled,
  });

  final Color track;
  final Color trackHover;
  final Color trackActive;
  final Color trackDisabled;
  final Color outline;
  final Color outlineHover;
  final Color outlineActive;
  final Color outlineDisabled;
  final Color thumb;
  final Color thumbHover;
  final Color thumbActive;
  final Color thumbDisabled;

  IxToggleVisualState copyWith({
    Color? track,
    Color? trackHover,
    Color? trackActive,
    Color? trackDisabled,
    Color? outline,
    Color? outlineHover,
    Color? outlineActive,
    Color? outlineDisabled,
    Color? thumb,
    Color? thumbHover,
    Color? thumbActive,
    Color? thumbDisabled,
  }) {
    return IxToggleVisualState(
      track: track ?? this.track,
      trackHover: trackHover ?? this.trackHover,
      trackActive: trackActive ?? this.trackActive,
      trackDisabled: trackDisabled ?? this.trackDisabled,
      outline: outline ?? this.outline,
      outlineHover: outlineHover ?? this.outlineHover,
      outlineActive: outlineActive ?? this.outlineActive,
      outlineDisabled: outlineDisabled ?? this.outlineDisabled,
      thumb: thumb ?? this.thumb,
      thumbHover: thumbHover ?? this.thumbHover,
      thumbActive: thumbActive ?? this.thumbActive,
      thumbDisabled: thumbDisabled ?? this.thumbDisabled,
    );
  }

  static IxToggleVisualState lerp(
    IxToggleVisualState a,
    IxToggleVisualState b,
    double t,
  ) {
    Color lerp(Color ca, Color cb) => Color.lerp(ca, cb, t) ?? ca;
    return IxToggleVisualState(
      track: lerp(a.track, b.track),
      trackHover: lerp(a.trackHover, b.trackHover),
      trackActive: lerp(a.trackActive, b.trackActive),
      trackDisabled: lerp(a.trackDisabled, b.trackDisabled),
      outline: lerp(a.outline, b.outline),
      outlineHover: lerp(a.outlineHover, b.outlineHover),
      outlineActive: lerp(a.outlineActive, b.outlineActive),
      outlineDisabled: lerp(a.outlineDisabled, b.outlineDisabled),
      thumb: lerp(a.thumb, b.thumb),
      thumbHover: lerp(a.thumbHover, b.thumbHover),
      thumbActive: lerp(a.thumbActive, b.thumbActive),
      thumbDisabled: lerp(a.thumbDisabled, b.thumbDisabled),
    );
  }
}

/// Bundles on/off visuals for a semantic toggle status.
class IxToggleStateBundle {
  const IxToggleStateBundle({required this.on, required this.off});

  final IxToggleVisualState on;
  final IxToggleVisualState off;

  IxToggleStateBundle copyWith({
    IxToggleVisualState? on,
    IxToggleVisualState? off,
  }) {
    return IxToggleStateBundle(on: on ?? this.on, off: off ?? this.off);
  }

  static IxToggleStateBundle lerp(
    IxToggleStateBundle a,
    IxToggleStateBundle b,
    double t,
  ) {
    return IxToggleStateBundle(
      on: IxToggleVisualState.lerp(a.on, b.on, t),
      off: IxToggleVisualState.lerp(a.off, b.off, t),
    );
  }
}

/// Theme extension exposing Siemens IX toggle primitives and Material switch theming.
class IxToggleTheme extends ThemeExtension<IxToggleTheme> {
  const IxToggleTheme({
    required this.materialSwitchTheme,
    required this.styles,
    required this.overlayHoverColor,
    required this.overlayActiveColor,
    required this.focusOutlineColor,
  });

  factory IxToggleTheme.fromPalette({
    required Map<IxThemeColorToken, Color> palette,
  }) {
    Color pick(IxThemeColorToken token) => palette[token]!;

    IxToggleVisualState visual({
      required IxThemeColorToken track,
      required IxThemeColorToken trackHover,
      required IxThemeColorToken trackActive,
      required IxThemeColorToken trackDisabled,
      required IxThemeColorToken outline,
      IxThemeColorToken? outlineHover,
      IxThemeColorToken? outlineActive,
      IxThemeColorToken? outlineDisabled,
      required IxThemeColorToken thumb,
      IxThemeColorToken? thumbHover,
      IxThemeColorToken? thumbActive,
      IxThemeColorToken? thumbDisabled,
    }) {
      return IxToggleVisualState(
        track: pick(track),
        trackHover: pick(trackHover),
        trackActive: pick(trackActive),
        trackDisabled: pick(trackDisabled),
        outline: pick(outline),
        outlineHover: pick(outlineHover ?? outline),
        outlineActive: pick(outlineActive ?? outlineHover ?? outline),
        outlineDisabled: pick(outlineDisabled ?? outline),
        thumb: pick(thumb),
        thumbHover: pick(thumbHover ?? thumb),
        thumbActive: pick(thumbActive ?? thumbHover ?? thumb),
        thumbDisabled: pick(thumbDisabled ?? IxThemeColorToken.component3),
      );
    }

    IxToggleStateBundle standard = IxToggleStateBundle(
      on: visual(
        track: IxThemeColorToken.dynamic,
        trackHover: IxThemeColorToken.dynamicHover,
        trackActive: IxThemeColorToken.dynamicActive,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.color0,
        thumb: IxThemeColorToken.primaryContrast,
        thumbDisabled: IxThemeColorToken.component3,
      ),
      off: visual(
        track: IxThemeColorToken.component4,
        trackHover: IxThemeColorToken.component5,
        trackActive: IxThemeColorToken.component4,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.color0,
        thumb: IxThemeColorToken.invStdText,
        thumbDisabled: IxThemeColorToken.component3,
      ),
    );

    IxToggleStateBundle info = IxToggleStateBundle(
      on: visual(
        track: IxThemeColorToken.info,
        trackHover: IxThemeColorToken.infoHover,
        trackActive: IxThemeColorToken.infoActive,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.color0,
        thumb: IxThemeColorToken.infoContrast,
      ),
      off: visual(
        track: IxThemeColorToken.component4,
        trackHover: IxThemeColorToken.component5,
        trackActive: IxThemeColorToken.component4,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.info,
        outlineHover: IxThemeColorToken.infoHover,
        outlineActive: IxThemeColorToken.infoActive,
        thumb: IxThemeColorToken.invStdText,
      ),
    );

    IxToggleStateBundle warning = IxToggleStateBundle(
      on: visual(
        track: IxThemeColorToken.warning,
        trackHover: IxThemeColorToken.warningHover,
        trackActive: IxThemeColorToken.warningActive,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.warningBdr,
        thumb: IxThemeColorToken.warningContrast,
      ),
      off: visual(
        track: IxThemeColorToken.component4,
        trackHover: IxThemeColorToken.component5,
        trackActive: IxThemeColorToken.component4,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.warningBdr,
        thumb: IxThemeColorToken.componentWarning,
        thumbDisabled: IxThemeColorToken.component2,
      ),
    );

    IxToggleStateBundle invalid = IxToggleStateBundle(
      on: visual(
        track: IxThemeColorToken.alarm,
        trackHover: IxThemeColorToken.alarmHover,
        trackActive: IxThemeColorToken.alarmActive,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.color0,
        thumb: IxThemeColorToken.alarmContrast,
      ),
      off: visual(
        track: IxThemeColorToken.component4,
        trackHover: IxThemeColorToken.component5,
        trackActive: IxThemeColorToken.component4,
        trackDisabled: IxThemeColorToken.component2,
        outline: IxThemeColorToken.alarmBdr,
        thumb: IxThemeColorToken.componentError,
        thumbDisabled: IxThemeColorToken.component2,
      ),
    );

    final styles = Map<IxToggleStatus, IxToggleStateBundle>.unmodifiable({
      IxToggleStatus.standard: standard,
      IxToggleStatus.info: info,
      IxToggleStatus.warning: warning,
      IxToggleStatus.invalid: invalid,
    });

    final overlayHover = pick(IxThemeColorToken.component1Hover);
    final overlayActive = pick(IxThemeColorToken.component1Active);
    final focusOutline = pick(IxThemeColorToken.focusBdr);

    return IxToggleTheme(
      materialSwitchTheme: _buildSwitchTheme(
        standard,
        overlayHover,
        overlayActive,
        focusOutline,
      ),
      styles: styles,
      overlayHoverColor: overlayHover,
      overlayActiveColor: overlayActive,
      focusOutlineColor: focusOutline,
    );
  }

  final SwitchThemeData materialSwitchTheme;
  final Map<IxToggleStatus, IxToggleStateBundle> styles;
  final Color overlayHoverColor;
  final Color overlayActiveColor;
  final Color focusOutlineColor;

  IxToggleStateBundle style(IxToggleStatus status) {
    return styles[status] ?? styles[IxToggleStatus.standard]!;
  }

  /// Builds a Material [SwitchThemeData] for a specific semantic status.
  SwitchThemeData themeData(IxToggleStatus status) {
    return _buildSwitchTheme(
      style(status),
      overlayHoverColor,
      overlayActiveColor,
      focusOutlineColor,
    );
  }

  @override
  IxToggleTheme copyWith({
    SwitchThemeData? materialSwitchTheme,
    Map<IxToggleStatus, IxToggleStateBundle>? styles,
    Color? overlayHoverColor,
    Color? overlayActiveColor,
    Color? focusOutlineColor,
  }) {
    return IxToggleTheme(
      materialSwitchTheme: materialSwitchTheme ?? this.materialSwitchTheme,
      styles: styles ?? this.styles,
      overlayHoverColor: overlayHoverColor ?? this.overlayHoverColor,
      overlayActiveColor: overlayActiveColor ?? this.overlayActiveColor,
      focusOutlineColor: focusOutlineColor ?? this.focusOutlineColor,
    );
  }

  @override
  IxToggleTheme lerp(ThemeExtension<IxToggleTheme>? other, double t) {
    if (other is! IxToggleTheme) {
      return this;
    }

    Map<IxToggleStatus, IxToggleStateBundle> lerpStyles(
      Map<IxToggleStatus, IxToggleStateBundle> a,
      Map<IxToggleStatus, IxToggleStateBundle> b,
    ) {
      final result = <IxToggleStatus, IxToggleStateBundle>{};
      final keys = <IxToggleStatus>{...a.keys, ...b.keys};
      for (final key in keys) {
        final first = a[key] ?? b[key]!;
        final second = b[key] ?? a[key]!;
        result[key] = IxToggleStateBundle.lerp(first, second, t);
      }
      return result;
    }

    return IxToggleTheme(
      materialSwitchTheme: SwitchThemeData.lerp(
        materialSwitchTheme,
        other.materialSwitchTheme,
        t,
      ),
      styles: lerpStyles(styles, other.styles),
      overlayHoverColor:
          Color.lerp(overlayHoverColor, other.overlayHoverColor, t) ??
          overlayHoverColor,
      overlayActiveColor:
          Color.lerp(overlayActiveColor, other.overlayActiveColor, t) ??
          overlayActiveColor,
      focusOutlineColor:
          Color.lerp(focusOutlineColor, other.focusOutlineColor, t) ??
          focusOutlineColor,
    );
  }
}

SwitchThemeData _buildSwitchTheme(
  IxToggleStateBundle bundle,
  Color overlayHover,
  Color overlayActive,
  Color focusOutline,
) {
  final borderWidth = IxCommonGeometry.borderWidthDefault;
  const paddingValue = IxCommonGeometry.spaceNeg3;
  const thumbDiameter = IxCommonGeometry.toggleThumbDiameter;
  Color resolveTrack(Set<WidgetState> states) {
    final visuals = _visualsFor(bundle, states);
    if (states.contains(WidgetState.disabled)) {
      return visuals.trackDisabled;
    }
    if (states.contains(WidgetState.pressed)) {
      return visuals.trackActive;
    }
    if (states.contains(WidgetState.hovered)) {
      return visuals.trackHover;
    }
    return visuals.track;
  }

  Color resolveOutline(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      final visuals = _visualsFor(bundle, states);
      return visuals.outlineDisabled;
    }
    if (states.contains(WidgetState.focused)) {
      return focusOutline;
    }
    final visuals = _visualsFor(bundle, states);
    if (states.contains(WidgetState.pressed)) {
      return visuals.outlineActive;
    }
    if (states.contains(WidgetState.hovered)) {
      return visuals.outlineHover;
    }
    return visuals.outline;
  }

  Color resolveThumb(Set<WidgetState> states) {
    final visuals = _visualsFor(bundle, states);
    if (states.contains(WidgetState.disabled)) {
      return visuals.thumbDisabled;
    }
    if (states.contains(WidgetState.pressed)) {
      return visuals.thumbActive;
    }
    if (states.contains(WidgetState.hovered)) {
      return visuals.thumbHover;
    }
    return visuals.thumb;
  }

  final overlay = WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) {
      return Colors.transparent;
    }
    if (states.contains(WidgetState.pressed)) {
      return overlayActive;
    }
    if (states.contains(WidgetState.focused)) {
      return focusOutline.withValues(alpha: 0.15);
    }
    if (states.contains(WidgetState.hovered)) {
      return overlayHover;
    }
    return Colors.transparent;
  });

  return SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith(resolveTrack),
    trackOutlineColor: WidgetStateProperty.resolveWith(resolveOutline),
    trackOutlineWidth: WidgetStatePropertyAll(borderWidth),
    thumbColor: WidgetStateProperty.resolveWith(resolveThumb),
    overlayColor: overlay,
    splashRadius: thumbDiameter,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.symmetric(
      horizontal: paddingValue,
      vertical: paddingValue,
    ),
  );
}

IxToggleVisualState _visualsFor(
  IxToggleStateBundle bundle,
  Set<WidgetState> states,
) {
  if (states.contains(WidgetState.selected)) {
    return bundle.on;
  }
  return bundle.off;
}
