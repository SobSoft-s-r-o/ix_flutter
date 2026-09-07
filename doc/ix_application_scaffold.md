# IxApplicationScaffold

The `IxApplicationScaffold` is a responsive application shell widget designed to mirror the Siemens IX application menu structure. It provides a consistent layout with a collapsible side navigation menu that adapts to different screen sizes.

## Features

*   **Responsive Layout**: Automatically switches between a permanent side navigation on large screens and a drawer-based layout on smaller screens (breakpoint at 1024px).
*   **Collapsible Navigation**: The side navigation can be expanded or collapsed to save screen space.
*   **Hierarchical Menu**: Supports nested menu categories and items.
*   **Customizable Entries**: Menu entries can have icons, labels, tooltips, and notification badges.
*   **Built-in Bottom Entries**: `settings:`, `about:` and `enableToggleTheme` add the upstream Settings, About & legal information and Toggle theme entries at the bottom of the menu.
*   **Fly-out Panels**: A category in a collapsed menu -- and the built-in settings/about entries -- reveal their content in an overlay panel anchored to the menu.
*   **Accessible**: The menu is a `menuBar` landmark with one semantics node per entry, full arrow-key navigation and a visible focus ring.
*   **Keyboard dismissal**: A tap outside a focused text input, or a drag of any scroll view in the frame, releases it and takes the soft keyboard down -- on every platform.
*   **Localizable**: Every user-facing string comes from `IxApplicationStrings`.
*   **Theming**: Integrates with `IxAppMenuTheme` and `IxSidebarTheme` for consistent styling.

## Usage

To use the `IxApplicationScaffold`, wrap your main application content with it. You need to provide the list of menu entries and handle navigation callbacks.

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

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
      body: Center(child: Text('Current Route: $_currentRoute')),
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
| `onOpenSettings` | `VoidCallback?` | Callback for a menu entry with the reserved id `settings` (deprecated, see below). | `null` |
| `onOpenAboutLegal` | `VoidCallback?` | Callback for a menu entry with the reserved id `about-legal` (deprecated, see below). | `null` |
| `strings` | `IxApplicationStrings` | Every user-facing string the menu renders. | `IxApplicationStrings()` |
| `settings` | `Widget?` | Content of the built-in Settings panel (upstream `<ix-menu-settings>`). When set, a Settings entry appears at the bottom of the menu. | `null` |
| `about` | `Widget?` | Content of the built-in About panel (upstream `<ix-menu-about>`). When set, an About & legal information entry appears at the bottom of the menu. | `null` |
| `enableToggleTheme` | `bool` | Whether the built-in theme toggle is shown. It only appears when `onThemeModeChanged` is also set. | `true` |
| `dismissKeyboardOnInteraction` | `bool` | Whether a tap outside a focused text input, or a drag of a scroll view, releases it and takes the soft keyboard down. See [Keyboard dismissal](#keyboard-dismissal). | `true` |

### IxApplicationStrings

All copy the menu renders, including the accessible names of its buttons. The
defaults mirror the upstream `menu.tsx` English strings.

| Property | Default | Used for |
|---|---|---|
| `menuLabel` | `Main navigation` | Accessible name of the `menuBar` landmark |
| `openMenu` | `Open menu` | Tooltip of the app bar drawer button (small screens); replaces Flutter's automatically localized `MaterialLocalizations.openAppDrawerTooltip`, so a localized app should set it |
| `expandSidebar` / `collapseSidebar` | `Expand sidebar` / `Collapse sidebar` | Tooltip of the sidebar toggle |
| `settings` | `Settings` | Label of the built-in settings entry |
| `about` | `About & legal information` | Label of the built-in about entry |
| `toggleTheme` | `Toggle theme` | Label of the built-in theme toggle |
| `themeSystem` / `themeLight` / `themeDark` | `System` / `Light` / `Dark` | Theme toggle indicator and accessibility value |
| `closePanel` | `Close` | Tooltip of the fly-out panel's close button |

```dart
Widget localizedScaffold({
  required List<IxMenuEntry> entries,
  required ValueChanged<String> onNavigate,
  required Widget body,
}) => IxApplicationScaffold(
  appTitle: 'My App',
  strings: const IxApplicationStrings(
    settings: 'Einstellungen',
    toggleTheme: 'Design wechseln',
  ),
  entries: entries,
  onNavigate: onNavigate,
  body: body,
);
```

### Built-in bottom entries

```dart
Widget scaffoldWithBottomEntries({
  required List<IxMenuEntry> entries,
  required ValueChanged<String> onNavigate,
  required Widget body,
  required ThemeMode themeMode,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) => IxApplicationScaffold(
  appTitle: 'My App',
  entries: entries,
  onNavigate: onNavigate,
  body: body,
  themeMode: themeMode,
  onThemeModeChanged: onThemeModeChanged,
  settings: const SettingsPanel(), // upstream <ix-menu-settings>
  about: const AboutLegalPanel(), // upstream <ix-menu-about>
  enableToggleTheme: true, // default
);
```

`settings` and `about` are opened in a fly-out panel anchored to the trailing
edge of the menu; the panel closes on `Escape`, on its close button, or on a
tap outside, and always hands focus back to the entry that opened it.

### Deprecated: reserved entry ids

Before this API existed, an entry whose `id` was `settings`, `theme-toggle` or
`about-legal` was given the built-in behaviour instead of reporting through
`onNavigate`. Those ids still work in 1.x -- together with `showSettings`,
`showThemeToggle`, `showAboutLegal`, `onOpenSettings` and `onOpenAboutLegal` --
but using one logs a one-time debug notice. **In 2.0 they become ordinary
entries** that simply report through `onNavigate`; migrate to `settings:`,
`about:` and `enableToggleTheme`.

### IxMenuEntry

Data model for defining items in the navigation menu.

| Property | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier for the entry. |
| `type` | `IxMenuEntryType` | Type of entry: `item`, `category`, or `custom`. |
| `label` | `String` | Display text for the entry. |
| `icon` | `IconData?` | Icon to display (Material IconData). |
| `iconWidget` | `Widget?` | Custom widget to use as an icon (e.g., `IxIcon.key(IxIconKey.home)`). Takes precedence over `icon`. |
| `tooltip` | `String?` | Tooltip text. Defaults to `label` if null. |
| `notificationCount` | `int?` | Number to display in a notification badge. |
| `selected` | `bool` | Whether the entry is currently selected/active. |
| `enabled` | `bool` | Whether the entry is interactive. |
| `children` | `List<IxMenuEntry>` | List of child entries (only for `category` type). |
| `isBottom` | `bool` | If true, the entry is rendered in the bottom section of the navigation. |

## Layout Behavior

*   **Large Screens (> 1024px)**: Displays a permanent side navigation bar on the left. The navigation can be toggled between expanded and collapsed states using the double-arrow button in the header.
*   **Small Screens (< 1024px)**: Displays a standard `AppBar` with a hamburger menu. Tapping the menu opens a modal `Drawer` containing the navigation. The drawer is always fully expanded.
*   **Collapsed rail**: A `category` entry has no room for inline children, so tapping it opens a fly-out panel with its children next to the rail instead.

## Keyboard dismissal

Flutter dismisses the soft keyboard neither on a tap outside a field nor on a
scroll, and both defaults live too far down to fix once for a whole app:

*   **Tapping outside.** The default action (`_EditableTextTapOutsideAction`
    in `packages/flutter/lib/src/widgets/editable_text.dart`) only drops the
    focus on **desktop**; it keeps it for a *touch* pointer on Android, iOS
    and Fuchsia.
*   **Scrolling.** Dismissal on scroll is per scroll view, through
    `ScrollView.keyboardDismissBehavior`, and the app-wide default in
    `packages/flutter/lib/src/widgets/scroll_configuration.dart` is
    `ScrollViewKeyboardDismissBehavior.manual` -- so every list, grid and
    `SingleChildScrollView` has to opt in one by one.

Either way the keyboard sits over the form the user is trying to read.
`IxApplicationScaffold` wraps its whole frame -- app bar, menu, fly-out,
drawer and `body` -- in `IxKeyboardDismissScope`, so both gestures dismiss
the keyboard with no extra code:

```dart
Widget scaffoldWithoutKeyboardDismissal({
  required List<IxMenuEntry> entries,
  required ValueChanged<String> onNavigate,
  required Widget body,
}) => IxApplicationScaffold(
  appTitle: 'My App',
  entries: entries,
  onNavigate: onNavigate,
  body: body,
  // Back to Flutter's own behaviour: on a touch screen a focused field
  // survives both a tap outside it and a scroll.
  dismissKeyboardOnInteraction: false,
);
```

What it does *not* do:

*   A tap inside the field, or on one of its `TextFieldTapRegion` satellites
    (the selection toolbar, the autofill dropdown, a decoration icon), keeps
    the focus -- the scope reads Flutter's own tap-region grouping rather
    than hit-testing on its own.
*   A touch that travels more than `kTouchSlop` before it lifts is a drag,
    not a tap; whether it dismisses is then up to the scroll trigger, so
    dragging a page that cannot scroll keeps the keyboard.
*   A programmatic `jumpTo`/`animateTo`, the ballistic settle after a fling
    and a mouse wheel carry no drag details and never dismiss. Neither does a
    field scrolling its own text under a selection drag.
*   A non-text focus (a button, a menu tile) is never cleared, so the
    keyboard focus model and the desktop focus ring are untouched. This is
    stricter than Flutter's own `onDrag`, which unfocuses whatever holds the
    primary focus.
*   Taps and scroll notifications are observed, never consumed: the button
    you tapped still fires and every other scroll listener still sees the
    scroll.

Outside the scaffold, wrap any subtree in the same widget. `onTapOutside` and
`onDrag` turn the two triggers on and off independently, and `enabled: false`
restores Flutter's defaults for both:

```dart
Widget formPage() => IxKeyboardDismissScope(
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: TextField(decoration: InputDecoration(labelText: 'Name')),
  ),
);
```

| Property | Type | Description | Default |
|---|---|---|---|
| `child` | `Widget` | The subtree whose text inputs are released. | Required |
| `enabled` | `bool` | Whether the scope does anything at all. | `true` |
| `onTapOutside` | `bool` | Release a focused field on a tap outside it. | `true` |
| `onDrag` | `bool` | Release a focused field when the user drags a scroll view. | `true` |
| `dismissKeyboard` | `bool` | Also ask the platform to hide the IME, ahead of Flutter's own teardown of the input connection. | `true` |

Scopes nest, and the one nearest above a focused field owns it -- the tap
trigger through the `Actions` lookup, the scroll trigger by matching the
field's own nearest scope. A drag inside a *sibling* scope therefore never
releases a field that belongs to another one. Because the override is
installed whatever the switches say, a nested `enabled: false` hands that
subtree back to Flutter's platform defaults even inside
`IxApplicationScaffold`'s frame, where dismissal is on by default, and
`onTapOutside` and `onDrag` take precedence over an enclosing scope the
same way, independently of each other -- a nested scope can keep the tap
trigger while switching the scroll trigger off.

## Accessibility

The menu publishes exactly one semantics node per entry: its label, its
enabled state, and the state that applies to it -- `selected` for a plain
entry, `expanded` for a category, `toggled` plus the theme name as the
accessibility value for the theme switch. The entry's own `tooltip` is
surfaced as a hint; the visible tooltip never duplicates the label.

### Keyboard

| Key | Behavior |
|---|---|
| `Tab` | Moves into the menu (sidebar toggle first, then the entries) and out of it again |
| `ArrowDown` / `ArrowUp` | Move between entries; focus stops at the first/last entry (no wrapping) |
| `Home` / `End` | Jump to the first/last entry |
| `Enter` / `Space` | Activate the focused entry |
| `Escape` | Close the open fly-out panel and return focus to the entry that opened it |
