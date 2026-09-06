import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// The row model every example on this page uses.
class MyItem {
  const MyItem({required this.name, required this.status});

  final String name;
  final String status;
}

class MyDataView extends StatelessWidget {
  const MyDataView({super.key, required this.items});

  final List<MyItem> items;

  @override
  Widget build(BuildContext context) {
    return IxResponsiveDataView<MyItem>(
      items: items,
      // Define columns for Desktop/Tablet
      desktopColumns: [
        IxColumnDef(
          label: 'Name',
          flex: 2,
          cellBuilder: (context, item) => Text(item.name),
        ),
        IxColumnDef(
          label: 'Status',
          cellBuilder: (context, item) => Text(item.status),
        ),
      ],
      // Define fields for Mobile Cards
      mobileFields: [
        IxMobileFieldDef(
          label: 'Name',
          valueBuilder: (context, item) => Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IxMobileFieldDef(
          label: 'Status',
          valueBuilder: (context, item) => Text(item.status),
        ),
      ],
      // Define Actions (shared between layouts)
      rowActions: [
        IxRowAction(
          id: 'edit',
          label: 'Edit',
          icon: const Icon(Icons.edit),
          onSelected: (item) => debugPrint('Edit ${item.name}'),
        ),
        IxRowAction(
          id: 'delete',
          label: 'Delete',
          icon: const Icon(Icons.delete),
          destructive: true,
          onSelected: (item) => debugPrint('Delete ${item.name}'),
        ),
      ],
    );
  }
}

/// The column, field and action definitions from [MyDataView], reused by the
/// examples below.
List<IxColumnDef<MyItem>> demoColumns() => [
  IxColumnDef(
    label: 'Name',
    sortKey: 'name', // Key reported through onSortChanged
    cellBuilder: (context, item) => Text(item.name),
  ),
  IxColumnDef(
    label: 'Status',
    sortKey: 'status',
    cellBuilder: (context, item) => Text(item.status),
  ),
];

List<IxMobileFieldDef<MyItem>> demoMobileFields() => [
  IxMobileFieldDef(
    label: 'Name',
    valueBuilder: (context, item) => Text(item.name),
  ),
  IxMobileFieldDef(
    label: 'Status',
    valueBuilder: (context, item) => Text(item.status),
  ),
];

List<IxRowAction<MyItem>> demoRowActions() => [
  IxRowAction(
    id: 'edit',
    label: 'Edit',
    icon: const Icon(Icons.edit),
    onSelected: (item) => debugPrint('Edit ${item.name}'),
  ),
];

Widget standardPagination({
  required List<MyItem> currentItems,
  required int currentPage,
  required ValueChanged<int> onPageChanged,
  required ValueChanged<int> onPageSizeChanged,
}) => IxResponsiveDataView<MyItem>(
  items: currentItems,
  desktopColumns: demoColumns(),
  mobileFields: demoMobileFields(),
  rowActions: demoRowActions(),
  pagination: IxPaginationConfig(
    mode: IxPaginationMode.standard,
    page: currentPage, // Current page number (1-based)
    pageSize: 20, // Items per page
    totalItems: 100, // Total items in dataset
    totalPages: 5, // Total pages
    pageSizeOptions: const [10, 20, 50], // Options for dropdown
  ),
  onPageChanged: onPageChanged,
  onPageSizeChanged: onPageSizeChanged,
);

Widget localizedPaginationBar({
  required int page,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
}) => IxPaginationBar(
  page: page,
  totalPages: totalPages,
  onPageChanged: onPageChanged,
  paginationStrings: const IxPaginationStrings(
    previousPage: 'Back',
    nextPage: 'Forward',
    rowsPerPage: 'Rows per view',
    pageSelection: 'Choose rows per page',
  ),
);

Widget infiniteScroll({
  required List<MyItem> currentItems,
  required bool isFetchingMore,
  required Future<void> Function() fetchMoreItems,
}) => IxResponsiveDataView<MyItem>(
  items: currentItems,
  desktopColumns: demoColumns(),
  mobileFields: demoMobileFields(),
  rowActions: demoRowActions(),
  isPageLoading: isFetchingMore, // Show bottom spinner while loading
  pagination: const IxPaginationConfig(
    mode: IxPaginationMode.infinite,
    hasMore: true, // Set to false when no more data
  ),
  onLoadNextPage: () async {
    // Fetch next batch of items and append to list
    await fetchMoreItems();
  },
);

Widget sortableDataView({
  required List<MyItem> items,
  required ValueChanged<IxSortSpec> onSortChanged,
}) => IxResponsiveDataView<MyItem>(
  items: items,
  desktopColumns: demoColumns(),
  mobileFields: demoMobileFields(),
  rowActions: demoRowActions(),
  enableSorting: true,
  initialSortKey: 'name', // Initial sort column
  initialSortAscending: true, // Initial sort direction
  onSortChanged: onSortChanged,
);

Widget searchableDataView({
  required List<MyItem> filteredItems,
  required String currentSearchQuery,
  required VoidCallback onClearSearch,
  required VoidCallback onResetPagination,
}) => IxResponsiveDataView<MyItem>(
  items: filteredItems,
  desktopColumns: demoColumns(),
  mobileFields: demoMobileFields(),
  rowActions: demoRowActions(),
  searchQuery: currentSearchQuery, // The current search string
  onClearSearch: onClearSearch,
  // Optional: Customize the "No results" text
  noResultsTextBuilder: (query) => 'No items found for "$query"',
  // Optional: Reset pagination when the search changes
  searchAffectsPagination: true,
  onSearchChangedRequestResetPagination: onResetPagination,
);

Widget customMobileCard(List<MyItem> items) => IxResponsiveDataView<MyItem>(
  items: items,
  desktopColumns: demoColumns(),
  mobileFields: const [], // Can be empty if mobileItemBuilder is used
  rowActions: demoRowActions(),
  mobileItemBuilder: (context, item) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(item.status),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Actions',
          onPressed: () {
            // Show actions
          },
        ),
      ),
    );
  },
);

Widget dataViewWithStrings(List<MyItem> items) => IxResponsiveDataView<MyItem>(
  items: items,
  desktopColumns: demoColumns(),
  mobileFields: demoMobileFields(),
  rowActions: demoRowActions(),
  strings: const IxResponsiveDataViewStrings(
    emptyTitle: 'No data found',
    toolsColumnHeader: 'Actions',
  ),
);

Widget dataViewWithStringsResolver(List<MyItem> items) =>
    IxResponsiveDataView<MyItem>(
      items: items,
      desktopColumns: demoColumns(),
      mobileFields: demoMobileFields(),
      rowActions: demoRowActions(),
      stringsResolver: (context) {
        // Example: fetch from AppLocalizations
        // final l10n = AppLocalizations.of(context);
        return IxResponsiveDataViewStrings(
          emptyTitle: 'Localized Empty Title', // l10n.emptyTitle
          pageOfBuilder: (page, total) => 'Page $page / $total',
        );
      },
    );
