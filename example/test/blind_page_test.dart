import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'package:example/app.dart';
import 'package:example/router/router.dart';
import 'package:example/screen/blind_page.dart';
import 'package:example/screen/home_page.dart';

/// Manual testing on Android (dark theme) reported that an expanded
/// `IxBlind` (outline variant) draws its content's top-border divider only
/// as wide as the content text ("Content for outline variant."), instead of
/// spanning the whole blind the way the header does -- upstream iX and
/// ix_flutter 1.0.2 both draw it full width. The root cause (and the
/// isolated regression test) live in the library's `IxCollapsible`, see
/// `packages/ix_flutter/test/blind/ix_blind_test.dart`; this reproduces the
/// same bug through the actual example page a user would see it on.
void main() {
  testWidgets(
    "the outline variant's content divider spans the blind's full width",
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const IxDemoApp());
      await tester.pump(const Duration(milliseconds: 300));

      // `router` is a top-level singleton shared by every test in this
      // package, so put it back where it started.
      addTearDown(() => router.go(HomePage.routePath));
      router.go(BlindPage.routePath);
      await tester.pump(const Duration(milliseconds: 600));

      final header = find.text('outline Variant');
      await tester.ensureVisible(header);
      await tester.tap(header);
      await tester.pumpAndSettle();

      final blind = find.ancestor(
        of: find.text('Content for outline variant.'),
        matching: find.byType(IxBlind),
      );
      expect(blind, findsOneWidget);
      final blindWidth = tester.getRect(blind).width;

      // The divider is the `Container` whose `BoxDecoration.border` sets
      // only the top side -- unlike the blind's own outer `Container`,
      // which uses `Border.all` on every side.
      final divider = find.descendant(
        of: blind,
        matching: find.byWidgetPredicate((widget) {
          if (widget is! Container) {
            return false;
          }
          final decoration = widget.decoration;
          if (decoration is! BoxDecoration) {
            return false;
          }
          final border = decoration.border;
          return border is Border &&
              border.top != BorderSide.none &&
              border.bottom == BorderSide.none;
        }),
      );
      expect(divider, findsOneWidget);

      // Full width up to the blind's own ~1px border inset on each side --
      // not shrunk to the short content text's intrinsic width.
      expect(tester.getRect(divider).width, greaterThan(blindWidth - 4));
    },
  );
}
