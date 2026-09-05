import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:example/app.dart';
import 'package:example/router/router.dart';

/// Každá routa demo aplikácie sa musí vykresliť bez výnimky.
/// Spinner stránky animujú donekonečna, preto sa používa pump(duration).
void main() {
  testWidgets('every route renders', (tester) async {
    await tester.pumpWidget(const IxDemoApp());
    await tester.pump(const Duration(milliseconds: 300));

    // `router` (top-level GoRouter) musí byť najprv pristúpený až tu, nie na
    // module-level: GoRouter() interne volá WidgetsFlutterBinding.ensureInitialized(),
    // čo pred inicializáciou TestWidgetsFlutterBinding zhodí binding assert.
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
