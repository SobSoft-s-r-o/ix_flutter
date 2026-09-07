import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:example/app.dart';
import 'package:example/router/router.dart';

/// Every route of the demo app must render without throwing.
/// Page spinners animate indefinitely, so pump(duration) is used instead of
/// pumpAndSettle.
void main() {
  testWidgets('every route renders', (tester) async {
    await tester.pumpWidget(const IxDemoApp());
    await tester.pump(const Duration(milliseconds: 300));

    // `router` (the top-level GoRouter) must only be accessed here, not at
    // module level: GoRouter() internally calls
    // WidgetsFlutterBinding.ensureInitialized(), which trips the binding
    // assert if it runs before TestWidgetsFlutterBinding is initialized.
    final routes = router.configuration.routes
        .expand((r) => r is GoRoute ? [r] : (r as ShellRoute).routes)
        .whereType<GoRoute>()
        .map((r) => r.path)
        .toList();

    for (final path in routes) {
      router.go(path);
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull, reason: 'route $path threw');
    }
  });
}
