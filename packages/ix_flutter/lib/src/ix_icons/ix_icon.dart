import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ix_colors/ix_theme_color_tokens.dart';
import '../ix_theme/ix_theme_builder.dart';
import 'ix_icon_data.dart';
import 'ix_icon_key.dart';
import 'ix_icon_resolver.dart';
import 'ix_icon_size.dart';

/// Renders a single Siemens IX icon from an explicit [IxIconData] source or,
/// via [IxIcon.key], from the app's registered [IxIconResolver].
///
/// Every [IxIcon] occupies a fixed [size.px] square box regardless of its
/// source (a Material glyph, a bundled SVG, or a custom widget builder), so
/// swapping sources — including falling back from a broken SVG asset to its
/// Material [IxIconData.fallback] — never changes layout, hit area, or
/// semantics.
class IxIcon extends StatelessWidget {
  /// Renders [data] directly.
  const IxIcon(
    this.data, {
    super.key,
    this.size = IxIconSize.s24,
    this.color,
    this.colorToken,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }) : iconKey = null;

  /// Renders the icon [IxIconResolver.of] the surrounding context resolves
  /// [iconKey] to.
  const IxIcon.key(
    this.iconKey, {
    super.key,
    this.size = IxIconSize.s24,
    this.color,
    this.colorToken,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }) : data = null;

  /// The explicit icon source, set by the default constructor.
  final IxIconData? data;

  /// The resolver key, set by [IxIcon.key].
  final IxIconKey? iconKey;

  /// The fixed square box size to render at. Defaults to [IxIconSize.s24].
  final IxIconSize size;

  /// Overrides the resolved color outright, taking precedence over
  /// [colorToken] and every other fallback.
  final Color? color;

  /// A Siemens IX color token resolved through [IxTheme], used when [color]
  /// is not set.
  final IxThemeColorToken? colorToken;

  /// Overrides the semantic label the icon data itself may declare.
  final String? semanticLabel;

  /// When `true`, hides this icon and its label from the semantics tree
  /// entirely (for purely decorative icons next to a labelled control).
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final resolved = data ?? IxIconResolver.of(context).resolve(iconKey!);
    final ix = Theme.of(context).extension<IxTheme>();
    final resolvedColor =
        color ??
        (colorToken != null && ix != null ? ix.color(colorToken!) : null) ??
        IconTheme.of(context).color ??
        ix?.color(IxThemeColorToken.stdText) ??
        Theme.of(context).colorScheme.onSurface;
    final label = semanticLabel ?? resolved.semanticLabel;

    Widget child = switch (resolved) {
      IxMaterialIconData(icon: final icon) => Icon(
        icon,
        size: size.px,
        color: resolvedColor,
      ),
      IxWidgetIconData(builder: final builder) => IconTheme(
        data: IconThemeData(size: size.px, color: resolvedColor),
        child: Builder(builder: builder),
      ),
      IxPackageIconData() ||
      IxAssetIconData() => _svg(context, resolved, resolvedColor),
    };
    child = SizedBox.square(
      dimension: size.px,
      child: Center(child: child),
    );
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }
    return Semantics(label: label, image: label != null, child: child);
  }

  /// Renders a bundled/asset SVG source through [SvgPicture.asset], tinted
  /// with [color] via a `srcIn` color filter.
  ///
  /// If the asset is missing or the SVG fails to decode, [errorBuilder]
  /// swaps in `data.fallback ?? Icons.broken_image` at the same size (the
  /// enclosing `SizedBox`/`Semantics` in [build] never changes), and — in
  /// debug mode — reports the failure via [FlutterError.reportError] under
  /// the `ix_flutter icons` library name so the app's error console/crash
  /// reporting surfaces it without crashing the UI.
  Widget _svg(BuildContext context, IxIconData data, Color color) {
    final (path, package) = switch (data) {
      IxPackageIconData(assetPath: final p) => (p, 'ix_flutter'),
      IxAssetIconData(assetPath: final p, package: final pk) => (p, pk),
      _ => throw StateError('not an asset icon'),
    };
    return SvgPicture.asset(
      path,
      package: package,
      width: size.px,
      height: size.px,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox.square(dimension: size.px),
      errorBuilder: (context, error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'ix_flutter icons',
            context: ErrorDescription(
              'while loading icon "$path" (package: $package); using '
              'material fallback',
            ),
          ),
        );
        return Icon(
          data.fallback ?? Icons.broken_image,
          size: size.px,
          color: color,
        );
      },
    );
  }
}
