import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// [IxApplicationScaffold] wires [IxKeyboardDismissScope] around its whole
/// frame, so an app built on the scaffold dismisses the keyboard both on a
/// tap outside a field and on a scroll without writing any code -- which is
/// what the two Android emulator reports asked for. The behaviour itself is
/// covered by
/// `test/focus/ix_keyboard_dismiss_scope_test.dart`; this file only proves
/// the scaffold's wiring and its opt-out.
void main() {
  group('IxApplicationScaffold.dismissKeyboardOnInteraction', () {
    late FocusNode fieldNode;
    late ScrollController listController;

    FocusNode newFocusNode(String label) {
      final node = FocusNode(debugLabel: label);
      addTearDown(node.dispose);
      return node;
    }

    ScrollController newController() {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      return scroll;
    }

    /// See the note in `test/focus/ix_keyboard_dismiss_scope_test.dart`:
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

    /// [bodyOptsOut] wraps the body in a scope of its own that is switched
    /// off -- one page declining the behaviour the frame turned on.
    Widget scaffold({
      bool dismissKeyboardOnInteraction = true,
      bool bodyOptsOut = false,
    }) {
      fieldNode = newFocusNode('field');
      final body = Column(
        children: [
          TextField(key: const Key('field'), focusNode: fieldNode),
          Container(
            key: const Key('outside'),
            height: 160,
            width: 400,
            color: const Color(0xFF445566),
          ),
        ],
      );
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
        dismissKeyboardOnInteraction: dismissKeyboardOnInteraction,
        body: bodyOptsOut
            ? IxKeyboardDismissScope(enabled: false, child: body)
            : body,
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

    testWidgets(
      'dismissKeyboardOnInteraction: false keeps the 1.x/Flutter default',
      (tester) async {
        await withPlatform(TargetPlatform.android, () async {
          await pumpIx(tester, scaffold(dismissKeyboardOnInteraction: false));
          await focusField(tester);

          await tester.tap(find.byKey(const Key('outside')));
          await tester.pump();

          expect(fieldNode.hasPrimaryFocus, isTrue);
          expect(tester.testTextInput.isVisible, isTrue);
        });
      },
    );

    /// The scaffold turns the behaviour on for the whole frame, so a page
    /// that wants Flutter's default back has nowhere to go but a nested
    /// scope with `enabled: false` -- documented as putting "Flutter's
    /// platform defaults back for [child]".
    testWidgets('a body scope with enabled: false opts that page out', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, scaffold(bodyOptsOut: true));
        await focusField(tester);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'the page opted out of the scaffold-wide scope',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    /// The same scaffold, but with a scrollable body.
    Widget scrollingScaffold({bool dismissKeyboardOnInteraction = true}) {
      fieldNode = newFocusNode('field');
      listController = newController();
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
        dismissKeyboardOnInteraction: dismissKeyboardOnInteraction,
        body: ListView(
          controller: listController,
          children: [
            TextField(key: const Key('field'), focusNode: fieldNode),
            for (var i = 0; i < 20; i++)
              SizedBox(
                key: Key('row$i'),
                height: 120,
                child: ColoredBox(
                  color: const Color(0xFF445566),
                  child: Text('Row $i'),
                ),
              ),
          ],
        ),
      );
    }

    testWidgets('a drag in a scrollable body releases the field', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, scrollingScaffold());
        await focusField(tester);

        await tester.drag(find.byKey(const Key('row1')), const Offset(0, -200));
        await tester.pump();

        expect(listController.offset, greaterThan(0));
        expect(fieldNode.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('dismissKeyboardOnInteraction: false keeps the drag default', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(
          tester,
          scrollingScaffold(dismissKeyboardOnInteraction: false),
        );
        await focusField(tester);

        await tester.drag(find.byKey(const Key('row1')), const Offset(0, -200));
        await tester.pump();

        expect(listController.offset, greaterThan(0));
        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });
  });
}
