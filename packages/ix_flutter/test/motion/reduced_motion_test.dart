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
        // IxBlind: the expansion transition is asserted by behaviour rather
        // than by the duration of a particular widget -- the blind drives it
        // with its own AnimationController, whose zero duration is not
        // readable off the tree. A single pump after the tap is the whole
        // transition: the content is already at its full height, with no
        // intermediate frame in between.
        await pumpIx(
          tester,
          const IxBlind(
            title: 'T',
            child: SizedBox(key: Key('blind-content'), height: 60),
          ),
          disableAnimations: true,
        );
        await tester.tap(find.text('T'));
        await tester.pump();
        expect(
          tester.getSize(find.byKey(const Key('blind-content'))).height,
          60,
        );
        expect(
          tester.getRect(find.byKey(const Key('blind-content'))).bottom,
          tester.getRect(find.byType(IxBlind)).bottom -
              IxCommonGeometry.borderWidthDefault,
        );
        expect(
          tester
              .widget<AnimatedRotation>(find.byType(AnimatedRotation))
              .duration,
          Duration.zero,
        );

        // IxDropdownButton: the overlay's fade-in AnimationController is
        // constructed with a Duration.zero duration under reduced motion.
        // AnimationController.forward() has a synchronous fast path for a
        // Duration.zero animation (see animation_controller.dart's
        // `_animateToInternal`: `if (simulationDuration == Duration.zero)`
        // sets the value and completes without ever starting a ticker), so
        // the menu is already fully opaque by the single pump that first
        // builds the overlay. (transientCallbackCount is not asserted here:
        // tester.tap's own Material ink-splash animation on the trigger
        // button legitimately keeps ticking for a moment afterwards --
        // that is unrelated real-time Material feedback, not something
        // IxMotion drives, so it is not a reliable zero-duration signal
        // for this specific interaction.)
        await pumpIx(
          tester,
          IxDropdownButton<int>(
            label: 'Actions',
            items: const [IxDropdownMenuItem(label: 'Edit', value: 1)],
          ),
          disableAnimations: true,
        );
        await tester.tap(find.text('Actions'));
        await tester.pump();
        expect(find.text('Edit'), findsOneWidget);
        // MaterialApp's own route transition (Material 3's default
        // ZoomPageTransitionsBuilder) already contributes FadeTransition
        // widgets to the tree, so find.byType(FadeTransition) alone is not
        // unique here -- narrow to the ancestors of the menu item text. The
        // menu is hosted by an OverlayPortal, so it stays a descendant of
        // the route (and of the route transition's own FadeTransition) in
        // the element tree: take the nearest ancestor, which is the menu's.
        final dropdownFade = tester.widget<FadeTransition>(
          find
              .ancestor(
                of: find.text('Edit'),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        expect(dropdownFade.opacity.value, 1.0);
        // Let the trigger button's Material ink-splash (started by the tap
        // above, and unrelated to IxMotion) fully settle before moving on,
        // so it cannot leave a stray ticker that would pollute the toast
        // section's own transientCallbackCount assertions below.
        await tester.pumpAndSettle();

        // IxToastOverlay: AnimatedList.insertItem/removeItem durations are
        // Duration.zero under reduced motion, so both the enter and exit
        // transitions resolve through the same synchronous fast path.
        // autoClose is disabled so the toast's own (intentionally
        // real-time, not motion-token-driven) auto-close progress bar
        // never starts a ticker of its own, keeping this assertion focused
        // on the enter/exit transition only.
        final service = IxToastService();
        addTearDown(service.dispose);
        await pumpIx(
          tester,
          Stack(children: [IxToastOverlay(service: service)]),
          disableAnimations: true,
        );
        // Every pumpIx() call builds a brand-new IxThemeBuilder ThemeData,
        // and this is not the first pumpIx() in this test, so Material's
        // own AnimatedTheme cross-fade (kThemeAnimationDuration, ~200ms --
        // also unrelated to IxMotion) is mid-flight here; settle it before
        // measuring the toast's own transition, for the same reason as the
        // pumpAndSettle above.
        await tester.pumpAndSettle();
        final toast = service.show(message: 'Saved', autoClose: false);
        await tester.pump();
        expect(find.text('Saved'), findsOneWidget);
        // Unlike the dropdown (rendered into a plain Overlay entry outside
        // any route's own transition subtree), this Stack is pumped as
        // ordinary route content, so it also sits under MaterialApp's own
        // route-transition FadeTransition -- narrow to the nearest match,
        // which is the toast item's own.
        final toastFade = tester.widget<FadeTransition>(
          find
              .ancestor(
                of: find.text('Saved'),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        expect(toastFade.opacity.value, 1.0);
        expect(tester.binding.transientCallbackCount, 0);

        service.dismiss(toast.id);
        await tester.pump();
        expect(find.text('Saved'), findsNothing);
        expect(tester.binding.transientCallbackCount, 0);
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
