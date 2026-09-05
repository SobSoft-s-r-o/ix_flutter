import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'helpers/pump_ix.dart';
import 'helpers/upstream.dart';

/// Traceability: the status-role/reduced-motion test below cites the
/// upstream `spinner.tsx` `role="status" aria-label="Loading"` markup via
/// `@Upstream`. The second test, guarding the theme-less fallback (no
/// `IxThemeBuilder` on the ambient `Theme`), has no upstream Playwright/
/// `.scss` counterpart -- the web component always ships its own tokens --
/// so it carries no `@Upstream` tag; it guards a Flutter-specific
/// precondition (consumers who forget to wire `IxThemeBuilder` must still
/// see a correctly sized custom-painted spinner, not a crash or a
/// Material `CircularProgressIndicator` substitute).
void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // invoked immediately below it (see test/a11y/semantics_matrix_test.dart
  // for the same pattern).
  @Upstream('spinner.tsx:38-44 role=status aria-label=Loading')
  void spinnerExposesStatusRoleAndRespectsReducedMotion() {
    testWidgets(
      'spinner exposes a status role with label and respects reduced motion',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(tester, const IxSpinner(), disableAnimations: true);

        // `matchesSemantics()` in this Flutter version has no `role:`
        // parameter (verified by reading flutter_test's matchers.dart), so
        // the role is asserted directly off the SemanticsData it returns
        // and the label is verified separately via the matcher.
        final semantics = tester.getSemantics(find.byType(IxSpinner));
        expect(semantics.role, SemanticsRole.status);
        expect(semantics, matchesSemantics(label: 'Loading'));

        expect(
          tester.binding.transientCallbackCount,
          0,
          reason: 'no repeating animation under reduced motion',
        );
        await tester.pumpAndSettle();
        handle.dispose();
      },
    );
  }

  spinnerExposesStatusRoleAndRespectsReducedMotion();

  testWidgets(
    'spinner without IxThemeBuilder keeps its size and custom painter',
    (tester) async {
      // Wrapped in Center: a bare MaterialApp.home stretches its child to the
      // full view size in this Flutter version (verified empirically -- a
      // plain SizedBox(width: 10, height: 10) placed directly as `home:`
      // measures 800x600, not 10x10), which would make the size assertion
      // below meaningless regardless of IxSpinner's own implementation.
      // IxThemeBuilder is still intentionally absent from this MaterialApp.
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: IxSpinner(size: IxSpinnerSize.large)),
        ),
      );
      expect(tester.getSize(find.byType(IxSpinner)), const Size(96, 96));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
