import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// [IxEmptyState] has no upstream Playwright/`.scss` counterpart for
/// rendering without an [IxThemeBuilder] theme: the web component always
/// ships its own tokens. This guards a Flutter-specific precondition
/// (consumers who forget to wire `IxThemeBuilder` must still see the empty
/// state's title/subtitle/actions instead of a blank `SizedBox.shrink()`),
/// so it carries no `@Upstream` tag.
void main() {
  testWidgets(
    'renders title, subtitle, icon and actions without IxThemeBuilder',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IxEmptyState(
              icon: const Icon(Icons.inbox),
              title: 'No data',
              subtitle: 'Nothing here',
              primaryAction: FilledButton(
                onPressed: () {},
                child: const Text('Reload'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Reload'), findsOneWidget);
      expect(tester.getSize(find.byType(IxEmptyState)).height, greaterThan(0));
    },
  );
}
