# IxDropdownButton

The `IxDropdownButton` widget is a button that reveals a dropdown menu of actions when activated. It mirrors the Siemens iX `<ix-dropdown-button>` web component.

## Features

*   **Variants**: Supports all standard button variants (primary, secondary, tertiary, subtle, danger).
*   **Placements**: Supports 8 placement options (top/bottom/left/right + start/end alignment).
*   **Auto-Placement**: Automatically flips the dropdown position if there isn't enough screen space, and always shifts the menu back inside the viewport (8px margin).
*   **Content width**: The menu is as wide as its widest item and never wider than the viewport; longer labels are ellipsized.
*   **Scrolling**: The menu scrolls vertically once it exceeds `maxHeight` (half the viewport height minus 48px by default).
*   **Keyboard**: A full iX keyboard model (see below) with a 1px focus outline on the focused row.
*   **Screen readers**: The trigger is a button with an expanded state, the menu carries the `menu` role and every row the `menuItem` role, including enabled and checked state.
*   **Icons**: Supports optional leading icons on the button and within menu items.
*   **Theming**: Fully integrated with `IxTheme`, `IxButtonTheme` and `IxDropdownTheme`.

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

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
        debugPrint('Selected: $value');
      },
    );
  }
}
```

### With Icon and Variant

```dart
Widget dropdownWithIconAndVariant(ValueChanged<String> onItemSelected) =>
    IxDropdownButton<String>(
      label: 'Settings',
      icon: const IxIcon.key(IxIconKey.cogwheel, size: IxIconSize.s16),
      buttonVariant: IxButtonVariant.secondary,
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
      onItemSelected: onItemSelected,
    );
```

### Checked items

A menu that contains at least one `checked` item reserves a leading checkmark column for every row, so all labels stay aligned. The checked state is exposed to screen readers.

```dart
Widget dropdownWithCheckedItem() => const IxDropdownButton<String>(
  label: 'Sort by',
  items: [
    IxDropdownMenuItem(label: 'Name', value: 'name', checked: true),
    IxDropdownMenuItem(label: 'Date', value: 'date'),
  ],
);
```

### Controlled open state

Passing `isOpen` makes the widget controlled: it never opens or closes on its own, it only reports the requested state through `onOpenChanged` and renders whatever `isOpen` says. Leave `isOpen` unset for the uncontrolled default.

```dart
Widget controlledDropdown({
  required bool isOpen,
  required ValueChanged<bool> onOpenChanged,
}) => IxDropdownButton<String>(
  label: 'Actions',
  isOpen: isOpen,
  onOpenChanged: onOpenChanged,
  items: const [IxDropdownMenuItem(label: 'Edit', value: 'edit')],
);
```

`onWillOpen` vetoes an open request before it happens (and before `onOpenChanged` fires), which is useful for lazily loading the items or blocking the menu while a form is invalid:

```dart
Widget dropdownWithOpenVeto({
  required bool formIsValid,
  required List<IxDropdownMenuItem<String>> items,
}) => IxDropdownButton<String>(
  label: 'Actions',
  onWillOpen: () => formIsValid,
  items: items,
);
```

### Close behaviour

`closeBehavior` decides which interactions dismiss the open menu:

| Value | Item selection closes | Outside tap closes |
| :--- | :--- | :--- |
| `IxDropdownCloseBehavior.both` (default) | yes | yes |
| `IxDropdownCloseBehavior.inside` | yes | no |
| `IxDropdownCloseBehavior.outside` | no | yes |
| `IxDropdownCloseBehavior.none` | no | no |

`Escape` and `Tab` always close the menu regardless of this setting, so a keyboard user can never be trapped inside it (WCAG 2.1.2).

### Placements

You can control the preferred placement of the dropdown menu using the `placement` parameter. The widget will attempt to respect this placement but will automatically adjust if there is insufficient space.

```dart
Widget dropdownWithPlacement(List<IxDropdownMenuItem<String>> items) =>
    IxDropdownButton<String>(
      label: 'Top Start',
      placement: IxDropdownPlacement.topStart,
      items: items,
    );
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

## Overlay requirement

`IxDropdownButton` builds fine with no `Overlay` ancestor -- the trigger
button always renders -- but *opening* the menu needs one: the menu is laid
out by an `OverlayPortal` into the nearest `Overlay`, not by the trigger's
own parent, the same way `Tooltip` and other floating Material widgets work.

Placed directly in `MaterialApp.builder`, above the `Navigator` that
normally hosts the app's `Overlay`, the trigger still renders, but tapping
it logs a one-time debug notice instead of opening the menu, and the menu
stays closed. Fix it one of two ways:

*   Wrap that shell in `Overlay.wrap(child: ...)`.
*   Nest it inside [IxApplicationScaffold](ix_application_scaffold.md), which
    self-hosts an `Overlay` for exactly this placement.

## Keyboard model

Mirrors upstream `dropdown.tsx` / `dropdown-focus.ts`.

| Key | On the trigger | In the menu |
| :--- | :--- | :--- |
| `ArrowDown`, `Home`, `Enter`, `Space` | opens the menu on the first enabled item | — |
| `ArrowUp`, `End` | opens the menu on the last enabled item | — |
| `ArrowDown` / `ArrowUp` | — | moves to the next/previous enabled item, cycling |
| `Home` / `End` | — | first / last enabled item |
| `Enter` / `Space` | — | activates the focused item |
| `Escape` | closes the open menu, focus stays on the trigger | closes the menu, focus returns to the trigger |
| `Tab` / `Shift+Tab` | — | closes the menu, focus continues past the trigger |

Disabled items are skipped by every one of these keys and cannot be activated. Opening with a pointer also focuses the first enabled item, so the arrow keys work immediately.

`Escape` is handled on the trigger as well, because a menu whose items are all disabled (or that has none) leaves the focus on the trigger with nothing inside the menu to receive the key — a keyboard user must still be able to close it (WCAG 2.1.2).

Every key that moves the focus also scrolls the menu by the smallest amount that brings the focused row fully into view, including when the focus wraps around the ends of the list and when the menu opens on a row that is already past its height budget.

## Accessibility

*   The trigger is a `button` with an expanded state (`aria-expanded`), so screen readers announce whether the menu is open.
*   `semanticLabel` replaces the visible `label` as the trigger's accessible name — useful when the visible label is terse (`IxPaginationBar` uses it for its "rows per page" trigger).
*   The menu is a `menu` node labelled with the trigger's name; every row is a `menuItem` with its enabled state and, when applicable, its checked state.
*   The focused row draws a 1px `focusBdr` outline inside its own bounds, so it never overlaps the neighbouring row or the menu's rounded corner.

## API

### IxDropdownButton

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String` | required | The text label displayed on the button. |
| `items` | `List<IxDropdownMenuItem<T>>` | required | The list of items to display in the dropdown menu. |
| `buttonVariant` | `IxButtonVariant?` | `null` | The visual style of the button. Takes precedence over `variant`. |
| `variant` | `IxDropdownButtonVariant` | `primary` | **Deprecated**, removed in 2.0 — use `buttonVariant`. |
| `placement` | `IxDropdownPlacement` | `bottomStart` | The preferred position of the dropdown menu. |
| `disabled` | `bool` | `false` | Whether the button is disabled. |
| `icon` | `Widget?` | `null` | An optional icon to display before the label. |
| `onItemSelected` | `ValueChanged<T>?` | `null` | Callback triggered when a menu item is selected. |
| `isOpen` | `bool?` | `null` | When set, the caller owns the open state (controlled mode). |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | Called whenever the menu wants to open (`true`) or close (`false`). |
| `onWillOpen` | `bool Function()?` | `null` | Consulted before opening; returning `false` vetoes the request. |
| `closeBehavior` | `IxDropdownCloseBehavior` | `both` | Which interactions dismiss the open menu. |
| `maxHeight` | `double?` | `null` | Maximum menu height. Defaults to half the viewport height minus 48px. |
| `semanticLabel` | `String?` | `null` | Accessible name of the trigger, replacing `label` for screen readers. |

### IxDropdownMenuItem

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `label` | `String` | required | The text to display for the item, and its accessible name. |
| `value` | `T` | required | The value associated with the item. |
| `icon` | `Widget?` | `null` | An optional icon to display before the item label. |
| `disabled` | `bool` | `false` | Whether the item is disabled (unfocusable and unselectable). |
| `checked` | `bool` | `false` | Whether the item is checked; reserves a checkmark column for the whole menu. |

### IxDropdownTheme

Registered by `IxThemeBuilder` as a `ThemeExtension`; read it with `Theme.of(context).extension<IxDropdownTheme>()`.

| Property | Type | Value | Description |
| :--- | :--- | :--- | :--- |
| `background` | `Color` | `color2` | Background of the menu surface. |
| `borderRadius` | `double` | `4` | Corner radius of the menu surface. |
| `shadow` | `List<BoxShadow>` | 3 layers | Approximation of the upstream `--theme-shadow-4`. |
| `padding` | `EdgeInsets` | vertical `4` | Padding between the surface and its first/last row. |
| `itemHeight` | `double` | `40` | Minimum height of a menu row. |
| `itemPadding` | `EdgeInsets` | left `8`, right `24` | Horizontal padding inside a row. |
| `checkColumnWidth` | `double` | `24` | Width of the leading checkmark column. |
| `itemHover` | `Color` | `ghostHover` | Row background on hover. |
| `itemActive` | `Color` | `ghostActive` | Row background while pressed. |
| `itemDisabledText` | `Color` | `weakText` | Label color of a disabled row. |
| `itemFocusBorder` | `Color` | `focusBdr` | Color of the row's focus outline. |
| `itemText` | `Color` | `stdText` | Label color of an enabled row. |
| `itemTextStyle` | `TextStyle` | `typography.body` | Text style of a row label. |
