import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../helpers/pump_ix.dart';

/// Icons the library hands to a slot that already styles them.
///
/// `IxIcon` follows the ambient `IconTheme` when it is given no `size:`, so
/// a widget that styles its own icon slot must not also pin a size on the
/// icon it puts there -- doing so overrides the slot and produces the wrong
/// visual (an empty-state glyph at 32px inside a 56px slot, a breadcrumb
/// home icon at 16px inside an 18px one).

IxResponsiveDataView<int> _emptyView({String? searchQuery}) =>
    IxResponsiveDataView<int>(
      items: const [],
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
      searchQuery: searchQuery,
    );

void main() {
  testWidgets('the data view empty state fills its 56px slot', (tester) async {
    await pumpIx(tester, _emptyView(), size: const Size(1024, 768));
    expect(tester.getSize(find.byType(IxIcon)).width, 56);
  });

  testWidgets('the data view no-results state fills its 56px slot', (
    tester,
  ) async {
    await pumpIx(
      tester,
      _emptyView(searchQuery: 'zzz'),
      size: const Size(1024, 768),
    );
    expect(tester.getSize(find.byType(IxIcon)).width, 56);
  });

  testWidgets('a compact empty state still fills its 32px slot', (
    tester,
  ) async {
    await pumpIx(
      tester,
      const IxEmptyState(
        layout: IxEmptyStateLayout.compact,
        icon: IxIcon.key(IxIconKey.info),
        title: 'Nothing here',
      ),
    );
    expect(tester.getSize(find.byType(IxIcon)).width, 32);
  });

  testWidgets('the breadcrumb home icon fills its 18px slot', (tester) async {
    await pumpIx(
      tester,
      const IxBreadcrumb(
        items: [
          IxBreadcrumbItemData(label: 'Home', breadcrumbKey: 'home'),
          IxBreadcrumbItemData(label: 'Leaf', breadcrumbKey: 'leaf'),
        ],
      ),
    );
    expect(tester.getSize(find.byType(IxIcon).first).width, 18);
  });
}
