import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // invoked immediately below it (see test/a11y/semantics_matrix_test.dart
  // for the same pattern).
  @Upstream(
    'toast.ct.ts:33-53 sets live-region attributes for screen reader '
    'announcements; toast.tsx:81 Close toast',
  )
  void toastIsLiveRegionWithLabelledCloseReachableByTab() {
    testWidgets(
      'toast is a live region alert with a labelled close button reachable by Tab',
      (tester) async {
        final handle = tester.ensureSemantics();
        final service = IxToastService();
        await pumpIx(
          tester,
          Stack(
            children: [
              const TextField(key: Key('page')),
              IxToastOverlay(service: service),
            ],
          ),
        );
        service.showToast(
          message: 'Saved',
          title: 'Done',
          actionLabel: 'Undo',
          onAction: () {},
        );
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          tester.getSemantics(find.text('Saved')),
          matchesSemantics(isLiveRegion: true),
        );
        expect(find.bySemanticsLabel('Close toast'), findsOneWidget);
        await tester.tap(find.byKey(const Key('page')));
        for (var i = 0; i < 4; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
        final focused = FocusManager.instance.primaryFocus?.context?.widget;
        expect(focused, isNotNull);
        expect(
          find.descendant(
            of: find.byType(IxToast),
            matching: find.byWidget(focused!),
          ),
          findsOneWidget,
          reason: 'toast controls are in the focus traversal',
        );
        // The toast's default 5s auto-close timer is still pending here (the
        // test only ever pumps 400ms + a handful of zero-duration frames for
        // the Tab presses) -- flutter_test's AutomatedTestWidgetsFlutterBinding
        // runs every testWidgets body inside a FakeAsync zone and fails the
        // test with "A Timer is still pending even after the widget tree was
        // disposed" unless every Timer started during the test has fired or
        // been cancelled by the time it ends (verified empirically). Clearing
        // the service is the smallest fix that doesn't disturb anything the
        // assertions above already observed.
        service.dismissAll();
        handle.dispose();
      },
    );
  }

  toastIsLiveRegionWithLabelledCloseReachableByTab();
}
