import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Regression tests for the bug reported from the Android emulator: tapping
/// next to a focused text input left it focused and the soft keyboard up.
///
/// The cause is Flutter's own default, `_EditableTextTapOutsideAction` in
/// `packages/flutter/lib/src/widgets/editable_text.dart`:
///
/// ```dart
/// // The focus dropping behavior is only present on desktop platforms.
/// switch (defaultTargetPlatform) {
///   case TargetPlatform.android:
///   case TargetPlatform.iOS:
///   case TargetPlatform.fuchsia:
///     // On mobile platforms, we don't unfocus on touch events unless they're
///     // in the web browser, but we do unfocus for all other kinds of events.
///     switch (intent.pointerDownEvent.kind) {
///       case ui.PointerDeviceKind.touch:
///         if (kIsWeb) {
///           intent.focusNode.unfocus();
///         }
/// ```
///
/// The last test pins that upstream behaviour, so this file keeps saying
/// what [IxUnfocusOnTapOutside] is for even if Flutter changes its mind.
void main() {
  group('IxUnfocusOnTapOutside', () {
    late FocusNode fieldNode;

    /// A focus node disposed with the test rather than after it: a group
    /// `tearDown` runs once the binding has already disposed the
    /// [FocusManager], and detaching a node then throws.
    FocusNode newFocusNode(String label) {
      final node = FocusNode(debugLabel: label);
      addTearDown(node.dispose);
      return node;
    }

    /// Runs [body] with [platform] pinned.
    ///
    /// `addTearDown` is too late for this one: `testWidgets` verifies that
    /// no foundation debug variable is still set at the end of the test
    /// *body* (`TestWidgetsFlutterBinding._verifyInvariants`), before any
    /// tear-down runs. Hence the `finally`, which also survives a failing
    /// expectation.
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

    /// A text field, a satellite that belongs to the field's own
    /// [TextFieldTapRegion] group, an inert area, and a button.
    Widget form({
      bool enabled = true,
      bool dismissKeyboard = true,
      VoidCallback? onPressed,
      FocusNode? buttonNode,
    }) {
      fieldNode = newFocusNode('field');
      return IxUnfocusOnTapOutside(
        enabled: enabled,
        dismissKeyboard: dismissKeyboard,
        child: Column(
          children: [
            TextField(
              key: const Key('field'),
              focusNode: fieldNode,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFieldTapRegion(
              child: Container(
                key: const Key('satellite'),
                height: 40,
                width: 200,
                color: const Color(0xFF112233),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              key: const Key('outside'),
              height: 120,
              width: 400,
              color: const Color(0xFF445566),
            ),
            const SizedBox(height: 16),
            TextButton(
              key: const Key('button'),
              focusNode: buttonNode,
              onPressed: onPressed ?? () {},
              child: const Text('Press me'),
            ),
          ],
        ),
      );
    }

    /// Taps the field and waits for the keyboard to come up.
    Future<void> focusField(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('field')));
      await tester.pump();
      expect(fieldNode.hasPrimaryFocus, isTrue, reason: 'field did not focus');
      expect(
        tester.testTextInput.isVisible,
        isTrue,
        reason: 'keyboard did not open',
      );
    }

    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
      // Desktop already unfocuses on its own; the wrapper must not regress it.
      TargetPlatform.macOS,
    ]) {
      testWidgets('releases the field and hides the keyboard on $platform', (
        tester,
      ) async {
        await withPlatform(platform, () async {
          await pumpIx(tester, form());
          await focusField(tester);

          await tester.tap(find.byKey(const Key('outside')));
          await tester.pump();

          expect(fieldNode.hasFocus, isFalse, reason: 'field kept focus');
          expect(
            tester.testTextInput.isVisible,
            isFalse,
            reason: 'keyboard stayed open',
          );
        });
      });
    }

    testWidgets('a tap inside the field keeps focus and the keyboard', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        await tester.tap(find.byKey(const Key('field')));
        await tester.pump();

        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('a tap on a TextFieldTapRegion satellite keeps focus', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        await tester.tap(find.byKey(const Key('satellite')));
        await tester.pump();

        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('dragging a selection inside the field keeps focus', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        await tester.drag(find.byKey(const Key('field')), const Offset(60, 0));
        await tester.pump();

        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('a drag that starts outside the field is a scroll, not a tap', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        // Past kTouchSlop: the gesture the user meant was "scroll the form",
        // and a scroll must not take the keyboard away mid-gesture.
        await tester.drag(
          find.byKey(const Key('outside')),
          const Offset(0, -3 * kTouchSlop),
        );
        await tester.pump();

        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('a button outside still fires while the field is released', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        var pressed = 0;
        await pumpIx(tester, form(onPressed: () => pressed++));
        await focusField(tester);

        await tester.tap(find.byKey(const Key('button')));
        await tester.pump();

        expect(pressed, 1, reason: 'the wrapper swallowed the tap');
        expect(fieldNode.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('a non-text focus survives a tap elsewhere', (tester) async {
      await withPlatform(TargetPlatform.android, () async {
        final buttonNode = newFocusNode('button');
        await pumpIx(tester, form(buttonNode: buttonNode));

        buttonNode.requestFocus();
        await tester.pump();
        expect(buttonNode.hasPrimaryFocus, isTrue);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(
          buttonNode.hasPrimaryFocus,
          isTrue,
          reason: 'the keyboard focus model must not change for non-text focus',
        );
      });
    });

    testWidgets("enabled: false restores Flutter's mobile default", (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form(enabled: false));
        await focusField(tester);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    // Closing the input connection is what normally takes the keyboard
    // down: `TextInput._clearClient()` schedules a `TextInput.hide` of its
    // own. `dismissKeyboard` is the extra, explicit ask that goes out with
    // the unfocus itself -- ahead of that teardown -- for embedders that do
    // not act on the connection closing. Both settings therefore end with
    // the keyboard down; they differ in who asked for it.
    testWidgets('dismissKeyboard: true hides ahead of Flutter\'s teardown', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        tester.testTextInput.log.clear();
        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(tester.testTextInput.log.map((call) => call.method), <String>[
          'TextInput.hide',
          'TextInput.clearClient',
          'TextInput.hide',
        ]);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('dismissKeyboard: false leaves the IME to Flutter', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form(dismissKeyboard: false));
        await focusField(tester);

        tester.testTextInput.log.clear();
        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(fieldNode.hasFocus, isFalse);
        expect(
          tester.testTextInput.log.map((call) => call.method),
          <String>['TextInput.clearClient', 'TextInput.hide'],
          reason: 'the wrapper must not add a hide of its own',
        );
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('without the wrapper Flutter keeps focus on a mobile tap', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        await pumpIx(
          tester,
          Column(
            children: [
              TextField(key: const Key('field'), focusNode: fieldNode),
              Container(
                key: const Key('outside'),
                height: 120,
                width: 400,
                color: const Color(0xFF445566),
              ),
            ],
          ),
        );
        await focusField(tester);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'Flutter still keeps focus on a mobile touch tap outside',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });
  });
}
