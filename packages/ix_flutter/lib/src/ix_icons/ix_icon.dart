import 'dart:async';
import 'dart:typed_data';

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
/// Every [IxIcon] occupies a fixed square box regardless of its source (a
/// Material glyph, a bundled SVG, or a custom widget builder), so swapping
/// sources — including falling back from a broken SVG asset to its Material
/// [IxIconData.fallback] — never changes layout, hit area, or semantics.
///
/// The box is the explicit [size], else the ambient [IconTheme] size (used
/// exactly, not snapped to an [IxIconSize]), else 24 px. That makes an
/// [IxIcon] interchangeable with a Material [Icon] in any slot that styles
/// its icon through an [IconTheme] — [IxIconButton], `TextButton.icon`,
/// `InputDecoration.prefixIcon` — while an explicit [size] still wins over
/// whatever the surrounding slot asks for.
class IxIcon extends StatelessWidget {
  /// Renders [data] directly.
  const IxIcon(
    this.data, {
    super.key,
    this.size,
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
    this.size,
    this.color,
    this.colorToken,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }) : data = null;

  /// The explicit icon source, set by the default constructor.
  final IxIconData? data;

  /// The resolver key, set by [IxIcon.key].
  final IxIconKey? iconKey;

  /// The fixed square box size to render at.
  ///
  /// When `null` (the default) the ambient [IconTheme]'s size is used —
  /// exactly as given, so a slot asking for a non-[IxIconSize] value such as
  /// `TextButton.icon`'s 18 px is honoured — falling back to 24 px
  /// ([IxIconSize.s24], and `MaterialApp`'s own default) when the ambient
  /// theme declares no size either.
  final IxIconSize? size;

  /// The default box size, in logical pixels, when neither [size] nor the
  /// ambient [IconTheme] says anything.
  static const double _defaultSizePx = 24;

  /// Forgets every SVG asset whose load has failed, and the cached empty-SVG
  /// bytes handed to `flutter_svg` in their place.
  ///
  /// [IxIcon] remembers a failed asset — identified by its path, package and
  /// [AssetBundle] — for the life of the process, so a missing or corrupt
  /// icon is not re-loaded (and re-reported) by every later instance of it.
  /// That is the right behaviour for an application, where a bundle does not
  /// change under a running app, and the wrong one for a test suite, where
  /// each test wants a clean slate:
  ///
  /// ```dart
  /// setUp(IxIcon.debugResetFailedSvgAssets);
  /// tearDown(IxIcon.debugResetFailedSvgAssets);
  /// ```
  ///
  /// Every currently mounted [IxIcon] rebuilds, so an icon showing the
  /// Material fallback retries its asset on the next frame.
  @visibleForTesting
  static void debugResetFailedSvgAssets() {
    _IxSvgFailures.reset();
    _emptySvgBytes = null;
  }

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
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size?.px ?? iconTheme.size ?? _defaultSizePx;
    final resolvedColor =
        color ??
        (colorToken != null && ix != null ? ix.color(colorToken!) : null) ??
        iconTheme.color ??
        ix?.color(IxThemeColorToken.stdText) ??
        Theme.of(context).colorScheme.onSurface;
    final label = semanticLabel ?? resolved.semanticLabel;

    Widget child = switch (resolved) {
      IxMaterialIconData(icon: final icon) => Icon(
        icon,
        size: resolvedSize,
        color: resolvedColor,
      ),
      IxWidgetIconData(builder: final builder) => IconTheme(
        data: IconThemeData(size: resolvedSize, color: resolvedColor),
        child: Builder(builder: builder),
      ),
      IxPackageIconData() ||
      IxAssetIconData() => _svg(context, resolved, resolvedColor, resolvedSize),
    };
    child = SizedBox.square(
      dimension: resolvedSize,
      child: Center(child: child),
    );
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }
    return Semantics(label: label, image: label != null, child: child);
  }

  /// Renders a bundled/asset SVG source through `flutter_svg`, tinted with
  /// [color] via a `srcIn` color filter.
  ///
  /// If the asset is missing or the SVG fails to decode, the icon swaps in
  /// `data.fallback ?? Icons.broken_image` at the same size (the enclosing
  /// `SizedBox`/`Semantics` in [build] never changes) and — in debug builds
  /// only — reports the failure via [FlutterError.reportError] under the
  /// `ix_flutter icons` library name, so the app's error console or crash
  /// reporting surfaces it without crashing the UI. The failure never
  /// escapes as an uncaught asynchronous error; see [_IxGuardedSvgLoader].
  Widget _svg(
    BuildContext context,
    IxIconData data,
    Color color,
    double sizePx,
  ) {
    final (path, package) = switch (data) {
      IxPackageIconData(assetPath: final p) => (p, 'ix_flutter'),
      IxAssetIconData(assetPath: final p, package: final pk) => (p, pk),
      _ => throw StateError('not an asset icon'),
    };
    return _IxSvgIcon(
      loader: _IxGuardedSvgLoader(SvgAssetLoader(path, packageName: package)),
      fallback: data.fallback ?? Icons.broken_image,
      sizePx: sizePx,
      color: color,
    );
  }
}

/// Process-wide record of the SVG asset keys whose load has already failed,
/// plus the listeners that want to hear about a new one.
///
/// An asset that failed once — it is missing from the bundle, or its content
/// is not decodable SVG — cannot start working later in the same process, so
/// every [IxIcon] for that key renders its Material fallback straight away
/// instead of paying for (and reporting) the same failing load again.
///
/// A plain listener set rather than a [ChangeNotifier]: this registry lives
/// for the life of the process by design, and a never-disposed
/// [ChangeNotifier] is exactly what leak-tracking test suites flag.
abstract final class _IxSvgFailures {
  static final Set<Object> _keys = <Object>{};
  static final Set<VoidCallback> _listeners = <VoidCallback>{};

  static bool contains(Object key) => _keys.contains(key);

  static void addListener(VoidCallback listener) => _listeners.add(listener);

  static void removeListener(VoidCallback listener) =>
      _listeners.remove(listener);

  /// Records [key] as failed.
  ///
  /// Returns `true` only for a key that was not already recorded, so a
  /// caller reports the failure exactly once even when several loads of the
  /// same asset are in flight together (two `SvgTheme`s, say, are two
  /// separate `flutter_svg` cache entries and therefore two separate loads).
  static bool record(Object key) {
    if (!_keys.add(key)) {
      return false;
    }
    _notify();
    return true;
  }

  /// See [IxIcon.debugResetFailedSvgAssets].
  static void reset() {
    if (_keys.isEmpty) {
      return;
    }
    _keys.clear();
    _notify();
  }

  static void _notify() {
    for (final listener in _listeners.toList(growable: false)) {
      listener();
    }
  }
}

/// The compiled bytes of an empty SVG, built once and reused.
///
/// Handed to `flutter_svg` in place of a load that failed, so the future it
/// receives always succeeds (see [_IxGuardedSvgLoader.loadBytes]). Nothing is
/// ever painted from it: the widget has already switched to the Material
/// fallback by the time these bytes arrive.
Future<ByteData>? _emptySvgBytes;

Future<ByteData> _loadEmptySvg(BuildContext? context) {
  return _emptySvgBytes ??= const SvgStringLoader(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"/>',
  ).loadBytes(context);
}

/// Wraps an [SvgAssetLoader] so that a failing load is contained instead of
/// escaping into the application's zone.
///
/// Two separate leaks make an unguarded `SvgPicture.asset` report a missing
/// or corrupt icon as an *uncaught asynchronous error*, on top of whatever
/// its `errorBuilder` does:
///
/// * `flutter_svg`'s `Cache.putIfAbsent` chains a `.then()` with no error
///   handler onto the load future purely to update its own bookkeeping
///   (`flutter_svg/lib/src/cache.dart`, unchanged across 2.x). The derived
///   future it creates is never observed, so a rejected load is reported to
///   whichever zone started the load. Starting it inside
///   [runZonedGuarded] here keeps that report where the failure is already
///   handled below.
/// * `vector_graphics`' `_VectorGraphicWidgetState._loadPicture` chains a
///   `whenComplete()` onto the same future to clear its pending map, which
///   leaks the same way. That one is out of reach — so this loader simply
///   never fails: on error it reports once, records the key, and completes
///   with the bytes of an empty SVG.
///
/// [cacheKey] delegates to the wrapped loader, so wrapping does not split
/// `flutter_svg`'s picture cache.
class _IxGuardedSvgLoader extends BytesLoader {
  const _IxGuardedSvgLoader(this.inner);

  final SvgAssetLoader inner;

  /// The key this loader's failures are remembered under.
  ///
  /// The wrapped loader's own `SvgCacheKey.keyData` — the asset path, its
  /// package, and the [AssetBundle] resolved from [context] — so a path that
  /// is missing from one bundle does not condemn the same path in another.
  ///
  /// Deliberately *not* the whole `SvgCacheKey`: that also carries the
  /// [SvgTheme], and whether an asset exists and decodes has nothing to do
  /// with the theme it would be encoded with. Keying on the theme too would
  /// record — and report — the same missing asset once per theme in use.
  Object failureKey(BuildContext? context) => inner.cacheKey(context).keyData;

  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    final key = failureKey(context);
    if (_IxSvgFailures.contains(key)) {
      return _loadEmptySvg(context);
    }
    final completer = Completer<ByteData>();
    // The wrapped load's own failure, so the zone handler below can tell it
    // apart from anything else that fails in there. `flutter_svg`'s
    // unobserved cache future is completed *before* the handler this loader
    // attached to the same load future, so the leaked copy reliably reaches
    // the zone before `handledError` is known -- hence the buffer, drained
    // once the load has settled and the comparison can actually be made.
    Object? handledError;
    var settled = false;
    final buffered = <(Object, StackTrace)>[];

    void reportUnrelated(Object error, StackTrace stack) {
      // Not this loader's to hide: a future `flutter_svg` change could route
      // an unrelated failure through the same call, and silently dropping it
      // would be worse than the leak this guard closes. Reported rather than
      // rethrown so it still cannot crash the app from here, and
      // unconditionally -- unlike the load's own failure, which the fallback
      // glyph already makes visible, this one has no other trace.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'ix_flutter icons',
          context: ErrorDescription(
            'caught by the guarded loader for icon "${inner.assetName}" '
            '(package: ${inner.packageName}) but unrelated to its own '
            'load failure',
          ),
        ),
      );
    }

    void settle() {
      settled = true;
      for (final (error, stack) in buffered) {
        if (!identical(error, handledError)) {
          reportUnrelated(error, stack);
        }
      }
      buffered.clear();
    }

    runZonedGuarded(
      () {
        Future<ByteData> load;
        try {
          load = inner.loadBytes(context);
        } catch (error, stack) {
          // A loader that throws synchronously (an asset bundle that does
          // not defer its lookup, say) must take the same path as one whose
          // future fails -- otherwise the error would only reach the zone
          // handler and the completer below would never complete.
          load = Future<ByteData>.error(error, stack);
        }
        load.then(
          (ByteData bytes) {
            settle();
            completer.complete(bytes);
          },
          onError: (Object error, StackTrace stack) {
            handledError = error;
            settle();
            // Report only for a key that was not already known to have
            // failed: several loads of the same asset can be in flight
            // at once (one per `SvgTheme`), and they are one failure.
            if (_IxSvgFailures.record(key)) {
              _report(error, stack);
            }
            // `null`, not `context`: this runs after an async gap, so
            // the element may already be gone. The empty SVG carries no
            // `currentColor`/font-size units, so the default `SvgTheme`
            // encodes it identically to the ambient one.
            _loadEmptySvg(null).then(
              completer.complete,
              // The empty SVG is a compile-time constant string; if even
              // that cannot be encoded there is nothing left to render,
              // so complete with an empty buffer rather than handing
              // flutter_svg a failed future after all.
              onError: (Object _, StackTrace _) =>
                  completer.complete(ByteData(0)),
            );
          },
        );
      },
      (Object error, StackTrace stack) {
        if (!settled) {
          buffered.add((error, stack));
          return;
        }
        if (identical(error, handledError)) {
          // flutter_svg's unobserved cache-bookkeeping rejection for the
          // failure already reported above (see the class doc). Swallowed
          // on purpose: it is the leak this loader exists to close, and
          // re-reporting it would duplicate the error.
          return;
        }
        reportUnrelated(error, stack);
      },
    );
    return completer.future;
  }

  void _report(Object error, StackTrace? stack) {
    assert(() {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'ix_flutter icons',
          context: ErrorDescription(
            'while loading icon "${inner.assetName}" '
            '(package: ${inner.packageName}); using material fallback',
          ),
        ),
      );
      return true;
    }());
  }

  @override
  Object cacheKey(BuildContext? context) => inner.cacheKey(context);

  @override
  int get hashCode => inner.hashCode;

  @override
  bool operator ==(Object other) =>
      other is _IxGuardedSvgLoader && other.inner == inner;
}

/// The SVG branch of [IxIcon]: an `SvgPicture` that swaps itself for the
/// Material [fallback] as soon as its asset is known to be unloadable.
///
/// A [StatefulWidget] because the swap is driven by an asynchronous load
/// failure recorded in [_IxSvgFailures]. An icon built *after* that failure
/// renders the fallback in its very first build, without asking the loader
/// again.
class _IxSvgIcon extends StatefulWidget {
  const _IxSvgIcon({
    required this.loader,
    required this.fallback,
    required this.sizePx,
    required this.color,
  });

  final _IxGuardedSvgLoader loader;
  final IconData fallback;
  final double sizePx;
  final Color color;

  @override
  State<_IxSvgIcon> createState() => _IxSvgIconState();
}

class _IxSvgIconState extends State<_IxSvgIcon> {
  @override
  void initState() {
    super.initState();
    _IxSvgFailures.addListener(_onFailureRecorded);
  }

  @override
  void dispose() {
    _IxSvgFailures.removeListener(_onFailureRecorded);
    super.dispose();
  }

  void _onFailureRecorded() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _fallbackIcon() =>
      Icon(widget.fallback, size: widget.sizePx, color: widget.color);

  @override
  Widget build(BuildContext context) {
    if (_IxSvgFailures.contains(widget.loader.failureKey(context))) {
      return _fallbackIcon();
    }
    return SvgPicture(
      widget.loader,
      width: widget.sizePx,
      height: widget.sizePx,
      colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
      placeholderBuilder: (_) => SizedBox.square(dimension: widget.sizePx),
      // Belt and braces: the guarded loader never fails, so this only runs
      // if flutter_svg rejects bytes it did accept from the loader.
      errorBuilder: (context, error, stack) {
        widget.loader._report(error, stack);
        return _fallbackIcon();
      },
    );
  }
}
