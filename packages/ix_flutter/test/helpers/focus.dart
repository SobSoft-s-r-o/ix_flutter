import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared focus-assertion helpers (B11), replacing the near-identical copies
/// `test/a11y/keyboard_menu_test.dart`, `test/scaffold/
/// ix_application_scaffold_navigation_test.dart` and `test/
/// ix_responsive_data_view_test.dart` each maintained on their own.

/// The [BuildContext] of the widget that currently owns the primary focus.
///
/// Fails the test with [reason] instead of returning `null` when nothing
/// does, so every helper built on top of this can assume a non-null result.
BuildContext focusedContext(
  WidgetTester tester, {
  String reason = 'nothing focused',
}) {
  final ctx = FocusManager.instance.primaryFocus?.context;
  expect(ctx, isNotNull, reason: reason);
  return ctx!;
}

/// Asserts that the widget owning the primary focus renders [label].
void expectFocusOn(WidgetTester tester, String label) {
  final ctx = focusedContext(tester);
  expect(
    find.descendant(of: find.byWidget(ctx.widget), matching: find.text(label)),
    findsOneWidget,
    reason: 'expected focus on "$label"',
  );
}

/// Asserts that the currently focused widget lives inside the widget
/// identified by [key] -- used to walk the Tab order without depending on
/// exactly which internal widget (e.g. the `InkWell`) ends up owning the
/// platform focus node.
void expectFocusWithin(WidgetTester tester, Key key) {
  final ctx = focusedContext(tester);
  expect(
    find.ancestor(of: find.byWidget(ctx.widget), matching: find.byKey(key)),
    findsOneWidget,
    reason: 'focus is not inside $key',
  );
}

/// Asserts that [inner] lies within [outer] on every edge, with a 0.5
/// logical-pixel tolerance for floating-point layout rounding.
///
/// Pass both rects from `tester.getRect(...)`; [reason] names what is being
/// checked (e.g. "focused tile $tile is outside the menu viewport $viewport")
/// for a clearer failure message than the default per-edge one.
void expectRectWithin(Rect inner, Rect outer, {String? reason}) {
  expect(
    inner.top,
    greaterThanOrEqualTo(outer.top - 0.5),
    reason: reason ?? '$inner is above $outer',
  );
  expect(
    inner.bottom,
    lessThanOrEqualTo(outer.bottom + 0.5),
    reason: reason ?? '$inner is below $outer',
  );
  expect(
    inner.left,
    greaterThanOrEqualTo(outer.left - 0.5),
    reason: reason ?? '$inner is left of $outer',
  );
  expect(
    inner.right,
    lessThanOrEqualTo(outer.right + 0.5),
    reason: reason ?? '$inner is right of $outer',
  );
}
