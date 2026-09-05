import 'package:flutter/material.dart';

import 'ix_icon_data.dart';
import 'ix_icon_key.dart';

/// Theme extension that maps every [IxIconKey] to concrete [IxIconData].
///
/// Register a custom resolver via `IxThemeBuilder(icons: ...)` to replace
/// individual icons (e.g. swap in the bundled Siemens iX SVG set); anything
/// the resolver leaves unspecified falls back to [IxIconResolver.material],
/// so a partial map is a complete resolver.
/// Until the SVG set ships (gated behind legal review), [material] is the
/// default resolver registered by `IxThemeBuilder`.
class IxIconResolver extends ThemeExtension<IxIconResolver> {
  /// Creates a resolver backed by an explicit [icons] map.
  ///
  /// The map does not need to cover every [IxIconKey]: [resolve] falls back
  /// to [IxIconResolver.material] for any key it omits, so a resolver that
  /// declares a single override is a complete, usable resolver. Layering
  /// overrides with [copyWith] on top of [IxIconResolver.material] is still
  /// the way to get a resolver whose own map is exhaustive.
  const IxIconResolver({required this.icons});

  /// The backing key-to-data map.
  ///
  /// May be partial — an override map produced by [copyWith], or one written
  /// by hand. It is the *declared* set, not the resolvable set; see
  /// [resolve].
  final Map<IxIconKey, IxIconData> icons;

  /// The built-in Material resolver, created on first use.
  ///
  /// Every other resolver falls back to it (see [resolve]), so its map must
  /// stay total over `IxIconKey.values`; a test pins that.
  static final IxIconResolver _material = IxIconResolver.material();

  /// Builds a resolver that maps every [IxIconKey] to a Material [IconData]
  /// glyph.
  ///
  /// This is the default resolver `IxThemeBuilder` registers when no
  /// `icons:` override is supplied, and the fallback branch used while the
  /// bundled Siemens iX SVG set is pending legal review (see
  /// `UPSTREAM.md`).
  factory IxIconResolver.material() {
    IxIconData glyph(IconData icon) => IxIconData.material(icon);
    return IxIconResolver(
      icons: Map.unmodifiable({
        IxIconKey.chevronLeft: glyph(Icons.chevron_left),
        IxIconKey.chevronRight: glyph(Icons.chevron_right),
        IxIconKey.chevronUp: glyph(Icons.expand_less),
        IxIconKey.chevronDown: glyph(Icons.expand_more),
        IxIconKey.chevronLeftSmall: glyph(Icons.chevron_left),
        IxIconKey.chevronRightSmall: glyph(Icons.chevron_right),
        IxIconKey.chevronUpSmall: glyph(Icons.expand_less),
        IxIconKey.chevronDownSmall: glyph(Icons.expand_more),
        IxIconKey.close: glyph(Icons.close),
        IxIconKey.closeSmall: glyph(Icons.close),
        IxIconKey.apps: glyph(Icons.apps),
        IxIconKey.moreMenu: glyph(Icons.more_vert),
        IxIconKey.search: glyph(Icons.search),
        IxIconKey.info: glyph(Icons.info_outline),
        IxIconKey.about: glyph(Icons.info_outline),
        IxIconKey.success: glyph(Icons.check_circle_outline),
        IxIconKey.warning: glyph(Icons.warning_amber),
        IxIconKey.error: glyph(Icons.error_outline),
        IxIconKey.alarm: glyph(Icons.notifications_active_outlined),
        IxIconKey.home: glyph(Icons.home_outlined),
        IxIconKey.document: glyph(Icons.description_outlined),
        IxIconKey.cogwheel: glyph(Icons.settings_outlined),
        IxIconKey.lightDark: glyph(Icons.brightness_6_outlined),
        IxIconKey.doubleChevronLeft: glyph(Icons.keyboard_double_arrow_left),
        IxIconKey.doubleChevronRight: glyph(Icons.keyboard_double_arrow_right),
        IxIconKey.sun: glyph(Icons.wb_sunny_outlined),
        IxIconKey.moon: glyph(Icons.nightlight_round_outlined),
        IxIconKey.filter: glyph(Icons.filter_list),
      }),
    );
  }

  /// Resolves [key] to its [IxIconData].
  ///
  /// Never fails: a key this resolver's own [icons] map does not declare
  /// falls back to [IxIconResolver.material]'s glyph for it. Every
  /// [IxIconKey] is therefore resolvable through any resolver, which is what
  /// lets a consumer register a one-key override with
  /// `IxThemeBuilder(icons:)` without every built-in widget that asks for
  /// some other key breaking.
  IxIconData resolve(IxIconKey key) => icons[key] ?? _material.icons[key]!;

  /// Resolves the [IxIconResolver] registered on the closest [Theme], or
  /// [IxIconResolver.material] if the [ThemeData] carries no such extension
  /// (e.g. a plain `MaterialApp` not built via `IxThemeBuilder`).
  static IxIconResolver of(BuildContext context) =>
      Theme.of(context).extension<IxIconResolver>() ??
      IxIconResolver.material();

  /// Returns a copy with [icons] merged over the current [icons] map, so
  /// individual keys can be overridden without losing the rest.
  @override
  IxIconResolver copyWith({Map<IxIconKey, IxIconData>? icons}) {
    if (icons == null) {
      return this;
    }
    return IxIconResolver(icons: Map.unmodifiable({...this.icons, ...icons}));
  }

  /// Resolvers hold discrete, non-interpolable icon sources, so instead of
  /// blending, this switches wholesale from `this` to [other] at the theme
  /// animation's midpoint.
  @override
  IxIconResolver lerp(ThemeExtension<IxIconResolver>? other, double t) {
    if (other is! IxIconResolver) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
