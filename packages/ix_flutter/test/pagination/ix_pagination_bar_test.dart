import 'package:flutter/material.dart';
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
            // alongside `tap` -- real, additive assistive-tech behaviour
            // (not asserted by the RDV header/row cases, which own their
            // semantics outright via `excludeSemantics`).
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
}
