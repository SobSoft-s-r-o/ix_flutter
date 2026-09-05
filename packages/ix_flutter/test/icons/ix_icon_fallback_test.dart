import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/fixture_asset_bundle.dart';
import '../helpers/pump_ix.dart';

Widget _bundled(Widget child, Map<String, String> files) =>
    DefaultAssetBundle(bundle: FixtureAssetBundle(files), child: child);

/// Runs [body], swallowing an unrelated `flutter_svg` internals quirk that
/// would otherwise crash the test binding whenever an SVG fails to load.
///
/// `flutter_svg`'s `Cache.putIfAbsent` (`src/cache.dart`) attaches a second,
/// error-handler-less `.then()` to the same load future purely to update its
/// own bookkeeping. When the load fails — exactly the case these tests
/// exercise — that second callback is a *separate, unobserved* Future
/// rejection with no relation to `IxIcon`'s own (properly awaited and
/// caught) load path; Dart reports it to the current zone as an uncaught
/// error (`library: 'Flutter test framework'`). Left alone, that reaches
/// `flutter_test`'s own zone handler and trips its internal
/// `_pendingExceptionDetails != null` invariant, crashing the test run
/// outright instead of merely failing an assertion. Running the pump inside
/// this narrower zone intercepts that specific noise first, so it never
/// reaches `flutter_test`'s zone at all — independently of `IxIcon`'s own
/// deliberate `FlutterError.reportError` call in its `errorBuilder`, which
/// each test observes separately (via `FlutterError.onError` or
/// `WidgetTester.takeException`).
Future<void> _ignoringSvgCacheBookkeepingErrors(
  Future<void> Function() body,
) async {
  final result = runZonedGuarded(body, (error, stack) {
    // Swallow (see doc comment above): this zone only ever observes
    // flutter_svg's unrelated cache-bookkeeping rejection in these tests.
  });
  if (result != null) {
    await result;
  }
}

/// Guards `IxIcon`'s emergency Material fallback, which has no direct
/// upstream `.ct.ts`/scss counterpart to cite via `@Upstream`.
///
/// The plan's fallback policy
/// (`docs/superpowers/plans/2026-09-04-ix-flutter-2-0-icons-runtime.md`)
/// states that Material
/// glyphs remain an emergency fallback only — a missing asset, a corrupt
/// SVG, or an explicit `IxIconResolver.material()` — that iX and Material
/// glyphs are never mixed on the success path, and that the fallback never
/// changes the icon's `SizedBox` size, hit area, or `Semantics`. These tests
/// exercise all three fallback triggers plus the unaffected success path.
void main() {
  testWidgets(
    'missing asset falls back to the material glyph with identical box and semantics',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.runAsync(() async {
        await _ignoringSvgCacheBookkeepingErrors(() async {
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
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(tester.getSize(find.byKey(const Key('i'))), const Size(16, 16));
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      // IxIcon's own errorBuilder deliberately reports this failure in
      // debug mode (asserted in full by the "corrupt SVG" test below);
      // consume it here so it doesn't fail this test, which only checks
      // the rendered fallback, box size, and semantics.
      expect(tester.takeException(), isNotNull);
      handle.dispose();
    },
  );

  testWidgets('corrupt SVG falls back and reports in debug', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final prev = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = prev);
    await tester.runAsync(() async {
      await _ignoringSvgCacheBookkeepingErrors(() async {
        await pumpIx(
          tester,
          _bundled(
            const IxIcon(IxIconData.asset('broken.svg', fallback: Icons.info)),
            const {'broken.svg': 'test/fixtures/icons/broken.svg'},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
      });
    });
    expect(find.byIcon(Icons.info), findsOneWidget);
    expect(errors.where((e) => e.library == 'ix_flutter icons'), isNotEmpty);
  });

  testWidgets('valid SVG does not use the fallback', (tester) async {
    await tester.runAsync(() async {
      await pumpIx(
        tester,
        _bundled(
          const IxIcon(IxIconData.asset('valid.svg', fallback: Icons.info)),
          const {'valid.svg': 'test/fixtures/icons/valid.svg'},
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
    });
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
