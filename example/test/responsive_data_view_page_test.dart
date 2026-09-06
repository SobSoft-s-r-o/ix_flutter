import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/app.dart';
import 'package:example/router/router.dart';
import 'package:example/screen/home_page.dart';
import 'package:example/screen/responsive_data_view_example.dart';

/// The demo app's Responsive Data View page, driven the way a user drives it
/// on desktop.
void main() {
  /// Pumps the demo app on the data view route at a desktop viewport and
  /// waits out the page's 1.5s simulated network load.
  Future<void> pumpDataViewPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const IxDemoApp());
    await tester.pump(const Duration(milliseconds: 300));

    // `router` is a top-level singleton shared by every test in this
    // package, so put it back where it started.
    addTearDown(() => router.go(HomePage.routePath));
    router.go(ResponsiveDataViewExample.routePath);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
  }

  testWidgets('the pagination-mode menu opens on the current mode', (
    tester,
  ) async {
    await pumpDataViewPage(tester);

    // The trigger carries the current mode's label; opening adds a second
    // widget with the same text -- the menu row.
    expect(find.text('STANDARD'), findsOneWidget);
    await tester.tap(find.text('STANDARD'));
    await tester.pumpAndSettle();

    expect(find.text('STANDARD'), findsNWidgets(2));
    // `IxPaginationMode` is {none, standard, infinite}: the current mode is
    // the second row, not the first one the menu used to open on.
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'IxDropdownButton.item[1]',
    );

    // Exactly one row carries the checkmark the reserved column renders.
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
