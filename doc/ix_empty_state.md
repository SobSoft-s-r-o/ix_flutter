# IxEmptyState

The `IxEmptyState` widget mirrors the Siemens iX `<ix-empty-state>` web component. It is used to communicate that there is currently no data, content, or result for a given view or context (e.g., an empty list, empty search result, first-time setup, or error state).

## Features

*   **Layout Variants**: Supports `large` (default), `compact`, and `compactBreak` layouts to adapt to different screen sizes and contexts.
*   **Customizable Content**: Supports a title, optional subtitle, and an optional leading icon.
*   **Actions**: Supports primary and secondary action widgets (typically buttons) to guide the user.
*   **Theming**: Fully integrated with `IxTheme` for consistent styling (colors, typography) across the application.
*   **Semantic Types**: Includes an `IxEmptyStateType` enum for future compatibility with semantic variants (neutral, info, warning, error, success).

## Usage

### Basic Example (Large Layout)

The default layout is `IxEmptyStateLayout.large`, which centers the content vertically and uses a larger icon.

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget largeEmptyState(VoidCallback onCreate) => IxEmptyState(
  icon: const IxIcon.key(IxIconKey.document),
  title: 'No elements available',
  subtitle: 'Create an element first',
  primaryAction: FilledButton(
    onPressed: onCreate,
    child: const Text('Create element'),
  ),
);
```

### Compact Layout

Use `IxEmptyStateLayout.compact` for a horizontal layout suitable for smaller spaces or lists.

```dart
Widget compactEmptyState(VoidCallback onClearSearch) => IxEmptyState(
  layout: IxEmptyStateLayout.compact,
  icon: const IxIcon.key(IxIconKey.search),
  title: 'No results found',
  subtitle: 'Try adjusting your search terms',
  primaryAction: FilledButton(
    onPressed: onClearSearch,
    child: const Text('Clear search'),
  ),
);
```

### Error State

You can specify the semantic type using `IxEmptyStateType`. While visually similar in the current version, this ensures semantic correctness.

```dart
Widget errorEmptyState(VoidCallback onRetry) => IxEmptyState(
  type: IxEmptyStateType.error,
  icon: const IxIcon.key(IxIconKey.error),
  title: 'Something went wrong',
  subtitle: 'Please try again later',
  primaryAction: FilledButton(onPressed: onRetry, child: const Text('Retry')),
);
```

## Properties

| Property | Type | Description | Default |
| :--- | :--- | :--- | :--- |
| `title` | `String` | The main headline text. | Required |
| `subtitle` | `String?` | Optional description text displayed below the title. | `null` |
| `icon` | `Widget?` | Optional icon widget displayed above (large) or beside (compact) the text. | `null` |
| `layout` | `IxEmptyStateLayout` | The visual layout variant (`large`, `compact`, `compactBreak`). | `large` |
| `type` | `IxEmptyStateType` | The semantic variant (`neutral`, `info`, `warning`, `error`, `success`). | `neutral` |
| `primaryAction` | `Widget?` | Primary action widget (e.g., a button). | `null` |
| `secondaryAction` | `Widget?` | Secondary action widget. | `null` |
