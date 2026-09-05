import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Keyboard model of the [IxApplicationScaffold] navigation menu, mirroring
/// the upstream key set handled by `menu.tsx:842-911` (`ArrowDown`,
/// `ArrowUp`, `Home`, `End`). Upstream wraps around at both ends; this
/// library clamps instead, as `global-constraints.md` prescribes for the
/// 1.x menu.
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so each `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it (the same pattern used by
/// `test/a11y/keyboard_dropdown_test.dart`).

const _entries = [
  IxMenuEntry(
    id: 'link1',
    type: IxMenuEntryType.item,
    label: 'Link 1',
    icon: Icons.home,
  ),
  IxMenuEntry(
    id: 'link2',
    type: IxMenuEntryType.item,
    label: 'Link 2',
    icon: Icons.settings,
  ),
  IxMenuEntry(
    id: 'link3',
    type: IxMenuEntryType.item,
    label: 'Link 3',
    icon: Icons.info,
  ),
];

Widget _app({List<String>? navigated}) => IxApplicationScaffold(
  appTitle: 'App',
  entries: _entries,
  initiallyExpanded: true,
  onNavigate: (id) => navigated?.add(id),
  body: const Text('body'),
);

/// Asserts that the focused tile is inside the menu's scroll viewport, so
/// the focus ring the arrow keys move is actually on screen.
void expectFocusedTileVisible(WidgetTester tester) {
  final ctx = FocusManager.instance.primaryFocus?.context;
  expect(ctx, isNotNull);
  final tile = tester.getRect(find.byWidget(ctx!.widget));
  final viewport = tester.getRect(find.byType(Scrollable));
  expect(
    tile.top,
    greaterThanOrEqualTo(viewport.top - 0.5),
    reason: 'focused tile $tile is above the menu viewport $viewport',
  );
  expect(
    tile.bottom,
    lessThanOrEqualTo(viewport.bottom + 0.5),
    reason: 'focused tile $tile is below the menu viewport $viewport',
  );
}

/// Asserts that the widget owning the primary focus renders [label].
void expectFocusOn(WidgetTester tester, String label) {
  final ctx = FocusManager.instance.primaryFocus?.context;
  expect(ctx, isNotNull);
  expect(
    find.descendant(of: find.byWidget(ctx!.widget), matching: find.text(label)),
    findsOneWidget,
    reason: 'expected focus on "$label"',
  );
}

void main() {
  @Upstream('menu.ct.ts:412-457 should navigate with arrow keys')
  void arrowKeysMoveFocusBetweenMenuItems() {
    testWidgets(
      'ArrowDown/ArrowUp move focus between menu items, Home/End jump, '
      'Enter activates',
      (tester) async {
        final navigated = <String>[];
        await pumpIx(
          tester,
          _app(navigated: navigated),
          size: const Size(1440, 900),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // collapse button
        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // first item
        await tester.pump();
        expectFocusOn(tester, 'Link 1');

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expectFocusOn(tester, 'Link 2');

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expectFocusOn(tester, 'Link 3');

        // No wrapping: ArrowDown on the last item keeps it focused.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expectFocusOn(tester, 'Link 3');

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expectFocusOn(tester, 'Link 2');

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expectFocusOn(tester, 'Link 1');

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expectFocusOn(tester, 'Link 3');

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(navigated, ['link3']);
      },
    );
  }

  arrowKeysMoveFocusBetweenMenuItems();

  @Upstream(
    'menu.tsx:842-911 handleMenuKeyDown walks every focusable menu item and '
    'calls focus() on it',
  )
  void arrowKeysReachEveryEntryOfAScrollingMenu() {
    testWidgets(
      'Arrow/Home/End reach every entry of a scrolling menu and keep the '
      'focused tile on screen',
      (tester) async {
        await pumpIx(
          tester,
          IxApplicationScaffold(
            appTitle: 'App',
            entries: [
              for (var i = 1; i <= 20; i++)
                IxMenuEntry(
                  id: 'e$i',
                  type: IxMenuEntryType.item,
                  label: 'Entry $i',
                ),
            ],
            initiallyExpanded: true,
            onNavigate: (_) {},
            body: const Text('body'),
          ),
          // Far shorter than the 20 entries need, so the menu scrolls.
          size: const Size(1440, 400),
        );

        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // sidebar toggle
        await tester.sendKeyEvent(LogicalKeyboardKey.tab); // first entry
        await tester.pump();
        expectFocusOn(tester, 'Entry 1');
        expectFocusedTileVisible(tester);

        for (var i = 2; i <= 20; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pump();
          expectFocusOn(tester, 'Entry $i');
          expectFocusedTileVisible(tester);
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expectFocusOn(tester, 'Entry 1');
        expectFocusedTileVisible(tester);

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expectFocusOn(tester, 'Entry 20');
        expectFocusedTileVisible(tester);
      },
    );
  }

  arrowKeysReachEveryEntryOfAScrollingMenu();
}
