import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// What a built theme says about itself, what a package-prefixed typography
/// carries across a family change, and what a `custom` family without a
/// palette does.

/// Captures `debugPrint` so a one-time notice never leaks into the suite
/// log. The body must call `restore` itself: Flutter checks for a leaked
/// foundation debug variable before `addTearDown` callbacks run.
({List<String> logs, VoidCallback restore}) _captureDebugPrint() {
  final logs = <String>[];
  final previous = debugPrint;
  var restored = false;
  void restore() {
    if (restored) {
      return;
    }
    restored = true;
    debugPrint = previous;
  }

  addTearDown(restore);
  debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
  return (logs: logs, restore: restore);
}

void main() {
  group('IxTheme stamping', () {
    test(
      'IxThemeBuilder.dark() reports a dark mode and the classic family',
      () {
        final ix = IxThemeBuilder.dark().build().extension<IxTheme>()!;
        expect(ix.brightness, Brightness.dark);
        // ignore: deprecated_member_use_from_same_package
        expect(ix.mode, ThemeMode.dark);
        // ignore: deprecated_member_use_from_same_package
        expect(ix.family, IxThemeFamily.classic);
      },
    );

    test('IxThemeBuilder.light() reports a light mode', () {
      final ix = IxThemeBuilder.light().build().extension<IxTheme>()!;
      // ignore: deprecated_member_use_from_same_package
      expect(ix.mode, ThemeMode.light);
    });

    test('brightness: dark reports a dark mode', () {
      final ix = const IxThemeBuilder(
        brightness: Brightness.dark,
      ).build().extension<IxTheme>()!;
      // ignore: deprecated_member_use_from_same_package
      expect(ix.mode, ThemeMode.dark);
    });

    test('a custom theme name reports the custom family', () {
      final ix = IxThemeBuilder(
        theme: const IxThemeName('acme'),
        customPalette: IxCustomPalette.partial(
          light: const {IxThemeColorToken.dynamic: Color(0xFF00FF00)},
        ),
      ).build().extension<IxTheme>()!;
      // ignore: deprecated_member_use_from_same_package
      expect(ix.family, IxThemeFamily.custom);
    });

    test('the deprecated mode: is still reported verbatim', () {
      final ix = const IxThemeBuilder(
        // ignore: deprecated_member_use_from_same_package
        mode: ThemeMode.system,
        // ignore: deprecated_member_use_from_same_package
        systemBrightness: Brightness.dark,
      ).build().extension<IxTheme>()!;
      // ignore: deprecated_member_use_from_same_package
      expect(ix.mode, ThemeMode.system);
      expect(ix.brightness, Brightness.dark);
    });
  });

  test('a custom family without a palette falls back with a notice', () {
    IxThemeBuilder.debugResetCustomPaletteNotice();
    final capture = _captureDebugPrint();
    final theme = const IxThemeBuilder(
      // ignore: deprecated_member_use_from_same_package
      family: IxThemeFamily.custom,
    ).build();
    // Built a second time: the notice is once per process.
    const IxThemeBuilder(
      // ignore: deprecated_member_use_from_same_package
      family: IxThemeFamily.custom,
    ).build();
    capture.restore();

    final classic = const IxThemeBuilder(
      // ignore: deprecated_member_use_from_same_package
      family: IxThemeFamily.classic,
    ).build();
    expect(
      theme.extension<IxTheme>()!.color(IxThemeColorToken.dynamic),
      classic.extension<IxTheme>()!.color(IxThemeColorToken.dynamic),
    );
    expect(capture.logs.where((l) => l.contains('customPalette')).length, 1);
  });

  group('IxTypography.copyWith', () {
    test('a new fontFamily drops a package that belonged to the old one', () {
      final base = IxTypography(fontFamily: 'Work Sans', package: 'ix_flutter');
      final swapped = base.copyWith(fontFamily: 'Inter');
      expect(swapped.package, isNull);
      expect(swapped.body.fontFamily, 'Inter');
    });

    test('an explicit package wins, and null clears it', () {
      final base = IxTypography(fontFamily: 'Work Sans', package: 'ix_flutter');
      expect(base.copyWith(package: 'other').package, 'other');
      expect(base.copyWith(package: null).package, isNull);
      expect(base.copyWith().package, 'ix_flutter');
    });
  });

  testWidgets('IxIconButton keeps its size under useMaterial3: false', (
    tester,
  ) async {
    await pumpIx(
      tester,
      const Center(
        child: IxIconButton(
          icon: IxIcon.key(IxIconKey.close),
          size: IxIconButtonSize.s24,
          tooltip: 'Close',
          onPressed: null,
        ),
      ),
      theme: ThemeData(useMaterial3: false),
    );
    expect(tester.getSize(find.byType(IconButton)).width, 24);
    expect(tester.getSize(find.byType(IconButton)).height, 24);
  });
}
