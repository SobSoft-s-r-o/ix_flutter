import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../ix_theme/ix_theme_builder.dart';

/// Siemens IX adaptive density policy driving interactive control hit areas.
///
/// [compact] targets pointer/keyboard input (a 32px visual size with a hit
/// area equal to the visual size); [comfortable] targets touch input (the
/// same 32px visual size wrapped in a 48x48 hit area, per WCAG 2.5.8);
/// [adaptive] resolves to one of the two at runtime via [resolve].
///
/// In this 1.x release only the *hit area* changes between densities --
/// button/checkbox/radio/switch visual sizes stay at their existing 40px
/// height. The 40px -> 32px visual change lands in 2.0.
enum IxDensity {
  /// Pointer/keyboard-driven density: hit area equals the visual size.
  compact,

  /// Touch-driven density: hit area is padded out to 48x48.
  comfortable,

  /// Resolves to [compact] or [comfortable] at runtime via [resolve].
  adaptive;

  /// Resolves [adaptive] modality from [context]; never returns [adaptive].
  ///
  /// A viewport narrower than 600 logical pixels always resolves to
  /// [comfortable] (a small screen implies touch). Otherwise the platform
  /// decides first — a desktop platform (and a desktop browser) is
  /// [compact] whether or not a mouse has moved yet — and a touch platform
  /// upgrades to [compact] once a mouse is connected or the app is being
  /// driven with [NavigationMode.directional] (TV/remote control).
  ///
  /// The platform is consulted *before* the mouse because
  /// `mouseIsConnected` only becomes true once a pointer event has actually
  /// been seen: treating "no mouse tracked yet" as touch made every desktop
  /// app start [comfortable] and then resize its controls the first time
  /// the cursor entered the window — and disagree with the static density
  /// `IxThemeBuilder.build()` bakes from the same platform.
  static IxDensity resolve(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 600) return IxDensity.comfortable;
    if (resolvePlatform(Theme.of(context).platform) == IxDensity.compact) {
      return IxDensity.compact;
    }
    final pointer = RendererBinding.instance.mouseTracker.mouseIsConnected;
    final directional =
        MediaQuery.navigationModeOf(context) == NavigationMode.directional;
    return pointer || directional ? IxDensity.compact : IxDensity.comfortable;
  }

  /// The static density default for [platform] (defaults to
  /// [defaultTargetPlatform]).
  ///
  /// Mirrors Material's own platform rule for `materialTapTargetSize`:
  /// touch platforms (Android/iOS/Fuchsia) get [comfortable] (48x48 hit
  /// areas), desktop platforms (Linux/macOS/Windows, and therefore
  /// desktop browsers) get [compact] (hit area equals the visual size).
  ///
  /// Used by `IxThemeBuilder.build()` to bake a static default when
  /// `density` is [adaptive] and no [BuildContext] exists yet. Prefer
  /// [IxDensityScope] / [effectiveOf] for live, input-modality-driven
  /// resolution, which additionally accounts for a connected mouse, the
  /// viewport width and [NavigationMode.directional].
  static IxDensity resolvePlatform([TargetPlatform? platform]) {
    return switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia => IxDensity.comfortable,
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => IxDensity.compact,
    };
  }

  /// Resolves the effective density for [context].
  ///
  /// Precedence: [IxDensityScope] (nearest ancestor) overrides
  /// `IxTheme.density` (from `IxThemeBuilder(density:)`), which overrides
  /// [adaptive]. Whichever value is chosen, [adaptive] is then resolved via
  /// [resolve] so this method never returns [adaptive] either.
  static IxDensity effectiveOf(BuildContext context) {
    final scoped = IxDensityScope.maybeOf(context);
    final themed = Theme.of(context).extension<IxTheme>()?.density;
    final chosen = scoped ?? themed ?? IxDensity.adaptive;
    return chosen == IxDensity.adaptive ? resolve(context) : chosen;
  }

  /// The minimum interactive hit area, in logical pixels, for this density.
  double get minTapTarget => this == IxDensity.comfortable ? 48 : 32;

  /// The Material tap-target sizing mode matching this density.
  MaterialTapTargetSize get tapTargetSize => this == IxDensity.comfortable
      ? MaterialTapTargetSize.padded
      : MaterialTapTargetSize.shrinkWrap;
}

/// Provides a resolved [IxDensity] to descendants and re-themes Material
/// component tap targets (button/checkbox/radio/switch/slider) to match.
///
/// Wrap the app once, below `MaterialApp.builder`, so every descendant
/// picks up the same resolved density:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) =>
///       IxDensityScope(child: child ?? const SizedBox.shrink()),
///   home: const MyHome(),
/// )
/// ```
///
/// [density] defaults to [IxDensity.adaptive], which re-resolves on every
/// rebuild (in particular, when a mouse connects/disconnects, since this
/// widget listens to `RendererBinding.instance.mouseTracker`). Pass an
/// explicit [IxDensity.compact]/[IxDensity.comfortable] to pin the density
/// for a subtree regardless of input modality; an explicit [IxDensityScope]
/// always takes precedence over `IxThemeBuilder(density:)`.
class IxDensityScope extends StatelessWidget {
  const IxDensityScope({
    super.key,
    this.density = IxDensity.adaptive,
    required this.child,
  });

  /// The density to apply, or [IxDensity.adaptive] to resolve it from the
  /// ambient input modality on every rebuild.
  final IxDensity density;

  /// The subtree that receives the resolved density and re-themed Material
  /// component tap targets.
  final Widget child;

  /// The nearest ancestor [IxDensityScope]'s resolved density (never
  /// [IxDensity.adaptive]), or `null` if there is none.
  static IxDensity? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_IxDensityInherited>()
      ?.density;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      // Rebuilds this scope when a mouse connects/disconnects, so `adaptive`
      // re-resolves live rather than only on unrelated rebuilds.
      listenable: RendererBinding.instance.mouseTracker,
      builder: (context, _) {
        final resolved = density == IxDensity.adaptive
            ? IxDensity.resolve(context)
            : density;
        return _IxDensityInherited(
          density: resolved,
          child: Theme(
            data: IxDensityAdapter.apply(Theme.of(context), resolved),
            child: child,
          ),
        );
      },
    );
  }
}

class _IxDensityInherited extends InheritedWidget {
  const _IxDensityInherited({required this.density, required super.child});

  final IxDensity density;

  @override
  bool updateShouldNotify(_IxDensityInherited old) => old.density != density;
}

/// Applies [IxDensity]'s tap-target sizing to a [ThemeData]'s Material
/// component themes (button variants, checkbox, radio, switch, slider).
///
/// Used both by [IxThemeBuilder.build] (to bake in a static default) and by
/// [IxDensityScope] (to re-theme a subtree with a live-resolved density).
abstract final class IxDensityAdapter {
  /// Returns a copy of [base] with every button/checkbox/radio/switch/slider
  /// theme adapted to [density]'s [IxDensity.tapTargetSize], and, when
  /// [base] carries an `IxTheme` extension (i.e. it was built by
  /// [IxThemeBuilder]), that extension's `density` field set to [density].
  ///
  /// [IxDensityScope] calls this on whatever ambient [ThemeData] is
  /// current, which is not guaranteed to be an [IxThemeBuilder] theme (an
  /// app may wrap a plain [MaterialApp] in [IxDensityScope], or simply
  /// forget `theme: IxThemeBuilder().build()`); the Material component
  /// tap-target adaptation below applies regardless, but the `IxTheme`
  /// re-stamp is skipped rather than throwing when there is no `IxTheme`
  /// to re-stamp.
  static ThemeData apply(ThemeData base, IxDensity density) {
    final tts = density.tapTargetSize;
    ButtonStyle? withTts(ButtonStyle? style) =>
        (style ?? const ButtonStyle()).copyWith(tapTargetSize: tts);
    final ixTheme = base.extension<IxTheme>();

    return base.copyWith(
      materialTapTargetSize: tts,
      filledButtonTheme: FilledButtonThemeData(
        style: withTts(base.filledButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: withTts(base.elevatedButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: withTts(base.outlinedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: withTts(base.textButtonTheme.style),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: withTts(base.iconButtonTheme.style),
      ),
      checkboxTheme: base.checkboxTheme.copyWith(materialTapTargetSize: tts),
      radioTheme: base.radioTheme.copyWith(materialTapTargetSize: tts),
      switchTheme: base.switchTheme.copyWith(materialTapTargetSize: tts),
      sliderTheme: base.sliderTheme.copyWith(
        overlayShape: density == IxDensity.comfortable
            ? const RoundSliderOverlayShape(overlayRadius: 24)
            : const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      extensions: [
        ...base.extensions.values.where((e) => e is! IxTheme),
        if (ixTheme != null) ixTheme.copyWith(density: density),
      ],
    );
  }
}
