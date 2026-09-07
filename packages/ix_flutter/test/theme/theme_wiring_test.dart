// The IxBlind typography case below builds through the deprecated
// `mode:` parameter on purpose (it is the 1.x spelling that must keep
// working until 2.0).
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart'; // the only import -- verifies the public barrel

import '../helpers/pump_ix.dart';

/// Verifies the public API surface for spec finding IXF exports/`IxTheme.of`
/// (app-frame plan Task X-1): `IxPaginationBar` and `IxBottomSheetTheme` are
/// reachable from the `package:ix_flutter/ix_flutter.dart` barrel,
/// `IxTheme.of`/`IxTheme.maybeOf` resolve the theme extension from a
/// `BuildContext`, and `IxBlind` renders its title using the typography
/// supplied via `IxThemeBuilder(typography:)`. This checks our own public API
/// surface rather than a Siemens iX upstream source, so it carries a
/// doc-comment instead of `@Upstream`.
void main() {
  testWidgets('IxBottomSheetTheme is exported and wired into ThemeData', (
    tester,
  ) async {
    await pumpIx(
      tester,
      Builder(
        builder: (c) {
          final ext = Theme.of(c).extension<IxBottomSheetTheme>();
          expect(ext, isNotNull);
          expect(Theme.of(c).bottomSheetTheme, ext!.materialBottomSheetTheme);
          return const SizedBox();
        },
      ),
    );
  });

  testWidgets('IxBlindTheme is wired into ThemeData', (tester) async {
    // Manual-testing regression (Android, dark theme, Blind example page):
    // `IxBlindTheme.fromPalette` existed but was never added to
    // `IxThemeBuilder.build()`'s `extensions:` list, so every `IxBlind` in
    // an `IxThemeBuilder`-themed app silently fell back to
    // `IxBlindTheme.fallback(ThemeData)` -- a generic Material-role
    // approximation never meant to be authoritative for an iX-themed app
    // (see its own doc comment: "might not match exact iX specs").
    await pumpIx(
      tester,
      Builder(
        builder: (c) {
          final ext = Theme.of(c).extension<IxBlindTheme>();
          expect(ext, isNotNull);
          return const SizedBox();
        },
      ),
    );
  });

  testWidgets(
    'IxTheme.of returns the extension; maybeOf is null without IxThemeBuilder',
    (tester) async {
      await pumpIx(
        tester,
        Builder(
          builder: (c) {
            expect(IxTheme.of(c).brightness, Brightness.light);
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) {
              expect(IxTheme.maybeOf(c), isNull);
              expect(() => IxTheme.of(c), throwsFlutterError);
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );

  testWidgets('IxBlind title uses IxThemeBuilder(typography:)', (tester) async {
    await pumpIx(
      tester,
      IxBlind(
        title: 'T',
        expanded: false,
        onExpandedChanged: (_) {},
        child: const Text('b'),
      ),
      theme: IxThemeBuilder(
        mode: ThemeMode.light,
        typography: IxTypography(fontFamily: 'Custom'),
      ).build(),
    );
    expect(tester.widget<Text>(find.text('T')).style?.fontFamily, 'Custom');
  });

  test('IxPaginationBar is reachable from the public barrel', () {
    expect(IxPaginationBar, isA<Type>());
  });
}
