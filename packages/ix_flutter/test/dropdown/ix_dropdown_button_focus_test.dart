import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Who owns the keyboard focus once an [IxDropdownButton] menu closes.
///
/// The rule: the trigger takes the focus back only when the focus was still
/// inside the menu -- that is, when the menu was being driven from the
/// keyboard. A pointer never put the focus there, so a pointer-driven close
/// must not put a focus ring on the trigger, and a selection handler that
/// moves the focus somewhere of its own must win.

/// Host that declines the first open request and accepts the next.
class _PickyHost extends StatefulWidget {
  const _PickyHost();

  @override
  State<_PickyHost> createState() => _PickyHostState();
}

class _PickyHostState extends State<_PickyHost> {
  bool _open = false;
  var _declineNext = true;

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<int>(
      label: 'Actions',
      isOpen: _open,
      onOpenChanged: (open) {
        if (open && _declineNext) {
          _declineNext = false;
          return;
        }
        setState(() => _open = open);
      },
      items: const [
        IxDropdownMenuItem(value: 1, label: 'One'),
        IxDropdownMenuItem(value: 2, label: 'Two'),
      ],
    );
  }
}

/// Host that starts controlled and hands the menu over to the widget.
class _HandoverHost extends StatefulWidget {
  const _HandoverHost({required this.opens});

  final List<bool> opens;

  @override
  State<_HandoverHost> createState() => _HandoverHostState();
}

class _HandoverHostState extends State<_HandoverHost> {
  bool? _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IxDropdownButton<int>(
          label: 'Actions',
          isOpen: _open,
          // The hand-over button is a tap outside the menu; `inside` keeps
          // that from closing the menu before the hand-over happens.
          closeBehavior: IxDropdownCloseBehavior.inside,
          onOpenChanged: (open) {
            widget.opens.add(open);
            if (_open != null) {
              setState(() => _open = open);
            }
          },
          items: const [IxDropdownMenuItem(value: 1, label: 'One')],
        ),
        // Far enough below the trigger that the open menu does not cover
        // it: a tap that landed on a menu row would select it instead.
        const SizedBox(height: 200),
        TextButton(
          onPressed: () => setState(() => _open = null),
          child: const Text('hand over'),
        ),
      ],
    );
  }
}

bool _focusedIs(FocusNode node) =>
    identical(FocusManager.instance.primaryFocus, node);

void main() {
  testWidgets('a selection handler that moves the focus keeps it', (
    tester,
  ) async {
    final elsewhere = FocusNode(debugLabel: 'elsewhere');
    addTearDown(elsewhere.dispose);

    await pumpIx(
      tester,
      Column(
        children: [
          IxDropdownButton<int>(
            label: 'Actions',
            items: const [
              IxDropdownMenuItem(value: 1, label: 'One'),
              IxDropdownMenuItem(value: 2, label: 'Two'),
            ],
            onItemSelected: (_) => elsewhere.requestFocus(),
          ),
          Focus(focusNode: elsewhere, child: const Text('target')),
        ],
      ),
    );

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    expect(
      _focusedIs(elsewhere),
      isTrue,
      reason: 'the trigger stole the focus the selection handler asked for',
    );
  });

  testWidgets('a pointer click outside leaves the trigger unfocused', (
    tester,
  ) async {
    await pumpIx(
      tester,
      Column(
        children: [
          IxDropdownButton<int>(
            label: 'Actions',
            items: const [IxDropdownMenuItem(value: 1, label: 'One')],
          ),
          const SizedBox(height: 200, child: Text('elsewhere')),
        ],
      ),
    );

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.text('elsewhere')));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsNothing);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      isNot('IxDropdownButton.trigger'),
      reason:
          'a pointer never focused the trigger, so it must not end up '
          'wearing the focus ring',
    );
  });

  testWidgets('Escape from the menu still returns the focus to the trigger', (
    tester,
  ) async {
    await pumpIx(
      tester,
      IxDropdownButton<int>(
        label: 'Actions',
        items: const [IxDropdownMenuItem(value: 1, label: 'One')],
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'IxDropdownButton.trigger',
    );
  });

  testWidgets('a declined open does not arm a stale row focus request', (
    tester,
  ) async {
    await pumpIx(tester, const _PickyHost());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // ArrowUp asks to open on the *last* row; the owner declines.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsNothing);

    // ArrowDown asks to open on the first row; the owner accepts.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'IxDropdownButton.item[0]',
      reason: 'the declined request for the last row fired on the next open',
    );
  });

  testWidgets('an owner-driven close returns the focus to the trigger', (
    tester,
  ) async {
    // Pinned rather than fixed: Flutter\'s per-scope focus history already
    // does this when the focused row unmounts.
    final opens = <bool>[];
    await pumpIx(tester, _HandoverHost(opens: opens));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'IxDropdownButton.trigger',
    );
  });

  testWidgets(
    'a controlled -> uncontrolled handover keeps the menu as it was',
    (tester) async {
      final opens = <bool>[];
      await pumpIx(tester, _HandoverHost(opens: opens));

      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);
      opens.clear();

      await tester.tap(find.text('hand over'));
      await tester.pumpAndSettle();
      expect(
        find.text('One'),
        findsOneWidget,
        reason: 'the handover snapped the menu shut',
      );
      expect(opens, isEmpty, reason: 'the handover reported a state change');
    },
  );
}
