import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// The [IxApplicationScaffold] navigation menu's category expansion, which
/// animates an arbitrary, consumer-supplied subtree ([IxMenuEntry.children],
/// including each child's [IxMenuEntry.iconWidget]) and therefore has to
/// survive both of the hazards a zero-duration `AnimatedSize` carries: an
/// open subtree that changes its own height, and a live flip of the
/// platform's reduce-motion setting.
///
/// The same contract `IxBlind` carries (see `test/blind/ix_blind_test.dart`);
/// it has no distinct upstream `.tsx`/`.scss` counterpart of its own -- the
/// web component's `<ix-menu-category>` animates in CSS -- so these tests
/// carry an English file-level doc-comment instead of an `@Upstream` tag.

/// Counts how many times a [_CountingIcon] state has been created, so a test
/// can tell a preserved child subtree from a remounted one. Reset via
/// `addTearDown` in every test that reads it.
int _iconInits = 0;

class _CountingIcon extends StatefulWidget {
  const _CountingIcon();

  @override
  State<_CountingIcon> createState() => _CountingIconState();
}

class _CountingIconState extends State<_CountingIcon> {
  late final String _stamp;

  @override
  void initState() {
    super.initState();
    _iconInits++;
    _stamp = 'icon $_iconInits';
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: 16, child: Text(_stamp, maxLines: 1));
}

Widget _scaffold({
  required List<IxMenuEntry> children,
  bool trailingEntry = false,
}) {
  return IxApplicationScaffold(
    appTitle: 'App',
    initiallyExpanded: true,
    entries: [
      IxMenuEntry(
        id: 'cat',
        type: IxMenuEntryType.category,
        label: 'Reports',
        children: children,
      ),
      if (trailingEntry)
        const IxMenuEntry(
          id: 'after',
          type: IxMenuEntryType.item,
          label: 'After',
        ),
    ],
    onNavigate: (_) {},
    body: const SizedBox(),
  );
}

IxMenuEntry _child(String id, {Widget? iconWidget}) => IxMenuEntry(
  id: id,
  type: IxMenuEntryType.item,
  label: id,
  iconWidget: iconWidget,
);

const Size _desktop = Size(1440, 900);

void main() {
  testWidgets('an expanded category lays out a change in its children under '
      'reduced motion', (tester) async {
    await pumpIx(
      tester,
      _scaffold(children: [_child('One')]),
      disableAnimations: true,
      size: _desktop,
    );
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    // The consumer rebuilds with more children while the category is open --
    // `entries` is public API, so this is an ordinary thing to do.
    await pumpIx(
      tester,
      _scaffold(children: [_child('One'), _child('Two'), _child('Three')]),
      disableAnimations: true,
      size: _desktop,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Three'), findsOneWidget);
  });

  testWidgets('turning reduced motion on keeps an open category\'s children '
      'mounted', (tester) async {
    addTearDown(() => _iconInits = 0);
    Future<void> pumpWith(bool disableAnimations) => pumpIx(
      tester,
      _scaffold(children: [_child('One', iconWidget: const _CountingIcon())]),
      disableAnimations: disableAnimations,
      size: _desktop,
    );

    await pumpWith(false);
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(_iconInits, 1);
    expect(find.text('icon 1'), findsOneWidget);

    await pumpWith(true);
    await tester.pumpAndSettle();
    expect(_iconInits, 1);
    expect(find.text('icon 1'), findsOneWidget);
  });

  testWidgets('a category snaps open in one frame under reduced motion', (
    tester,
  ) async {
    await pumpIx(
      tester,
      _scaffold(children: [_child('One')], trailingEntry: true),
      disableAnimations: true,
      size: _desktop,
    );
    final closed = tester.getRect(find.text('After')).top;

    await tester.tap(find.text('Reports'));
    await tester.pump();
    final opened = tester.getRect(find.text('After')).top;
    await tester.pumpAndSettle();

    // One pump is the whole transition: the entry below the category has
    // already moved all the way down.
    expect(opened, greaterThan(closed));
    expect(opened, tester.getRect(find.text('After')).top);
  });

  testWidgets('a category animates open under normal motion', (tester) async {
    await pumpIx(
      tester,
      _scaffold(children: [_child('One')], trailingEntry: true),
      disableAnimations: false,
      size: _desktop,
    );
    await tester.pumpAndSettle();
    final closed = tester.getRect(find.text('After')).top;

    await tester.tap(find.text('Reports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final midway = tester.getRect(find.text('After')).top;
    await tester.pumpAndSettle();
    final settled = tester.getRect(find.text('After')).top;

    expect(midway, greaterThan(closed));
    expect(midway, lessThan(settled));
  });

  testWidgets('a collapsing category is already inert while it is still on '
      'screen', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      _scaffold(children: [_child('One')], trailingEntry: true),
      disableAnimations: false,
      size: _desktop,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(_semanticsHasLabel(tester, 'One'), isTrue);
    expect(_traversalReaches('One'), isTrue);

    // Collapse and stop halfway. The children are still mounted -- they are
    // what the transition shrinks -- so they must already be inert:
    // announcing them, or letting Tab land on one, would point at something
    // that is about to be unmounted.
    await tester.tap(find.text('Reports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('One'), findsOneWidget, reason: 'still mounted');
    expect(_semanticsHasLabel(tester, 'One'), isFalse);
    expect(_traversalReaches('One'), isFalse);

    await tester.pumpAndSettle();
    handle.dispose();
  });
}

/// Whether the *compiled* semantics tree currently contains a node labelled
/// [label].
///
/// `find.bySemanticsLabel` reads each render object's cached
/// `debugSemantics`, which outlives the node's removal from the tree, so it
/// cannot answer "is this still announced?" -- the owner's tree can.
bool _semanticsHasLabel(WidgetTester tester, String label) {
  final root =
      tester.binding.renderViews.first.owner?.semanticsOwner?.rootSemanticsNode;
  if (root == null) {
    return false;
  }
  var found = false;
  void visit(SemanticsNode node) {
    if (node.label == label) {
      found = true;
      return;
    }
    node.visitChildren((child) {
      visit(child);
      return !found;
    });
  }

  visit(root);
  return found;
}

/// Whether keyboard traversal can currently reach the entry rendering
/// [label] -- i.e. whether `Tab` could land on it.
///
/// `FocusScopeNode.traversalDescendants` filters by `canRequestFocus`, which
/// walks the node's ancestors and honours every `descendantsAreFocusable`
/// (what `ExcludeFocus` sets) on the way, so this asks exactly the question
/// `Tab` does without depending on the surrounding scaffold's tab order.
bool _traversalReaches(String label) {
  final element = find.text(label).evaluate().single;
  // The entry's own focusable: `_NavigationTile` builds an `InkWell` with
  // the tile's focus node directly around this text.
  final node = Focus.maybeOf(element, createDependency: false);
  if (node == null) {
    return false;
  }
  return FocusManager.instance.rootScope.traversalDescendants.contains(node);
}
