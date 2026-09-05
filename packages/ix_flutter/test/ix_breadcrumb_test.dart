import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'helpers/pump_ix.dart';
import 'helpers/upstream.dart';

/// Rendering, callback and accessibility regression tests for
/// [IxBreadcrumb].
///
/// The tests added for the accessibility-interaction programme (Task A-8:
/// navigation landmark, one labelled node per crumb, current-page state,
/// stable `breadcrumbKey` click payloads) that mirror a specific upstream
/// ARIA/keyboard contract carry their own `@Upstream` tag. The remaining
/// tests -- the first two (predating this repository's `@Upstream`
/// citation convention, `test/helpers/upstream.dart`), the
/// `breadcrumbKey`-fallback test, and the `IxBreadcrumbTheme`/layout
/// regression tests at the bottom -- assert plain rendering/callback/theme
/// mechanics native to this Flutter port, with no single upstream
/// `.ct.ts`/`.tsx` counterpart of their own.
/// Captures `debugPrint` so the one-time `breadcrumbKey` notice never leaks
/// into the suite log, and returns the captured lines plus the callback that
/// puts `debugPrint` back.
///
/// Flutter asserts that no foundation debug variable is still overridden
/// *before* `addTearDown` callbacks run, so the test body has to call
/// `restore` itself; the tear-down is the guard for a body that throws
/// first, latched so it can never clobber a later override. Same pattern as
/// `test/scaffold/ix_menu_flyout_test.dart`.
({List<String> logs, VoidCallback restore}) _captureDebugPrint() {
  final logs = <String>[];
  final previous = debugPrint;
  var restored = false;
  void restore() {
    if (restored) {
      return;
    }
    restored = true;
    debugPrint = previous;
  }

  addTearDown(restore);
  debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
  return (logs: logs, restore: restore);
}

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
      final capture = _captureDebugPrint();
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
      capture.restore();
      expect(clicks, ['Legacy']);
      // The notice is emitted once per unique label, and other tests in this
      // suite may have already used these labels, so only assert that it
      // never reached the suite log.
      expect(
        capture.logs.where((l) => l.contains('breadcrumbKey')),
        isNotEmpty,
        reason: 'the deprecation notice should still be emitted',
      );
    },
  );

  testWidgets(
    'a custom IxBreadcrumbTheme.dropdownBackground still colours the open '
    'overflow menu',
    (tester) async {
      // dropdownBackground/dropdownBorderRadius are deprecated (removed in
      // 2.0, superseded by IxDropdownTheme for the rest of the popup's
      // styling) but must keep working until then -- an explicit override
      // must not silently stop applying.
      final baseTheme = const IxThemeBuilder().build();
      const customBackground = Color(0xFFAB1234);
      final customTheme = baseTheme.copyWith(
        extensions: [
          // ThemeData.copyWith(extensions:) *replaces* the whole
          // extensions map rather than merging into it, so every other
          // extension is carried over unchanged and only IxBreadcrumbTheme
          // is swapped out.
          for (final extension in baseTheme.extensions.values)
            if (extension is IxBreadcrumbTheme)
              // ignore: deprecated_member_use_from_same_package
              extension.copyWith(dropdownBackground: customBackground)
            else
              extension,
        ],
      );

      await pumpIx(
        tester,
        const IxBreadcrumb(
          showHomeLabel: true,
          items: [
            IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'home'),
            IxBreadcrumbItemData(label: 'Plants', breadcrumbKey: 'plants'),
          ],
        ),
        theme: customTheme,
      );

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Material && widget.color == customBackground,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'a non-interactive current-page crumb shrink-wraps like an interactive '
    'one, instead of stretching to maxItemWidth',
    (tester) async {
      final maxItemWidth = const IxThemeBuilder()
          .build()
          .extension<IxBreadcrumbTheme>()!
          .maxItemWidth;

      // No press callback anywhere: the last crumb ('Hi') takes the
      // non-interactive "current page" branch. Regression test for the
      // bug fixed alongside this task: that branch used to wrap its
      // content in `Align`, which -- sitting inside the row's
      // unbounded-width horizontal scroll view -- expanded to the full
      // `maxItemWidth` ceiling instead of shrink-wrapping to "Hi".
      await pumpIx(
        tester,
        const IxBreadcrumb(
          items: [
            IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'home'),
            IxBreadcrumbItemData(label: 'Hi', breadcrumbKey: 'hi'),
          ],
        ),
      );
      final nonInteractiveWidth = tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Hi'),
                  matching: find.byType(ConstrainedBox),
                )
                .first,
          )
          .width;

      // onItemClick set: 'Hi' stays a normal, interactive TextButton
      // (1.x-preserving behaviour), which already shrink-wraps -- the
      // previous, known-good behaviour this compares against.
      await pumpIx(
        tester,
        IxBreadcrumb(
          items: const [
            IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'home'),
            IxBreadcrumbItemData(label: 'Hi', breadcrumbKey: 'hi'),
          ],
          onItemClick: (_) {},
        ),
      );
      final interactiveWidth = tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Hi'),
                  matching: find.byType(ConstrainedBox),
                )
                .first,
          )
          .width;

      expect(nonInteractiveWidth, lessThan(maxItemWidth / 2));
      expect(nonInteractiveWidth, closeTo(interactiveWidth, 0.5));
    },
  );
}
