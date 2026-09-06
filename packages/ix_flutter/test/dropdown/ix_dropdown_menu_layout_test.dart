import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// Where the dropdown menu lands: reading direction and safe area.
///
/// The layout delegate works in the target `Overlay`'s coordinate space, and
/// the overlay is not the screen -- the status bar, a notch and the home
/// indicator all sit inside it. It is also not left-to-right by definition:
/// `bottomStart` means the *reading* start.

const Key _menuKey = Key('ix-dropdown-menu');

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(400, 800),
  EdgeInsets padding = EdgeInsets.zero,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: padding,
        disableAnimations: true,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: const IxThemeBuilder(mode: ThemeMode.light).build(),
        builder: (context, app) => Directionality(
          textDirection: textDirection,
          child: app ?? const SizedBox.shrink(),
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
}

IxDropdownButton<int> _dropdown({
  IxDropdownPlacement placement = IxDropdownPlacement.bottomStart,
}) => IxDropdownButton<int>(
  label: 'Actions',
  placement: placement,
  items: const [
    IxDropdownMenuItem(value: 1, label: 'One'),
    IxDropdownMenuItem(value: 2, label: 'Two'),
  ],
);

void main() {
  testWidgets('bottomStart aligns to the reading start in RTL', (tester) async {
    await _pump(
      tester,
      textDirection: TextDirection.rtl,
      child: Align(alignment: Alignment.topCenter, child: _dropdown()),
    );
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    final trigger = tester.getRect(find.byType(ElevatedButton));
    final menu = tester.getRect(find.byKey(_menuKey));
    expect(menu.right, moreOrLessEquals(trigger.right, epsilon: 0.5));
    expect(menu.left, isNot(moreOrLessEquals(trigger.left, epsilon: 0.5)));
  });

  testWidgets('bottomStart still aligns to the left edge in LTR', (
    tester,
  ) async {
    await _pump(
      tester,
      child: Align(alignment: Alignment.topCenter, child: _dropdown()),
    );
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();

    final trigger = tester.getRect(find.byType(ElevatedButton));
    final menu = tester.getRect(find.byKey(_menuKey));
    expect(menu.left, moreOrLessEquals(trigger.left, epsilon: 0.5));
  });

  // A trigger low enough that the menu still fits between it and the bottom
  // edge of an 800px viewport, but not between it and a 34px home indicator.
  Widget nearTheBottom() => Column(
    children: [const Spacer(), _dropdown(), const SizedBox(height: 120)],
  );

  testWidgets('precondition: the menu opens downwards with no safe area', (
    tester,
  ) async {
    await _pump(tester, child: nearTheBottom());
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(_menuKey)).top,
      greaterThan(tester.getRect(find.byType(ElevatedButton)).bottom),
    );
  });

  testWidgets('the home indicator is not counted as room below the trigger', (
    tester,
  ) async {
    await _pump(
      tester,
      padding: const EdgeInsets.only(top: 47, bottom: 34),
      child: nearTheBottom(),
    );
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    final trigger = tester.getRect(find.byType(ElevatedButton));
    final menu = tester.getRect(find.byKey(_menuKey));
    expect(menu.bottom, lessThanOrEqualTo(trigger.top));
    expect(menu.bottom, lessThanOrEqualTo(800 - 34));
  });
}
