import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'helpers/pump_ix.dart';

class TestItem {
  final int id;
  final String name;

  TestItem(this.id, this.name);
}

/// Asserts that the currently focused widget lives inside the widget
/// identified by [key] -- used to walk the Tab order without depending on
/// exactly which internal widget (e.g. the `InkWell`) ends up owning the
/// platform focus node.
void expectFocusWithin(WidgetTester tester, Key key) {
  final ctx = FocusManager.instance.primaryFocus?.context;
  expect(ctx, isNotNull, reason: 'nothing focused');
  expect(
    find.ancestor(of: find.byWidget(ctx!.widget), matching: find.byKey(key)),
    findsOneWidget,
    reason: 'focus is not inside $key',
  );
}

void main() {
  final List<TestItem> testItems = List.generate(
    20,
    (index) => TestItem(index, 'Item $index'),
  );

  final desktopColumns = [
    IxColumnDef<TestItem>(
      label: 'ID',
      cellBuilder: (context, item) => Text('${item.id}'),
    ),
    IxColumnDef<TestItem>(
      label: 'Name',
      cellBuilder: (context, item) => Text(item.name),
    ),
  ];

  final mobileFields = [
    IxMobileFieldDef<TestItem>(
      label: 'Name',
      valueBuilder: (context, item) => Text(item.name),
    ),
  ];

  final sortableDesktopColumns = [
    IxColumnDef<TestItem>(
      label: 'ID',
      cellBuilder: (context, item) => Text('${item.id}'),
      sortKey: 'id',
    ),
    IxColumnDef<TestItem>(
      label: 'Name',
      cellBuilder: (context, item) => Text(item.name),
      sortKey: 'name',
    ),
  ];

  Widget buildTestWidget({
    required List<TestItem> items,
    List<IxColumnDef<TestItem>>? columns,
    IxPaginationConfig? pagination,
    Future<void> Function()? onLoadNextPage,
    void Function(int)? onPageChanged,
    String? searchQuery,
    VoidCallback? onClearSearch,
    bool enableSorting = false,
    void Function(IxSortSpec)? onSortChanged,
  }) {
    final theme = IxThemeBuilder(
      family: IxThemeFamily.classic,
      mode: ThemeMode.light,
      systemBrightness: Brightness.light,
    ).build();

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        body: IxResponsiveDataView<TestItem>(
          items: items,
          desktopColumns: columns ?? desktopColumns,
          mobileFields: mobileFields,
          rowActions: [],
          pagination: pagination,
          onLoadNextPage: onLoadNextPage,
          onPageChanged: onPageChanged,
          searchQuery: searchQuery,
          onClearSearch: onClearSearch,
          enableSorting: enableSorting,
          onSortChanged: onSortChanged,
        ),
      ),
    );
  }

  group('IxResponsiveDataView Tests', () {
    testWidgets('renders without pagination', (WidgetTester tester) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestWidget(items: testItems));

      // Verify items are displayed
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);

      // Verify no pagination bar
      expect(find.byType(IxPaginationBar), findsNothing);
    });

    testWidgets('renders with standard pagination', (
      WidgetTester tester,
    ) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      int? requestedPage;

      await tester.pumpWidget(
        buildTestWidget(
          items: testItems.take(5).toList(),
          pagination: const IxPaginationConfig(
            mode: IxPaginationMode.standard,
            page: 1,
            pageSize: 5,
            totalItems: 20,
            totalPages: 4,
          ),
          onPageChanged: (page) {
            requestedPage = page;
          },
        ),
      );

      // Verify pagination bar is present
      expect(find.byType(IxPaginationBar), findsOneWidget);
      expect(find.text('Page 1 of 4'), findsOneWidget);

      // Tap next page
      await tester.tap(find.byTooltip('Next page'));
      await tester.pump();

      expect(requestedPage, 2);
    });

    testWidgets('renders with infinite scroll', (WidgetTester tester) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      bool loadMoreCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          items: testItems,
          pagination: const IxPaginationConfig(
            mode: IxPaginationMode.infinite,
            hasMore: true,
          ),
          onLoadNextPage: () async {
            loadMoreCalled = true;
          },
        ),
      );

      // Verify no pagination bar
      expect(find.byType(IxPaginationBar), findsNothing);

      // Scroll to bottom to trigger load more
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -1000));
      await tester.pump();

      // Note: Triggering infinite scroll in test might require more precise scrolling or mocking
      // For now, we check if the list is scrollable and setup is correct.
      // In a real infinite scroll implementation, we'd expect onLoadNextPage to be called.
      // However, IxResponsiveDataView's infinite scroll logic depends on ScrollController listeners
      // which might need a frame or two.

      // Let the scroll controller process and ensure load more is requested.
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(loadMoreCalled, isTrue);
    });

    testWidgets('renders with search query', (WidgetTester tester) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      bool clearSearchCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          items: testItems,
          searchQuery: 'Item',
          onClearSearch: () {
            clearSearchCalled = true;
          },
        ),
      );

      expect(find.text('Filtered by: "Item"'), findsOneWidget);
      expect(find.text('Results: 20'), findsOneWidget);
      expect(clearSearchCalled, isFalse);
    });

    testWidgets('renders empty state with search', (WidgetTester tester) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      bool clearSearchCalled = false;

      await tester.pumpWidget(
        buildTestWidget(
          items: [],
          searchQuery: 'NonExistent',
          onClearSearch: () {
            clearSearchCalled = true;
          },
        ),
      );

      expect(find.text('No results for "NonExistent"'), findsOneWidget);
      expect(find.text('Clear search'), findsOneWidget);

      await tester.tap(find.text('Clear search'));
      expect(clearSearchCalled, true);
    });

    testWidgets('renders empty state without search', (
      WidgetTester tester,
    ) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestWidget(items: []));

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('sorting works without pagination', (
      WidgetTester tester,
    ) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      IxSortSpec? lastSortSpec;

      await tester.pumpWidget(
        buildTestWidget(
          items: testItems,
          columns: sortableDesktopColumns,
          enableSorting: true,
          onSortChanged: (sortSpec) {
            lastSortSpec = sortSpec;
          },
        ),
      );

      // Tap on ID column header to sort
      await tester.tap(find.text('ID'));
      await tester.pump();

      // Default sort is usually ascending, tapping again might toggle or set specific order
      // Based on implementation:
      // final newAscending = _sortKey == key ? !_sortAscending : true;
      // Initial state: _sortKey = null, _sortAscending = true
      // First tap: key='id', ascending=true

      expect(lastSortSpec?.key, 'id');
      expect(lastSortSpec?.ascending, true);

      // Tap again to toggle
      await tester.tap(find.text('ID'));
      await tester.pump();

      expect(lastSortSpec?.key, 'id');
      expect(lastSortSpec?.ascending, false);
    });

    testWidgets('sorting works with standard pagination', (
      WidgetTester tester,
    ) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      IxSortSpec? lastSortSpec;

      await tester.pumpWidget(
        buildTestWidget(
          items: testItems.take(5).toList(),
          columns: sortableDesktopColumns,
          enableSorting: true,
          onSortChanged: (sortSpec) {
            lastSortSpec = sortSpec;
          },
          pagination: const IxPaginationConfig(
            mode: IxPaginationMode.standard,
            page: 1,
            pageSize: 5,
            totalItems: 20,
            totalPages: 4,
          ),
        ),
      );

      // Tap on Name column header to sort
      await tester.tap(find.text('Name'));
      await tester.pump();

      expect(lastSortSpec?.key, 'name');
      expect(lastSortSpec?.ascending, true);
    });

    testWidgets('sorting works with infinite pagination', (
      WidgetTester tester,
    ) async {
      // Set screen size to desktop
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      IxSortSpec? lastSortSpec;

      await tester.pumpWidget(
        buildTestWidget(
          items: testItems,
          columns: sortableDesktopColumns,
          enableSorting: true,
          onSortChanged: (sortSpec) {
            lastSortSpec = sortSpec;
          },
          pagination: const IxPaginationConfig(
            mode: IxPaginationMode.infinite,
            hasMore: true,
          ),
        ),
      );

      // Tap on ID column header to sort
      await tester.tap(find.text('ID'));
      await tester.pump();

      expect(lastSortSpec?.key, 'id');
      expect(lastSortSpec?.ascending, true);
    });
  });

  group('IxResponsiveDataView keyboard focus and sort semantics (A-4)', () {
    // No upstream counterpart: `@siemens/ix` has no table component (and
    // therefore no `table.ct.ts`) -- `IxResponsiveDataView` is a
    // Flutter-specific composite (see `doc/ix_responsive_data_view.md`,
    // "Flutter-specific composite"). This guards WCAG 2.4.3 (focus order)
    // per finding IXF-002 ("RDV focusability", spec
    // `2026-09-04-ix-flutter-2-0-design.md`, task A-4).
    testWidgets(
      'Tab order: clear → headers → rows → row actions → pagination',
      (tester) async {
        await pumpIx(
          tester,
          IxResponsiveDataView<TestItem>(
            items: testItems.take(2).toList(),
            desktopColumns: sortableDesktopColumns,
            mobileFields: mobileFields,
            enableSorting: true,
            onSortChanged: (_) {},
            onRowTapDesktop: (_) {},
            rowActions: [
              IxRowAction<TestItem>(
                id: 'edit',
                label: 'Edit',
                icon: const Icon(Icons.edit),
                onSelected: (_) {},
              ),
            ],
            searchQuery: 'Item',
            onClearSearch: () {},
            // `page: 2` (not 1): a disabled Material button is excluded
            // from focus traversal, so page 1 would make "previous page"
            // unreachable by Tab and contradict this test's own premise
            // that it is one of the expected stops.
            pagination: const IxPaginationConfig(
              mode: IxPaginationMode.standard,
              page: 2,
              totalPages: 3,
              pageSize: 10,
              pageSizeOptions: [10, 20],
            ),
            onPageChanged: (_) {},
            onPageSizeChanged: (_) {},
          ),
          size: const Size(1024, 768),
        );
        final expected = <Key>[
          const Key('ix-rdv-clear'),
          const Key('ix-rdv-header-id'),
          const Key('ix-rdv-header-name'),
          const Key('ix-rdv-row-0'),
          const Key('ix-rdv-row-actions-0'),
          const Key('ix-rdv-row-1'),
          const Key('ix-rdv-row-actions-1'),
          const Key('ix-pagination-size'),
          const Key('ix-pagination-prev'),
          const Key('ix-pagination-next'),
        ];
        for (final key in expected) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expectFocusWithin(tester, key);
        }
      },
    );

    testWidgets(
      'sortable header is a button with sort hint and toggles on Enter',
      (tester) async {
        final handle = tester.ensureSemantics();
        IxSortSpec? spec;
        await pumpIx(
          tester,
          buildTestWidget(
            items: testItems,
            columns: sortableDesktopColumns,
            enableSorting: true,
            onSortChanged: (s) => spec = s,
          ),
          size: const Size(1024, 768),
        );
        expect(
          tester.getSemantics(find.byKey(const Key('ix-rdv-header-name'))),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Name',
            hint: 'Sort',
          ),
        );
        // One Tab reaches the first sortable header ("id", the leftmost
        // column in `sortableDesktopColumns`). Its semantics node must
        // report `isFocused` once actually focused -- InkWell's own focus
        // state has to merge into the labelled node, not be swallowed by
        // an `excludeSemantics` that spans the whole header (WCAG 2.4.7:
        // a screen reader user must be able to tell the header is
        // focused, not just that it is focusable).
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          tester.getSemantics(find.byKey(const Key('ix-rdv-header-id'))),
          isSemantics(isFocused: true),
        );
        await tester.tap(find.byKey(const Key('ix-rdv-header-name')));
        await tester.pump();
        expect(spec, const IxSortSpec(key: 'name', ascending: true));
        expect(
          tester.getSemantics(find.byKey(const Key('ix-rdv-header-name'))).hint,
          'Sorted ascending',
        );
        handle.dispose();
      },
    );

    testWidgets('a non-sortable header is a plain label, not a disabled '
        'control', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpIx(
        tester,
        // `enableSorting` is off, so every heading is a plain label even
        // though the columns declare a sortKey.
        buildTestWidget(items: testItems, columns: sortableDesktopColumns),
        size: const Size(1024, 768),
      );
      expect(
        tester.getSemantics(find.text('Name').first),
        isSemantics(hasEnabledState: false, isButton: false, label: 'Name'),
      );
      handle.dispose();
    });

    testWidgets('rows are focusable buttons only when onRowTapDesktop is set', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpIx(
        tester,
        buildTestWidget(items: testItems.take(1).toList()),
        size: const Size(1024, 768),
      );
      expect(
        tester
            .getSemantics(find.byKey(const Key('ix-rdv-row-0')))
            .flagsCollection
            .isButton,
        isFalse,
      );
      handle.dispose();
    });

    testWidgets(
      'search status header results label does not overflow with a long custom builder',
      (tester) async {
        await pumpIx(
          tester,
          IxResponsiveDataView<TestItem>(
            items: testItems,
            desktopColumns: desktopColumns,
            mobileFields: mobileFields,
            rowActions: const [],
            searchQuery: 'q',
            onClearSearch: () {},
            strings: IxResponsiveDataViewStrings(
              resultsCountBuilder: (c) =>
                  'Insgesamt $c Ergebnisse in dieser Ansicht gefunden',
            ),
          ),
          size: const Size(620, 800),
          textScaler: const TextScaler.linear(2.0),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
