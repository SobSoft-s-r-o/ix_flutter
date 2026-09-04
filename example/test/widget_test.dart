// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:example/app.dart';

void main() {
  testWidgets('renders iX design system overview', (WidgetTester tester) async {
    await tester.pumpWidget(const IxDemoApp());
    // IxSpinner drží scheduler (repeat()), preto nie pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('IX Flutter Theme Overview'), findsOneWidget);
  });
}
