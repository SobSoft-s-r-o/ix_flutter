import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// Traceability: the per-control focus-ring checks below cite the upstream
/// `button-mixin.scss` / `checkbox.scss` focus-visible outline rules via
/// `@Upstream`. The final test in this file (`ThemeData.focusColor is
/// transparent`) has no distinct upstream `.scss`/`.tsx` counterpart of its
/// own: it guards a Flutter-specific precondition (Material's built-in
/// translucent focus overlay must be disabled so the token-coloured 1px
/// ring painted by `IxFocusRing` and the state-based borders stay visible)
/// that those same upstream focus-visible rules assume implicitly, so it
/// carries no separate `@Upstream` tag.
///
/// Scans the pixels of the [RepaintBoundary] identified by [boundaryFinder]
/// for the Siemens IX `focusBdr` color (`#199fff`), within a small margin
/// around [controlFinder]'s on-screen bounds. The boundary is a `Key`ed
/// boundary local to the test, tightly wrapping the control (not
/// `pumpIx`'s ambient `MaterialApp`/route-level boundaries), and the scan
/// rect is translated into the boundary's own local coordinate space via
/// its global origin, so the pixel index math is correct regardless of
/// where `pumpIx` places its own internal repaint boundaries.
Future<bool> _hasFocusBdrPixels(
  WidgetTester tester,
  Finder boundaryFinder,
  Finder controlFinder,
) async {
  final image = await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(boundaryFinder);
    return boundary.toImage(pixelRatio: 1);
  });
  final data = (await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  ))!;
  final origin = tester
      .renderObject<RenderBox>(boundaryFinder)
      .localToGlobal(Offset.zero);
  final rect = tester.getRect(controlFinder).shift(-origin).inflate(4);
  for (var y = rect.top.toInt(); y < rect.bottom; y++) {
    for (var x = rect.left.toInt(); x < rect.right; x++) {
      if (x < 0 || y < 0 || x >= image!.width || y >= image.height) continue;
      final i = (y * image.width + x) * 4;
      if (i + 2 >= data.lengthInBytes) continue;
      if (data.getUint8(i) == 0x19 &&
          data.getUint8(i + 1) == 0x9f &&
          data.getUint8(i + 2) == 0xff) {
        return true;
      }
    }
  }
  return false;
}

/// Describes how a control's keyboard focus is exercised: whether it is
/// driven by an explicit [FocusNode] passed straight to the control (for
/// Flutter's own form widgets, which accept one) or by real Tab traversal
/// (for [IxBlind], whose header manages its own internal [FocusNode] and
/// has no public `focusNode:` parameter), and whether
/// [FocusHighlightStrategy.alwaysTraditional] should be forced. The latter
/// is required for [Checkbox]/[Radio]/[IxBlind] to report
/// `WidgetState.focused` reliably in a widget test with no real input
/// device, but must be left at Flutter's default for [FilledButton]: with
/// it forced, `FilledButton`'s focused `Material.shape` border never
/// settles visually in this Flutter version's widget-test environment
/// (verified in isolation: the same `ButtonStyle.side` resolves correctly
/// to `focusBdr` and reaches the built `Material` widget either way, but
/// `_MaterialInteriorState`'s implicit shape animation only completes when
/// the strategy is left at its default).
typedef _FocusedControl = ({
  Widget Function(FocusNode node) build,
  bool forceTraditionalHighlight,
});

void main() {
  final controls = <String, _FocusedControl>{
    'checkbox': (
      build: (node) =>
          Checkbox(focusNode: node, value: false, onChanged: (_) {}),
      forceTraditionalHighlight: true,
    ),
    'radio': (
      build: (node) => RadioGroup<int>(
        groupValue: 0,
        onChanged: (_) {},
        child: Radio<int>(focusNode: node, value: 1),
      ),
      forceTraditionalHighlight: true,
    ),
    'filled': (
      build: (node) => FilledButton(
        focusNode: node,
        onPressed: () {},
        child: const Text('Save'),
      ),
      forceTraditionalHighlight: false,
    ),
    'blind': (
      build: (_) => IxBlind(
        title: 'T',
        expanded: false,
        onExpandedChanged: (_) {},
        child: const SizedBox(),
      ),
      forceTraditionalHighlight: true,
    ),
  };

  // Metadata annotations can only precede a declaration, not a bare
  // statement (see test/a11y/semantics_matrix_test.dart for the same
  // pattern), so the per-control test is wrapped in one local function
  // invoked once per entry of `controls` below.
  @Upstream(
    'button-mixin.scss:171-182 / checkbox.scss:50-53 focus-visible outline 1px focus-bdr',
  )
  void focusRingIsVisible(String name, _FocusedControl entry) {
    testWidgets('$name shows a focus-bdr ring on keyboard focus', (
      tester,
    ) async {
      final previousStrategy = FocusManager.instance.highlightStrategy;
      if (entry.forceTraditionalHighlight) {
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTraditional;
      }
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousStrategy;
      });

      final node = FocusNode(debugLabel: name);
      addTearDown(node.dispose);
      final boundaryKey = UniqueKey();
      final control = entry.build(node);
      // The RepaintBoundary sits *inside* Center (tightly wrapping the
      // control, with 8px of padding) rather than around Center: a
      // boundary sized to the full available area intermittently misses
      // the focused-state repaint of Material's implicit shape/border
      // animation in this Flutter version's widget-test environment
      // (verified in isolation), and IxFocusRing paints its outset ring
      // outside the control's own bounds, which RenderRepaintBoundary.
      // toImage() would otherwise crop away entirely.
      await pumpIx(
        tester,
        Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: Padding(padding: const EdgeInsets.all(8), child: control),
          ),
        ),
      );

      if (name == 'blind') {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      } else {
        node.requestFocus();
      }
      await tester.pumpAndSettle();

      expect(
        await _hasFocusBdrPixels(
          tester,
          find.byKey(boundaryKey),
          find.byWidget(control),
        ),
        isTrue,
        reason: 'expected a focus-bdr (#199fff) pixel around the $name',
      );
    });
  }

  for (final entry in controls.entries) {
    focusRingIsVisible(entry.key, entry.value);
  }

  testWidgets('ThemeData.focusColor is transparent (no opaque fill)', (
    tester,
  ) async {
    final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
    expect(theme.focusColor, Colors.transparent);
  });
}
