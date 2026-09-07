import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Traceability: upstream `breadcrumb.ct.ts` covers keyboard navigation and
/// overflow, not RTL mirroring, so there is no direct upstream `.ct.ts` /
/// scss/tsx test to cite here (no `@Upstream`). IXF-048 was reserved for an
/// RTL breadcrumb-order regression; this test currently passes — the only
/// gap found while writing this matrix (Task 2/C-2) was a test-authoring
/// omission (`showHomeLabel` defaults to `false`, hiding the "Home" text in
/// any direction), fixed below by passing `showHomeLabel: true` — so no
/// skip or follow-up un-skip task is pending for this file.
void main() {
  testWidgets('IxBreadcrumb renders in RTL without exceptions', (tester) async {
    await pumpIx(
      tester,
      const IxBreadcrumb(
        items: [
          IxBreadcrumbItemData(label: 'Home'),
          IxBreadcrumbItemData(label: 'Plants'),
        ],
        showHomeLabel: true,
      ),
      textDirection: TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
    final home = tester.getTopLeft(find.text('Home'));
    final plants = tester.getTopLeft(find.text('Plants'));
    expect(home.dx, greaterThan(plants.dx), reason: 'RTL mirrors order');
  });
}
