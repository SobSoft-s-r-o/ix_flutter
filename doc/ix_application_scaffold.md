# IxApplicationScaffold

The `IxApplicationScaffold` is a responsive application shell widget designed to mirror the Siemens IX application menu structure. It provides a consistent layout with a collapsible side navigation menu that adapts to different screen sizes.

## Features

*   **Responsive Layout**: Automatically switches between a permanent side navigation on large screens and a drawer-based layout on smaller screens (breakpoint at 1024px).
*   **Collapsible Navigation**: The side navigation can be expanded or collapsed to save screen space.
*   **Hierarchical Menu**: Supports nested menu categories and items.
*   **Customizable Entries**: Menu entries can have icons, labels, tooltips, and notification badges.
*   **Built-in Footer Actions**: Includes standard footer actions for Settings, Theme Toggle, and About/Legal information.
*   **Theming**: Integrates with `IxAppMenuTheme` and `IxSidebarTheme` for consistent styling.

## Usage

To use the `IxApplicationScaffold`, wrap your main application content with it. You need to provide the list of menu entries and handle navigation callbacks.

```dart
import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentRoute = 'home';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return IxApplicationScaffold(
      appTitle: 'My App',
      themeMode: _themeMode,
      onThemeModeChanged: (mode) {
        setState(() {
          _themeMode = mode;
        });
      },
      entries: [
        const IxMenuEntry(
          id: 'home',
          label: 'Home',
          icon: Icons.home,
          type: IxMenuEntryType.item,
        ),
        const IxMenuEntry(
          id: 'projects',
          label: 'Projects',
          icon: Icons.folder,
          type: IxMenuEntryType.category,
          children: [
            IxMenuEntry(
              id: 'project-a',
              label: 'Project A',
              type: IxMenuEntryType.item,
            ),
            IxMenuEntry(
              id: 'project-b',
              label: 'Project B',
              type: IxMenuEntryType.item,
            ),
          ],
        ),
      ],
      onNavigate: (id) {
        setState(() {
          _currentRoute = id;
        });
      },
      body: Center(
        child: Text('Current Route: $_currentRoute'),
      ),
    );
  }
}
```

## API Reference

### IxApplicationScaffold

| Property | Type | Description | Default |
|---|---|---|---|
| `appTitle` | `String` | The title displayed in the app bar and navigation header. | Required |
| `entries` | `List<IxMenuEntry>` | The list of menu entries to display in the navigation. | Required |
| `onNavigate` | `ValueChanged<String>` | Callback triggered when a menu item is tapped. Returns the entry ID. | Required |
| `body` | `Widget` | The main content of the application. | Required |
| `appBar` | `PreferredSizeWidget?` | Optional custom AppBar. If null, a default AppBar is created. | `null` |
| `initiallyExpanded` | `bool` | Whether the side navigation is initially expanded. | `true` |
| `animationDuration` | `Duration` | Duration of the expand/collapse animation. | `250ms` |
| `expandedWidth` | `double` | Width of the navigation panel when expanded. | `320` |
| `collapsedWidth` | `double` | Width of the navigation panel when collapsed. | `72` |
| `themeMode` | `ThemeMode` | Current theme mode (system, light, dark) for the theme toggle. | `ThemeMode.system` |
| `onThemeModeChanged` | `ValueChanged<ThemeMode>?` | Callback for when the theme toggle is used. | `null` |
| `showSettings` | `bool` | Whether to show the Settings button in the bottom area. | `true` |
| `showThemeToggle` | `bool` | Whether to show the Theme Toggle button in the bottom area. | `true` |
| `showAboutLegal` | `bool` | Whether to show the About/Legal button in the bottom area. | `true` |
| `onOpenSettings` | `VoidCallback?` | Callback for the Settings button. | `null` |
| `onOpenAboutLegal` | `VoidCallback?` | Callback for the About/Legal button. | `null` |

### IxMenuEntry

Data model for defining items in the navigation menu.

| Property | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier for the entry. |
| `type` | `IxMenuEntryType` | Type of entry: `item`, `category`, or `custom`. |
| `label` | `String` | Display text for the entry. |
| `icon` | `IconData?` | Icon to display (Material IconData). |
| `iconWidget` | `Widget?` | Custom widget to use as an icon (e.g., `IxIcons.home`). Takes precedence over `icon`. |
| `tooltip` | `String?` | Tooltip text. Defaults to `label` if null. |
| `notificationCount` | `int?` | Number to display in a notification badge. |
| `selected` | `bool` | Whether the entry is currently selected/active. |
| `enabled` | `bool` | Whether the entry is interactive. |
| `children` | `List<IxMenuEntry>` | List of child entries (only for `category` type). |
| `isBottom` | `bool` | If true, the entry is rendered in the bottom section of the navigation. |

## Layout Behavior

*   **Large Screens (> 1024px)**: Displays a permanent side navigation bar on the left. The navigation can be toggled between expanded and collapsed states using the double-arrow button in the header.
*   **Small Screens (< 1024px)**: Displays a standard `AppBar` with a hamburger menu. Tapping the menu opens a modal `Drawer` containing the navigation. The drawer is always fully expanded.
