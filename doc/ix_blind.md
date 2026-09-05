# IxBlind

The `IxBlind` widget is a collapsible container that mirrors the Siemens iX `<ix-blind>` web component. It consists of a header area (with a chevron, label, optional icon, optional sublabel, and optional header actions) and a content area that is shown or hidden when the blind is expanded or collapsed.

## Features

*   **Collapsible Content**: Smooth expansion and collapse animation.
*   **Uncontrolled or Controlled**: Manages its own expanded state by default, or hands full control to the caller -- see [Expanded state](#expanded-state).
*   **Header Customization**: Supports title, subtitle, leading icon, and trailing header actions (e.g., buttons).
*   **Accessible Header**: The header is exposed as a single button with an expanded/collapsed state; header actions keep their own accessible name instead of inheriting the title -- see [Accessibility](#accessibility).
*   **Visual Variants**: Supports all Siemens iX variants (`filled`, `outline`, `primary`, `alarm`, `critical`, `warning`, `success`, `info`, `neutral`).
*   **Accordion Support**: Can be used with `IxBlindAccordion` to stack multiple blinds with correct spacing.
*   **Theming**: Fully integrated with `IxBlindTheme` for consistent styling across the application.

## Expanded state

`IxBlind` supports two ways of driving its expanded state.

### Uncontrolled (default)

With `expanded` left `null` the blind manages its own state internally, starting from `initiallyExpanded`, and flips it on every header tap. Nothing else is required:

```dart
Widget uncontrolledBlind() => const IxBlind(
  title: 'Details',
  initiallyExpanded: true, // optional; defaults to false in 1.x
  child: Text('Content...'),
);
```

### Controlled

With `expanded` set, the blind always renders exactly the value you pass and never changes it on its own. Update `expanded` from `onExpandedChanged` to make the header respond to taps -- this is the pre-2.0 contract and keeps working unchanged.

```dart
Widget controlledBlind({
  required bool expanded,
  required ValueChanged<bool> onExpandedChanged,
}) => IxBlind(
  title: 'Details',
  expanded: expanded,
  onExpandedChanged: onExpandedChanged,
  child: const Text('Content...'),
);
```

`initiallyExpanded` is ignored once `expanded` is set. It defaults to `false` for 1.x source compatibility; the iX Flutter 2.0 breaking-changes plan flips that default to `true`.

## Accessibility

The header renders as a single semantics node with `button: true`, `expanded: <state>`, `label: title` and `hint: subtitle` (WCAG-equivalent to the upstream `<button aria-expanded aria-controls>` pattern). The chevron, optional leading icon, and title/subtitle text are excluded from that node so a screen reader announces one clean button rather than several fragments. `headerActions` (e.g., an `IconButton`) sit outside the header's semantics node entirely, so they keep their own accessible name (such as a tooltip) instead of being merged into the header's label. A `disabled` blind exposes `enabled: false` on the same node and ignores taps.

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
      icon: const IxIcon.key(IxIconKey.info), // Optional leading icon
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
Widget blindWithHeaderActions({
  required bool expanded,
  required ValueChanged<bool> onExpandedChanged,
  required VoidCallback onDelete,
}) => IxBlind(
  title: 'Blind with Actions',
  expanded: expanded,
  onExpandedChanged: onExpandedChanged,
  headerActions: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    ],
  ),
  child: const Text('Content...'),
);
```

### Accordion

Use `IxBlindAccordion` to group multiple blinds vertically with the correct spacing.

```dart
Widget blindAccordion({
  required bool firstExpanded,
  required ValueChanged<bool> onFirstExpandedChanged,
  required bool secondExpanded,
  required ValueChanged<bool> onSecondExpandedChanged,
}) => IxBlindAccordion(
  children: [
    IxBlind(
      title: 'First Blind',
      expanded: firstExpanded,
      onExpandedChanged: onFirstExpandedChanged,
      child: const Text('Content 1'),
    ),
    IxBlind(
      title: 'Second Blind',
      expanded: secondExpanded,
      onExpandedChanged: onSecondExpandedChanged,
      child: const Text('Content 2'),
    ),
  ],
);
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
| `headerActions` | `Widget?` | Optional widgets to display on the right side of the header, outside its semantics node. |
| `expanded` | `bool?` | Whether the blind content is visible. `null` (default) means uncontrolled: the blind tracks its own state starting from `initiallyExpanded`. Set it to make the blind controlled. |
| `initiallyExpanded` | `bool` | The expanded state used on first build in uncontrolled mode. Ignored once `expanded` is set. Defaults to `false` in 1.x. |
| `onExpandedChanged` | `ValueChanged<bool>?` | Called when the user taps the header to toggle the expanded state. |
| `disabled` | `bool` | Whether the blind is disabled. A disabled header exposes `enabled: false` in its semantics and ignores taps. |
| `child` | `Widget` | The content to display when the blind is expanded. |
