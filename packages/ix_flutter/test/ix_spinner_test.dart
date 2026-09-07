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

  group('partial consumer-built variant maps', () {
    const legacyStandard = IxSpinnerVariantStyle(
      indicatorColor: Color(0xFF112233),
      trackColor: Color(0xFF445566),
    );
    const legacyPrimary = IxSpinnerVariantStyle(
      indicatorColor: Color(0xFF778899),
      trackColor: Color(0xFFAABBCC),
    );

    /// Builds a theme whose [IxSpinnerTheme] carries only [variants],
    /// exactly as a consumer's `copyWith(variants: ...)` written against
    /// 1.0.x would: the map is authoritative and has no `secondary` key,
    /// because that value did not exist yet.
    ThemeData themeWithVariants(
      Map<IxSpinnerVariant, IxSpinnerVariantStyle> variants,
    ) {
      final base = const IxThemeBuilder(mode: ThemeMode.light).build();
      final spinner = base.extension<IxSpinnerTheme>()!;
      return base.copyWith(
        extensions: [
          ...base.extensions.values.where((e) => e is! IxSpinnerTheme),
          spinner.copyWith(variants: variants),
        ],
      );
    }

    testWidgets('a 1.0.x variant map without secondary still renders the '
        'default spinner', (tester) async {
      await pumpIx(
        tester,
        const IxSpinner(),
        theme: themeWithVariants(const {
          // ignore: deprecated_member_use_from_same_package
          IxSpinnerVariant.standard: legacyStandard,
          IxSpinnerVariant.primary: legacyPrimary,
        }),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(IxSpinner), findsOneWidget);
    });

    testWidgets('an explicit secondary spinner falls back to the aliased '
        'standard style', (tester) async {
      final theme = themeWithVariants(const {
        // ignore: deprecated_member_use_from_same_package
        IxSpinnerVariant.standard: legacyStandard,
        IxSpinnerVariant.primary: legacyPrimary,
      });
      await pumpIx(
        tester,
        const IxSpinner(variant: IxSpinnerVariant.secondary),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
      expect(
        theme.extension<IxSpinnerTheme>()!.style(IxSpinnerVariant.secondary),
        same(legacyStandard),
      );
    });

    testWidgets('a secondary-only variant map serves the deprecated standard '
        'variant', (tester) async {
      final theme = themeWithVariants(const {
        IxSpinnerVariant.secondary: legacyStandard,
      });
      await pumpIx(
        tester,
        // ignore: deprecated_member_use_from_same_package
        const IxSpinner(variant: IxSpinnerVariant.standard),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
      expect(
        theme.extension<IxSpinnerTheme>()!.style(
          // ignore: deprecated_member_use_from_same_package
          IxSpinnerVariant.standard,
        ),
        same(legacyStandard),
      );
    });

    test(
      'a variant map with neither alias key still resolves every variant',
      () {
        final base = const IxThemeBuilder(mode: ThemeMode.light).build();
        final partial = base.extension<IxSpinnerTheme>()!.copyWith(
          variants: const {IxSpinnerVariant.primary: legacyPrimary},
        );
        expect(partial.style(IxSpinnerVariant.primary), same(legacyPrimary));
        expect(partial.style(IxSpinnerVariant.secondary), isNotNull);
        expect(
          // ignore: deprecated_member_use_from_same_package
          partial.style(IxSpinnerVariant.standard),
          isNotNull,
        );
      },
    );

    test('lerp between a 1.0.x and a 1.1 variant map does not throw', () {
      final base = const IxThemeBuilder(mode: ThemeMode.light).build();
      final spinner = base.extension<IxSpinnerTheme>()!;
      final legacy = spinner.copyWith(
        variants: const {
          // ignore: deprecated_member_use_from_same_package
          IxSpinnerVariant.standard: legacyStandard,
          IxSpinnerVariant.primary: legacyPrimary,
        },
      );
      final modern = spinner.copyWith(
        variants: const {IxSpinnerVariant.secondary: legacyPrimary},
      );
      final blended = legacy.lerp(modern, 0.5);
      expect(blended.style(IxSpinnerVariant.secondary), isNotNull);
      expect(blended.style(IxSpinnerVariant.primary), isNotNull);
      // The blended `secondary` interpolates the legacy `standard` style
      // (its alias) into the modern `secondary` one, rather than snapping.
      expect(
        blended.style(IxSpinnerVariant.secondary).indicatorColor,
        Color.lerp(
          legacyStandard.indicatorColor,
          legacyPrimary.indicatorColor,
          0.5,
        ),
      );
    });
  });
}
