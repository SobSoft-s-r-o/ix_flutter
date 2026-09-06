import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// [IxApplicationScaffold] wires [IxUnfocusOnTapOutside] around its whole
/// frame, so an app built on the scaffold gets the tap-to-dismiss behaviour
/// without writing any code -- which is what the Android emulator report
/// asked for. The behaviour itself is covered by
/// `test/focus/ix_unfocus_on_tap_outside_test.dart`; this file only proves
/// the scaffold's wiring and its opt-out.
void main() {
  group('IxApplicationScaffold.unfocusOnTapOutside', () {
    late FocusNode fieldNode;

    FocusNode newFocusNode(String label) {
      final node = FocusNode(debugLabel: label);
      addTearDown(node.dispose);
      return node;
    }

    /// See the note in `test/focus/ix_unfocus_on_tap_outside_test.dart`:
    /// `testWidgets` verifies the foundation debug variables at the end of
    /// the test body, before any tear-down runs.
    Future<void> withPlatform(
      TargetPlatform platform,
      Future<void> Function() body,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await body();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    Widget scaffold({bool unfocusOnTapOutside = true}) {
      fieldNode = newFocusNode('field');
      return IxApplicationScaffold(
        appTitle: 'Demo',
        entries: const [
          IxMenuEntry(
            id: 'home',
            type: IxMenuEntryType.item,
            label: 'Home',
            icon: Icons.home,
          ),
        ],
        onNavigate: (_) {},
        unfocusOnTapOutside: unfocusOnTapOutside,
        body: Column(
          children: [
            TextField(key: const Key('field'), focusNode: fieldNode),
            Container(
              key: const Key('outside'),
              height: 160,
              width: 400,
              color: const Color(0xFF445566),
            ),
          ],
        ),
      );
    }

    Future<void> focusField(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('field')));
      await tester.pump();
      expect(fieldNode.hasPrimaryFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    }

    testWidgets('a tap in the body releases the field and the keyboard', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, scaffold());
        await focusField(tester);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(fieldNode.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('a tap on the menu releases the field as well', (tester) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, scaffold());
        await focusField(tester);

        await tester.tap(find.text('Home'));
        await tester.pump();

        expect(fieldNode.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('unfocusOnTapOutside: false keeps the 1.x/Flutter default', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, scaffold(unfocusOnTapOutside: false));
        await focusField(tester);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });
  });
}
