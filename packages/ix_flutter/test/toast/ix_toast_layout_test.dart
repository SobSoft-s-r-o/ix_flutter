import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Traceability: the parametrized viewport-width suite below cites upstream
/// `toast.scss`/`toast-container.scss` sizing rules via `@Upstream`. The
/// final test, guarding [IxToastOverlay]'s `didUpdateWidget` service-swap
/// handling, has no upstream Playwright/`.tsx` counterpart -- the web
/// component has no equivalent of rebinding a Flutter widget to a
/// *different* [IxToastService] instance, that concept only exists because
/// [IxToastOverlay] is a long-lived Flutter widget wrapping a
/// separately-owned service object -- so it carries no `@Upstream` tag; it
/// guards a Flutter-specific precondition instead.
void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so the @Upstream-tagged suite below is wrapped in a local
  // function invoked immediately after it (see
  // test/a11y/semantics_matrix_test.dart for the same pattern).
  @Upstream('toast.scss:20-22 width 17.5rem; toast-container.scss:25-33')
  void toastFitsEveryViewportWithSafeMargins() {
    for (final w in [320.0, 360.0, 600.0, 1440.0]) {
      testWidgets(
        'toast fits the viewport at ${w.toInt()}px with 16px margin',
        (tester) async {
          final service = IxToastService();
          await pumpIx(
            tester,
            Stack(children: [IxToastOverlay(service: service)]),
            size: Size(w, 800),
          );
          service.showToast(
            title: 'Warning',
            message: 'Temperature threshold exceeded on machine 42.',
            actionLabel: 'Undo',
            onAction: () {},
          );
          await tester.pump(const Duration(milliseconds: 400));
          final r = tester.getRect(find.byType(IxToast));
          expect(r.left, greaterThanOrEqualTo(16));
          expect(r.right, lessThanOrEqualTo(w - 16));
          expect(r.width, w >= 312 ? 280 : w - 32);
          expect(r.height, lessThanOrEqualTo(140));
          // See ix_toast_semantics_test.dart for why this is needed: the
          // default 5s auto-close timer is still pending here (verified
          // empirically -- flutter_test fails the test with "A Timer is
          // still pending" otherwise).
          service.dismissAll();
        },
      );
    }
  }

  toastFitsEveryViewportWithSafeMargins();

  testWidgets('overlay re-subscribes when service changes', (tester) async {
    final serviceA = IxToastService();
    final serviceB = IxToastService();
    await pumpIx(tester, Stack(children: [IxToastOverlay(service: serviceA)]));

    // Same widget shape, different service instance: IxToastOverlay's
    // State is reused, so didUpdateWidget must unsubscribe serviceA and
    // subscribe serviceB for this to work.
    await pumpIx(tester, Stack(children: [IxToastOverlay(service: serviceB)]));

    serviceB.showToast(message: 'From B', autoClose: false);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('From B'), findsOneWidget);

    serviceA.dismissAll();
    serviceB.dismissAll();
  });
}
