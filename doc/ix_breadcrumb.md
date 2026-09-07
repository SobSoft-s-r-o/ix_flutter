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
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget basicBreadcrumb() => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Products', breadcrumbKey: 'products'),
    IxBreadcrumbItemData(label: 'Electronics', breadcrumbKey: 'electronics'),
    IxBreadcrumbItemData(label: 'Laptops', breadcrumbKey: 'laptops'),
  ],
  onItemClick: (click) {
    // Navigate to the selected level
    debugPrint('Navigate to: ${click.breadcrumbKey}');
  },
);
```

## Item Configuration

### IxBreadcrumbItemData

Represents a single level in the navigation hierarchy.

```dart
const manufacturingLevel = IxBreadcrumbItemData(
  label: 'Manufacturing', // Required: display text
  breadcrumbKey: 'manufacturing', // Recommended: stable identifier
  icon: IxIcon.key(IxIconKey.apps), // Optional: leading icon
);
```

`breadcrumbKey` is the identifier reported through `onItemClick`/
`onNextClick` (see below) and falls back to `label` when omitted -- which
is only safe as long as no two items share the same label. A missing
`breadcrumbKey` also prints a one-time debug notice, since it becomes a
required parameter starting with ix_flutter 2.0.

### With Navigation Menu

Add child destinations to the last breadcrumb item:

```dart
Widget breadcrumbWithNextItems() => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Settings', breadcrumbKey: 'settings'),
  ],
  nextItems: const [
    IxBreadcrumbMenuItem(label: 'General', breadcrumbKey: 'general'),
    IxBreadcrumbMenuItem(label: 'Privacy', breadcrumbKey: 'privacy'),
    IxBreadcrumbMenuItem(label: 'Security', breadcrumbKey: 'security'),
  ],
  onNextClick: (click) {
    // Navigate to child page
    debugPrint('Navigate to: ${click.breadcrumbKey}');
  },
);
```

## Appearance Styles

### Tertiary (Default)
Subtle, low-emphasis breadcrumbs suitable for most interfaces.

```dart
Widget tertiaryBreadcrumb(List<IxBreadcrumbItemData> items) => IxBreadcrumb(
  items: items,
  buttonAppearance: IxBreadcrumbButtonAppearance.tertiary,
);
```

### Subtle Primary
More prominent breadcrumbs using the primary brand color.

```dart
Widget subtlePrimaryBreadcrumb(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      buttonAppearance: IxBreadcrumbButtonAppearance.subtlePrimary,
    );
```

## Overflow Handling

Control how many items remain visible before collapsing into the overflow menu:

```dart
Widget breadcrumbWithVisibleItemCount(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      visibleItemCount: 4, // Show up to 4 items, collapse rest
    );
```

The component automatically calculates the best fit based on available width. Items beyond the visible count collapse into a dropdown menu at the start of the path.

## Home Button Customization

### Custom Home Icon

```dart
Widget breadcrumbWithCustomHomeIcon(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(items: items, homeIcon: const Icon(Icons.dashboard));
```

### Show Home Label

```dart
Widget breadcrumbWithHomeLabel(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      showHomeLabel: true, // Shows the label text next to home icon
    );
```

### Disable Navigation Menu

```dart
Widget breadcrumbWithoutNavigationMenu(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      showNavigationMenu: false, // Home button won't show dropdown
    );
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
  const ProductDetailPage({super.key, required this.onNavigate});

  /// Wire this to your router, e.g. `context.go` from `go_router`.
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IxBreadcrumb(
            items: const [
              IxBreadcrumbItemData(
                label: 'Home',
                breadcrumbKey: '/',
                icon: IxIcon.key(IxIconKey.home),
              ),
              IxBreadcrumbItemData(
                label: 'Products',
                breadcrumbKey: '/products',
              ),
              IxBreadcrumbItemData(
                label: 'Widget Pro',
                breadcrumbKey: '/products/widget-pro',
              ),
            ],
            onItemClick: (click) => onNavigate(click.breadcrumbKey),
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
Widget deepBreadcrumb(ValueChanged<String> navigateToLevel) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(
      label: 'Manufacturing',
      breadcrumbKey: 'manufacturing',
    ),
    IxBreadcrumbItemData(label: 'Production Lines', breadcrumbKey: 'lines'),
    IxBreadcrumbItemData(label: 'Line 04', breadcrumbKey: 'line-04'),
    IxBreadcrumbItemData(label: 'Station A', breadcrumbKey: 'station-a'),
    IxBreadcrumbItemData(label: 'Inspection', breadcrumbKey: 'inspection'),
  ],
  visibleItemCount: 3, // Only show 3 items, rest in overflow
  buttonAppearance: IxBreadcrumbButtonAppearance.subtlePrimary,
  onItemClick: (click) => navigateToLevel(click.breadcrumbKey),
);
```

### With Child Navigation

```dart
Widget breadcrumbWithChildNavigation({
  required ValueChanged<String> goBack,
  required ValueChanged<String> navigateForward,
}) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Settings', breadcrumbKey: 'settings'),
  ],
  nextItems: const [
    IxBreadcrumbMenuItem(label: 'Account', breadcrumbKey: 'account'),
    IxBreadcrumbMenuItem(label: 'Privacy', breadcrumbKey: 'privacy'),
    IxBreadcrumbMenuItem(
      label: 'Notifications',
      breadcrumbKey: 'notifications',
    ),
    IxBreadcrumbMenuItem(label: 'Display', breadcrumbKey: 'display'),
  ],
  onItemClick: (click) => goBack(click.breadcrumbKey),
  onNextClick: (click) => navigateForward(click.breadcrumbKey),
);
```

### Responsive Breadcrumb

```dart
Widget responsiveBreadcrumb(List<IxBreadcrumbItemData> breadcrumbPath) =>
    LayoutBuilder(
      builder: (context, constraints) {
        final visibleCount = constraints.maxWidth < 600 ? 2 : 4;
        return IxBreadcrumb(
          items: breadcrumbPath,
          visibleItemCount: visibleCount,
          showHomeLabel: constraints.maxWidth > 800,
        );
      },
    );
```

## Integration with Router

### Using with go_router

`IxBreadcrumb` has no router dependency: give it a callback and wire that to
your router (`context.go` for `go_router`, `Navigator` for the stock router).

```dart
class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key, required this.currentPath, required this.go});

  final String currentPath;

  /// Wire this to `context.go` from `go_router` (or your router's equivalent).
  final ValueChanged<String> go;

  @override
  Widget build(BuildContext context) {
    return IxBreadcrumb(
      items: _buildBreadcrumbsFromPath(currentPath),
      onItemClick: (click) => go(click.breadcrumbKey),
    );
  }

  List<IxBreadcrumbItemData> _buildBreadcrumbsFromPath(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    var route = '';
    return [
      const IxBreadcrumbItemData(
        label: 'Home',
        breadcrumbKey: '/',
        icon: IxIcon.key(IxIconKey.home),
      ),
      ...segments.map((segment) {
        route = '$route/$segment';
        return IxBreadcrumbItemData(
          label: _formatLabel(segment),
          breadcrumbKey: route,
        );
      }),
    ];
  }

  String _formatLabel(String segment) => segment
      .replaceAll('-', ' ')
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
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
Widget breadcrumbWithStableKeys(ValueChanged<String> go) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'reports-2024'),
    IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'reports-2025'),
  ],
  onItemClick: (click) {
    // click.breadcrumbKey is 'reports-2024' or 'reports-2025', never
    // ambiguous even though both items render as "Reports".
    go('/reports/${click.breadcrumbKey}');
  },
);
```

Pass `strings:` to localize the root landmark's accessible name, the
overflow trigger's accessible name and the current-page hint:

```dart
Widget localizedBreadcrumb(List<IxBreadcrumbItemData> items) => IxBreadcrumb(
  items: items,
  strings: const IxBreadcrumbStrings(
    breadcrumbs: 'Navigation de fil d\'Ariane',
    previousItems: 'Afficher les éléments précédents',
    currentPage: 'page actuelle',
  ),
);
```

## Theming

Customize breadcrumb appearance through `IxBreadcrumbTheme`:

```dart
ThemeData withBreadcrumbOverrides(ThemeData base) {
  final breadcrumb = base.extension<IxBreadcrumbTheme>();
  if (breadcrumb == null) return base; // not an IxThemeBuilder theme
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...base.extensions.values,
      breadcrumb.copyWith(
        height: 40,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4),
        itemSpacing: 8,
        maxItemWidth: 240,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.blue),
        currentItemStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        separatorColor: Colors.grey,
        iconColor: Colors.blue,
        ellipsisFontWeight: FontWeight.w700,
        focusOutlineColor: Colors.blue,
      ),
    ],
  );
}
```

Start from the extension `IxThemeBuilder` already registered (rather than
constructing an `IxBreadcrumbTheme` from scratch) and keep the other
extensions in place, as above.

The theme also carries `dropdownBackground`/`dropdownBorderRadius`, which
style the overflow/next-items popup's surface and corner radius. Both are
deprecated (removed in 2.0, once every dropdown-like surface in the app
shares one styling source) and are therefore left out of the example above;
they still take effect until then. The popup's row height comes from the
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
Widget breadcrumbWithSemanticLabels(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      semanticLabel: 'Page navigation breadcrumb',
      previousItemsLabel: 'Earlier pages',
      homeMenuLabel: 'Jump to page',
      strings: const IxBreadcrumbStrings(currentPage: 'you are here'),
    );
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
- [Color tokens](tokens.md) - Every classic-theme color token
