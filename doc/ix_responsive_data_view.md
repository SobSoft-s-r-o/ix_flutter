# IxResponsiveDataView

The `IxResponsiveDataView<T>` widget is a powerful, responsive data presentation component that automatically switches between a data table layout on desktop/tablet and a card-based list layout on mobile devices. It adheres to the Siemens iX design system and supports sorting, row actions, and advanced pagination modes.

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
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class MyDataView extends StatelessWidget {
  final List<MyItem> items;

  const MyDataView({super.key, required this.items});

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
          icon: IxIcons.pen,
          onSelected: (item) => print('Edit ${item.name}'),
        ),
        IxRowAction(
          id: 'delete',
          label: 'Delete',
          icon: IxIcons.trashcan,
          destructive: true,
          onSelected: (item) => print('Delete ${item.name}'),
        ),
      ],
    );
  }
}
```

### Pagination

The widget supports two pagination modes via the `pagination` parameter.

#### 1. Standard Pagination

Displays a pagination bar at the bottom of the table with page controls and optional page size selector.

```dart
IxResponsiveDataView<MyItem>(
  items: currentItems,
  pagination: IxPaginationConfig(
    mode: IxPaginationMode.standard,
    page: currentPage,       // Current page number (1-based)
    pageSize: 20,            // Items per page
    totalItems: 100,         // Total items in dataset
    totalPages: 5,           // Total pages
    pageSizeOptions: [10, 20, 50], // Options for dropdown
  ),
  onPageChanged: (newPage) {
    // Fetch new page and update state
  },
  onPageSizeChanged: (newSize) {
    // Update page size and reset to page 1
  },
  // ...
)
```

#### 2. Infinite Scroll

Automatically triggers a callback when the user scrolls near the bottom of the list.

```dart
IxResponsiveDataView<MyItem>(
  items: currentItems,
  isPageLoading: isFetchingMore, // Show bottom spinner while loading
  pagination: IxPaginationConfig(
    mode: IxPaginationMode.infinite,
    hasMore: true, // Set to false when no more data
  ),
  onLoadNextPage: () async {
    // Fetch next batch of items and append to list
    await fetchMoreItems();
  },
  // ...
)
```

### Sorting

Enable sorting by setting `enableSorting: true` and providing `sortKey` in `IxColumnDef`.

```dart
IxResponsiveDataView<MyItem>(
  items: items,
  enableSorting: true,
  onSortChanged: (IxSortSpec sortSpec) {
    // Perform sorting logic here based on sortSpec.key and sortSpec.ascending
    // e.g. items.sort(...) or fetchSortedData(...)
  },
  desktopColumns: [
    IxColumnDef(
      label: 'Name',
      sortKey: 'name', // Key passed to onSortChanged
      cellBuilder: (context, item) => Text(item.name),
    ),
    // ...
  ],
  // ...
)
```

## API Reference

### IxResponsiveDataView

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `items` | `List<T>` | The list of data items to display. |
| `desktopColumns` | `List<IxColumnDef<T>>` | Configuration for table columns (Desktop/Tablet). |
| `mobileFields` | `List<IxMobileFieldDef<T>>` | Configuration for card fields (Mobile). |
| `rowActions` | `List<IxRowAction<T>>` | List of actions available for each item. |
| `isLoading` | `bool` | Whether the initial data is loading (shows full spinner). |
| `isPageLoading` | `bool` | Whether the next page is loading (shows bottom spinner). |
| `pagination` | `IxPaginationConfig?` | Configuration for pagination behavior. |
| `onLoadNextPage` | `Future<void> Function()?` | Callback for infinite scroll loading. |
| `onPageChanged` | `ValueChanged<int>?` | Callback for standard pagination page change. |
| `onPageSizeChanged` | `ValueChanged<int>?` | Callback for standard pagination page size change. |
| `enableSorting` | `bool` | Enables sorting UI on column headers. |
| `onSortChanged` | `ValueChanged<IxSortSpec>?` | Callback when a sortable header is clicked. |

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
