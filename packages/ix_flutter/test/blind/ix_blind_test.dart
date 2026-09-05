import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Header semantics (button + expanded state, header actions kept outside
/// the header's own semantics node) and the uncontrolled/controlled dual
/// contract of [IxBlind].
///
/// Only the first test below mirrors a specific upstream source line and
/// carries its own `@Upstream`; the remaining tests exercise this library's
/// own uncontrolled/controlled state contract and disabled handling, which
/// has no distinct upstream `.tsx`/`.scss` counterpart of its own -- so this
/// file carries an English file-level doc-comment instead (see
/// `test/theme/theme_wiring_test.dart` for the same pattern).
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so the `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it (see
/// `test/a11y/semantics_matrix_test.dart` for the same pattern).
void main() {
  @Upstream(
    'blind.tsx:145-156 <button aria-labelledby aria-controls aria-expanded>',
  )
  void headerIsButtonWithExpandedStateAndActionsStaySeparate() {
    testWidgets(
      'header is a button with expanded state and header actions stay '
      'separate',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(
          tester,
          IxBlind(
            title: 'Section',
            subtitle: 'Sub',
            expanded: true,
            onExpandedChanged: (_) {},
            headerActions: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () {},
            ),
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
            hint: 'Sub',
          ),
        );
        final edit = tester.getSemantics(find.byTooltip('Edit'));
        expect(edit.label, isNot(contains('Section')));
        handle.dispose();
      },
    );
  }

  headerIsButtonWithExpandedStateAndActionsStaySeparate();

  testWidgets('uncontrolled blind toggles on tap without a callback', (
    tester,
  ) async {
    await pumpIx(tester, const IxBlind(title: 'T', child: Text('body')));
    expect(find.text('body'), findsNothing);
    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('controlled blind does not toggle without setState', (
    tester,
  ) async {
    var calls = 0;
    await pumpIx(
      tester,
      IxBlind(
        title: 'T',
        expanded: false,
        onExpandedChanged: (_) => calls++,
        child: const Text('body'),
      ),
    );
    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('body'), findsNothing);
  });

  testWidgets('disabled blind exposes enabled=false and ignores taps', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var calls = 0;
    await pumpIx(
      tester,
      IxBlind(
        title: 'T',
        disabled: true,
        expanded: false,
        onExpandedChanged: (_) => calls++,
        child: const Text('b'),
      ),
    );
    expect(
      tester.getSemantics(find.text('T')),
      matchesSemantics(
        hasEnabledState: true,
        isEnabled: false,
        isButton: true,
        hasExpandedState: true,
        label: 'T',
      ),
    );
    await tester.tap(find.text('T'));
    await tester.pump();
    expect(calls, 0);
    handle.dispose();
  });
}
