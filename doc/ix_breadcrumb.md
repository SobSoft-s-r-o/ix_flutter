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
  label: 'Manufacturing',    // Required: Display text
  icon: IxIcons.factory,     // Optional: Leading icon
)
```

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
| `onNextItemPressed` | `ValueChanged<IxBreadcrumbMenuItem>?` | `null` | Callback when next menu item is tapped |
| `homeIcon` | `Widget?` | `null` | Custom icon for home button |
| `showHomeLabel` | `bool` | `false` | Show label text next to home icon |
| `showNavigationMenu` | `bool` | `true` | Enable navigation menu on home button |
| `previousItemsLabel` | `String` | `'Previous levels'` | Semantic label for overflow menu |
| `homeMenuLabel` | `String` | `'Navigate to level'` | Semantic label for home menu |
| `semanticLabel` | `String?` | `null` | Overall semantic description |

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

## Theming

Customize breadcrumb appearance through `IxBreadcrumbTheme`:

```dart
ThemeData(
  extensions: [
    IxBreadcrumbTheme(
      height: 40,
      itemSpacing: 8,
      labelStyle: TextStyle(fontSize: 14),
      iconColor: Colors.blue,
      separatorIcon: Icon(Icons.chevron_right),
    ),
  ],
)
```

## Accessibility

The breadcrumb component provides comprehensive accessibility support:

- **Screen readers**: Announces navigation structure and current position
- **Keyboard navigation**: Full keyboard support for navigation
- **Semantic labels**: Custom labels for overflow and navigation menus
- **Focus management**: Proper focus indicators and tab order

### Custom Semantic Labels

```dart
IxBreadcrumb(
  items: myItems,
  semanticLabel: 'Page navigation breadcrumb',
  previousItemsLabel: 'Earlier pages',
  homeMenuLabel: 'Jump to page',
)
```

## Best Practices

1. **Keep paths concise**: Limit hierarchy depth when possible (5-7 levels max)
2. **Use meaningful labels**: Clear, descriptive text for each level
3. **Home icon consistency**: Use the same home icon across your app
4. **Handle navigation**: Always implement `onItemPressed` for functional breadcrumbs
5. **Consider mobile**: Use lower `visibleItemCount` on small screens
6. **Test overflow**: Verify breadcrumb behavior at various widths
7. **Match router structure**: Align breadcrumb hierarchy with routing

## See Also

- [IxApplicationScaffold](ix_application_scaffold.md) - App structure with navigation
- [Navigation Examples](../example/lib/screen/navigation_examples_page.dart) - Complete breadcrumb examples
- [Theme System](copilot_colors.md) - Customizing breadcrumb colors
