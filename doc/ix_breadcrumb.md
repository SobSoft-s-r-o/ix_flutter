# IxBreadcrumb

Navigation component that displays the current page location within a hierarchical structure and provides quick navigation to parent levels. Follows the IX Design System breadcrumb specifications.

## Overview

`IxBreadcrumb` provides contextual navigation showing the user's position in the app hierarchy. It automatically adapts to available space by collapsing overflow items into a dropdown menu and supports both forward and backward navigation through the hierarchy.

## Features

- 🗺️ Hierarchical path visualization
- 📦 Automatic overflow handling
- 🎨 Multiple button appearance styles
- 🏠 Customizable home icon
- ⬇️ Optional child navigation menu
- 📱 Responsive layout adaptation
- ♿ Full accessibility support

## Basic Usage

```dart
import 'package:ix_flutter/ix_flutter.dart';

IxBreadcrumb(
  items: [
    IxBreadcrumbItemData(label: 'Home', icon: IxIcons.home),
    const IxBreadcrumbItemData(label: 'Products'),
    const IxBreadcrumbItemData(label: 'Electronics'),
    const IxBreadcrumbItemData(label: 'Laptops'),
  ],
  onItemPressed: (item) {
    // Navigate to the selected level
    print('Navigate to: ${item.label}');
  },
)
```

## Item Configuration

### IxBreadcrumbItemData

Represents a single level in the navigation hierarchy.

```dart
IxBreadcrumbItemData(
  label: 'Manufacturing',       // Required: Display text
  breadcrumbKey: 'manufacturing', // Recommended: stable identifier
  icon: IxIcons.factory,        // Optional: Leading icon
)
```

`breadcrumbKey` is the identifier reported through `onItemClick`/
`onNextClick` (see below) and falls back to `label` when omitted -- which
is only safe as long as no two items share the same label. A missing
`breadcrumbKey` also prints a one-time debug notice, since it becomes a
required parameter starting with ix_flutter 2.0.

### With Navigation Menu

Add child destinations to the last breadcrumb item:

```dart
IxBreadcrumb(
  items: [
    IxBreadcrumbItemData(label: 'Home', icon: IxIcons.home),
    const IxBreadcrumbItemData(label: 'Settings'),
  ],
  nextItems: [
    IxBreadcrumbMenuItem(label: 'General'),
    IxBreadcrumbMenuItem(label: 'Privacy'),
    IxBreadcrumbMenuItem(label: 'Security'),
  ],
  onNextItemPressed: (menuItem) {
    // Navigate to child page
    print('Navigate to: ${menuItem.label}');
  },
)
```

## Appearance Styles

### Tertiary (Default)
Subtle, low-emphasis breadcrumbs suitable for most interfaces.

```dart
IxBreadcrumb(
  items: myItems,
  buttonAppearance: IxBreadcrumbButtonAppearance.tertiary,
)
```

### Subtle Primary
More prominent breadcrumbs using the primary brand color.

```dart
IxBreadcrumb(
  items: myItems,
  buttonAppearance: IxBreadcrumbButtonAppearance.subtlePrimary,
)
```

## Overflow Handling

Control how many items remain visible before collapsing into the overflow menu:

```dart
IxBreadcrumb(
  items: longPathItems,
  visibleItemCount: 4,  // Show up to 4 items, collapse rest
)
```

The component automatically calculates the best fit based on available width. Items beyond the visible count collapse into a dropdown menu at the start of the path.

## Home Button Customization

### Custom Home Icon

```dart
IxBreadcrumb(
  items: myItems,
  homeIcon: Icon(Icons.dashboard),
)
```

### Show Home Label

```dart
IxBreadcrumb(
  items: myItems,
  showHomeLabel: true,  // Shows the label text next to home icon
)
```

### Disable Navigation Menu

```dart
IxBreadcrumb(
  items: myItems,
  showNavigationMenu: false,  // Home button won't show dropdown
)
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `items` | `List<IxBreadcrumbItemData>` | required | Ordered breadcrumb path items |
| `visibleItemCount` | `int` | `9` | Max visible items before overflow |
| `buttonAppearance` | `IxBreadcrumbButtonAppearance` | `tertiary` | Visual style of breadcrumb buttons |
| `nextItems` | `List<IxBreadcrumbMenuItem>` | `[]` | Child destinations menu for last item |
| `onItemPressed` | `ValueChanged<IxBreadcrumbItemData>?` | `null` | Callback when item is tapped |
| `onItemClick` | `ValueChanged<IxBreadcrumbClick>?` | `null` | Stable-key callback fired alongside `onItemPressed` |
| `onNextItemPressed` | `ValueChanged<IxBreadcrumbMenuItem>?` | `null` | Callback when next menu item is tapped |
| `onNextClick` | `ValueChanged<IxBreadcrumbClick>?` | `null` | Stable-key callback fired alongside `onNextItemPressed` |
| `homeIcon` | `Widget?` | `null` | Custom icon for home button |
| `showHomeLabel` | `bool` | `false` | Show label text next to home icon |
| `showNavigationMenu` | `bool` | `true` | Enable navigation menu on home button |
| `previousItemsLabel` | `String` | `'Previous levels'` | Semantic label for the popup route announced when the overflow menu opens |
| `homeMenuLabel` | `String` | `'Navigate to level'` | Semantic label for the popup route announced when the home navigation menu opens |
| `semanticLabel` | `String?` | `null` | Overall semantic description; overrides `strings.breadcrumbs` |
| `strings` | `IxBreadcrumbStrings` | English copy | Localizable strings for the landmark, overflow trigger and current-page hint |

## Common Patterns

### Basic Navigation Path

```dart
class ProductDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IxBreadcrumb(
            items: [
              IxBreadcrumbItemData(label: 'Home', icon: IxIcons.home),
              const IxBreadcrumbItemData(label: 'Products'),
              const IxBreadcrumbItemData(label: 'Widget Pro'),
            ],
            onItemPressed: (item) {
              Navigator.of(context).popUntil((route) {
                // Navigate back to selected level
                return route.settings.name == item.label;
              });
            },
          ),
          // Page content
        ],
      ),
    );
  }
}
```

### Deep Hierarchy with Overflow

```dart
IxBreadcrumb(
  items: [
    IxBreadcrumbItemData(label: 'Home', icon: IxIcons.home),
    const IxBreadcrumbItemData(label: 'Manufacturing'),
    const IxBreadcrumbItemData(label: 'Production Lines'),
    const IxBreadcrumbItemData(label: 'Line 04'),
    const IxBreadcrumbItemData(label: 'Station A'),
    const IxBreadcrumbItemData(label: 'Inspection'),
  ],
  visibleItemCount: 3,  // Only show 3 items, rest in overflow
  buttonAppearance: IxBreadcrumbButtonAppearance.subtlePrimary,
  onItemPressed: (item) => _navigateToLevel(item.label),
)
```

### With Child Navigation

```dart
IxBreadcrumb(
  items: [
    IxBreadcrumbItemData(label: 'Home', icon: IxIcons.home),
    const IxBreadcrumbItemData(label: 'Settings'),
  ],
  nextItems: [
    IxBreadcrumbMenuItem(label: 'Account'),
    IxBreadcrumbMenuItem(label: 'Privacy'),
    IxBreadcrumbMenuItem(label: 'Notifications'),
    IxBreadcrumbMenuItem(label: 'Display'),
  ],
  onItemPressed: (item) => _goBack(item),
  onNextItemPressed: (item) => _navigateForward(item),
)
```

### Responsive Breadcrumb

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final visibleCount = constraints.maxWidth < 600 ? 2 : 4;
    return IxBreadcrumb(
      items: breadcrumbPath,
      visibleItemCount: visibleCount,
      showHomeLabel: constraints.maxWidth > 800,
    );
  },
)
```

## Integration with Router

### Using with go_router

```dart
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({required this.currentPath});
  
  final String currentPath;
  
  @override
  Widget build(BuildContext context) {
    final items = _buildBreadcrumbsFromPath(currentPath);
    
    return IxBreadcrumb(
      items: items,
      onItemPressed: (item) {
        context.go(item.label);  // Assuming label matches route
      },
    );
  }
  
  List<IxBreadcrumbItemData> _buildBreadcrumbsFromPath(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    return [
      IxBreadcrumbItemData(label: 'Home', icon: IxIcons.home),
      ...segments.map((seg) => IxBreadcrumbItemData(
        label: _formatLabel(seg),
      )),
    ];
  }
  
  String _formatLabel(String segment) {
    return segment.replaceAll('-', ' ').split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
  }
}
```

## Stable Keys and Click Payloads

`onItemPressed`/`onNextItemPressed` report the whole `IxBreadcrumbItemData`/
`IxBreadcrumbMenuItem`, which breaks down once two items share the same
`label` -- there is no way to tell them apart from the callback alone. The
additive `onItemClick`/`onNextClick` callbacks solve this: they fire
alongside the legacy callbacks (both run when both are set) with an
`IxBreadcrumbClick` payload carrying the activated item's stable
`breadcrumbKey`.

```dart
IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'reports-2024'),
    IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'reports-2025'),
  ],
  onItemClick: (click) {
    // click.breadcrumbKey is 'reports-2024' or 'reports-2025', never
    // ambiguous even though both items render as "Reports".
    context.go('/reports/${click.breadcrumbKey}');
  },
)
```

Pass `strings:` to localize the root landmark's accessible name, the
overflow trigger's accessible name and the current-page hint:

```dart
IxBreadcrumb(
  items: myItems,
  strings: const IxBreadcrumbStrings(
    breadcrumbs: 'Navigation de fil d\'Ariane',
    previousItems: 'Afficher les éléments précédents',
    currentPage: 'page actuelle',
  ),
)
```

## Theming

Customize breadcrumb appearance through `IxBreadcrumbTheme`:

```dart
ThemeData(
  extensions: [
    IxBreadcrumbTheme(
      height: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      itemSpacing: 8,
      maxItemWidth: 240,
      labelStyle: const TextStyle(fontSize: 14, color: Colors.blue),
      currentItemStyle: const TextStyle(fontSize: 14, color: Colors.grey),
      separatorColor: Colors.grey,
      iconColor: Colors.blue,
      ellipsisFontWeight: FontWeight.w700,
      // ignore: deprecated_member_use
      dropdownBackground: Colors.white,
      dropdownTextStyle: const TextStyle(fontSize: 14),
      dropdownElevation: 4,
      focusOutlineColor: Colors.blue,
      dropdownPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      // ignore: deprecated_member_use
      dropdownBorderRadius: const BorderRadius.all(Radius.circular(4)),
    ),
  ],
)
```

`dropdownBackground`/`dropdownBorderRadius` style the overflow/next-items
popup's surface and corner radius; they are deprecated (removed in 2.0,
once every dropdown-like surface in the app shares one styling source)
but still take effect until then. The popup's row height comes from the
shared `IxDropdownTheme` extension instead, so it already matches every
other Siemens IX dropdown menu's row height -- override that extension to
restyle it.

## Accessibility

The breadcrumb component provides comprehensive accessibility support:

- **Navigation landmark**: The root is exposed as a `navigation` landmark
  named `strings.breadcrumbs` (`semanticLabel` overrides it per instance)
- **One node per crumb**: Every crumb -- home, visible items and the
  overflow/next-items trigger -- is a single labelled, focusable node
- **Current-page state**: The last crumb is marked `selected` with a
  `strings.currentPage` hint, and becomes non-interactive automatically
  when no `onItemPressed`/`onItemClick`/`item.onPressed` callback is wired
  up for it (set one of those to keep it a regular, clickable crumb)
- **Labelled overflow trigger**: While the home button also reveals
  collapsed items, its accessible name switches to
  `strings.previousItems` so screen-reader users know it does more than
  navigate home
- **Keyboard navigation**: Full keyboard support -- Tab reaches every
  crumb and trigger, Enter/Space activates them and opens their menu
- **Focus management**: Proper focus indicators and tab order

### Custom Semantic Labels

```dart
IxBreadcrumb(
  items: myItems,
  semanticLabel: 'Page navigation breadcrumb',
  previousItemsLabel: 'Earlier pages',
  homeMenuLabel: 'Jump to page',
  strings: const IxBreadcrumbStrings(currentPage: 'you are here'),
)
```

## Best Practices

1. **Keep paths concise**: Limit hierarchy depth when possible (5-7 levels max)
2. **Use meaningful labels**: Clear, descriptive text for each level
3. **Home icon consistency**: Use the same home icon across your app
4. **Handle navigation**: Always implement `onItemPressed`/`onItemClick` for functional breadcrumbs
5. **Consider mobile**: Use lower `visibleItemCount` on small screens
6. **Test overflow**: Verify breadcrumb behavior at various widths
7. **Match router structure**: Align breadcrumb hierarchy with routing
8. **Set `breadcrumbKey`**: Give every item a stable, unique `breadcrumbKey` -- required if any two items can share the same `label`, and required outright starting with ix_flutter 2.0

## See Also

- [IxApplicationScaffold](ix_application_scaffold.md) - App structure with navigation
- [Navigation Examples](../example/lib/screen/navigation_examples_page.dart) - Complete breadcrumb examples
- [Theme System](copilot_colors.md) - Customizing breadcrumb colors
