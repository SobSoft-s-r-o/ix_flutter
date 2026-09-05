import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Header semantics (button + expanded state, header actions kept outside
/// the header's own semantics node) and the uncontrolled/controlled dual
/// contract of [IxBlind].
///
/// Only the first test below mirrors a specific upstream source line and
/// carries its own `@Upstream`; the remaining tests exercise this library's
/// own uncontrolled/controlled state contract and disabled handling, which
/// has no distinct upstream `.tsx`/`.scss` counterpart of its own -- so this
/// file carries an English file-level doc-comment instead (see
/// `test/theme/theme_wiring_test.dart` for the same pattern).
///
/// Metadata annotations can only precede a declaration, not a bare
/// statement, so the `@Upstream`-tagged test is wrapped in a local function
/// that is invoked immediately below it (see
/// `test/a11y/semantics_matrix_test.dart` for the same pattern).
void main() {
  @Upstream(
    'blind.tsx:145-156 <button aria-labelledby aria-controls aria-expanded>',
  )
  void headerIsButtonWithExpandedStateAndActionsStaySeparate() {
    testWidgets(
      'header is a button with expanded state and header actions stay '
      'separate',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(
          tester,
          IxBlind(
            title: 'Section',
            subtitle: 'Sub',
            expanded: true,
            onExpandedChanged: (_) {},
            headerActions: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () {},
            ),
            child: const Text('body'),
          ),
        );
        expect(
          tester.getSemantics(find.text('Section')),
          matchesSemantics(
            isButton: true,
            hasExpandedState: true,
            isExpanded: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            label: 'Section',
            hint: 'Sub',
          ),
        );
        final edit = tester.getSemantics(find.byTooltip('Edit'));
        expect(edit.label, isNot(contains('Section')));
        handle.dispose();
      },
    );
  }

  headerIsButtonWithExpandedStateAndActionsStaySeparate();

  testWidgets(
    "header actions keep the header content's 16px right-edge margin",
    (tester) async {
      await pumpIx(
        tester,
        IxBlind(
          title: 'T',
          expanded: false,
          onExpandedChanged: (_) {},
          headerActions: IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {},
          ),
          child: const Text('body'),
        ),
        size: const Size(400, 600),
      );
      final theme = Theme.of(tester.element(find.byType(IxBlind)));
      final borderWidth =
          (theme.extension<IxBlindTheme>() ?? IxBlindTheme.fallback(theme))
              .borderWidth;
      final blindRight = tester.getRect(find.byType(IxBlind)).right;
      // `find.byType(IconButton)`, not `find.byTooltip(...)`: `Tooltip`
      // reports a hit-test box inset a further 4px from its child's own
      // bounds, which is not the edge that matters for a visible margin --
      // `IconButton`'s own rect is the space actually allocated to
      // `headerActions` by the header's `Row`.
      final actionsRight = tester.getRect(find.byType(IconButton)).right;
      // The blind's own card border insets its content by `borderWidth`
      // (Container applies a decoration border as implicit padding), and
      // the header's own padded Container insets by `space3` (16px) on
      // top of that -- the same margin plain header content (chevron,
      // title) gets. `headerActions` must keep that margin now that it
      // lives outside the header's `Semantics` node (see the previous
      // test), instead of losing it to the bare 8px inter-item gap.
      expect(
        actionsRight,
        moreOrLessEquals(
          blindRight - borderWidth - IxCommonGeometry.space3,
          epsilon: 0.5,
        ),
      );
    },
  );

  testWidgets('tapping inside the header padding (not on the title) toggles an '
      'uncontrolled blind', (tester) async {
    await pumpIx(tester, const IxBlind(title: 'T', child: Text('body')));
    expect(find.text('body'), findsNothing);
    // 4px from the InkWell's own left edge, vertically centred: inside
    // the header's horizontal `space3` (16px) padding and well clear of
    // the chevron/title, but still on the interactive element itself.
    // Regression guard: when the padded `Container` sat *outside* the
    // `InkWell` instead of wrapping its content, the `InkWell` shrank to
    // the chevron/title's intrinsic size and this tap landed on inert
    // padding instead.
    final headerRect = tester.getRect(find.byType(InkWell));
    await tester.tapAt(Offset(headerRect.left + 4, headerRect.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets(
    "the header's InkWell is at least 48px tall for a title-only blind",
    (tester) async {
      await pumpIx(
        tester,
        IxBlind(
          title: 'T',
          expanded: false,
          onExpandedChanged: (_) {},
          child: const Text('body'),
        ),
      );
      // The 48px touch-target minimum (WCAG 2.5.5) must reach the
      // interactive `InkWell` itself, not just the header's overall visual
      // band -- a `Row` only ever passes its children a loose max-height,
      // never its own enforced `minHeight`, so an ancestor `Container`'s
      // `minHeight: 48` alone does not guarantee this.
      final inkWellHeight = tester.getRect(find.byType(InkWell)).height;
      expect(inkWellHeight, greaterThanOrEqualTo(48.0));
    },
  );

  testWidgets('uncontrolled blind toggles on tap without a callback', (
    tester,
  ) async {
    await pumpIx(tester, const IxBlind(title: 'T', child: Text('body')));
    expect(find.text('body'), findsNothing);
    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('controlled blind does not toggle without setState', (
    tester,
  ) async {
    var calls = 0;
    await pumpIx(
      tester,
      IxBlind(
        title: 'T',
        expanded: false,
        onExpandedChanged: (_) => calls++,
        child: const Text('body'),
      ),
    );
    await tester.tap(find.text('T'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('body'), findsNothing);
  });

  testWidgets('disabled blind exposes enabled=false and ignores taps', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var calls = 0;
    await pumpIx(
      tester,
      IxBlind(
        title: 'T',
        disabled: true,
        expanded: false,
        onExpandedChanged: (_) => calls++,
        child: const Text('b'),
      ),
    );
    expect(
      tester.getSemantics(find.text('T')),
      matchesSemantics(
        hasEnabledState: true,
        isEnabled: false,
        isButton: true,
        hasExpandedState: true,
        label: 'T',
      ),
    );
    await tester.tap(find.text('T'));
    await tester.pump();
    expect(calls, 0);
    handle.dispose();
  });

  testWidgets('the focused header reports isFocused, an unfocused sibling '
      'does not', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      const Column(
        children: [
          IxBlind(title: 'First', child: Text('a')),
          IxBlind(title: 'Second', child: Text('b')),
        ],
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // The header's `Semantics` sets `excludeSemantics: true`, which drops
    // the inner `InkWell`/`Focus` contribution -- including the focused
    // flag a screen reader needs to follow the keyboard (WCAG 2.4.7). The
    // header therefore has to republish the state its focus ring already
    // tracks (same fix as `_NavigationTile` and the data view's sortable
    // headers).
    expect(
      tester.getSemantics(find.text('First')),
      matchesSemantics(
        isButton: true,
        hasExpandedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        label: 'First',
      ),
    );
    expect(
      tester.getSemantics(find.text('Second')),
      matchesSemantics(
        isButton: true,
        hasExpandedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        label: 'Second',
      ),
    );
    handle.dispose();
  });

  group('expansion transition', () {
    testWidgets('an open blind lays out a content height change under '
        'reduced motion', (tester) async {
      Future<void> pumpWithHeight(double height) => pumpIx(
        tester,
        IxBlind(
          title: 'T',
          expanded: true,
          onExpandedChanged: (_) {},
          child: SizedBox(key: _contentKey, height: height),
        ),
        disableAnimations: true,
      );

      await pumpWithHeight(50);
      expect(tester.getSize(find.byKey(_contentKey)).height, 50);

      // The open content grows on its own (a lazily loaded list, a text
      // that wrapped, ...). Reduced motion must not make that a layout
      // error, and the new height must actually be laid out.
      await pumpWithHeight(100);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(_contentKey)).height, 100);
    });

    testWidgets('turning reduced motion on keeps the open content mounted', (
      tester,
    ) async {
      addTearDown(() => _contentInits = 0);
      Future<void> pumpWith(bool disableAnimations) => pumpIx(
        tester,
        IxBlind(
          title: 'T',
          expanded: true,
          onExpandedChanged: (_) {},
          child: const _StatefulContent(),
        ),
        disableAnimations: disableAnimations,
      );

      await pumpWith(false);
      await tester.pumpAndSettle();
      expect(_contentInits, 1);
      expect(find.text('instance 1'), findsOneWidget);

      // The platform's reduce-motion setting flips while the blind is open.
      // The transition's duration changes; the content subtree must not be
      // torn down and rebuilt around it.
      await pumpWith(true);
      await tester.pumpAndSettle();
      expect(_contentInits, 1);
      expect(find.text('instance 1'), findsOneWidget);
    });

    testWidgets('expanding animates and completes at IxMotion.defaultTime', (
      tester,
    ) async {
      await pumpIx(
        tester,
        const IxBlind(
          title: 'T',
          child: SizedBox(key: _contentKey, height: 100),
        ),
        disableAnimations: false,
      );
      final collapsed = tester.getSize(find.byType(IxBlind)).height;

      await tester.tap(find.text('T'));
      await tester.pump();
      await tester.pump(IxMotion.defaultTime ~/ 2);
      final midway = tester.getSize(find.byType(IxBlind)).height;
      await tester.pump(IxMotion.defaultTime ~/ 2);
      final atFullDuration = tester.getSize(find.byType(IxBlind)).height;
      await tester.pumpAndSettle();
      final settled = tester.getSize(find.byType(IxBlind)).height;

      expect(midway, greaterThan(collapsed));
      expect(midway, lessThan(settled));
      expect(atFullDuration, settled);
    });

    testWidgets('a controlled blind animates when expanded flips', (
      tester,
    ) async {
      late StateSetter setOuter;
      var expanded = false;
      await pumpIx(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return IxBlind(
              title: 'T',
              expanded: expanded,
              onExpandedChanged: (_) {},
              child: const SizedBox(key: _contentKey, height: 100),
            );
          },
        ),
        disableAnimations: false,
      );
      final collapsed = tester.getSize(find.byType(IxBlind)).height;

      setOuter(() => expanded = true);
      await tester.pump();
      await tester.pump(IxMotion.defaultTime ~/ 2);
      final midway = tester.getSize(find.byType(IxBlind)).height;
      await tester.pumpAndSettle();
      final settled = tester.getSize(find.byType(IxBlind)).height;

      expect(midway, greaterThan(collapsed));
      expect(midway, lessThan(settled));
    });

    testWidgets('a controlled blind snaps when expanded flips under reduced '
        'motion', (tester) async {
      late StateSetter setOuter;
      var expanded = false;
      Widget build(BuildContext context, StateSetter setState) {
        setOuter = setState;
        return IxBlind(
          title: 'T',
          expanded: expanded,
          onExpandedChanged: (_) {},
          child: const SizedBox(key: _contentKey, height: 100),
        );
      }

      await pumpIx(
        tester,
        StatefulBuilder(builder: build),
        disableAnimations: true,
      );
      final collapsed = tester.getSize(find.byType(IxBlind)).height;

      setOuter(() => expanded = true);
      await tester.pump();
      // One frame is the whole transition: no intermediate height.
      expect(tester.getSize(find.byKey(_contentKey)).height, 100);
      expect(
        tester.getSize(find.byType(IxBlind)).height,
        greaterThanOrEqualTo(collapsed + 100),
      );
    });

    testWidgets('collapsing removes the content once the transition ends', (
      tester,
    ) async {
      await pumpIx(
        tester,
        const IxBlind(title: 'T', initiallyExpanded: true, child: Text('body')),
      );
      expect(find.text('body'), findsOneWidget);

      await tester.tap(find.text('T'));
      await tester.pumpAndSettle();
      expect(find.text('body'), findsNothing);
    });

    testWidgets('collapsing content is skipped by Tab while it is still on '
        'screen', (tester) async {
      final before = FocusNode(debugLabel: 'before');
      final inside = FocusNode(debugLabel: 'inside');
      final after = FocusNode(debugLabel: 'after');
      addTearDown(before.dispose);
      addTearDown(inside.dispose);
      addTearDown(after.dispose);

      await pumpIx(
        tester,
        Column(
          children: [
            TextField(focusNode: before),
            IxBlind(
              title: 'T',
              initiallyExpanded: true,
              child: TextField(focusNode: inside),
            ),
            TextField(focusNode: after),
          ],
        ),
        disableAnimations: false,
      );
      await tester.pumpAndSettle();

      before.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focusedDebugLabel(), 'IxBlind.header');

      // Collapse and stop halfway: the content is still mounted (it is what
      // the transition is shrinking) but it is no longer reachable content,
      // so traversal must skip it -- otherwise Tab lands on a field that is
      // about to be unmounted and the focus is dropped.
      await tester.tap(find.text('T'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(inside.hasFocus, isFalse);
      expect(after.hasFocus, isTrue);

      await tester.pumpAndSettle();
      expect(after.hasFocus, isTrue);
    });

    testWidgets('collapsing a blind whose content holds the focus moves it to '
        'the header', (tester) async {
      final inside = FocusNode(debugLabel: 'inside');
      addTearDown(inside.dispose);

      await pumpIx(
        tester,
        Column(
          children: [
            IxBlind(
              title: 'T',
              initiallyExpanded: true,
              child: TextField(focusNode: inside),
            ),
          ],
        ),
        disableAnimations: false,
      );
      await tester.pumpAndSettle();

      inside.requestFocus();
      await tester.pump();
      expect(inside.hasFocus, isTrue);

      await tester.tap(find.text('T'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(inside.hasFocus, isFalse);
      await tester.pumpAndSettle();

      // The focus lands on the header rather than nowhere, so the next Tab
      // continues from the blind instead of restarting at the top of the
      // page.
      expect(_focusedDebugLabel(), 'IxBlind.header');
    });
  });
}

/// The `debugLabel` of the [FocusNode] that currently holds the primary
/// focus, or `null` when nothing (or only the root scope) does.
String? _focusedDebugLabel() {
  final node = FocusManager.instance.primaryFocus;
  return node?.debugLabel;
}

/// Counts how many times a [_StatefulContent] state has been created, so a
/// test can tell a preserved content subtree from a remounted one. Reset via
/// `addTearDown` in every test that reads it.
int _contentInits = 0;

const Key _contentKey = Key('blind-content');

/// Blind content that records its own mount and renders a stamp unique to
/// its [State] instance, so both the mount count and the surviving state are
/// observable from the widget tree.
class _StatefulContent extends StatefulWidget {
  const _StatefulContent();

  @override
  State<_StatefulContent> createState() => _StatefulContentState();
}

class _StatefulContentState extends State<_StatefulContent> {
  late final String _stamp;

  @override
  void initState() {
    super.initState();
    _contentInits++;
    _stamp = 'instance $_contentInits';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(key: _contentKey, height: 50, child: Text(_stamp));
  }
}
