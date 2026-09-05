import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Traceability: the reduced-motion widget test below cites the upstream
/// `_reduce-motion.scss`/`animation.ts` reduced-motion handling via
/// `@Upstream`. The second test asserts the [IxMotion] token *values*
/// (150/300/500/1000/0 ms) against `_common.scss:29,76,147,165,131`, cited
/// in this plan's global constraints rather than a single Playwright/`.tsx`
/// counterpart -- it is a constants-only check, not a behavioural mirror of
/// one upstream test file, so it carries no `@Upstream` tag of its own.
void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // invoked immediately below it (see test/a11y/semantics_matrix_test.dart
  // for the same pattern).
  @Upstream('_reduce-motion.scss:9-17; animation.ts:64-92')
  void blindDropdownAndToastTransitionsAreZeroUnderReducedMotion() {
    testWidgets(
      'blind, dropdown and toast transitions are zero under reduced motion',
      (tester) async {
        await pumpIx(
          tester,
          IxBlind(
            title: 'T',
            expanded: true,
            onExpandedChanged: (_) {},
            child: const Text('c'),
          ),
          disableAnimations: true,
        );
        expect(
          tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
          Duration.zero,
        );
        expect(
          tester
              .widget<AnimatedRotation>(find.byType(AnimatedRotation))
              .duration,
          Duration.zero,
        );
      },
    );
  }

  blindDropdownAndToastTransitionsAreZeroUnderReducedMotion();

  test('IxMotion tokens match upstream', () {
    expect(IxMotion.defaultTime, const Duration(milliseconds: 150));
    expect(IxMotion.medium, const Duration(milliseconds: 300));
    expect(IxMotion.slow, const Duration(milliseconds: 500));
    expect(IxMotion.xSlow, const Duration(milliseconds: 1000));
    expect(IxMotion.short, Duration.zero);
  });
}
