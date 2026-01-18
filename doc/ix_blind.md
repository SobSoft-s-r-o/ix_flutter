# IxBlind

The `IxBlind` widget is a collapsible container that mirrors the Siemens iX `<ix-blind>` web component. It consists of a header area (with a chevron, label, optional icon, optional sublabel, and optional header actions) and a content area that is shown or hidden when the blind is expanded or collapsed.

## Features

*   **Collapsible Content**: Smooth expansion and collapse animation.
*   **Header Customization**: Supports title, subtitle, leading icon, and trailing header actions (e.g., buttons).
*   **Visual Variants**: Supports all Siemens iX variants (`filled`, `outline`, `primary`, `alarm`, `critical`, `warning`, `success`, `info`, `neutral`).
*   **Accordion Support**: Can be used with `IxBlindAccordion` to stack multiple blinds with correct spacing.
*   **Theming**: Fully integrated with `IxBlindTheme` for consistent styling across the application.

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class MyBlindExample extends StatefulWidget {
  const MyBlindExample({super.key});

  @override
  State<MyBlindExample> createState() => _MyBlindExampleState();
}

class _MyBlindExampleState extends State<MyBlindExample> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return IxBlind(
      title: 'Basic Blind',
      subtitle: 'Optional subtitle',
      icon: IxIcons.info, // Optional leading icon
      expanded: _expanded,
      onExpandedChanged: (value) {
        setState(() {
          _expanded = value;
        });
      },
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('This is the content of the blind.'),
      ),
    );
  }
}
```

### Header Actions

You can add widgets to the right side of the header using the `headerActions` property.

```dart
IxBlind(
  title: 'Blind with Actions',
  expanded: _expanded,
  onExpandedChanged: (val) => setState(() => _expanded = val),
  headerActions: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          // Handle delete action
        },
      ),
    ],
  ),
  child: const Text('Content...'),
)
```

### Accordion

Use `IxBlindAccordion` to group multiple blinds vertically with the correct spacing.

```dart
IxBlindAccordion(
  children: [
    IxBlind(
      title: 'First Blind',
      expanded: _expanded1,
      onExpandedChanged: (v) => setState(() => _expanded1 = v),
      child: const Text('Content 1'),
    ),
    IxBlind(
      title: 'Second Blind',
      expanded: _expanded2,
      onExpandedChanged: (v) => setState(() => _expanded2 = v),
      child: const Text('Content 2'),
    ),
  ],
)
```

## Variants

The `variant` property controls the visual style of the blind. Available variants are defined in `IxBlindVariant`:

*   `IxBlindVariant.filled` (Default)
*   `IxBlindVariant.outline`
*   `IxBlindVariant.primary`
*   `IxBlindVariant.alarm`
*   `IxBlindVariant.critical`
*   `IxBlindVariant.warning`
*   `IxBlindVariant.success`
*   `IxBlindVariant.info`
*   `IxBlindVariant.neutral`

## API Reference

| Property | Type | Description |
| :--- | :--- | :--- |
| `title` | `String` | The main label of the blind. |
| `subtitle` | `String?` | An optional secondary label displayed below the title. |
| `variant` | `IxBlindVariant` | The visual style of the blind. Defaults to `filled`. |
| `icon` | `Widget?` | An optional icon displayed before the title. |
| `headerActions` | `Widget?` | Optional widgets to display on the right side of the header. |
| `expanded` | `bool` | Whether the blind content is visible. |
| `onExpandedChanged` | `ValueChanged<bool>?` | Called when the user taps the header to toggle the expanded state. |
| `disabled` | `bool` | Whether the blind is disabled. |
| `child` | `Widget` | The content to display when the blind is expanded. |
