import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/app.dart';
import 'package:example/router/router.dart';
import 'package:example/screen/home_page.dart';
import 'package:example/screen/navigation_examples_page.dart';

/// Manual testing on Android (phone width, dark theme) reported that the
/// Navigation Examples page's bottom app bar -- a `Row` of three pill-style
/// switches ("Snack bars", "Dialogs", "Breadcrumbs") -- overflows: Flutter's
/// "RIGHT OVERFLOWED BY n PIXELS" stripe covers the last pill. The bar is
/// entirely example-authored chrome (`_BottomAppBarNavigation` in
/// `example/lib/screen/navigation_examples_page.dart`, a plain Material
/// `BottomAppBar` wrapping a fixed `Row` of pills, sized `spaceEvenly`) --
/// no `ix_flutter` framework widget takes part in that layout (the only
/// library widget involved, `IxIcon`, is a fixed-size leaf icon renderer
/// inside each pill, not implicated in the `Row`'s own width). This is
/// therefore purely an example-code overflow, reproduced and fixed here.
void main() {
  Future<void> pumpNavigationExamplesPage(
    WidgetTester tester,
    Size size,
    double textScale,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const IxDemoApp());
    await tester.pump(const Duration(milliseconds: 300));

    // `router` is a top-level singleton shared by every test in this
    // package, so put it back where it started.
    addTearDown(() => router.go(HomePage.routePath));
    router.go(NavigationExamplesPage.routePath);
    await tester.pump(const Duration(milliseconds: 600));
  }

  // The reported bug reproduces at plain phone widths (360/320); the wider
  // 600px case and the text-scale steps are forward-looking regression
  // coverage for the same strip now that it scrolls instead of forcing a
  // fixed-width `Row` to fit.
  for (final width in const [320.0, 360.0, 600.0]) {
    for (final textScale in const [1.0, 1.3, 2.0]) {
      testWidgets('the bottom app bar pill strip does not overflow at '
          '${width.toInt()}px wide, ${textScale}x text scale', (tester) async {
        await pumpNavigationExamplesPage(tester, Size(width, 640), textScale);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
