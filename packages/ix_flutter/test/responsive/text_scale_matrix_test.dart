import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Matica šírok × text scale. Widgety, ktoré dnes pretekajú, sú označené
/// skip s ID nálezu; po oprave sa skip odstráni.
///
/// Traceability: upstream `@siemens/ix` nemá pre túto maticu šírok × text
/// scale priamy Playwright `.ct.ts` ani scss/tsx náprotivok (CSS breakpointy
/// vs. Flutter `LayoutBuilder` sa nedajú mapovať 1:1), preto jednotlivé testy
/// necitujú `@Upstream`. Matica stráži nález IXF-024 (WCAG 1.4.4 Resize
/// text) pre `IxDropdownButton`; skip bol odstránený v úlohe A-2, ktorá
/// spravila label triggeru flexibilným s ellipsis.
///
/// `IxResponsiveDataView`/`IxPaginationBar` cases (A-4, IXF-002/IXF-024/
/// IXF-031) were never skipped -- the header/row/search-chip labels and the
/// pagination `Wrap` are flexible/ellipsis-capable from the start here, so
/// these only guard against a future regression.
class _MatrixItem {
  const _MatrixItem(this.id, this.name);
  final String id;
  final String name;
}

const _matrixItems = [
  _MatrixItem('1', 'Item one'),
  _MatrixItem('2', 'Item two'),
];

final _matrixColumns = [
  IxColumnDef<_MatrixItem>(
    label: 'A very long column header that needs to ellipsize',
    sortKey: 'name',
    flex: 2,
    cellBuilder: (context, item) => Text(item.name),
  ),
  IxColumnDef<_MatrixItem>(
    label: 'Id',
    cellBuilder: (context, item) => Text(item.id),
  ),
];

final _matrixFields = [
  IxMobileFieldDef<_MatrixItem>(
    label: 'A very long field label that needs to ellipsize',
    valueBuilder: (context, item) => Text(item.name),
  ),
];

final _matrixActions = [
  IxRowAction<_MatrixItem>(
    id: 'edit',
    label: 'Edit',
    icon: const Icon(Icons.edit),
    onSelected: (_) {},
  ),
];

const _matrixPagination = IxPaginationConfig(
  mode: IxPaginationMode.standard,
  page: 2,
  totalPages: 5,
  pageSize: 20,
  totalItems: 100,
  pageSizeOptions: [10, 20, 50],
  showPaginationOnMobile: true,
);

void main() {
  const widths = [320.0, 360.0, 600.0, 768.0, 1024.0, 1440.0];
  const scales = [1.0, 1.3, 2.0];

  for (final w in widths) {
    for (final s in scales) {
      testWidgets('IxBlind ${w.toInt()}px × $s', (tester) async {
        await pumpIx(
          tester,
          const IxBlind(
            title: 'Long blind title that wraps',
            expanded: true,
            child: Text('x'),
          ),
          size: Size(w, 800),
          textScaler: TextScaler.linear(s),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('IxDropdownButton trigger ${w.toInt()}px × $s', (
        tester,
      ) async {
        await pumpIx(
          tester,
          IxDropdownButton<int>(
            label: 'Eine sehr lange Beschriftung für die Aktion',
            items: const [IxDropdownMenuItem(label: 'A', value: 1)],
          ),
          size: Size(w, 800),
          textScaler: TextScaler.linear(s),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('IxResponsiveDataView ${w.toInt()}px × $s', (tester) async {
        await pumpIx(
          tester,
          IxResponsiveDataView<_MatrixItem>(
            items: _matrixItems,
            desktopColumns: _matrixColumns,
            mobileFields: _matrixFields,
            rowActions: _matrixActions,
            enableSorting: true,
            onSortChanged: (_) {},
            onRowTapDesktop: (_) {},
            searchQuery: 'a rather long search phrase that stresses the chip',
            onClearSearch: () {},
            pagination: _matrixPagination,
            onPageChanged: (_) {},
            onPageSizeChanged: (_) {},
          ),
          size: Size(w, 800),
          textScaler: TextScaler.linear(s),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('IxPaginationBar ${w.toInt()}px × $s', (tester) async {
        await pumpIx(
          tester,
          IxPaginationBar(
            page: 2,
            totalPages: 5,
            totalItems: 100,
            pageSize: 20,
            pageSizeOptions: const [10, 20, 50],
            onPageChanged: (_) {},
            onPageSizeChanged: (_) {},
          ),
          size: Size(w, 800),
          textScaler: TextScaler.linear(s),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
