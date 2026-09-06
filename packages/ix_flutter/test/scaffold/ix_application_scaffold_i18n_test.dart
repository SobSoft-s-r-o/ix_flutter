import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Strings the scaffold does not have to invent, and the reserved 1.x entry
/// ids that now cooperate with the `settings:`/`about:` panels.

void main() {
  const material = DefaultMaterialLocalizations();

  testWidgets('the drawer button and panel close use the Material strings', (
    tester,
  ) async {
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        entries: const [
          IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
        ],
        settings: const Text('Settings panel'),
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
      size: const Size(600, 800),
    );

    expect(find.byTooltip(material.openAppDrawerTooltip), findsOneWidget);

    await tester.tap(find.byTooltip(material.openAppDrawerTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byTooltip(material.closeButtonTooltip), findsOneWidget);
  });

  testWidgets('an explicit openMenu still wins', (tester) async {
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        entries: const [
          IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
        ],
        strings: const IxApplicationStrings(openMenu: 'Menu offnen'),
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
      size: const Size(600, 800),
    );
    expect(find.byTooltip('Menu offnen'), findsOneWidget);
  });

  testWidgets('a reserved settings entry opens the settings: panel once', (
    tester,
  ) async {
    var deprecatedCalls = 0;
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        entries: const [
          IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
          IxMenuEntry(
            id: 'settings',
            type: IxMenuEntryType.item,
            label: 'Settings',
            isBottom: true,
          ),
        ],
        settings: const Text('Settings panel'),
        // ignore: deprecated_member_use_from_same_package
        onOpenSettings: () => deprecatedCalls++,
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
    );

    // One row, not two: the reserved entry suppresses the built-in one.
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings panel'), findsOneWidget);
    expect(deprecatedCalls, 1, reason: 'the 1.x callback must still fire');
  });

  testWidgets('a reserved settings entry in the top list is not duplicated', (
    tester,
  ) async {
    await pumpIx(
      tester,
      IxApplicationScaffold(
        appTitle: 'App',
        entries: const [
          IxMenuEntry(
            id: 'settings',
            type: IxMenuEntryType.item,
            label: 'Settings',
          ),
        ],
        settings: const Text('Settings panel'),
        onNavigate: (_) {},
        body: const SizedBox(),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
