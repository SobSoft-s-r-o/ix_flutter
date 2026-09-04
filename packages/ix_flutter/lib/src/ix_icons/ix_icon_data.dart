import 'package:flutter/widgets.dart';

/// Describes where an [IxIcon] gets its visual content from.
///
/// [fallback] is only ever used when the primary source fails to load or
/// decode (a missing/corrupt asset, or an SVG parsing failure) — it never
/// changes the icon's box size, hit area, or semantics.
sealed class IxIconData {
  /// Base constructor shared by every [IxIconData] subclass; construct a
  /// concrete variant through one of the `IxIconData.*` factories instead.
  const IxIconData({this.fallback, this.semanticLabel});

  /// Material glyph rendered in place of the primary source if it fails to
  /// load or decode. `null` means no fallback is available.
  final IconData? fallback;

  /// Overrides the semantic label an [IxIcon] otherwise leaves unset.
  ///
  /// `IxIcon(data, semanticLabel: ...)` always takes precedence over this
  /// value.
  final String? semanticLabel;

  /// An icon bundled with the `ix_flutter` package itself, addressed by its
  /// [IxIconKey]-derived asset name (see [IxPackageIconData.assetPath]).
  const factory IxIconData.packageAsset(
    String name, {
    IconData? fallback,
    String? semanticLabel,
  }) = IxPackageIconData;

  /// An icon loaded from an arbitrary asset path, optionally scoped to
  /// another package.
  const factory IxIconData.asset(
    String assetPath, {
    String? package,
    IconData? fallback,
    String? semanticLabel,
  }) = IxAssetIconData;

  /// A Material [IconData] glyph, rendered directly (no SVG involved).
  const factory IxIconData.material(IconData icon, {String? semanticLabel}) =
      IxMaterialIconData;

  /// A fully custom icon built by an application-supplied [WidgetBuilder].
  const factory IxIconData.widget(
    WidgetBuilder builder, {
    IconData? fallback,
    String? semanticLabel,
  }) = IxWidgetIconData;
}

/// An icon bundled with the `ix_flutter` package under
/// `assets/icons/internal/`.
final class IxPackageIconData extends IxIconData {
  /// Creates package-asset icon data for the internal icon named [name].
  const IxPackageIconData(this.name, {super.fallback, super.semanticLabel});

  /// The bare icon name (without directory or `.svg` extension), matching an
  /// `IxIconKey`'s generated SVG asset.
  final String name;

  /// The resolved asset path within the `ix_flutter` package.
  String get assetPath => 'assets/icons/internal/$name.svg';
}

/// An icon loaded from an arbitrary asset path, optionally scoped to
/// another package via [package].
final class IxAssetIconData extends IxIconData {
  /// Creates asset icon data pointing at [assetPath].
  const IxAssetIconData(
    this.assetPath, {
    this.package,
    super.fallback,
    super.semanticLabel,
  });

  /// The asset path passed to the underlying asset loader.
  final String assetPath;

  /// The package [assetPath] is scoped to, or `null` for the consuming
  /// application's own assets.
  final String? package;
}

/// A Material [IconData] glyph, rendered directly by [IxIcon] via [Icon].
final class IxMaterialIconData extends IxIconData {
  /// Creates Material icon data for [icon].
  ///
  /// [fallback] is always [icon] itself — a Material glyph cannot fail to
  /// load or decode the way an SVG asset can.
  const IxMaterialIconData(this.icon, {super.semanticLabel})
    : super(fallback: icon);

  /// The Material glyph to render.
  final IconData icon;
}

/// A fully custom icon rendered by invoking [builder].
final class IxWidgetIconData extends IxIconData {
  /// Creates widget icon data backed by [builder].
  const IxWidgetIconData(this.builder, {super.fallback, super.semanticLabel});

  /// Builds the icon's visual content. Invoked inside an [IconTheme] that
  /// carries the requested size and color.
  final WidgetBuilder builder;
}
