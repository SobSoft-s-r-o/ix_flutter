import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/fixture_asset_bundle.dart';
import '../helpers/pump_ix.dart';

Widget _bundled(Widget child, Map<String, String> files) =>
    DefaultAssetBundle(bundle: FixtureAssetBundle(files), child: child);

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
/// Each test uses its own asset key: `IxIcon` remembers a failed key for the
/// life of the process, so reusing one would make a later test observe the
/// earlier test's recorded failure.
void main() {
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
              IxIconData.asset('missing-box.svg', fallback: Icons.close),
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
              IxIconData.asset('broken-a.svg', fallback: Icons.info),
              key: Key('i'),
            ),
            const {'broken-a.svg': _brokenFixture},
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

    await tester.runAsync(() async {
      final uncaught = await _uncaughtDuring(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(
              IxIconData.asset('missing-twice.svg', fallback: Icons.close),
            ),
            const {},
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
      _bundled(
        const IxIcon(
          IxIconData.asset('missing-twice.svg', fallback: Icons.close),
          key: Key('second'),
        ),
        const {},
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
            const IxIcon(IxIconData.asset('valid-a.svg', fallback: Icons.info)),
            const {'valid-a.svg': _validFixture},
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
