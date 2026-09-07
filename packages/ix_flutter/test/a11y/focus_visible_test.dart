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

/// Captures [boundaryFinder]'s current paint as a raw RGBA image, its
/// `ByteData`, and the boundary's global origin (so pixel coordinates can
/// be derived from `tester.getRect(...)`, which reports positions in that
/// same global space).
Future<(ui.Image, ByteData, Offset)> _captureBoundary(
  WidgetTester tester,
  Finder boundaryFinder,
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
  return (image!, data, origin);
}

/// Reads the RGBA colour at boundary-local pixel ([x], [y]), or `null` if
/// outside the captured image.
Color? _pixelAt(ui.Image image, ByteData data, int x, int y) {
  if (x < 0 || y < 0 || x >= image.width || y >= image.height) return null;
  final i = (y * image.width + x) * 4;
  if (i + 3 >= data.lengthInBytes) return null;
  return Color.fromARGB(
    data.getUint8(i + 3),
    data.getUint8(i),
    data.getUint8(i + 1),
    data.getUint8(i + 2),
  );
}

/// Whether [a] and [b] are within [tolerance] on every channel (0-255
/// scale), ignoring alpha. For pixels expected to be fully opaque, such as
/// the 1px focus-bdr ring/border.
bool _closeTo(Color a, Color b, {int tolerance = 6}) {
  int channel(double v) => (v * 255).round();
  return (channel(a.r) - channel(b.r)).abs() <= tolerance &&
      (channel(a.g) - channel(b.g)).abs() <= tolerance &&
      (channel(a.b) - channel(b.b)).abs() <= tolerance;
}

/// Whether [a] and [b] are within [tolerance] on every channel (0-255
/// scale), alpha included. For a pixel read as premultiplied-alpha raw
/// bytes (as `toImage()`'s rawRgba format is) and compared against an
/// expected value expressed the same way -- unlike [_closeTo], alpha
/// matters here because it is part of what was actually painted.
bool _closeToPremultiplied(Color a, Color b, {int tolerance = 6}) {
  int channel(double v) => (v * 255).round();
  return (channel(a.a) - channel(b.a)).abs() <= tolerance &&
      (channel(a.r) - channel(b.r)).abs() <= tolerance &&
      (channel(a.g) - channel(b.g)).abs() <= tolerance &&
      (channel(a.b) - channel(b.b)).abs() <= tolerance;
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

  @Upstream(
    'button-mixin.scss:171-182 / checkbox.scss:50-53 focus-visible outline 1px focus-bdr',
  )
  void focusRingSitsAtTheMandatedOffset() {
    testWidgets('IxFocusRing keeps a 2px gap before the ring (outline-offset), '
        'verified on the blind header', (tester) async {
      final previousStrategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousStrategy;
      });

      final boundaryKey = UniqueKey();
      final control = IxBlind(
        title: 'T',
        expanded: false,
        onExpandedChanged: (_) {},
        child: const SizedBox(),
      );
      await pumpIx(
        tester,
        Center(
          child: RepaintBoundary(
            key: boundaryKey,
            child: Padding(padding: const EdgeInsets.all(8), child: control),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final (image, data, origin) = await _captureBoundary(
        tester,
        find.byKey(boundaryKey),
      );
      bool isFocusBdr(int x, int y) {
        final c = _pixelAt(image, data, x, y);
        return c != null && _closeTo(c, const Color(0xFF199fff));
      }

      final controlRect = tester.getRect(find.byWidget(control)).shift(-origin);
      // Sample straight up through the header, well clear of the rounded
      // corners (the blind spans the full viewport width, so its
      // horizontal centre is far from either corner).
      final x = controlRect.center.dx.round();
      final topEdge = controlRect.top.round();
      final offsetPx = IxCommonGeometry.focusOutlineOffset.round();

      // The gap between the header and the ring must be the full
      // outline-offset (2px): every row strictly between the header and
      // the ring stays background...
      for (var d = 1; d <= offsetPx; d++) {
        expect(
          isFocusBdr(x, topEdge - d),
          isFalse,
          reason:
              'row $d px above the header must be background -- the '
              'outline-offset gap, not the ring',
        );
      }
      // ...and the ring itself starts exactly one pixel further out.
      expect(
        isFocusBdr(x, topEdge - offsetPx - 1),
        isTrue,
        reason:
            'the ring must start exactly focusOutlineOffset '
            '($offsetPx px) above the header',
      );
    });
  }

  focusRingSitsAtTheMandatedOffset();

  test(
    'IxRadioTheme.materialRadioTheme.overlayColor resolves a focusBdr halo '
    'for {focused} and {selected, focused}, and stays transparent for {}',
    () {
      final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
      final ixTheme = theme.extension<IxTheme>()!;
      final overlay = theme
          .extension<IxRadioTheme>()!
          .materialRadioTheme
          .overlayColor!;
      final expectedHalo = ixTheme
          .color(IxThemeColorToken.focusBdr)
          .withValues(alpha: 0.3);

      expect(overlay.resolve({WidgetState.focused}), expectedHalo);
      expect(
        overlay.resolve({WidgetState.selected, WidgetState.focused}),
        expectedHalo,
      );
      expect(overlay.resolve(<WidgetState>{}), Colors.transparent);
    },
  );

  @Upstream(
    'button-mixin.scss:171-182 / checkbox.scss:50-53 focus-visible outline 1px focus-bdr',
  )
  void selectedRadioShowsAFocusHalo() {
    testWidgets(
      'a selected radio shows a focusBdr-tinted halo on keyboard focus',
      (tester) async {
        final previousStrategy = FocusManager.instance.highlightStrategy;
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTraditional;
        addTearDown(() {
          FocusManager.instance.highlightStrategy = previousStrategy;
        });

        final node = FocusNode(debugLabel: 'selectedRadio');
        addTearDown(node.dispose);
        final boundaryKey = UniqueKey();
        // groupValue == value: this radio starts out selected.
        final control = RadioGroup<int>(
          groupValue: 1,
          onChanged: (_) {},
          child: Radio<int>(focusNode: node, value: 1),
        );
        await pumpIx(
          tester,
          Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: Padding(padding: const EdgeInsets.all(8), child: control),
            ),
          ),
        );
        node.requestFocus();
        await tester.pumpAndSettle();

        final (image, data, origin) = await _captureBoundary(
          tester,
          find.byKey(boundaryKey),
        );
        final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
        final haloColor = theme.extension<IxTheme>()!.color(
          IxThemeColorToken.focusBdr,
        );
        // This test's RepaintBoundary is isolated (nothing paints an
        // opaque background inside it -- confirmed empirically, the
        // padding around the radio rasterizes as fully transparent), and
        // `toImage()`'s rawRgba bytes are premultiplied by alpha. So the
        // halo -- painted once, directly over that transparent canvas --
        // shows up as `haloColor` scaled by its own 0.3 alpha on every
        // channel, alpha included, not as an opaque `Color.alphaBlend`
        // result (there is no opaque backdrop here to blend over).
        const haloAlpha = 0.3;
        int scaledChannel(double v) => (v * haloAlpha * 255).round();
        final expectedPixel = Color.fromARGB(
          (haloAlpha * 255).round(),
          scaledChannel(haloColor.r),
          scaledChannel(haloColor.g),
          scaledChannel(haloColor.b),
        );

        final rect = tester
            .getRect(find.byWidget(control))
            .shift(-origin)
            .inflate(4);
        var found = false;
        for (var y = rect.top.toInt(); y < rect.bottom && !found; y++) {
          for (var x = rect.left.toInt(); x < rect.right; x++) {
            final c = _pixelAt(image, data, x, y);
            if (c != null && _closeToPremultiplied(c, expectedPixel)) {
              found = true;
              break;
            }
          }
        }
        expect(
          found,
          isTrue,
          reason:
              'expected a pixel within tolerance of the premultiplied '
              'focusBdr-tinted halo ($expectedPixel) around the selected, '
              'focused radio',
        );
      },
    );
  }

  selectedRadioShowsAFocusHalo();

  // FilledButton's focused Material.shape border does not settle visually
  // in this Flutter version's widget-test harness (see the
  // `_FocusedControl.forceTraditionalHighlight` doc comment above for the
  // investigation), so this asserts the resolved `ButtonStyle.side` value
  // directly instead of scanning pixels -- a harness-independent check
  // that the theme contract itself is correct. A manual Tab-through on
  // desktop/web is the owner's follow-up to confirm real end-user
  // behaviour.
  @Upstream('button-mixin.scss:171-182 focus-visible outline 1px focus-bdr')
  void filledButtonThemeResolvesFocusBdrBorder() {
    test('IxButtonTheme.primary.side resolves the focus-bdr border for '
        '{focused}', () {
      final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
      final ixTheme = theme.extension<IxTheme>()!;
      final resolvedSide = theme
          .extension<IxButtonTheme>()!
          .primary
          .side!
          .resolve({WidgetState.focused});
      expect(
        resolvedSide,
        BorderSide(
          color: ixTheme.color(IxThemeColorToken.focusBdr),
          width: IxCommonGeometry.focusBorderThickness,
        ),
      );
    });
  }

  filledButtonThemeResolvesFocusBdrBorder();

  testWidgets('ThemeData.focusColor is transparent (no opaque fill)', (
    tester,
  ) async {
    final theme = const IxThemeBuilder(mode: ThemeMode.light).build();
    expect(theme.focusColor, Colors.transparent);
  });
}
