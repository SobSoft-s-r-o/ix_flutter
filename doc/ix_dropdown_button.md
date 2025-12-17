# IxDropdownButton

The `IxDropdownButton` widget is a button that reveals a dropdown menu of actions when activated. It mirrors the Siemens iX `<ix-dropdown-button>` web component.

## Features

*   **Variants**: Supports all standard button variants (primary, secondary, ghost, danger, etc.).
*   **Placements**: Supports 8 placement options (top/bottom/left/right + start/end alignment).
*   **Auto-Placement**: Automatically flips the dropdown position if there isn't enough screen space.
*   **Icons**: Supports optional leading icons on the button and within menu items.
*   **Theming**: Fully integrated with `IxTheme` and `IxButtonTheme`.

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class MyDropdownExample extends StatelessWidget {
  const MyDropdownExample({super.key});

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<String>(
      label: 'Open Menu',
      items: const [
        IxDropdownMenuItem(label: 'Action 1', value: '1'),
        IxDropdownMenuItem(label: 'Action 2', value: '2'),
      ],
      onItemSelected: (value) {
        print('Selected: $value');
      },
    );
  }
}
```

### With Icon and Variant

```dart
IxDropdownButton<String>(
  label: 'Settings',
  icon: IxIcons.cogwheel,
  variant: IxDropdownButtonVariant.secondary,
  items: const [
    IxDropdownMenuItem(
      label: 'Profile',
      value: 'profile',
      icon: Icon(Icons.person, size: 16),
    ),
    IxDropdownMenuItem(
      label: 'Logout',
      value: 'logout',
      icon: Icon(Icons.logout, size: 16),
    ),
  ],
  onItemSelected: (value) {
    // Handle selection
  },
)
```

### Placements

You can control the preferred placement of the dropdown menu using the `placement` parameter. The widget will attempt to respect this placement but will automatically adjust if there is insufficient space.

```dart
IxDropdownButton<String>(
  label: 'Top Start',
  placement: IxDropdownPlacement.topStart,
  items: const [/* ... */],
)
```

Supported placements:
*   `bottomStart` (default)
*   `bottomEnd`
*   `topStart`
*   `topEnd`
*   `leftStart`
*   `leftEnd`
*   `rightStart`
*   `rightEnd`

## API

### IxDropdownButton

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String` | required | The text label displayed on the button. |
| `items` | `List<IxDropdownMenuItem<T>>` | required | The list of items to display in the dropdown menu. |
| `variant` | `IxDropdownButtonVariant` | `primary` | The visual style of the button. |
| `placement` | `IxDropdownPlacement` | `bottomStart` | The preferred position of the dropdown menu. |
| `disabled` | `bool` | `false` | Whether the button is disabled. |
| `icon` | `Widget?` | `null` | An optional icon to display before the label. |
| `onItemSelected` | `ValueChanged<T>?` | `null` | Callback triggered when a menu item is selected. |

### IxDropdownMenuItem

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String` | required | The text to display for the item. |
| `value` | `T` | required | The value associated with the item. |
| `icon` | `Widget?` | `null` | An optional icon to display before the item label. |
| `disabled` | `bool` | `false` | Whether the item is disabled (unselectable). |
