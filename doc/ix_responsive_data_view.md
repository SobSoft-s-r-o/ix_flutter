# IxResponsiveDataView

The `IxResponsiveDataView<T>` widget is a powerful, responsive data presentation component that automatically switches between a data table layout on desktop/tablet and a card-based list layout on mobile devices. It adheres to the Siemens iX design system and supports sorting, row actions, and advanced pagination modes.

## Flutter-specific composite

`IxResponsiveDataView` is a **Flutter-specific composite**, not a 1:1 port of a
single upstream `@siemens/ix` web component: it combines a table, a card
list, a search status bar and pagination into one widget. Upstream's closest
equivalent, `.ix-table`, is a utility style (not a component) that was moved
from `src/components/table/table.scss` to `scss/utilities/_table.scss` in
[PR #2632](https://github.com/siemens/ix/pull/2632) (commit
`0c952102075ef40aa5768488efe0198af143719a`), targeting the upcoming v6 -- it
was relocated, not deleted. This widget mirrors that utility's tokens
(`color-0`/`soft-bdr`/`weak-bdr`/`ghost-hover`) for its table/row/card
surfaces, and its own `IxPaginationBar` mirrors `ix-pagination`
(`pagination.tsx`).

A 2.0 milestone (internally tracked as "B-9") splits this composite into
smaller primitives -- `IxTable`, `IxDataCard`, `IxRowActions` and friends --
and moves the desktop/mobile breakpoint from 600px to 768px. Until then,
`IxResponsiveDataView` stays as the single entry point, and the breakpoint
stays at 600px for 1.x compatibility.

## Keyboard and screen reader

Every interactive part of `IxResponsiveDataView` is reachable by keyboard,
in this order:

1. The search status bar's clear button (`ix-rdv-clear`), when a search
   query is shown.
2. Each sortable column header (`ix-rdv-header-<sortKey>`), left to right.
3. Each row (`ix-rdv-row-<index>`) -- only focusable when
   `onRowTapDesktop` is set -- followed by that row's actions trigger
   (`ix-rdv-row-actions-<index>`).
4. The pagination bar's page-size selector (`ix-pagination-size`, when
   shown), then the previous/next chevrons (`ix-pagination-prev` /
   `ix-pagination-next`).

A sortable column header is a real button: `Enter`/`Space` toggle its sort
direction exactly like a tap, and it exposes a semantics hint so a screen
reader announces what activating it does -- `IxResponsiveDataViewStrings
.sortHint` ("Sort") when the column isn't the active sort key, or
`.sortedAscending`/`.sortedDescending` ("Sorted ascending"/"Sorted
descending") once it is. A mobile card (which always opens a details sheet
on tap) similarly exposes `.rowHint` ("Open row"). All four strings default
to English and can be overridden the same way as every other
`IxResponsiveDataViewStrings` field.

`IxPaginationBar`'s own controls -- including the pagination bar
`IxResponsiveDataView` renders internally -- are labelled through
[`IxPaginationStrings`](#ixpaginationstrings) (below): the previous/next
chevrons and the page-size selector all carry an accessible name, and the
selector additionally exposes its current value and expanded state.

## Features

*   **Responsive Layout**: Automatically renders a table on screens >= 600px and a card list on smaller screens.
*   **Generic Data Support**: Works with any data model `T`.
*   **Siemens iX Theming**: Fully integrated with `IxTheme` for colors, typography, and spacing.
*   **Row Actions**: Supports a unified list of actions (Edit, Delete, etc.) that appear in a dropdown menu on desktop and a bottom sheet on mobile.
*   **Sorting**: Built-in UI support for column sorting (logic delegated to parent).
*   **Pagination**: Supports both **Standard** (page numbers/controls) and **Infinite Scroll** pagination modes.
*   **Empty & Loading States**: Built-in support for loading spinners and empty state messages.

## Usage

### Basic Example

```dart
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
```

### Shared definitions

Every example below reuses the same column, field and action definitions:

```dart
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
```

### Pagination

The widget supports two pagination modes via the `pagination` parameter.

#### 1. Standard Pagination

Displays a pagination bar at the bottom of the table with page controls and optional page size selector.

```dart
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
```

The pagination bar lays its controls out with a `Wrap` instead of a plain
`Row`, so at a narrow width or a large text scale the page-size selector and
the prev/next controls drop to their own line instead of overflowing (WCAG
1.4.4 Resize text); it never shrinks below a 56px minimum height. Its
chevrons are 32px `IxIconButton`s.

##### IxPaginationStrings

`IxPaginationBar` (and the pagination bar `IxResponsiveDataView` renders
internally) can be localized directly through `paginationStrings`, without
touching `IxResponsiveDataViewStrings`:

```dart
Widget localizedPaginationBar({
  required int page,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
}) => IxPaginationBar(
  page: page,
  totalPages: totalPages,
  onPageChanged: onPageChanged,
  paginationStrings: const IxPaginationStrings(
    previousPage: 'Predchádzajúca strana',
    nextPage: 'Ďalšia strana',
    rowsPerPage: 'Položiek na stranu',
    pageSelection: 'Výber strany',
  ),
);
```

`paginationStrings` takes precedence over the legacy `strings:`
(`IxResponsiveDataViewStrings`) parameter, which is still accepted and
bridged via `IxPaginationStrings.fromDataView` for 1.x callers that never
migrated. When `IxResponsiveDataView` renders its own pagination bar, it
still only exposes `strings:` -- pass an `IxResponsiveDataViewStrings` with
the matching fields overridden (`paginationPrevTooltip`,
`paginationNextTooltip`, `rowsPerPageLabel`, `pageOfBuilder`, `pageBuilder`,
`totalItemsBuilder`) to localize it from there.

#### 2. Infinite Scroll

Automatically triggers a callback when the user scrolls near the bottom of the list.

```dart
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
```

### Sorting

Enable sorting by setting `enableSorting: true` and providing `sortKey` in `IxColumnDef`. You can also set the initial sort state using `initialSortKey` and `initialSortAscending`.

```dart
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
```

### Search / Filtering

The widget provides a built-in search status bar and empty state handling for search results.

```dart
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
```

### Custom Mobile Card

By default, `IxResponsiveDataView` generates a card layout for mobile using `mobileFields`. You can override this by providing a `mobileItemBuilder`.

```dart
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
```

### Localization

All user-visible strings in the widget can be localized. You can provide a `IxResponsiveDataViewStrings` object directly or use a resolver function to fetch strings from your app's localization layer.

#### 1. Per-widget Override

```dart
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
```

#### 2. Context-based Resolver (Recommended)

This approach allows you to integrate with `AppLocalizations` or any other localization solution.

```dart
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
```

## API Reference

### IxResponsiveDataView

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `items` | `List<T>` | The list of data items to display. |
| `desktopColumns` | `List<IxColumnDef<T>>` | Configuration for table columns (Desktop/Tablet). |
| `mobileFields` | `List<IxMobileFieldDef<T>>` | Configuration for card fields (Mobile). |
| `mobileItemBuilder` | `Widget Function(BuildContext, T)?` | Optional custom builder for mobile items, overriding `mobileFields`. |
| `rowActions` | `List<IxRowAction<T>>` | List of actions available for each item. |
| `rowKey` | `String Function(T item)?` | Stable identifier for an item. Accepted, but not read by the current rendering; it is the hook the 2.0 primitives split (`IxTable`/`IxDataCard`) will key rows by. |
| `onRowTapDesktop` | `void Function(T item)?` | Called when a table row is activated on desktop. A row is only focusable and keyboard-activatable when this is set. |
| `isLoading` | `bool` | Whether the initial data is loading (shows full spinner). |
| `isPageLoading` | `bool` | Whether the next page is loading (shows bottom spinner). |
| `pagination` | `IxPaginationConfig?` | Configuration for pagination behavior. |
| `onLoadNextPage` | `Future<void> Function()?` | Callback for infinite scroll loading. |
| `onPageChanged` | `ValueChanged<int>?` | Callback for standard pagination page change. |
| `onPageSizeChanged` | `ValueChanged<int>?` | Callback for standard pagination page size change. |
| `enableSorting` | `bool` | Enables sorting UI on column headers. |
| `onSortChanged` | `ValueChanged<IxSortSpec>?` | Callback when a sortable header is clicked. |
| `initialSortKey` | `String?` | The initial sort key to display as active. |
| `initialSortAscending` | `bool` | The initial sort direction (default true). |
| `searchQuery` | `String?` | The current search query to display in the status bar. |
| `onClearSearch` | `VoidCallback?` | Callback when the "Clear search" button is clicked. |
| `searchHintText` | `String?` | Hint text for the search field (if integrated). |
| `showSearchStatusBar` | `bool` | Whether to show the search status bar (default true). |
| `showSearchClearAction` | `bool` | Whether to show the clear action in the status bar (default true). |
| `searchAffectsPagination` | `bool` | Whether search changes should trigger pagination reset callbacks (default true). |
| `onSearchChangedRequestResetPagination` | `VoidCallback?` | Callback to reset pagination when search changes. |
| `resultsCountOverride` | `int?` | Override the displayed result count (defaults to `items.length` or `pagination.totalItems`). |
| `resultsLabelBuilder` | `String Function(int)?` | Custom builder for the results count label. |
| `noResultsTextBuilder` | `String Function(String)?` | Custom builder for the "No results" empty state title. |
| `strings` | `IxResponsiveDataViewStrings?` | Optional strings override for this widget instance. |
| `stringsResolver` | `IxResponsiveDataViewStrings Function(BuildContext)?` | Optional resolver to fetch strings from context. |

### IxPaginationConfig

| Property | Type | Description |
| :--- | :--- | :--- |
| `mode` | `IxPaginationMode` | `none`, `standard`, or `infinite`. |
| `page` | `int?` | Current page number (Standard). |
| `pageSize` | `int?` | Number of items per page (Standard). |
| `totalItems` | `int?` | Total number of items (Standard). |
| `totalPages` | `int?` | Total number of pages (Standard). |
| `pageSizeOptions` | `List<int>?` | Options for page size dropdown (Standard). |
| `hasMore` | `bool?` | Whether more items are available (Infinite). |
| `loadMoreThresholdPx` | `double` | Scroll threshold to trigger load (Infinite). |
| `showPaginationOnMobile` | `bool` | Whether to show standard pagination on mobile (default false). |
