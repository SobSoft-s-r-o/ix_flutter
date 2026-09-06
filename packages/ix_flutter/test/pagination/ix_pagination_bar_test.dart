import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';
import '../helpers/upstream.dart';

Widget _bar({int page = 2}) => IxPaginationBar(
  page: page,
  totalPages: 5,
  totalItems: 100,
  pageSize: 20,
  pageSizeOptions: const [10, 20, 50],
  onPageChanged: (_) {},
  onPageSizeChanged: (_) {},
);

/// 'chevrons are 32px IxIconButtons' and 'paginationStrings override wins
/// over strings' below have no upstream counterpart: `pagination.tsx`
/// (upstream `ix-pagination`) has no fixed pixel size for its chevrons --
/// sizing is a Flutter-specific density/geometry concern (`IxIconButton`
/// 32/24/16px sizes, findings IXF-020/IXF-047, task D-1) -- and no
/// `IxPaginationStrings`-style bridging class, since upstream sets ARIA
/// labels directly as component props rather than through a separate
/// strings/localization object. `IxPaginationStrings` itself, and its
/// precedence over the legacy `IxResponsiveDataViewStrings`, are additive
/// Flutter API introduced by this task (findings IXF-002/IXF-024/IXF-031,
/// task A-4, spec `2026-09-04-ix-flutter-2-0-design.md`).
void main() {
  // Metadata annotations can only precede a declaration, not a bare
  // statement (see `test/a11y/semantics_matrix_test.dart`), so the
  // @Upstream-tagged test is wrapped in a local function invoked right
  // below it.
  @Upstream(
    'pagination.tsx:102-118 aria labels; pagination.scss wraps on narrow width',
  )
  void noOverflowAt320pxTextScale2AndControlsKeepTheirLabels() {
    testWidgets(
      'no overflow at 320px × text scale 2.0 and controls keep their labels',
      (tester) async {
        final handle = tester.ensureSemantics();
        await pumpIx(
          tester,
          _bar(),
          size: const Size(320, 640),
          textScaler: const TextScaler.linear(2.0),
        );
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Previous page'), findsOneWidget);
        expect(find.bySemanticsLabel('Next page'), findsOneWidget);
        expect(
          tester.getSemantics(find.byKey(const Key('ix-pagination-size'))),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            // `IxDropdownButton`'s trigger is a `Focus` widget under the
            // hood, which contributes an explicit `focus` semantics action
            // alongside `tap` -- real, additive assistive-tech behaviour,
            // also asserted on the RDV sortable-header case (which merges
            // its own `InkWell`'s native focus semantics rather than
            // reconstructing them, see `ix_responsive_data_view_test.dart`).
            hasFocusAction: true,
            hasExpandedState: true,
            isExpanded: false,
            label: 'Page selection',
            value: '20',
          ),
        );
        handle.dispose();
      },
    );
  }

  noOverflowAt320pxTextScale2AndControlsKeepTheirLabels();

  testWidgets('chevrons are 32px IxIconButtons', (tester) async {
    await pumpIx(
      tester,
      IxDensityScope(density: IxDensity.compact, child: _bar()),
    );
    expect(
      tester.getSize(find.byKey(const Key('ix-pagination-prev'))),
      const Size(32, 32),
    );
  });

  testWidgets(
    'page label gets its own Wrap run instead of being truncated at 320px × 2.0',
    (tester) async {
      await pumpIx(
        tester,
        _bar(),
        size: const Size(320, 640),
        textScaler: const TextScaler.linear(2.0),
      );
      expect(tester.takeException(), isNull);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('Page 2 of 5'),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
    },
  );

  testWidgets('paginationStrings override wins over strings', (tester) async {
    await pumpIx(
      tester,
      IxPaginationBar(
        page: 1,
        totalPages: 2,
        onPageChanged: (_) {},
        paginationStrings: const IxPaginationStrings(nextPage: 'Ďalšia strana'),
      ),
    );
    expect(find.byTooltip('Ďalšia strana'), findsOneWidget);
  });

  testWidgets('IxResponsiveDataView localizes the page-size trigger', (
    tester,
  ) async {
    await pumpIx(
      tester,
      IxResponsiveDataView<int>(
        items: const [1, 2, 3],
        desktopColumns: [
          IxColumnDef<int>(
            label: 'N',
            cellBuilder: (context, item) => Text('$item'),
          ),
        ],
        mobileFields: [
          IxMobileFieldDef<int>(
            label: 'N',
            valueBuilder: (context, item) => Text('$item'),
          ),
        ],
        rowActions: const [],
        pagination: const IxPaginationConfig(
          mode: IxPaginationMode.standard,
          page: 0,
          pageSize: 10,
          totalPages: 3,
          pageSizeOptions: [10, 25],
        ),
        onPageChanged: (_) {},
        onPageSizeChanged: (_) {},
        strings: const IxResponsiveDataViewStrings(
          pageSelectionLabel: 'Seitenauswahl',
        ),
      ),
      size: const Size(1024, 768),
    );

    expect(find.bySemanticsLabel('Seitenauswahl'), findsOneWidget);
  });

  testWidgets('IxResponsiveDataView forwards an explicit paginationStrings', (
    tester,
  ) async {
    await pumpIx(
      tester,
      IxResponsiveDataView<int>(
        items: const [1, 2, 3],
        desktopColumns: [
          IxColumnDef<int>(
            label: 'N',
            cellBuilder: (context, item) => Text('$item'),
          ),
        ],
        mobileFields: [
          IxMobileFieldDef<int>(
            label: 'N',
            valueBuilder: (context, item) => Text('$item'),
          ),
        ],
        rowActions: const [],
        pagination: const IxPaginationConfig(
          mode: IxPaginationMode.standard,
          page: 0,
          pageSize: 10,
          totalPages: 3,
          pageSizeOptions: [10, 25],
        ),
        onPageChanged: (_) {},
        onPageSizeChanged: (_) {},
        paginationStrings: const IxPaginationStrings(
          pageSelection: 'Pages',
          previousPage: 'Zuruck',
        ),
      ),
      size: const Size(1024, 768),
    );

    expect(find.bySemanticsLabel('Pages'), findsOneWidget);
    expect(find.byTooltip('Zuruck'), findsOneWidget);
  });
}
