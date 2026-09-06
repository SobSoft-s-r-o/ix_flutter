import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/focus.dart';
import '../helpers/pump_ix.dart';

/// Arrow-key navigation and drawer dismissal in [IxApplicationScaffold].
///
/// The menu's traversal order is built from the entries the panel *renders*.
/// Anything else in it -- a disabled tile, whose `InkWell` refuses focus, or
/// a grandchild that is never mounted -- is a dead stop the arrow keys can
/// never move past.

/// Tabs into the menu (past the collapse button) so the first tile holds
/// the focus. Tapping a tile does not focus it: an `InkWell` takes focus
/// from the keyboard, not from a pointer.
Future<void> focusFirstTile(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab); // collapse button
  await tester.sendKeyEvent(LogicalKeyboardKey.tab); // first tile
  await tester.pumpAndSettle();
}

/// The drawer button now takes Flutter's own localized name unless the app
/// overrides it (`IxApplicationStrings.openMenu`).
final String _openDrawer =
    const DefaultMaterialLocalizations().openAppDrawerTooltip;

void main() {
  const withDisabled = [
    IxMenuEntry(id: 'first', type: IxMenuEntryType.item, label: 'First'),
    IxMenuEntry(
      id: 'off',
      type: IxMenuEntryType.item,
      label: 'Disabled',
      enabled: false,
    ),
    IxMenuEntry(id: 'last', type: IxMenuEntryType.item, label: 'Last'),
  ];

  Widget app(
    List<IxMenuEntry> entries, {
    void Function(String id)? onNavigate,
  }) => IxApplicationScaffold(
    appTitle: 'App',
    entries: entries,
    initiallyExpanded: true,
    onNavigate: onNavigate ?? (_) {},
    body: const Text('body'),
  );

  testWidgets('ArrowDown steps over a disabled entry', (tester) async {
    await pumpIx(tester, app(withDisabled));
    await focusFirstTile(tester);
    expectFocusOn(tester, 'First');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'Last');
  });

  testWidgets('ArrowUp steps back over a disabled entry', (tester) async {
    await pumpIx(tester, app(withDisabled));
    await focusFirstTile(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'Last');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'First');
  });

  testWidgets('Home and End skip disabled edges', (tester) async {
    const disabledEdges = [
      IxMenuEntry(
        id: 'a',
        type: IxMenuEntryType.item,
        label: 'A',
        enabled: false,
      ),
      IxMenuEntry(id: 'b', type: IxMenuEntryType.item, label: 'B'),
      IxMenuEntry(id: 'c', type: IxMenuEntryType.item, label: 'C'),
      IxMenuEntry(
        id: 'd',
        type: IxMenuEntryType.item,
        label: 'D',
        enabled: false,
      ),
    ];
    await pumpIx(tester, app(disabledEdges));
    await focusFirstTile(tester);
    expectFocusOn(tester, 'B');

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'C');

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'B');
  });

  testWidgets('a disabled theme-toggle entry is skipped too', (tester) async {
    // A reserved `theme-toggle` custom entry is disabled while
    // `onThemeModeChanged` is null.
    await pumpIx(
      tester,
      app(const [
        IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
        IxMenuEntry(
          id: 'theme-toggle',
          type: IxMenuEntryType.custom,
          label: 'Theme',
          isBottom: true,
        ),
        IxMenuEntry(
          id: 'help',
          type: IxMenuEntryType.item,
          label: 'Help',
          isBottom: true,
        ),
      ]),
    );
    await focusFirstTile(tester);
    expectFocusOn(tester, 'One');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'Help');
  });

  testWidgets('ArrowDown leaves a nested category without throwing', (
    tester,
  ) async {
    const nested = [
      IxMenuEntry(
        id: 'cat',
        type: IxMenuEntryType.category,
        label: 'Category',
        children: [
          IxMenuEntry(
            id: 'sub',
            type: IxMenuEntryType.category,
            label: 'Nested',
            children: [
              IxMenuEntry(
                id: 'deep',
                type: IxMenuEntryType.item,
                label: 'Deep',
              ),
            ],
          ),
        ],
      ),
      IxMenuEntry(id: 'after', type: IxMenuEntryType.item, label: 'After'),
    ];
    await pumpIx(tester, app(nested));
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nested'));
    await tester.pumpAndSettle();
    // The nested category's own children are never rendered inline.
    expect(find.text('Deep'), findsNothing);

    await focusFirstTile(tester);
    expectFocusOn(tester, 'Category');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expectFocusOn(tester, 'Nested');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expectFocusOn(tester, 'After');
  });

  // B2: the scaffold keeps one FocusNode per tile id in a map of its own
  // (so a fly-out can hand focus back to the tile that opened it) rather
  // than disposing it with the tile's widget; an app that adds and removes
  // menu entries at runtime must not grow that map forever, but pruning it
  // must never dispose the node a tile removed out from under the keyboard
  // focus is still holding.
  testWidgets(
    'removing the focused entry does not dispose its still-focused node',
    (tester) async {
      const both = [
        IxMenuEntry(id: 'first', type: IxMenuEntryType.item, label: 'First'),
        IxMenuEntry(id: 'second', type: IxMenuEntryType.item, label: 'Second'),
      ];
      await pumpIx(tester, app(both));
      await focusFirstTile(tester);
      expectFocusOn(tester, 'First');

      // Rebuilds the same scaffold (didUpdateWidget, not a remount) with
      // "first" gone while its node is still the primary focus.
      const secondOnly = [
        IxMenuEntry(id: 'second', type: IxMenuEntryType.item, label: 'Second'),
      ];
      await pumpIx(tester, app(secondOnly));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // The menu is still keyboard-navigable afterwards -- pruning did not
      // leave the traversal order or the focus tree in a broken state.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expectFocusOn(tester, 'Second');
    },
  );

  testWidgets('tapping an entry closes the drawer above the Navigator', (
    tester,
  ) async {
    final navigated = <String>[];
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(600, 800),
          disableAnimations: true,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: const IxThemeBuilder(mode: ThemeMode.light).build(),
          builder: (context, child) => IxApplicationScaffold(
            appTitle: 'App',
            entries: const [
              IxMenuEntry(id: 'one', type: IxMenuEntryType.item, label: 'One'),
            ],
            initiallyExpanded: true,
            onNavigate: navigated.add,
            body: child ?? const SizedBox.shrink(),
          ),
          home: const Scaffold(body: Text('page')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip(_openDrawer));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(navigated, ['one']);
    expect(find.text('One'), findsNothing);
  });
}
