import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/screen/buttons_page.dart';
import 'package:example/screen/home_page.dart';
import 'package:example/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// Regenerates the pub.dev screenshots in `packages/ix_flutter/screenshots/`
/// when run with `--dart-define=IX_CAPTURE_SCREENSHOTS=true`. Without the
/// define this test still pumps every page and asserts it renders cleanly,
/// so the regular `flutter test` (no define) stays green in CI.
const _capture = bool.fromEnvironment('IX_CAPTURE_SCREENSHOTS');
const _out = '../packages/ix_flutter/screenshots';

/// The sans-serif UI font family the screenshot themes below are explicitly
/// built with. [IxThemeBuilder]'s own default resolves to
/// `IxFonts.robotoMono` -- a monospace face -- because Work Sans
/// ([IxFonts.workSans]) is opt-in pre-2.0 (see its doc comment); pub.dev
/// screenshots should show the bundled Work Sans family instead, so `main()`
/// below passes `typography: IxTypography(fontFamily: IxFonts.workSans,
/// package: IxFonts.packageName)`, which resolves to this package-prefixed
/// family name.
const _uiFontFamily = 'packages/ix_flutter/Work Sans';

Future<void> _shoot(
  WidgetTester tester,
  String name,
  ThemeData theme,
  Widget page,
  Finder marker,
) async {
  await tester.binding.setSurfaceSize(const Size(1440, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // HomePage reads ThemeControllerScope (the demo-only theme family/mode
  // switcher); ButtonsPage only reads Theme extensions built by
  // IxThemeBuilder and ignores the scope. Providing it unconditionally keeps
  // a single _shoot code path instead of branching on the page type. The
  // controller's own mode is synced to the captured theme's brightness so
  // HomePage's "Current configuration"/"Theme mode" demo controls agree with
  // what the screenshot actually shows, instead of always reporting "Light".
  final controller = ThemeController();
  addTearDown(controller.dispose);
  controller.setMode(
    theme.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: RepaintBoundary(
        key: const Key('shot'),
        child: Scaffold(
          body: ThemeControllerScope(controller: controller, child: page),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Real assertions (rather than only capturing pixels when the define is
  // set) so this test is meaningful -- and green -- in the regular
  // `flutter test` run too.
  expect(tester.takeException(), isNull);
  expect(marker, findsOneWidget);

  // The marker's TextStyle comes straight from the IxThemeBuilder-built
  // theme, so checking its fontFamily confirms the glyphs flutter_test_config
  // .dart loaded are the ones actually in effect -- not the test harness's
  // placeholder Ahem font.
  final markerText = tester.widget<Text>(marker);
  expect(markerText.style?.fontFamily, _uiFontFamily);

  if (!_capture) return;

  final image = await tester.runAsync(
    () => tester
        .renderObject<RenderRepaintBoundary>(find.byKey(const Key('shot')))
        .toImage(pixelRatio: 1),
  );
  final bytes = await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.png),
  );
  File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  // Not `const`: IxTypography's constructor is a factory, so it isn't a
  // compile-time constant and neither is the IxThemeBuilder call it's passed
  // into.
  final light = IxThemeBuilder.light(
    typography: IxTypography(
      fontFamily: IxFonts.workSans,
      package: IxFonts.packageName,
    ),
  ).build();
  final dark = IxThemeBuilder.dark(
    typography: IxTypography(
      fontFamily: IxFonts.workSans,
      package: IxFonts.packageName,
    ),
  ).build();

  testWidgets(
    'overview light',
    (t) => _shoot(
      t,
      'overview_light',
      light,
      const HomePage(),
      find.text('IX Flutter Theme Overview'),
    ),
  );
  testWidgets(
    'overview dark',
    (t) => _shoot(
      t,
      'overview_dark',
      dark,
      const HomePage(),
      find.text('IX Flutter Theme Overview'),
    ),
  );
  testWidgets(
    'components light',
    (t) => _shoot(
      t,
      'components_light',
      light,
      const ButtonsPage(),
      find.text('Primary'),
    ),
  );
  testWidgets(
    'components dark',
    (t) => _shoot(
      t,
      'components_dark',
      dark,
      const ButtonsPage(),
      find.text('Primary'),
    ),
  );
}
