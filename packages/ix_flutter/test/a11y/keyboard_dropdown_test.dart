import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Keyboard, focus and semantics contract of [IxDropdownButton], mirroring
/// the upstream `dropdown.tsx` / `dropdown-focus.ts` interaction model.
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so each `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it (the same pattern used by
/// `test/a11y/semantics_matrix_test.dart`). This keeps the annotation
/// attached to its test 1:1.

/// Builds a trigger surrounded by two focusable text fields so traversal
/// (Tab in and out of the dropdown) can be observed.
Widget _dropdown({
  List<int>? selected,
  List<bool>? opens,
  FocusNode? before,
  FocusNode? after,
  IxDropdownCloseBehavior closeBehavior = IxDropdownCloseBehavior.both,
  List<IxDropdownMenuItem<int>> items = const [
    IxDropdownMenuItem(label: 'Edit', value: 1),
    IxDropdownMenuItem(label: 'Duplicate', value: 2),
    IxDropdownMenuItem(label: 'Delete', value: 3, disabled: true),
  ],
  double? maxHeight,
}) {
  return Column(
    children: [
      TextField(key: const Key('before'), focusNode: before),
      IxDropdownButton<int>(
        key: const Key('dd'),
        label: 'Actions',
        closeBehavior: closeBehavior,
        maxHeight: maxHeight,
        items: items,
        onItemSelected: selected?.add,
        onOpenChanged: opens?.add,
      ),
      TextField(key: const Key('after'), focusNode: after),
    ],
  );
}

/// A trigger whose 30 rows do not fit the menu's 160px height budget, so
/// keyboard navigation has to scroll the focused row into view.
Widget _scrollingDropdown({Set<int> disabled = const {}}) => _dropdown(
  maxHeight: 160,
  items: [
    for (var i = 0; i < 30; i++)
      IxDropdownMenuItem(
        label: 'Item $i',
        value: i,
        disabled: disabled.contains(i),
      ),
  ],
);

/// The open menu's current scroll offset, in logical pixels.
double _menuScrollOffset(WidgetTester tester) {
  return tester
      .state<ScrollableState>(
        find.descendant(
          of: find.byKey(const Key('ix-dropdown-menu')),
          matching: find.byType(Scrollable),
        ),
      )
      .position
      .pixels;
}

/// Asserts that the row labelled [label] is laid out inside the menu's own
/// bounds, i.e. is actually on screen rather than merely present in the
/// (eagerly built) scroll view.
void _expectRowVisible(WidgetTester tester, String label) {
  final menu = tester.getRect(find.byKey(const Key('ix-dropdown-menu')));
  final row = tester.getRect(find.text(label));
  expect(
    row.top,
    greaterThanOrEqualTo(menu.top - 0.5),
    reason: '"$label" is scrolled off the top of the menu',
  );
  expect(
    row.bottom,
    lessThanOrEqualTo(menu.bottom + 0.5),
    reason: '"$label" is scrolled off the bottom of the menu',
  );
}

/// Returns the text rendered inside the widget that currently owns the
/// primary focus, or the focused widget's runtime type when it contains no
/// [Text] (an empty `TextField`, for instance).
///
/// The element identity check (rather than `find.byWidget`) keeps the lookup
/// unambiguous when several identical widget instances are in the tree.
String? _focusedText(WidgetTester tester) {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) {
    return null;
  }
  final texts = find.descendant(
    of: find.byElementPredicate((element) => identical(element, context)),
    matching: find.byType(Text),
  );
  if (texts.evaluate().isEmpty) {
    return context.widget.runtimeType.toString();
  }
  return tester.widget<Text>(texts.first).data;
}

/// Focuses the trigger by tapping the preceding field and tabbing once.
Future<void> _focusTrigger(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('before')));
  await tester.pump();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

void main() {
  @Upstream(
    'dropdown.ct.ts A11y > Keyboard navigation > ArrowDown > trigger '
    '-> first item; dropdown-focus.ts:179-268',
  )
  void arrowDownOpensAndFocusesFirstItem() {
    testWidgets('ArrowDown on the trigger opens and focuses the first item', (
      tester,
    ) async {
      await pumpIx(tester, _dropdown());
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Edit'), findsOneWidget);
      expect(_focusedText(tester), 'Edit');
    });
  }

  arrowDownOpensAndFocusesFirstItem();

  @Upstream(
    'dropdown.tsx:362-459 ArrowUp/End open the dropdown on the last '
    'item',
  )
  void arrowUpOpensAndFocusesLastEnabledItem() {
    testWidgets(
      'ArrowUp and End on the trigger open and focus the last enabled item',
      (tester) async {
        await pumpIx(tester, _dropdown());
        await _focusTrigger(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump(const Duration(milliseconds: 200));
        expect(_focusedText(tester), 'Duplicate');

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump(const Duration(milliseconds: 200));
        expect(_focusedText(tester), 'Duplicate');
      },
    );
  }

  arrowUpOpensAndFocusesLastEnabledItem();

  @Upstream(
    'dropdown.ct.ts ArrowUp > second item -> fist item; '
    'dropdown-top-layer.ct.ts Escape key closes dropdown',
  )
  void arrowKeysCycleAndEscapeRestoresFocus() {
    testWidgets(
      'Arrow keys cycle, Escape closes and restores focus to the trigger',
      (tester) async {
        final opens = <bool>[];
        await pumpIx(tester, _dropdown(opens: opens));
        await _focusTrigger(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump(const Duration(milliseconds: 200));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(_focusedText(tester), 'Duplicate');

        // "Delete" is disabled, so the cycle wraps back to the first item.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        expect(_focusedText(tester), 'Edit');

        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect(_focusedText(tester), 'Duplicate');

        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expect(_focusedText(tester), 'Edit');

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(_focusedText(tester), 'Duplicate');

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('Edit'), findsNothing);
        expect(_focusedText(tester), 'Actions');
        expect(opens, [true, false]);
      },
    );
  }

  arrowKeysCycleAndEscapeRestoresFocus();

  @Upstream('dropdown-focus.ts:179-268 Enter/Space activate the focused item')
  void enterOnItemSelectsClosesAndReturnsFocus() {
    testWidgets('Enter on an item selects it, closes and returns focus', (
      tester,
    ) async {
      final selected = <int>[];
      await pumpIx(tester, _dropdown(selected: selected));
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 200));

      expect(selected, [2]);
      expect(find.text('Edit'), findsNothing);
      expect(_focusedText(tester), 'Actions');
    });
  }

  enterOnItemSelectsClosesAndReturnsFocus();

  @Upstream('dropdown-focus.ts:179-268 Space activates the focused item')
  void spaceOnItemSelectsIt() {
    testWidgets('Space on an item selects it', (tester) async {
      final selected = <int>[];
      await pumpIx(tester, _dropdown(selected: selected));
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 200));

      expect(selected, [1]);
      expect(find.text('Edit'), findsNothing);
    });
  }

  spaceOnItemSelectsIt();

  @Upstream(
    'dropdown.tsx:166-180 Tab closes the dropdown and lets focus move '
    'on',
  )
  void tabClosesAndFocusContinues() {
    testWidgets('Tab closes the menu and moves focus past the trigger', (
      tester,
    ) async {
      final after = FocusNode(debugLabel: 'after');
      addTearDown(after.dispose);
      await pumpIx(tester, _dropdown(after: after));
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_focusedText(tester), 'Edit');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Edit'), findsNothing);
      expect(after.hasFocus, isTrue);
    });
  }

  tabClosesAndFocusContinues();

  @Upstream(
    'dropdown-button.ct.ts:106-133 aria-expanded; '
    'dropdown-item.tsx:96 role=menuitem',
  )
  void semanticsExposeExpandedStateMenuAndItemRoles() {
    testWidgets(
      'semantics: trigger expanded state, menu role, item roles and disabled',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(tester, _dropdown());

        expect(
          tester.getSemantics(find.text('Actions')),
          matchesSemantics(
            isButton: true,
            hasExpandedState: true,
            isExpanded: false,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Actions',
          ),
        );

        await tester.tap(find.text('Actions'));
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          tester.getSemantics(find.text('Actions')),
          matchesSemantics(
            isButton: true,
            hasExpandedState: true,
            isExpanded: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Actions',
          ),
        );

        // `matchesSemantics`/`containsSemantics` have no `role` argument in
        // Flutter 3.44, so the ARIA role mapping is asserted on the node.
        expect(
          tester.getSemantics(find.byKey(const Key('ix-dropdown-menu'))).role,
          SemanticsRole.menu,
        );
        expect(
          tester.getSemantics(find.text('Edit')).role,
          SemanticsRole.menuItem,
        );
        expect(
          tester.getSemantics(find.text('Delete')).role,
          SemanticsRole.menuItem,
        );

        expect(
          tester.getSemantics(find.text('Edit')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Edit',
          ),
        );
        expect(
          tester.getSemantics(find.text('Delete')),
          matchesSemantics(
            hasEnabledState: true,
            isEnabled: false,
            label: 'Delete',
          ),
        );
        handle.dispose();
      },
    );
  }

  semanticsExposeExpandedStateMenuAndItemRoles();

  @Upstream('dropdown.scss:19,53-54 min-width 0, width max-content')
  void overlayWidthFollowsContentWithinViewport() {
    testWidgets(
      'overlay width follows content and never exceeds the viewport',
      (tester) async {
        await pumpIx(
          tester,
          IxDropdownButton<int>(
            label: 'A',
            items: const [
              IxDropdownMenuItem(label: 'Short', value: 1),
              IxDropdownMenuItem(
                label: 'A considerably longer dropdown item label',
                value: 2,
              ),
            ],
          ),
          size: const Size(360, 640),
        );
        await tester.tap(find.text('A'));
        await tester.pump(const Duration(milliseconds: 200));

        final menu = tester.getRect(find.byKey(const Key('ix-dropdown-menu')));
        expect(menu.width, greaterThan(200));
        expect(menu.left, greaterThanOrEqualTo(8));
        expect(menu.right, lessThanOrEqualTo(360 - 8));
      },
    );
  }

  overlayWidthFollowsContentWithinViewport();

  @Upstream('dropdown.scss:16-24 the menu scrolls inside its max height')
  void menuScrollsInsideHalfViewportMaxHeight() {
    testWidgets('30 items scroll inside max height ~ 50% of viewport', (
      tester,
    ) async {
      await pumpIx(
        tester,
        IxDropdownButton<int>(
          label: 'A',
          items: [
            for (var i = 0; i < 30; i++)
              IxDropdownMenuItem(label: 'Item $i', value: i),
          ],
        ),
        size: const Size(800, 600),
      );
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 200));

      final menu = tester.getRect(find.byKey(const Key('ix-dropdown-menu')));
      expect(menu.height, lessThanOrEqualTo(600 / 2 - 48 + 1));

      final scrollable = find.descendant(
        of: find.byKey(const Key('ix-dropdown-menu')),
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsOneWidget);
      expect(tester.widget<Scrollable>(scrollable).axis, Axis.vertical);

      await tester.drag(
        find.byKey(const Key('ix-dropdown-menu')),
        const Offset(0, -2000),
      );
      await tester.pump();
      expect(find.text('Item 29'), findsOneWidget);
      expect(
        tester.getRect(find.text('Item 29')).bottom,
        lessThanOrEqualTo(menu.bottom + 1),
      );
    });
  }

  menuScrollsInsideHalfViewportMaxHeight();

  @Upstream(
    'dropdown-focus.ts:75-92 focusItem() follows focusElement() with '
    "element.scrollIntoView({block: 'nearest'})",
  )
  void keyboardFocusScrollsTheRowIntoView() {
    testWidgets('End, Home and repeated ArrowDown keep the focused row inside '
        'the menu viewport', (tester) async {
      await pumpIx(tester, _scrollingDropdown());
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_focusedText(tester), 'Item 0');
      expect(_menuScrollOffset(tester), 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_focusedText(tester), 'Item 29');
      expect(_menuScrollOffset(tester), greaterThan(0));
      _expectRowVisible(tester, 'Item 29');

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_focusedText(tester), 'Item 0');
      _expectRowVisible(tester, 'Item 0');

      for (var i = 1; i <= 20; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump(const Duration(milliseconds: 200));
        expect(_focusedText(tester), 'Item $i');
        _expectRowVisible(tester, 'Item $i');
      }
    });
  }

  keyboardFocusScrollsTheRowIntoView();

  @Upstream(
    'dropdown-focus.ts:75-92 focusItem() follows focusElement() with '
    "element.scrollIntoView({block: 'nearest'})",
  )
  void openingRevealsTheInitiallyFocusedRow() {
    testWidgets('opening reveals the initially focused row when it is off '
        'screen', (tester) async {
      // The first *enabled* row is the one the menu opens on, so a long
      // run of disabled rows above it puts it outside the menu's viewport
      // on the very first frame -- before any row's focus node is even
      // attached.
      await pumpIx(
        tester,
        _scrollingDropdown(disabled: {for (var i = 0; i < 25; i++) i}),
      );
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 200));

      expect(_focusedText(tester), 'Item 25');
      expect(_menuScrollOffset(tester), greaterThan(0));
      _expectRowVisible(tester, 'Item 25');
    });
  }

  openingRevealsTheInitiallyFocusedRow();

  @Upstream(
    'dropdown-controller.ts:154-158 a window keydown of Escape dismisses '
    'the open dropdown stack',
  )
  void escapeClosesAMenuWithNothingToFocus() {
    testWidgets('Escape closes a menu with no focusable row and keeps the '
        'trigger focused', (tester) async {
      await pumpIx(
        tester,
        _dropdown(
          items: const [
            IxDropdownMenuItem(label: 'Only', value: 1, disabled: true),
          ],
        ),
      );
      await _focusTrigger(tester);
      // Opened from the keyboard with nothing focusable inside: focus stays
      // on the trigger, so the menu's own FocusScope never sees a key event.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('ix-dropdown-menu')), findsOneWidget);
      expect(_focusedText(tester), 'Actions');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('ix-dropdown-menu')), findsNothing);
      expect(_focusedText(tester), 'Actions');
    });
  }

  escapeClosesAMenuWithNothingToFocus();

  @Upstream(
    'dropdown-controller.ts:154-158 a window keydown of Escape dismisses '
    'the open dropdown stack',
  )
  void escapeClosesAnEmptyMenu() {
    testWidgets('Escape closes a menu with no rows at all', (tester) async {
      await pumpIx(tester, _dropdown(items: const []));
      await _focusTrigger(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('ix-dropdown-menu')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byKey(const Key('ix-dropdown-menu')), findsNothing);
      expect(_focusedText(tester), 'Actions');
    });
  }

  escapeClosesAnEmptyMenu();
}
