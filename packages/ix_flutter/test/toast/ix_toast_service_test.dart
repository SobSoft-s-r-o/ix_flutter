import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so each @Upstream-tagged test is wrapped in a local function
  // invoked immediately below it (see test/a11y/semantics_matrix_test.dart
  // for the same pattern).
  @Upstream(
    'toast.ct.ts verify functionality of pause and resume api; verify '
    'isPaused method',
  )
  void handlePauseResumeIsPausedCloseOnClose() {
    test('handle: pause/resume/isPaused/close/onClose', () {
      fakeAsync((async) {
        final s = IxToastService()
          // DateTime.now() is not zone-aware and would ignore async.elapse
          // below (verified empirically); clock.now() is fakeAsync's own
          // zone-local clock, so pause/resume see the simulated time.
          ..now = clock.now;
        final h = s.showToast(
          message: 'x',
          autoCloseDelay: const Duration(seconds: 5),
        );
        Object? result;
        var closed = false;
        h.onClose.then((r) {
          closed = true;
          result = r;
        });
        async.elapse(const Duration(seconds: 2));
        h.pause();
        expect(h.isPaused, isTrue);
        async.elapse(const Duration(seconds: 10));
        expect(s.toasts, hasLength(1));
        h.resume();
        expect(h.isPaused, isFalse);
        async.elapse(const Duration(seconds: 3, milliseconds: 100));
        expect(s.toasts, isEmpty);
        async.flushMicrotasks();
        expect(closed, isTrue);
        expect(result, isNull);
        final h2 = s.showToast(message: 'y');
        h2.close('ok');
        async.flushMicrotasks();
        expect(s.toasts, isEmpty);
      });
    });
  }

  handlePauseResumeIsPausedCloseOnClose();

  @Upstream('toast.tsx:163-184 action button dismiss behaviour')
  void dismissOnActionFalseKeepsTheToastOpenAfterTheAction() {
    testWidgets('dismissOnAction=false keeps the toast open after the action', (
      tester,
    ) async {
      final service = IxToastService();
      await pumpIx(tester, Stack(children: [IxToastOverlay(service: service)]));
      var tapped = false;
      service.showToast(
        message: 'Saved',
        actionLabel: 'Undo',
        onAction: () => tapped = true,
        dismissOnAction: false,
      );
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Undo'));
      await tester.pump();

      expect(tapped, isTrue, reason: 'the action callback still runs');
      expect(
        find.byType(IxToast),
        findsOneWidget,
        reason: 'dismissOnAction=false keeps the toast in the tree',
      );

      // flutter_test's AutomatedTestWidgetsFlutterBinding runs every
      // testWidgets body inside a FakeAsync zone and fails the test with
      // "A Timer is still pending even after the widget tree was
      // disposed" unless every Timer started during the test has fired or
      // been cancelled by the time it ends (verified empirically) -- the
      // default 5s auto-close timer is still pending here. Clearing the
      // service is the smallest fix that doesn't disturb the assertions
      // above.
      service.dismissAll();
    });
  }

  dismissOnActionFalseKeepsTheToastOpenAfterTheAction();

  @Upstream('toast.tsx:53-58 pause the auto-close timer while pressed')
  void pointerDownPausesAndPointerUpResumes() {
    testWidgets('pointer down pauses the countdown; pointer up resumes it', (
      tester,
    ) async {
      final service = IxToastService()
        // testWidgets bodies already run inside flutter_test's own
        // FakeAsync zone (AutomatedTestWidgetsFlutterBinding.runTest
        // wraps every test in FakeAsync().run(...), which itself installs
        // package:clock's zone override -- verified by reading
        // package:fake_async's source), so clock.now() tracks
        // tester.pump(duration)'s simulated time the same way it tracks
        // fakeAsync's `async.elapse` in the unit test above; plain
        // DateTime.now() would not.
        ..now = clock.now;
      await pumpIx(tester, Stack(children: [IxToastOverlay(service: service)]));
      final handle = service.showToast(
        message: 'Saved',
        autoCloseDelay: const Duration(seconds: 5),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Press down somewhere on the card away from the close/action
      // buttons (near its top-left corner).
      final gesture = await tester.startGesture(
        tester.getTopLeft(find.byType(IxToast)) + const Offset(2, 2),
      );
      await tester.pump();
      expect(handle.isPaused, isTrue);

      // Paused: the countdown doesn't advance while the pointer is down.
      await tester.pump(const Duration(seconds: 10));
      expect(service.toasts, hasLength(1));

      await gesture.up();
      await tester.pump();
      expect(handle.isPaused, isFalse);

      // Resumed: the remaining countdown still completes on release.
      await tester.pump(const Duration(seconds: 6));
      expect(service.toasts, isEmpty);
    });
  }

  pointerDownPausesAndPointerUpResumes();
}
