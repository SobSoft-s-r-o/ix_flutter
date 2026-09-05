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
        final s = IxToastService();
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
}
