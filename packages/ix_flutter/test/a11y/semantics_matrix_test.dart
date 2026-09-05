import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

void main() {
  group('semantics matrix (red until the referenced task lands)', () {
    // Metadata annotations can only precede a declaration, not a bare
    // statement, so each @Upstream-tagged test is wrapped in a local
    // function that is invoked immediately below it. This keeps the
    // annotation attached to its test 1:1, matching how flutter_test
    // registers the test at the same point in `main()` either way.
    @Upstream('blind.tsx:145-156 <button aria-expanded aria-controls>')
    void ixBlindHeaderIsButtonWithExpandedState() {
      testWidgets(
        'IxBlind header is a button with expanded state',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpIx(
            tester,
            IxBlind(
              title: 'Section',
              expanded: true,
              onExpandedChanged: (_) {},
              child: const Text('body'),
            ),
          );
          expect(
            tester.getSemantics(find.text('Section')),
            matchesSemantics(
              isButton: true,
              hasExpandedState: true,
              isExpanded: true,
              hasEnabledState: true,
              isEnabled: true,
              isFocusable: true,
              hasTapAction: true,
              label: 'Section',
            ),
          );
          handle.dispose();
        },
        skip: true,
      ); // IXF-023 – implemented by accessibility-interaction Task 5 (A-6)
    }

    ixBlindHeaderIsButtonWithExpandedState();

    @Upstream(
      'toast.ct.ts:33-53 sets live-region attributes for screen reader announcements',
    )
    void ixToastIsLiveRegionAndCloseButtonIsLabelled() {
      testWidgets(
        'IxToast is a live region and close button is labelled',
        (tester) async {
          final handle = tester.ensureSemantics();
          final service = IxToastService();
          await pumpIx(
            tester,
            Stack(children: [IxToastOverlay(service: service)]),
          );
          service.show(message: 'Saved');
          await tester.pump(const Duration(milliseconds: 400));
          expect(
            tester.getSemantics(find.text('Saved')),
            matchesSemantics(isLiveRegion: true, label: 'Saved'),
          );
          expect(find.bySemanticsLabel('Close toast'), findsOneWidget);
          handle.dispose();
        },
        skip: true,
      ); // IXF-003 – implemented by accessibility-interaction Task 3 (A-3)
    }

    ixToastIsLiveRegionAndCloseButtonIsLabelled();

    @Upstream('dropdown-button.ct.ts:106-133 aria-expanded')
    void ixDropdownButtonTriggerExposesExpandedState() {
      testWidgets('IxDropdownButton trigger exposes expanded state', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpIx(
          tester,
          IxDropdownButton<int>(
            label: 'Actions',
            items: const [IxDropdownMenuItem(label: 'Edit', value: 1)],
          ),
        );
        // `isSemantics` (not `matchesSemantics`) because the flags this
        // case is about are additions to the trigger's own button
        // semantics: `matchesSemantics` asserts every unlisted flag is
        // absent, which no real button can satisfy. The exhaustive flag
        // set is asserted in `test/a11y/keyboard_dropdown_test.dart`.
        expect(
          tester.getSemantics(find.text('Actions')),
          isSemantics(
            isButton: true,
            hasExpandedState: true,
            isExpanded: false,
          ),
        );
        handle.dispose();
      });
    }

    ixDropdownButtonTriggerExposesExpandedState();
  });
}
