import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Regression tests for the two keyboard bugs reported from the Android
/// emulator: tapping next to a focused text input (bug 10) and scrolling the
/// page (bug 11) both left the field focused and the soft keyboard up.
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
/// what [IxKeyboardDismissScope] is for even if Flutter changes its mind.
void main() {
  group('IxKeyboardDismissScope.onTapOutside', () {
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
      return IxKeyboardDismissScope(
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

    testWidgets('a drag outside the field is not treated as a tap', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        // Past kTouchSlop, and nothing here scrolls: the tap trigger must
        // not fire for a gesture the user did not mean as a tap. A drag that
        // really does scroll is the onDrag trigger's job, below.
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

  /// Bug 11: with the keyboard open, scrolling the page did not dismiss it.
  ///
  /// Flutter only dismisses on scroll per scroll view, and the app-wide
  /// default opts out (`widgets/scroll_configuration.dart`):
  ///
  /// ```dart
  /// ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(BuildContext context) =>
  ///     ScrollViewKeyboardDismissBehavior.manual;
  /// ```
  ///
  /// The last test pins that default, the way the tap group pins Flutter's
  /// tap-outside default.
  group('IxKeyboardDismissScope.onDrag', () {
    late FocusNode fieldNode;
    late ScrollController controller;

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

    TextEditingController newTextController(String text) {
      final text0 = TextEditingController(text: text);
      addTearDown(text0.dispose);
      return text0;
    }

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

    /// Rows tall enough that the list is scrollable in the 1024x768 viewport.
    List<Widget> rows() => <Widget>[
      for (var i = 0; i < 20; i++)
        SizedBox(
          key: Key('row$i'),
          height: 120,
          child: ColoredBox(
            color: const Color(0xFF445566),
            child: Text('Row $i'),
          ),
        ),
    ];

    Widget scoped({
      required Widget child,
      bool enabled = true,
      bool onTapOutside = true,
      bool onDrag = true,
    }) => IxKeyboardDismissScope(
      enabled: enabled,
      onTapOutside: onTapOutside,
      onDrag: onDrag,
      child: child,
    );

    /// A field at the top of a scrollable list.
    Widget listForm({
      bool enabled = true,
      bool onTapOutside = true,
      bool onDrag = true,
      FocusNode? buttonNode,
      String? fieldText,
    }) {
      fieldNode = newFocusNode('field');
      controller = newController();
      return scoped(
        enabled: enabled,
        onTapOutside: onTapOutside,
        onDrag: onDrag,
        child: ListView(
          controller: controller,
          children: [
            TextField(
              key: const Key('field'),
              focusNode: fieldNode,
              controller: fieldText == null
                  ? null
                  : newTextController(fieldText),
            ),
            if (buttonNode != null)
              TextButton(
                key: const Key('button'),
                focusNode: buttonNode,
                onPressed: () {},
                child: const Text('Press me'),
              ),
            ...rows(),
          ],
        ),
      );
    }

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

    /// Drags [key] up far enough to scroll, with a touch pointer.
    Future<void> dragUp(WidgetTester tester, String key) async {
      await tester.drag(find.byKey(Key(key)), const Offset(0, -200));
      await tester.pump();
    }

    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
    ]) {
      testWidgets(
        'a user drag scrolls and dismisses the keyboard on $platform',
        (tester) async {
          await withPlatform(platform, () async {
            await pumpIx(tester, listForm());
            await focusField(tester);

            await dragUp(tester, 'row1');

            expect(
              controller.offset,
              greaterThan(0),
              reason: 'the drag must still scroll the list',
            );
            expect(fieldNode.hasFocus, isFalse, reason: 'field kept focus');
            expect(
              tester.testTextInput.isVisible,
              isFalse,
              reason: 'keyboard stayed open',
            );
          });
        },
      );
    }

    testWidgets('a programmatic scroll does not dismiss the keyboard', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, listForm());
        await focusField(tester);

        controller.jumpTo(300);
        await tester.pump();

        expect(controller.offset, 300);
        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('a SingleChildScrollView dismisses on a user drag', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        controller = newController();
        await pumpIx(
          tester,
          scoped(
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  TextField(key: const Key('field'), focusNode: fieldNode),
                  ...rows(),
                ],
              ),
            ),
          ),
        );
        await focusField(tester);

        await dragUp(tester, 'row1');

        expect(controller.offset, greaterThan(0));
        expect(fieldNode.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('a nested scrollable dismisses on a user drag', (tester) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        final inner = newController();
        await pumpIx(
          tester,
          scoped(
            child: ListView(
              children: [
                TextField(key: const Key('field'), focusNode: fieldNode),
                SizedBox(
                  height: 200,
                  child: ListView(
                    key: const Key('inner'),
                    controller: inner,
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < 20; i++)
                        SizedBox(
                          key: Key('cell$i'),
                          width: 200,
                          child: ColoredBox(
                            color: const Color(0xFF223344),
                            child: Text('Cell $i'),
                          ),
                        ),
                    ],
                  ),
                ),
                ...rows(),
              ],
            ),
          ),
        );
        await focusField(tester);

        await tester.drag(
          find.byKey(const Key('cell1')),
          const Offset(-200, 0),
        );
        await tester.pump();

        expect(
          inner.offset,
          greaterThan(0),
          reason: 'the inner list must still scroll',
        );
        expect(fieldNode.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('a selection drag inside the field does not dismiss', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        // Long enough to overflow, so the field's own scroll view can move
        // and emit drag-driven scroll notifications of its own.
        await pumpIx(tester, listForm(fieldText: 'x' * 400));
        await focusField(tester);

        await tester.drag(find.byKey(const Key('field')), const Offset(-60, 0));
        await tester.pump();

        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'the field must not dismiss its own keyboard',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('a non-text focus survives a user drag', (tester) async {
      await withPlatform(TargetPlatform.android, () async {
        final buttonNode = newFocusNode('button');
        await pumpIx(tester, listForm(buttonNode: buttonNode));

        buttonNode.requestFocus();
        await tester.pump();
        expect(buttonNode.hasPrimaryFocus, isTrue);

        await dragUp(tester, 'row1');

        expect(
          buttonNode.hasPrimaryFocus,
          isTrue,
          reason: 'only a text input may be released by a scroll',
        );
      });
    });

    testWidgets('onDrag: false keeps the keyboard, onTapOutside still works', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, listForm(onDrag: false));
        await focusField(tester);

        await dragUp(tester, 'row1');
        expect(controller.offset, greaterThan(0));
        expect(fieldNode.hasPrimaryFocus, isTrue, reason: 'onDrag was off');
        expect(tester.testTextInput.isVisible, isTrue);

        await tester.tap(find.byKey(const Key('row1')));
        await tester.pump();
        expect(
          fieldNode.hasFocus,
          isFalse,
          reason: 'the tap trigger is independent of onDrag',
        );
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('onTapOutside: false keeps the tap, onDrag still works', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, listForm(onTapOutside: false));
        await focusField(tester);

        await tester.tap(find.byKey(const Key('row1')));
        await tester.pump();
        expect(fieldNode.hasPrimaryFocus, isTrue, reason: 'onTapOutside off');
        expect(tester.testTextInput.isVisible, isTrue);

        await dragUp(tester, 'row1');
        expect(fieldNode.hasFocus, isFalse, reason: 'onDrag is independent');
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets("enabled: false restores Flutter's default for both triggers", (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(tester, listForm(enabled: false));
        await focusField(tester);

        await dragUp(tester, 'row1');
        expect(controller.offset, greaterThan(0));
        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        await tester.tap(find.byKey(const Key('row1')));
        await tester.pump();
        expect(fieldNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('without the scope a user drag keeps the keyboard', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        controller = newController();
        await pumpIx(
          tester,
          ListView(
            controller: controller,
            children: [
              TextField(key: const Key('field'), focusNode: fieldNode),
              ...rows(),
            ],
          ),
        );
        await focusField(tester);

        await dragUp(tester, 'row1');

        expect(controller.offset, greaterThan(0));
        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'ScrollViewKeyboardDismissBehavior.manual is the default',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });
  });

  /// The scope covers one subtree -- its [IxKeyboardDismissScope.child] --
  /// but the two triggers reach that subtree by different means: the tap
  /// trigger through an [Actions] override the field itself looks up, the
  /// drag trigger through a [NotificationListener] paired with
  /// `FocusManager.instance.primaryFocus`. These tests ask whether both stay
  /// within the subtree: whether a scroll releases a field the scope does not
  /// own, and whether a nested scope may opt out under an enabled one.
  group('IxKeyboardDismissScope scope boundaries', () {
    late FocusNode fieldNode;
    late ScrollController controller;

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

    List<Widget> rows() => <Widget>[
      for (var i = 0; i < 20; i++)
        SizedBox(
          key: Key('row$i'),
          height: 120,
          child: ColoredBox(
            color: const Color(0xFF445566),
            child: Text('Row $i'),
          ),
        ),
    ];

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

    testWidgets('a scroll inside the scope leaves a field outside it alone', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        controller = newController();
        await pumpIx(
          tester,
          Column(
            children: [
              // A sibling of the scope, not a descendant of it: a field this
              // scope was never given.
              TextField(key: const Key('field'), focusNode: fieldNode),
              SizedBox(
                height: 400,
                child: IxKeyboardDismissScope(
                  child: ListView(controller: controller, children: rows()),
                ),
              ),
            ],
          ),
        );
        await focusField(tester);

        await tester.drag(find.byKey(const Key('row1')), const Offset(0, -200));
        await tester.pump();

        expect(
          controller.offset,
          greaterThan(0),
          reason: 'the drag must still scroll the list',
        );
        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'a scope may only release a field inside its own subtree',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    /// `enabled: false` is documented to put "Flutter's platform defaults
    /// back for [child]", and a page inside an app that opted in globally --
    /// what [IxApplicationScaffold] does for its whole frame by default -- is
    /// exactly where a consumer reaches for it.
    testWidgets('a nested enabled: false scope keeps the tap default', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        await pumpIx(
          tester,
          IxKeyboardDismissScope(
            child: IxKeyboardDismissScope(
              enabled: false,
              child: Column(
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
            ),
          ),
        );
        await focusField(tester);

        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'the inner scope opted its subtree out of the tap trigger',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    testWidgets('a nested enabled: false scope keeps the drag default', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        fieldNode = newFocusNode('field');
        controller = newController();
        await pumpIx(
          tester,
          IxKeyboardDismissScope(
            child: IxKeyboardDismissScope(
              enabled: false,
              child: ListView(
                controller: controller,
                children: [
                  TextField(key: const Key('field'), focusNode: fieldNode),
                  ...rows(),
                ],
              ),
            ),
          ),
        );
        await focusField(tester);

        await tester.drag(find.byKey(const Key('row1')), const Offset(0, -200));
        await tester.pump();

        expect(
          controller.offset,
          greaterThan(0),
          reason: 'the drag must still scroll the list',
        );
        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'the inner scope opted its subtree out of the drag trigger',
        );
        expect(tester.testTextInput.isVisible, isTrue);
      });
    });

    /// A field and an inert area beside it: the smallest thing the tap
    /// trigger can act on.
    Widget form() {
      fieldNode = newFocusNode('field');
      return Column(
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
    }

    /// A field at the top of a scrollable list, so one test can exercise
    /// both triggers.
    Widget listForm() {
      fieldNode = newFocusNode('field');
      controller = newController();
      return ListView(
        controller: controller,
        children: [
          TextField(key: const Key('field'), focusNode: fieldNode),
          ...rows(),
        ],
      );
    }

    testWidgets('a nested onTapOutside: false keeps its own drag trigger', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(
          tester,
          IxKeyboardDismissScope(
            child: IxKeyboardDismissScope(
              onTapOutside: false,
              child: listForm(),
            ),
          ),
        );
        await focusField(tester);

        await tester.tap(find.byKey(const Key('row1')));
        await tester.pump();
        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'the inner scope turned the tap trigger off',
        );
        expect(tester.testTextInput.isVisible, isTrue);

        await tester.drag(find.byKey(const Key('row1')), const Offset(0, -200));
        await tester.pump();
        expect(controller.offset, greaterThan(0));
        expect(
          fieldNode.hasFocus,
          isFalse,
          reason: 'the inner scope left the drag trigger on',
        );
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    testWidgets('a nested onDrag: false keeps its own tap trigger', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.android, () async {
        await pumpIx(
          tester,
          IxKeyboardDismissScope(
            child: IxKeyboardDismissScope(onDrag: false, child: listForm()),
          ),
        );
        await focusField(tester);

        await tester.drag(find.byKey(const Key('row1')), const Offset(0, -200));
        await tester.pump();
        expect(controller.offset, greaterThan(0));
        expect(
          fieldNode.hasPrimaryFocus,
          isTrue,
          reason: 'the inner scope turned the drag trigger off',
        );
        expect(tester.testTextInput.isVisible, isTrue);

        await tester.tap(find.byKey(const Key('row1')));
        await tester.pump();
        expect(
          fieldNode.hasFocus,
          isFalse,
          reason: 'the inner scope left the tap trigger on',
        );
        expect(tester.testTextInput.isVisible, isFalse);
      });
    });

    /// An opt-out has to mean *Flutter's* behaviour, and that is not "do
    /// nothing": on a desktop platform Flutter drops the focus on a tap
    /// outside whatever the pointer is. The first test pins that stock
    /// behaviour, the second requires the nested opt-out to match it down to
    /// the IME calls -- a leading `TextInput.hide` would mean an enclosing
    /// scope had answered in the inner scope's place.
    const stockTeardown = <String>['TextInput.clearClient', 'TextInput.hide'];

    testWidgets('without a scope macOS drops the focus on a tap outside', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.macOS, () async {
        await pumpIx(tester, form());
        await focusField(tester);

        tester.testTextInput.log.clear();
        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(fieldNode.hasFocus, isFalse);
        expect(
          tester.testTextInput.log.map((call) => call.method),
          stockTeardown,
        );
      });
    });

    testWidgets('a nested enabled: false matches that desktop default', (
      tester,
    ) async {
      await withPlatform(TargetPlatform.macOS, () async {
        await pumpIx(
          tester,
          IxKeyboardDismissScope(
            child: IxKeyboardDismissScope(enabled: false, child: form()),
          ),
        );
        await focusField(tester);

        tester.testTextInput.log.clear();
        await tester.tap(find.byKey(const Key('outside')));
        await tester.pump();

        expect(
          fieldNode.hasFocus,
          isFalse,
          reason: "Flutter's own action drops the focus on desktop",
        );
        expect(
          tester.testTextInput.log.map((call) => call.method),
          stockTeardown,
          reason: 'an enclosing scope answered instead of the field',
        );
      });
    });
  });
}
