import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

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
