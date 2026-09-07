import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// A control that publishes `isFocusable` owes assistive technology a way to
/// act on it: without a `focus` action a screen reader can say the control
/// can take the focus, but not put it there. `excludeSemantics: true` drops
/// the `InkWell`'s own action, so these nodes have to supply one.
void main() {
  testWidgets('an enabled IxBlind header offers a focus action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      IxBlind(
        title: 'Section',
        expanded: false,
        onExpandedChanged: (_) {},
        child: const SizedBox(),
      ),
    );
    expect(
      tester.getSemantics(find.text('Section')),
      isSemantics(hasFocusAction: true, isFocusable: true),
    );
    handle.dispose();
  });

  testWidgets('a disabled IxBlind header offers none', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      const IxBlind(
        title: 'Section',
        expanded: false,
        disabled: true,
        child: SizedBox(),
      ),
    );
    expect(
      tester.getSemantics(find.text('Section')),
      isSemantics(hasFocusAction: false, isFocusable: false),
    );
    handle.dispose();
  });

  testWidgets('an enabled scaffold menu tile offers a focus action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        entries: const [
          IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
          IxMenuEntry(
            id: 'off',
            type: IxMenuEntryType.item,
            label: 'Off',
            enabled: false,
          ),
        ],
        initiallyExpanded: true,
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
    );
    expect(
      tester.getSemantics(find.text('One')),
      isSemantics(hasFocusAction: true, isFocusable: true),
    );
    expect(
      tester.getSemantics(find.text('Off')),
      isSemantics(hasFocusAction: false, isFocusable: false),
    );
    handle.dispose();
  });
}
