import 'dart:ui' as ui;

import 'package:example/ix_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// The generated icon assets must actually paint something.
///
/// `@siemens/ix-icons` ships its SVGs for the web, where `icon.css`
/// (`svg [fill] { fill: currentColor !important }`) overrides every `fill` at
/// paint time. 891 of the 1479 icons rely on that: they declare `fill="none"`
/// on the root `<svg>` and give their `<path>`s no fill of their own. Flutter
/// has no such stylesheet, so before the generator learned to strip that
/// attribute those icons compiled to zero draw commands and rendered blank —
/// a fully transparent box that `srcIn` tinting has nothing to tint.
///
/// `dashboard` is one of the 891 (root `fill="none"`); `home` is one of the
/// 588 Sketch-exported icons that were never affected, and guards against a
/// cleaning rule that overreaches and breaks the icons that already worked.
void main() {
  /// Counts the pixels of [finder]'s repaint boundary whose alpha is not 0.
  Future<int> paintedPixels(WidgetTester tester, Finder finder) async {
    final image = await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
      return boundary.toImage(pixelRatio: 1);
    });
    final data = (await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    ))!;
    var painted = 0;
    for (var i = 3; i < data.lengthInBytes; i += 4) {
      if (data.getUint8(i) != 0) {
        painted++;
      }
    }
    image!.dispose();
    return painted;
  }

  Future<void> pumpIcon(WidgetTester tester, IxIconData icon) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              key: const Key('boundary'),
              child: ColoredBox(
                color: const Color(0x00000000),
                child: IxIcon(icon, size: IxIconSize.s32),
              ),
            ),
          ),
        ),
      );
      // The SVG is decoded off the platform thread; give the real event loop
      // a turn so the picture is available before the frame is captured.
      await tester.pump(const Duration(milliseconds: 200));
    });
    await tester.pump();
  }

  testWidgets('a root-fill="none" icon paints visible pixels', (tester) async {
    await pumpIcon(tester, IxIconsData.dashboard);
    expect(
      await paintedPixels(tester, find.byKey(const Key('boundary'))),
      greaterThan(0),
      reason: 'IxIconsData.dashboard rendered a fully transparent box',
    );
  });

  testWidgets('an already-working icon still paints visible pixels', (
    tester,
  ) async {
    await pumpIcon(tester, IxIconsData.home);
    expect(
      await paintedPixels(tester, find.byKey(const Key('boundary'))),
      greaterThan(0),
      reason: 'IxIconsData.home rendered a fully transparent box',
    );
  });
}
