import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/app.dart';
import 'package:example/router/router.dart';
import 'package:example/screen/home_page.dart';
import 'package:example/screen/modals_page.dart';

/// The Modals page's persistent bottom sheet, driven exactly the way a user
/// drives it on desktop.
///
/// Manual testing on macOS reported "the bottom sheet does not close when
/// its close button is tapped": the toggle button never changed its label,
/// so a second click opened a *second* sheet, and the first sheet's
/// `closed` future then cleared the controller belonging to the second one
/// -- leaving a sheet whose close button called `close()` on `null`.
void main() {
  /// Pumps the demo app on the Modals route at a desktop viewport.
  Future<void> pumpModalsPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const IxDemoApp());
    await tester.pump(const Duration(milliseconds: 300));

    // `router` is a top-level singleton shared by every test in this
    // package, so put it back where it started.
    addTearDown(() => router.go(HomePage.routePath));
    router.go(ModalsPage.routePath);
    await tester.pump(const Duration(milliseconds: 600));
  }

  /// One `pump()` to apply the frame the tap scheduled, then enough time
  /// for the sheet's 250ms open/close transition to finish. `pumpAndSettle`
  /// is avoided: the page's cards keep no animation running, but the demo
  /// app's chrome does.
  Future<void> settleSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder toggle(String label) => find.widgetWithText(FilledButton, label);

  Future<void> tapToggle(WidgetTester tester, String label) async {
    final button = toggle(label);
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
  }

  final sheetTitle = find.text('Release readiness');
  final sheetCloseIcon = find.widgetWithIcon(IconButton, Icons.close);

  testWidgets('opening the sheet turns the toggle into a close button', (
    tester,
  ) async {
    await pumpModalsPage(tester);

    await tapToggle(tester, 'Show bottom sheet');
    await settleSheet(tester);

    expect(sheetTitle, findsOneWidget);
    expect(toggle('Close bottom sheet'), findsOneWidget);
    expect(toggle('Show bottom sheet'), findsNothing);
  });

  testWidgets('the sheet closes from its own close icon', (tester) async {
    await pumpModalsPage(tester);

    await tapToggle(tester, 'Show bottom sheet');
    await settleSheet(tester);
    expect(sheetTitle, findsOneWidget);

    await tester.tap(sheetCloseIcon);
    await settleSheet(tester);

    expect(sheetTitle, findsNothing);
    expect(toggle('Show bottom sheet'), findsOneWidget);
  });

  testWidgets('two taps on the toggle leave no sheet open', (tester) async {
    await pumpModalsPage(tester);

    await tapToggle(tester, 'Show bottom sheet');
    await settleSheet(tester);
    await tapToggle(tester, 'Close bottom sheet');
    await settleSheet(tester);

    expect(sheetTitle, findsNothing);
    expect(toggle('Show bottom sheet'), findsOneWidget);
  });

  testWidgets('the sheet reopens, and its action buttons close it too', (
    tester,
  ) async {
    await pumpModalsPage(tester);

    for (final closeLabel in ['Not now', 'Publish release']) {
      await tapToggle(tester, 'Show bottom sheet');
      await settleSheet(tester);
      expect(sheetTitle, findsOneWidget, reason: closeLabel);

      await tester.tap(find.text(closeLabel));
      await settleSheet(tester);

      expect(sheetTitle, findsNothing, reason: closeLabel);
      expect(toggle('Show bottom sheet'), findsOneWidget, reason: closeLabel);
    }
  });
}
