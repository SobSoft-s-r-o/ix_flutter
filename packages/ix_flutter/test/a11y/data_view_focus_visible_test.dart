import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

/// [IxResponsiveDataView]'s sortable headers, desktop rows and mobile cards
/// are keyboard-focusable and hoverable, so both states have to be visible
/// (WCAG 2.4.7 / 1.4.1). Neither was: `focusColor: Colors.transparent` (the
/// app-wide setting that lets `IxFocusRing` own the focus affordance) left
/// them with no indicator at all, and the `InkWell`'s hover splash was
/// painted *behind* the opaque `Container` that draws the row background.
///
/// Both are checked the same way: capture the boundary, change one thing
/// (Tab, or move the mouse in), capture again, and require the paint to
/// differ. The colour itself is asserted for the focus ring, which has a
/// token (`focusBdr` #199fff).

const _focusBdr = Color(0xFF199FFF);

Future<(ui.Image, ByteData)> _capture(
  WidgetTester tester,
  Finder boundary,
) async {
  final image = await tester.runAsync(() async {
    return tester
        .renderObject<RenderRepaintBoundary>(boundary)
        .toImage(pixelRatio: 1);
  });
  final data = (await tester.runAsync(
    () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
  ))!;
  return (image!, data);
}

int _differingPixels(ByteData a, ByteData b) {
  var differing = 0;
  final length = a.lengthInBytes < b.lengthInBytes
      ? a.lengthInBytes
      : b.lengthInBytes;
  for (var i = 0; i < length; i += 4) {
    if (a.getUint32(i) != b.getUint32(i)) {
      differing++;
    }
  }
  return differing;
}

bool _hasColour(ui.Image image, ByteData data, Color colour) {
  int channel(double v) => (v * 255).round();
  for (var i = 0; i + 3 < data.lengthInBytes; i += 4) {
    if (data.getUint8(i) == channel(colour.r) &&
        data.getUint8(i + 1) == channel(colour.g) &&
        data.getUint8(i + 2) == channel(colour.b) &&
        data.getUint8(i + 3) != 0) {
      return true;
    }
  }
  return false;
}

final _items = List.generate(3, (i) => 'Row $i');

IxResponsiveDataView<String> _dataView() => IxResponsiveDataView<String>(
  items: _items,
  desktopColumns: [
    IxColumnDef<String>(
      label: 'Name',
      sortKey: 'name',
      cellBuilder: (context, item) => Text(item),
    ),
  ],
  mobileFields: [
    IxMobileFieldDef<String>(
      label: 'Name',
      valueBuilder: (context, item) => Text(item),
    ),
  ],
  rowActions: const [],
  enableSorting: true,
  onRowTapDesktop: (_) {},
);

Future<void> _pumpView(
  WidgetTester tester,
  Key boundaryKey, {
  Size size = const Size(1024, 768),
}) async {
  await pumpIx(
    tester,
    RepaintBoundary(key: boundaryKey, child: _dataView()),
    size: size,
  );
}

void main() {
  @Upstream('table.scss focus-visible outline 1px focus-bdr on the header/row')
  void headersAndRowsShowAFocusRing() {
    testWidgets('a sortable header and a row show a focus-bdr ring on Tab', (
      tester,
    ) async {
      final previousStrategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousStrategy;
      });

      final boundaryKey = UniqueKey();
      await _pumpView(tester, boundaryKey);
      final boundary = find.byKey(boundaryKey);

      final (before, beforeData) = await _capture(tester, boundary);
      addTearDown(before.dispose);

      // First Tab lands on the sortable header (the search field and its
      // clear action are not built for this view).
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final (header, headerData) = await _capture(tester, boundary);
      addTearDown(header.dispose);
      expect(
        _differingPixels(beforeData, headerData),
        greaterThan(0),
        reason: 'focusing the header changed nothing on screen',
      );
      expect(
        _hasColour(header, headerData, _focusBdr),
        isTrue,
        reason: 'expected a focus-bdr ring around the focused header',
      );

      // Next Tab moves to the first row.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final (row, rowData) = await _capture(tester, boundary);
      addTearDown(row.dispose);
      expect(
        _differingPixels(headerData, rowData),
        greaterThan(0),
        reason: 'focusing the first row changed nothing on screen',
      );
      expect(
        _hasColour(row, rowData, _focusBdr),
        isTrue,
        reason: 'expected a focus-bdr ring around the focused row',
      );
    });
  }

  headersAndRowsShowAFocusRing();

  @Upstream('table.scss focus-visible outline on the mobile card')
  void mobileCardsShowAFocusRing() {
    testWidgets('a mobile card shows a focus-bdr ring on Tab', (tester) async {
      final previousStrategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousStrategy;
      });

      final boundaryKey = UniqueKey();
      await _pumpView(tester, boundaryKey, size: const Size(400, 800));
      final boundary = find.byKey(boundaryKey);

      final (before, beforeData) = await _capture(tester, boundary);
      addTearDown(before.dispose);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final (after, afterData) = await _capture(tester, boundary);
      addTearDown(after.dispose);

      expect(
        _differingPixels(beforeData, afterData),
        greaterThan(0),
        reason: 'focusing the first card changed nothing on screen',
      );
      expect(
        _hasColour(after, afterData, _focusBdr),
        isTrue,
        reason: 'expected a focus-bdr ring around the focused card',
      );
    });
  }

  mobileCardsShowAFocusRing();

  @Upstream('table.scss row hover background')
  void hoverIsVisible() {
    testWidgets('the header and a desktop row repaint on hover', (
      tester,
    ) async {
      final boundaryKey = UniqueKey();
      await _pumpView(tester, boundaryKey);
      final boundary = find.byKey(boundaryKey);

      final (before, beforeData) = await _capture(tester, boundary);
      addTearDown(before.dispose);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(() => mouse.removePointer());
      await mouse.addPointer(location: Offset.zero);
      await tester.pump();

      await mouse.moveTo(
        tester.getCenter(find.byKey(const Key('ix-rdv-row-0'))),
      );
      await tester.pumpAndSettle();
      final (row, rowData) = await _capture(tester, boundary);
      addTearDown(row.dispose);
      expect(
        _differingPixels(beforeData, rowData),
        greaterThan(0),
        reason: 'hovering a desktop row painted nothing',
      );

      await mouse.moveTo(
        tester.getCenter(find.byKey(const Key('ix-rdv-header-name'))),
      );
      await tester.pumpAndSettle();
      final (header, headerData) = await _capture(tester, boundary);
      addTearDown(header.dispose);
      expect(
        _differingPixels(rowData, headerData),
        greaterThan(0),
        reason: 'hovering the header painted nothing',
      );
    });
  }

  hoverIsVisible();

  @Upstream('table.scss card hover background')
  void mobileCardHoverIsVisible() {
    testWidgets('a mobile card repaints on hover', (tester) async {
      final boundaryKey = UniqueKey();
      await _pumpView(tester, boundaryKey, size: const Size(400, 800));
      final boundary = find.byKey(boundaryKey);

      final (before, beforeData) = await _capture(tester, boundary);
      addTearDown(before.dispose);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(() => mouse.removePointer());
      await mouse.addPointer(location: Offset.zero);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Row 0')));
      await tester.pumpAndSettle();

      final (after, afterData) = await _capture(tester, boundary);
      addTearDown(after.dispose);
      expect(
        _differingPixels(beforeData, afterData),
        greaterThan(0),
        reason: 'hovering a mobile card painted nothing',
      );
    });
  }

  mobileCardHoverIsVisible();
}
