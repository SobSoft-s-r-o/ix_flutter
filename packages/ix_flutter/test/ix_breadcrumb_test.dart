import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'helpers/pump_ix.dart';
import 'helpers/upstream.dart';

/// Rendering, callback and accessibility regression tests for
/// [IxBreadcrumb].
///
/// The first two tests below predate this repository's `@Upstream`
/// citation convention (`test/helpers/upstream.dart`): they assert plain
/// rendering/callback mechanics native to this Flutter port
/// (`visibleItemCount` overflow, `onItemPressed`) with no single upstream
/// `.ct.ts`/`.tsx` counterpart of their own. The tests added for the
/// accessibility-interaction programme (Task A-8: navigation landmark,
/// one labelled node per crumb, current-page state, stable
/// `breadcrumbKey` click payloads) each carry their own `@Upstream` tag,
/// except the `breadcrumbKey`-fallback test at the bottom: falling back to
/// `label` (with a one-time debug notice) is a migration shim specific to
/// this Flutter port, with no upstream counterpart of its own either.
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

  // Metadata annotations can only precede a declaration, not a bare
  // statement, so each @Upstream-tagged test below is wrapped in a local
  // function invoked immediately after it (same pattern as
  // test/a11y/semantics_matrix_test.dart).
  @Upstream(
    'breadcrumb.tsx:161-165 role=navigation aria-label=Breadcrumbs; '
    'breadcrumb-item.tsx:129 aria-current=page',
  )
  void rootIsANavigationLandmarkEachCrumbIsOneLabelledNodeLastIsCurrent() {
    testWidgets(
      'root is a navigation landmark, each crumb is one labelled node, '
      'last is current',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(
          tester,
          const IxBreadcrumb(
            items: [
              IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'home'),
              IxBreadcrumbItemData(label: 'Plants', breadcrumbKey: 'plants'),
            ],
          ),
        );

        // `matchesSemantics` has no `role:` parameter in this Flutter
        // version, so the ARIA role mapping is asserted on the node
        // directly (same split used by test/a11y/keyboard_dropdown_test.dart).
        final root = tester.getSemantics(find.byType(IxBreadcrumb));
        expect(root.role, SemanticsRole.navigation);
        expect(root, matchesSemantics(label: 'Breadcrumbs'));

        expect(find.bySemanticsLabel('Home'), findsOneWidget);
        expect(
          tester.getSemantics(find.text('Plants')),
          matchesSemantics(
            label: 'Plants',
            hint: 'current page',
            isSelected: true,
            hasSelectedState: true,
          ),
        );
        handle.dispose();
      },
    );
  }

  rootIsANavigationLandmarkEachCrumbIsOneLabelledNodeLastIsCurrent();

  @Upstream('BREAKING_CHANGES/v5.md breadcrumbKey payload')
  void onItemClickReceivesStableKeysEvenForDuplicateLabels() {
    testWidgets('onItemClick receives stable keys even for duplicate labels', (
      tester,
    ) async {
      final clicks = <String>[];
      await pumpIx(
        tester,
        IxBreadcrumb(
          items: const [
            IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'r1'),
            IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'r2'),
            IxBreadcrumbItemData(label: 'Now', breadcrumbKey: 'now'),
          ],
          showHomeLabel: true,
          showNavigationMenu: false,
          onItemClick: (c) => clicks.add(c.breadcrumbKey),
        ),
      );
      await tester.tap(find.text('Reports').first);
      await tester.pumpAndSettle();
      expect(clicks, ['r1']);
    });
  }

  onItemClickReceivesStableKeysEvenForDuplicateLabels();

  testWidgets(
    'effectiveKey falls back to label without throwing when breadcrumbKey '
    'is omitted',
    (tester) async {
      final clicks = <String>[];
      await pumpIx(
        tester,
        IxBreadcrumb(
          items: const [
            IxBreadcrumbItemData(label: 'Home'),
            IxBreadcrumbItemData(label: 'Legacy'),
          ],
          showNavigationMenu: false,
          onItemClick: (c) => clicks.add(c.breadcrumbKey),
        ),
      );
      await tester.tap(find.text('Legacy'));
      await tester.pumpAndSettle();
      expect(clicks, ['Legacy']);
    },
  );
}
