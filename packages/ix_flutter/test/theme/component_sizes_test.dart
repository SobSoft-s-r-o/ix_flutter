import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Traceability: the comfortable-density hit-area check below cites the
/// upstream `button-mixin.scss` control height and WCAG 2.5.8 target-size
/// guidance via `@Upstream`. The other tests in this file have no
/// upstream `.scss`/`.tsx` counterpart of their own: they guard
/// Flutter-specific mechanics introduced by this package --
/// [IxDensityAdapter]'s `MaterialTapTargetSize` wiring keeping `1.x`
/// buttons at their existing 40px visual height while only the hit area
/// grows, [IxIconButton]'s fixed 32/24/16px visual sizes and matching
/// `IconTheme` size at each [IxIconButtonSize], and [IxIconButton]'s
/// merged semantics node (both with a `tooltip`-derived label and with an
/// icon-supplied `semanticLabel` alone) -- so they carry no `@Upstream`
/// tag.
Widget _controls() => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    FilledButton(
      key: const Key('filled'),
      onPressed: () {},
      child: const Text('Save'),
    ),
    Checkbox(key: const Key('checkbox'), value: false, onChanged: (_) {}),
    RadioGroup<int>(
      groupValue: 0,
      onChanged: (_) {},
      child: Radio<int>(key: const Key('radio'), value: 1),
    ),
    Switch(key: const Key('switch'), value: false, onChanged: (_) {}),
    IxIconButton(
      key: const Key('iconbtn'),
      icon: const Icon(Icons.close),
      onPressed: () {},
      tooltip: 'Close',
    ),
  ],
);

void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement, so the @Upstream-tagged test is wrapped in a local function
  // invoked immediately below it (see test/a11y/focus_visible_test.dart for
  // the same pattern).
  @Upstream('button-mixin.scss height 2rem; WCAG 2.5.8 target size')
  void comfortableHitAreaIsAtLeast48px() {
    testWidgets('comfortable: every control has a hit area of at least 48 px', (
      tester,
    ) async {
      await pumpIx(
        tester,
        IxDensityScope(density: IxDensity.comfortable, child: _controls()),
      );
      for (final k in ['filled', 'checkbox', 'radio', 'switch', 'iconbtn']) {
        final size = tester.getSize(find.byKey(Key(k)));
        expect(size.height, greaterThanOrEqualTo(48), reason: k);
        expect(size.width, greaterThanOrEqualTo(48), reason: k);
      }
    });
  }

  comfortableHitAreaIsAtLeast48px();

  testWidgets(
    'compact: icon button is 32 px, checkbox 40 px (Material shrinkWrap), '
    'button keeps 40 px in 1.x',
    (tester) async {
      await pumpIx(
        tester,
        IxDensityScope(density: IxDensity.compact, child: _controls()),
      );
      expect(
        tester.getSize(find.byKey(const Key('iconbtn'))),
        const Size(32, 32),
      );
      expect(tester.getSize(find.byKey(const Key('checkbox'))).height, 40);
      // FilledButton's own minimumSize height is exactly 40, but its
      // intrinsic content (typography.label's metrics + basePadding)
      // rounds to 41 in this Flutter version, independent of density --
      // the same 41 shows up with MaterialTapTargetSize.shrinkWrap even
      // with IxDensityAdapter bypassed entirely. closeTo captures the
      // real intent (compact does not inflate the button to comfortable's
      // 48px floor) without pinning that unrelated sub-pixel rounding.
      expect(
        tester.getSize(find.byKey(const Key('filled'))).height,
        closeTo(40, 1),
      );
    },
  );

  testWidgets('IxIconButton sizes 32/24/16 and icon 24/16/12', (tester) async {
    await pumpIx(
      tester,
      IxDensityScope(
        density: IxDensity.compact,
        child: Row(
          children: [
            for (final s in IxIconButtonSize.values)
              IxIconButton(
                key: Key(s.name),
                // Not `const`: a `const Icon(Icons.close)` written inside a
                // collection-for is canonicalized to ONE shared instance
                // across all iterations, which later breaks
                // find.byWidget(icon) below (it would match all three
                // buttons' icons at once instead of just this one).
                icon: Icon(Icons.close),
                onPressed: () {},
                size: s,
              ),
          ],
        ),
      ),
    );
    for (final s in IxIconButtonSize.values) {
      expect(tester.getSize(find.byKey(Key(s.name))), Size(s.px, s.px));
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(Key(s.name)),
          matching: find.byType(Icon),
        ),
      );
      expect(
        IconTheme.of(tester.element(find.byWidget(icon))).size,
        s.iconSize.px,
      );
    }
  });

  testWidgets('IxIconButton exposes a labelled button', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpIx(
      tester,
      IxIconButton(
        icon: const Icon(Icons.close),
        onPressed: () {},
        tooltip: 'Close',
      ),
    );
    expect(
      tester.getSemantics(find.byType(IxIconButton)),
      matchesSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        // IconButton natively exposes a `focus` semantics action in this
        // Flutter version (letting assistive tech request focus
        // programmatically), alongside the `isFocusable` flag.
        hasFocusAction: true,
        label: 'Close',
      ),
    );
    handle.dispose();
  });

  testWidgets(
    'IxIconButton keeps an icon-supplied semanticLabel when tooltip and '
    'semanticLabel are both absent',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpIx(
        tester,
        IxIconButton(
          // No tooltip, no IxIconButton.semanticLabel: the icon's own
          // semanticLabel must not be discarded (regression test for the
          // `excludeSemantics: true` version, which dropped it).
          icon: const Icon(Icons.close, semanticLabel: 'Close'),
          onPressed: () {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(IxIconButton)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Close',
        ),
      );
      handle.dispose();
    },
  );
}
