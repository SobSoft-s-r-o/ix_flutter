import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Keyboard and focus contract of [IxBreadcrumb]'s overflow trigger,
/// mirroring the upstream `breadcrumb.ct.ts` "previous items" keyboard
/// navigation case.
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so the `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it (the same pattern used by
/// `test/a11y/keyboard_dropdown_test.dart`).
void main() {
  @Upstream('breadcrumb.ct.ts:141-180 keyboard navigation > previous items')
  void overflowTriggerIsLabelledAndOpensOnEnterWithFocusInTheMenu() {
    testWidgets(
      'overflow trigger is labelled and opens on Enter with focus in the '
      'menu',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(
          tester,
          const IxBreadcrumb(
            visibleItemCount: 2,
            items: [
              IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'h'),
              IxBreadcrumbItemData(label: 'Plant', breadcrumbKey: 'p'),
              IxBreadcrumbItemData(label: 'Line', breadcrumbKey: 'l'),
            ],
          ),
        );

        expect(
          find.bySemanticsLabel('Show previous breadcrumb items'),
          findsOneWidget,
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(find.text('Plant'), findsOneWidget);
        handle.dispose();
      },
    );
  }

  overflowTriggerIsLabelledAndOpensOnEnterWithFocusInTheMenu();
}
