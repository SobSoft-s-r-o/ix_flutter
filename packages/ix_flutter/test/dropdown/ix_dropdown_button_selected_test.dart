import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Which row an [IxDropdownButton] menu opens on.
///
/// Upstream `dropdown.tsx` opens a menu on the option that is currently
/// selected, so the user sees where they are; only a menu with nothing
/// selected falls back to the first item. The explicit positional keys
/// (`Home`, `End`, `ArrowUp`) keep meaning first/last.
void main() {
  const items = [
    IxDropdownMenuItem(value: 1, label: 'One'),
    IxDropdownMenuItem(value: 2, label: 'Two', checked: true),
    IxDropdownMenuItem(value: 3, label: 'Three'),
  ];

  String? focusedLabel() => FocusManager.instance.primaryFocus?.debugLabel;

  Future<void> pumpDropdown(
    WidgetTester tester, {
    List<IxDropdownMenuItem<int>> menuItems = items,
  }) => pumpIx(
    tester,
    Align(
      alignment: Alignment.topLeft,
      child: IxDropdownButton<int>(label: 'Actions', items: menuItems),
    ),
  );

  testWidgets('a click opens the menu on the checked row', (tester) async {
    await pumpDropdown(tester);

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    expect(focusedLabel(), 'IxDropdownButton.item[1]');
  });

  for (final key in [
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.space,
  ]) {
    testWidgets('a keyboard open (${key.debugName}) lands on the checked row', (
      tester,
    ) async {
      await pumpDropdown(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();

      expect(focusedLabel(), 'IxDropdownButton.item[1]');
    });
  }

  testWidgets('Home and End stay explicitly first and last', (tester) async {
    await pumpDropdown(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(focusedLabel(), 'IxDropdownButton.item[0]');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(focusedLabel(), 'IxDropdownButton.item[2]');
  });

  testWidgets('with nothing checked the first enabled row is focused', (
    tester,
  ) async {
    await pumpDropdown(
      tester,
      menuItems: const [
        IxDropdownMenuItem(value: 1, label: 'One', disabled: true),
        IxDropdownMenuItem(value: 2, label: 'Two'),
        IxDropdownMenuItem(value: 3, label: 'Three'),
      ],
    );

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    expect(focusedLabel(), 'IxDropdownButton.item[1]');
  });

  testWidgets('a disabled checked row falls back to the first enabled one', (
    tester,
  ) async {
    await pumpDropdown(
      tester,
      menuItems: const [
        IxDropdownMenuItem(value: 1, label: 'One'),
        IxDropdownMenuItem(
          value: 2,
          label: 'Two',
          checked: true,
          disabled: true,
        ),
      ],
    );

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    expect(focusedLabel(), 'IxDropdownButton.item[0]');
  });

  testWidgets('the checked row is announced as checked', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDropdown(tester);
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Two')),
      matchesSemantics(
        label: 'Two',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        isFocused: true,
        hasFocusAction: true,
        hasTapAction: true,
        isChecked: true,
        hasCheckedState: true,
      ),
    );
    // Disposed here rather than through addTearDown: flutter_test verifies
    // that every SemanticsHandle is gone *before* the tear-downs run.
    handle.dispose();
  });

  testWidgets('the pagination page-size menu opens on the current size', (
    tester,
  ) async {
    await pumpIx(
      tester,
      Align(
        alignment: Alignment.topLeft,
        child: IxPaginationBar(
          page: 1,
          totalPages: 5,
          pageSize: 25,
          pageSizeOptions: const [10, 25, 50],
          onPageSizeChanged: (_) {},
          onPageChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();

    expect(focusedLabel(), 'IxDropdownButton.item[1]');
  });
}
