import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/gestures.dart';
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

  @Upstream('toast.tsx:53-58 pause the auto-close timer while hovered')
  void hoverThenClickInsideKeepsItPaused() {
    testWidgets('hovering then clicking inside the toast keeps it paused', (
      tester,
    ) async {
      final service = IxToastService()..now = clock.now;
      await pumpIx(tester, Stack(children: [IxToastOverlay(service: service)]));
      final handle = service.showToast(
        message: 'Saved',
        autoCloseDelay: const Duration(seconds: 5),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final location =
          tester.getTopLeft(find.byType(IxToast)) + const Offset(2, 2);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(() => mouse.removePointer());
      await mouse.addPointer(location: location);
      await tester.pump();
      expect(handle.isPaused, isTrue, reason: 'hover pauses');

      // A click (press then release) while the mouse stays over the
      // toast must not resume the countdown: the cursor is still
      // hovering.
      await mouse.down(location);
      await tester.pump();
      await mouse.up();
      await tester.pump();
      expect(handle.isPaused, isTrue, reason: 'still hovering after the click');

      await tester.pump(const Duration(seconds: 10));
      expect(
        service.toasts,
        hasLength(1),
        reason: 'paused countdown does not advance',
      );

      service.dismissAll();
    });
  }

  hoverThenClickInsideKeepsItPaused();

  @Upstream('toast.tsx:53-58 pause the auto-close timer while hovered')
  void hoverClickExitReenterNeverOrphansTheTimer() {
    testWidgets(
      'hover, click, exit and re-enter never orphans the auto-close timer',
      (tester) async {
        final service = IxToastService()..now = clock.now;
        await pumpIx(
          tester,
          Stack(children: [IxToastOverlay(service: service)]),
        );
        final handle = service.showToast(
          message: 'Saved',
          autoCloseDelay: const Duration(seconds: 5),
        );
        await tester.pump(const Duration(milliseconds: 100));

        final location =
            tester.getTopLeft(find.byType(IxToast)) + const Offset(2, 2);
        const elsewhere = Offset(10, 10);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(() => mouse.removePointer());

        await mouse.addPointer(location: location);
        await tester.pump();
        expect(handle.isPaused, isTrue);

        await mouse.down(location);
        await tester.pump();
        await mouse.up();
        await tester.pump();
        expect(
          handle.isPaused,
          isTrue,
          reason: 'click while hovering keeps it paused',
        );

        // Exit: this is the transition that must produce exactly one
        // resumeTimer call -- not an extra one orphaned by the earlier
        // click's pointer-up.
        await mouse.moveTo(elsewhere);
        await tester.pump();
        expect(
          handle.isPaused,
          isFalse,
          reason: 'leaving resumes the countdown',
        );

        // Re-enter: pauses again.
        await mouse.moveTo(location);
        await tester.pump();
        expect(handle.isPaused, isTrue);

        await tester.pump(const Duration(seconds: 10));
        expect(
          service.toasts,
          hasLength(1),
          reason: 'paused again, still not closed',
        );

        // Final exit: resumes once, and the (single) remaining timer
        // closes it exactly once -- if an earlier orphaned timer existed,
        // this would either already be empty (closed too early) or would
        // double-complete the handle.
        await mouse.moveTo(elsewhere);
        await tester.pump();
        expect(handle.isPaused, isFalse);

        await tester.pump(const Duration(seconds: 6));
        expect(
          service.toasts,
          isEmpty,
          reason: 'closes exactly once after the remaining time',
        );
      },
    );
  }

  hoverClickExitReenterNeverOrphansTheTimer();

  @Upstream('toast.tsx:53-58 pause the auto-close timer while hovered')
  void progressBarFreezesWhileHoveredAndResumesAfterExit() {
    testWidgets(
      'the progress bar freezes while hovered and resumes after exit',
      (tester) async {
        final service = IxToastService()..now = clock.now;
        await pumpIx(
          tester,
          Stack(children: [IxToastOverlay(service: service)]),
          disableAnimations: false,
        );
        service.showToast(
          message: 'Saved',
          autoCloseDelay: const Duration(seconds: 5),
        );
        await tester.pump();

        double progressValue() => tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value!;

        final initial = progressValue();
        await tester.pump(const Duration(milliseconds: 500));
        final beforeHover = progressValue();
        expect(beforeHover, isNot(initial), reason: 'moving before hover');

        final location =
            tester.getTopLeft(find.byType(IxToast)) + const Offset(2, 2);
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(() => mouse.removePointer());
        await mouse.addPointer(location: location);
        await tester.pump();

        final atHoverStart = progressValue();
        await tester.pump(const Duration(seconds: 1));
        expect(progressValue(), atHoverStart, reason: 'frozen while hovered');

        await mouse.moveTo(const Offset(10, 10));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          progressValue(),
          isNot(atHoverStart),
          reason: 'moving again after exit',
        );

        service.dismissAll();
      },
    );
  }

  progressBarFreezesWhileHoveredAndResumesAfterExit();

  test('dismiss after dispose, and a second close, are no-ops', () {
    final service = IxToastService();
    final handle = service.showToast(message: 'x', autoClose: false);
    var notifications = 0;
    void listener() => notifications++;
    service.addListener(listener);

    handle.close('first');
    expect(notifications, 1);
    // A second close of an id that is no longer live must not notify
    // (a listener would rebuild for nothing) nor complete `onClose` twice.
    handle.close('second');
    expect(notifications, 1);

    service.removeListener(listener);
    service.dispose();
    // A kept handle firing later -- an animation callback, a pending
    // future -- must not resurrect a disposed ChangeNotifier.
    expect(handle.close, returnsNormally);
    expect(() => service.dismiss('nope'), returnsNormally);
    expect(() => service.dismissAll(), returnsNormally);
  });

  test('close reports its result exactly once', () {
    fakeAsync((async) {
      final service = IxToastService();
      final handle = service.showToast(message: 'x', autoClose: false);
      final results = <Object?>[];
      handle.onClose.then(results.add);
      handle.close('first');
      handle.close('second');
      async.flushMicrotasks();
      expect(results, ['first']);
      service.dispose();
    });
  });

  testWidgets('a programmatic pause freezes the progress bar', (tester) async {
    final service = IxToastService()..now = clock.now;
    addTearDown(service.dispose);
    await pumpIx(
      tester,
      Stack(children: [IxToastOverlay(service: service)]),
      disableAnimations: false,
    );
    final handle = service.showToast(
      message: 'Saved',
      autoCloseDelay: const Duration(seconds: 10),
    );
    await tester.pump();

    double progress() => tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;

    await tester.pump(const Duration(seconds: 1));
    handle.pause();
    await tester.pump();
    final atPause = progress();
    expect(atPause, greaterThan(0));

    await tester.pump(const Duration(seconds: 2));
    expect(
      progress(),
      atPause,
      reason: 'the bar kept draining through a programmatic pause',
    );

    handle.resume();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // The bar counts down, so a running countdown *lowers* the value.
    expect(progress(), lessThan(atPause), reason: 'resume did not restart');

    service.dismissAll();
  });

  testWidgets('leaving a hover does not resume a programmatic pause', (
    tester,
  ) async {
    final service = IxToastService()..now = clock.now;
    addTearDown(service.dispose);
    await pumpIx(
      tester,
      Stack(children: [IxToastOverlay(service: service)]),
      disableAnimations: false,
    );
    final handle = service.showToast(
      message: 'Saved',
      autoCloseDelay: const Duration(seconds: 10),
    );
    await tester.pump();
    handle.pause();
    await tester.pump(const Duration(milliseconds: 500));

    double progress() => tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;
    final atPause = progress();

    final location =
        tester.getTopLeft(find.byType(IxToast)) + const Offset(2, 2);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(() => mouse.removePointer());
    await mouse.addPointer(location: location);
    await tester.pump();
    await mouse.moveTo(const Offset(2000, 2000));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(
      progress(),
      atPause,
      reason: 'a hover exit resumed a countdown the owner had paused',
    );
    expect(handle.isPaused, isTrue);

    service.dismissAll();
  });

  testWidgets('the toast overlay survives a viewport narrower than its '
      'margins', (tester) async {
    final service = IxToastService();
    addTearDown(service.dispose);
    await pumpIx(
      tester,
      Stack(children: [IxToastOverlay(service: service)]),
      size: const Size(20, 200),
    );
    service.showToast(message: 'x', autoClose: false);
    await tester.pump();
    expect(tester.takeException(), isNull);
    service.dismissAll();
  });

  testWidgets('the toast overlay survives a zero-size MediaQuery', (
    tester,
  ) async {
    final service = IxToastService();
    addTearDown(service.dispose);
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(width: 400, height: 400, child: _OverlayHost()),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

/// Hosts an [IxToastOverlay] with its own service, for the zero-size
/// `MediaQuery` case above (which cannot use `pumpIx`, since that supplies a
/// size).
class _OverlayHost extends StatefulWidget {
  const _OverlayHost();

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost> {
  final IxToastService _service = IxToastService();

  @override
  void initState() {
    super.initState();
    _service.showToast(message: 'x', autoClose: false);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Overlay.wrap(
    // The toast's close button is a tooltipped `IxIconButton`, and a
    // Material tooltip needs an `Overlay` wherever it is rendered.
    child: Material(
      child: Stack(children: [IxToastOverlay(service: _service)]),
    ),
  );
}
