import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

void main() {
  testWidgets('breadcrumbs render and trigger callbacks', (tester) async {
    final pressed = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: const IxThemeBuilder().build(),
        home: Scaffold(
          body: IxBreadcrumb(
            items: const [
              IxBreadcrumbItemData(label: 'Home'),
              IxBreadcrumbItemData(label: 'Reports'),
            ],
            showHomeLabel: true,
            showNavigationMenu: false,
            onItemPressed: (item) => pressed.add(item.label),
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    expect(pressed, contains('Home'));
    expect(pressed, contains('Reports'));
  });

  testWidgets('home menu surfaces overflowed items', (tester) async {
    final pressed = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: const IxThemeBuilder().build(),
        home: Scaffold(
          body: IxBreadcrumb(
            visibleItemCount: 2,
            showHomeLabel: true,
            items: const [
              IxBreadcrumbItemData(label: 'Home'),
              IxBreadcrumbItemData(label: 'Plant'),
              IxBreadcrumbItemData(label: 'Line'),
            ],
            onItemPressed: (item) => pressed.add(item.label),
          ),
        ),
      ),
    );

    expect(find.text('Plant'), findsNothing);
    expect(find.text('Line'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Plant'), findsOneWidget);

    await tester.tap(find.text('Plant'));
    await tester.pumpAndSettle();

    expect(pressed, contains('Plant'));
  });
}
