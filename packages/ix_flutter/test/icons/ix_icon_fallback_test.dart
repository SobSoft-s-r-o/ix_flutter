import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/fixture_asset_bundle.dart';
import '../helpers/pump_ix.dart';

Widget _bundled(Widget child, Map<String, String> files) =>
    DefaultAssetBundle(bundle: FixtureAssetBundle(files), child: child);

Widget _inBundle(Widget child, AssetBundle bundle) =>
    DefaultAssetBundle(bundle: bundle, child: child);

/// A bundle whose every load fails *and* leaks an unrelated, unobserved
/// asynchronous error into whatever zone asked for the asset.
///
/// That second failure is the one `IxIcon`'s guard must not hide: it is not
/// the load's own error, so swallowing it would mean a future `flutter_svg`
/// change could silently take unrelated application errors with it.
class _LeakyAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Unobserved on purpose, and created in the caller's zone -- exactly the
    // shape of the `flutter_svg` cache leak, but with an unrelated error.
    Future<void>.error(StateError('unrelated bookkeeping failure'));
    throw FlutterError('Unable to load asset: "$key" (leaky fixture)');
  }
}

/// Leaks the same unrelated error, then hands back a load that never
/// settles at all — a bundle waiting on a network call that hangs, say.
///
/// The guard cannot compare an unrelated error against a failure that never
/// arrives, so it must not hold it back indefinitely either.
class _StalledAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    Future<void>.error(StateError('unrelated bookkeeping failure'));
    return Completer<ByteData>().future;
  }
}

const String _brokenFixture = 'test/fixtures/icons/broken.svg';
const String _validFixture = 'test/fixtures/icons/valid.svg';

/// Runs [body] inside a zone that *collects* uncaught asynchronous errors
/// (rather than swallowing them) and returns whatever escaped, so a test can
/// assert that a failing icon load leaks nothing into the app's zone.
///
/// Errors raised by [body] itself are forwarded to the caller instead of
/// being counted as leaks, so a failing pump still fails its test.
Future<List<Object>> _uncaughtDuring(Future<void> Function() body) async {
  final uncaught = <Object>[];
  final done = Completer<void>();
  runZonedGuarded(() {
    body().then(
      (_) => done.complete(),
      onError: (Object error, StackTrace stack) =>
          done.completeError(error, stack),
    );
  }, (Object error, StackTrace stack) => uncaught.add(error));
  await done.future;
  return uncaught;
}

const String _iconLibrary = 'ix_flutter icons';

/// Captures everything reported through [FlutterError.reportError] for the
/// duration of one test, and restores the previous handler afterwards.
///
/// Reports from [_iconLibrary] are `IxIcon`'s own deliberate, documented
/// debug-mode reporting and are swallowed here; everything else is forwarded
/// to the previous handler so the test binding still treats it as a failure.
/// That matters for the leak this file guards: an uncaught asynchronous
/// error reaches the binding as a `Flutter test framework` report, and
/// swallowing it here would both hide the leak and trip the binding's own
/// `_pendingExceptionDetails != null` invariant.
List<FlutterErrorDetails> _captureReportedErrors() {
  final reported = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    reported.add(details);
    if (details.library != _iconLibrary) {
      previous?.call(details);
    }
  };
  addTearDown(() => FlutterError.onError = previous);
  return reported;
}

Iterable<FlutterErrorDetails> _iconErrors(List<FlutterErrorDetails> all) =>
    all.where((e) => e.library == _iconLibrary);

Iterable<FlutterErrorDetails> _otherErrors(List<FlutterErrorDetails> all) =>
    all.where((e) => e.library != _iconLibrary);

/// Guards `IxIcon`'s emergency Material fallback, which has no direct
/// upstream `.ct.ts`/scss counterpart to cite via `@Upstream`.
///
/// The plan's fallback policy
/// (`docs/superpowers/plans/2026-09-04-ix-flutter-2-0-icons-runtime.md`)
/// states that Material glyphs remain an emergency fallback only — a missing
/// asset, a corrupt SVG, or an explicit `IxIconResolver.material()` — that iX
/// and Material glyphs are never mixed on the success path, and that the
/// fallback never changes the icon's `SizedBox` size, hit area, or
/// `Semantics`. These tests exercise all three fallback triggers plus the
/// unaffected success path.
///
/// They also pin the containment requirement: a failing load must not escape
/// as an uncaught asynchronous error. `flutter_svg`'s `Cache.putIfAbsent`
/// (`src/cache.dart`) chains an error-handler-less `.then()` onto the load
/// future purely to update its own bookkeeping, so a rejected load is
/// reported to whatever zone started it — which, without containment inside
/// `IxIcon`, is the application's own zone.
///
/// `IxIcon` remembers a failed asset for the life of the process, so every
/// test here clears that record through
/// [IxIcon.debugResetFailedSvgAssets] in an `addTearDown` rather than
/// tiptoeing around it with a unique asset name per test.
void main() {
  setUp(IxIcon.debugResetFailedSvgAssets);
  tearDown(IxIcon.debugResetFailedSvgAssets);

  testWidgets('a missing asset falls back with the same box and semantics, '
      'and leaks no uncaught error', (tester) async {
    final handle = tester.ensureSemantics();
    final reported = _captureReportedErrors();

    late List<Object> uncaught;
    await tester.runAsync(() async {
      uncaught = await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(
              IxIconData.asset('missing.svg', fallback: Icons.close),
              size: IxIconSize.s16,
              semanticLabel: 'Close',
              key: Key('i'),
            ),
            const {},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();

    expect(uncaught, isEmpty);
    expect(_otherErrors(reported), isEmpty);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('i'))), const Size(16, 16));
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    // The failure is still surfaced, just not as an uncaught error.
    expect(_iconErrors(reported), isNotEmpty);
    handle.dispose();
  });

  testWidgets('a corrupt SVG falls back, reports in debug and leaks no '
      'uncaught error', (tester) async {
    final reported = _captureReportedErrors();

    late List<Object> uncaught;
    await tester.runAsync(() async {
      uncaught = await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(
              IxIconData.asset('broken.svg', fallback: Icons.info),
              key: Key('i'),
            ),
            const {'broken.svg': _brokenFixture},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();

    expect(uncaught, isEmpty);
    expect(_otherErrors(reported), isEmpty);
    expect(find.byIcon(Icons.info), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('i'))), const Size(24, 24));
    expect(_iconErrors(reported), isNotEmpty);
  });

  testWidgets('a second icon for an asset that already failed falls back on '
      'its first frame, without loading again', (tester) async {
    final reported = _captureReportedErrors();
    // One bundle for both pumps: a recorded failure belongs to the bundle it
    // happened in (see the bundle test below), so a fresh one would be a
    // different asset as far as the registry is concerned.
    final bundle = FixtureAssetBundle(const {});

    await tester.runAsync(() async {
      final uncaught = await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _inBundle(
            const IxIcon(
              IxIconData.asset('missing.svg', fallback: Icons.close),
            ),
            bundle,
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
      expect(uncaught, isEmpty);
    });
    expect(_otherErrors(reported), isEmpty);
    expect(_iconErrors(reported), hasLength(1));
    reported.clear();

    // A brand-new icon for the same asset. No extra pump: the recorded
    // failure means the fallback is what its very first build produces, and
    // the loader is never asked for the asset a second time (which is what
    // an empty `reported` shows -- a second load attempt would report again).
    await pumpIx(
      tester,
      _inBundle(
        const IxIcon(
          IxIconData.asset('missing.svg', fallback: Icons.close),
          key: Key('second'),
        ),
        bundle,
      ),
    );
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('second'))), const Size(24, 24));
    expect(reported, isEmpty);
  });

  testWidgets('a valid SVG renders through flutter_svg and reports nothing', (
    tester,
  ) async {
    final reported = _captureReportedErrors();

    late List<Object> uncaught;
    await tester.runAsync(() async {
      uncaught = await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(IxIconData.asset('valid.svg', fallback: Icons.info)),
            const {'valid.svg': _validFixture},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();

    expect(uncaught, isEmpty);
    expect(reported, isEmpty);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('the same missing asset under two SvgThemes reports once', (
    tester,
  ) async {
    final reported = _captureReportedErrors();

    late List<Object> uncaught;
    await tester.runAsync(() async {
      uncaught = await _uncaughtDuring(() async {
        // Two `SvgTheme`s means two separate `flutter_svg` cache entries, so
        // both icons really do start their own load in the same frame --
        // whether the asset exists has nothing to do with the theme, so the
        // pair must still be recorded and reported once.
        await pumpIx(
          tester,
          _bundled(
            const Column(
              children: [
                DefaultSvgTheme(
                  theme: SvgTheme(fontSize: 12),
                  child: IxIcon(
                    IxIconData.asset('missing.svg', fallback: Icons.close),
                  ),
                ),
                DefaultSvgTheme(
                  theme: SvgTheme(fontSize: 24),
                  child: IxIcon(
                    IxIconData.asset('missing.svg', fallback: Icons.close),
                  ),
                ),
              ],
            ),
            const {},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();

    expect(uncaught, isEmpty);
    expect(_otherErrors(reported), isEmpty);
    expect(find.byIcon(Icons.close), findsNWidgets(2));
    expect(_iconErrors(reported), hasLength(1));
  });

  testWidgets('a failure recorded for one bundle does not condemn the same '
      'path in another', (tester) async {
    final reported = _captureReportedErrors();

    await tester.runAsync(() async {
      await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(IxIconData.asset('valid.svg', fallback: Icons.info)),
            const {},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();
    expect(find.byIcon(Icons.info), findsOneWidget, reason: 'missing here');
    expect(_iconErrors(reported), hasLength(1));

    // The very same asset path, served by a different bundle that does have
    // it: the recorded failure belongs to the bundle it happened in.
    await tester.runAsync(() async {
      await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(IxIconData.asset('valid.svg', fallback: Icons.info)),
            const {'valid.svg': _validFixture},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('an unrelated async error raised by the load is not swallowed', (
    tester,
  ) async {
    final reported = _captureReportedErrors();

    await tester.runAsync(() async {
      await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          DefaultAssetBundle(
            bundle: _LeakyAssetBundle(),
            child: const IxIcon(
              IxIconData.asset('missing.svg', fallback: Icons.close),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();

    expect(find.byIcon(Icons.close), findsOneWidget);
    // The load's own failure, reported as usual...
    expect(
      _iconErrors(reported).where((e) => e.exception is FlutterError),
      isNotEmpty,
    );
    // ...and the unrelated one, surfaced rather than hidden by the guard.
    expect(
      _iconErrors(reported).where((e) => e.exception is StateError),
      isNotEmpty,
    );
  });

  testWidgets('an unrelated async error is reported even when the load never '
      'settles', (tester) async {
    final reported = _captureReportedErrors();

    await tester.runAsync(() async {
      await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          DefaultAssetBundle(
            bundle: _StalledAssetBundle(),
            child: const IxIcon(
              IxIconData.asset('missing.svg', fallback: Icons.close),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    await tester.pump();

    // The load is still in flight and always will be, so there is no own
    // failure to compare against -- the unrelated one must not be held back
    // waiting for one.
    expect(
      _iconErrors(reported).where((e) => e.exception is StateError),
      hasLength(1),
    );

    // Disposing the icon does not double-report it either.
    await pumpIx(tester, const SizedBox());
    await tester.pump();
    expect(
      _iconErrors(reported).where((e) => e.exception is StateError),
      hasLength(1),
    );
  });

  testWidgets(
    'explicit material resolver renders material glyphs with unchanged layout',
    (tester) async {
      await pumpIx(
        tester,
        const IxIcon.key(IxIconKey.close, size: IxIconSize.s24, key: Key('c')),
        theme: IxThemeBuilder(
          mode: ThemeMode.light,
          icons: IxIconResolver.material(),
        ).build(),
      );
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(tester.getSize(find.byKey(const Key('c'))), const Size(24, 24));
    },
  );
}
