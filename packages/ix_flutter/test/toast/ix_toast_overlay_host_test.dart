import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// [IxToastOverlay] in its documented placement -- a `Stack` inside
/// `MaterialApp.builder`, above the `Navigator` -- has no [Overlay] in
/// scope, so it hosts one itself.
///
/// Traceability: no upstream Playwright/`.tsx` counterpart. The web
/// component's toast container is a DOM portal on `document.body` and has
/// no notion of an "overlay ancestor" at all; this guards a
/// Flutter-specific precondition found by manual testing on macOS desktop
/// (hovering a toast's close button rendered an `ErrorWidget` reading
/// "No Overlay widget found" where the button should be).
void main() {
  /// Mirrors `example/lib/app.dart`: the toast overlay sits in a `Stack`
  /// in `MaterialApp.builder`, i.e. a sibling of -- not below -- the app's
  /// `Navigator`, so `Overlay.maybeOf` finds nothing.
  Future<void> pumpBuilderPlacement(
    WidgetTester tester,
    IxToastService service, {
    Widget home = const Scaffold(body: Center(child: Text('page body'))),
    Size size = const Size(1440, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: const IxThemeBuilder(mode: ThemeMode.light).build(),
        debugShowCheckedModeBanner: false,
        home: home,
        builder: (context, child) => Stack(
          children: [
            if (child != null) child,
            IxToastOverlay(service: service),
          ],
        ),
      ),
    );
  }

  Finder closeButtonOf(Finder toast) =>
      find.descendant(of: toast, matching: find.byType(IxIconButton));

  testWidgets(
    'hovering the close button shows its tooltip, not an ErrorWidget',
    (tester) async {
      final service = IxToastService();
      addTearDown(service.dispose);

      await pumpBuilderPlacement(tester, service);
      service.showToast(message: 'My toast message!', autoClose: false);
      await tester.pumpAndSettle();

      final closeButton = closeButtonOf(find.byType(IxToast));
      expect(closeButton, findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(closeButton));
      // Past Tooltip's own wait/show durations, whatever they are.
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      // The tooltip really rendered -- the button's accessible name is a
      // `Semantics` label, not a `Text`, so this can only be the tooltip.
      expect(find.text(const IxToastStrings().closeToast), findsOneWidget);

      service.dismissAll();
    },
  );

  testWidgets('long-pressing the close button shows its tooltip too', (
    tester,
  ) async {
    final service = IxToastService();
    addTearDown(service.dispose);

    await pumpBuilderPlacement(tester, service);
    service.showToast(message: 'My toast message!', autoClose: false);
    await tester.pumpAndSettle();

    final closeButton = closeButtonOf(find.byType(IxToast));
    await tester.longPress(closeButton);
    // Past the fade-in but inside Tooltip's default 1.5s `showDuration`.
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.text(const IxToastStrings().closeToast), findsOneWidget);

    service.dismissAll();
    // Let the tooltip's own dismiss timer run out inside the test.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the close button still dismisses the toast it belongs to', (
    tester,
  ) async {
    final service = IxToastService();
    addTearDown(service.dispose);

    await pumpBuilderPlacement(tester, service);
    service.showToast(message: 'My toast message!', autoClose: false);
    await tester.pumpAndSettle();

    await tester.tap(closeButtonOf(find.byType(IxToast)));
    await tester.pumpAndSettle();

    expect(find.byType(IxToast), findsNothing);
    expect(service.toasts, isEmpty);
  });

  testWidgets('self-hosting leaves the toast stack geometry untouched', (
    tester,
  ) async {
    final service = IxToastService();
    addTearDown(service.dispose);

    await pumpBuilderPlacement(tester, service);
    service.showToast(message: 'Geometry', autoClose: false);
    await tester.pumpAndSettle();

    final rect = tester.getRect(find.byType(IxToast));
    expect(rect.width, 280);
    expect(rect.right, 1440 - 16);
    expect(rect.top, 32);

    service.dismissAll();
  });

  testWidgets('the self-hosted Overlay stays click-through', (tester) async {
    // The self-hosted Overlay fills the host `Stack`, so anything the app
    // draws under it -- a bottom sheet, a floating action button, the
    // right-hand strip of a page -- has to keep receiving pointer events,
    // toasts on screen or not.
    final service = IxToastService();
    addTearDown(service.dispose);
    var taps = 0;

    await pumpBuilderPlacement(
      tester,
      service,
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              right: 16,
              bottom: 16,
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('bottom right'),
              ),
            ),
            Positioned(
              right: 16,
              top: 200,
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('under the toast column'),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('bottom right'));
    await tester.tap(find.text('under the toast column'));
    await tester.pump();
    expect(taps, 2, reason: 'no toasts showing');

    service.showToast(message: 'Toast', autoClose: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('bottom right'));
    await tester.tap(find.text('under the toast column'));
    await tester.pump();
    expect(taps, 4, reason: 'one toast showing');

    service.dismissAll();
    await tester.pumpAndSettle();
  });

  testWidgets('an Overlay already in scope is used as-is', (tester) async {
    final service = IxToastService();
    addTearDown(service.dispose);

    // `pumpIx` puts the overlay below the app's Navigator, so the only
    // Overlay in the tree stays the Navigator's own.
    await pumpIx(tester, Stack(children: [IxToastOverlay(service: service)]));
    final overlaysBefore = find.byType(Overlay).evaluate().length;

    service.showToast(message: 'Nested', autoClose: false);
    await tester.pumpAndSettle();

    expect(find.byType(Overlay), findsNWidgets(overlaysBefore));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(closeButtonOf(find.byType(IxToast))));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text(const IxToastStrings().closeToast), findsOneWidget);

    service.dismissAll();
  });
}
