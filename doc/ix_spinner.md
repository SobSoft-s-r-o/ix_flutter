# IxSpinner

Animated loading spinner component that follows the IX Design System specifications. The spinner provides visual feedback for loading states and asynchronous operations.

## Overview

`IxSpinner` is a circular animated loading indicator with customizable sizes and color variants. It automatically adapts to the current theme and provides smooth animation patterns for a polished user experience.

## Features

- 🎨 Theme-aware colors and sizing
- 📏 Five predefined size options
- 🔄 Smooth rotation and sweep animations
- 🎯 Two color variants (standard and primary)
- ⚙️ Optional track visibility control

## Basic Usage

```dart
import 'package:ix_flutter/ix_flutter.dart';

// Default medium spinner
const IxSpinner()

// Custom size
const IxSpinner(size: IxSpinnerSize.large)

// Primary variant
const IxSpinner(variant: IxSpinnerVariant.primary)

// Without track (just the animated arc)
const IxSpinner(hideTrack: true)
```

## Sizes

The spinner comes with five size presets:

| Size | Diameter | Use Case |
|------|----------|----------|
| `IxSpinnerSize.xxSmall` | 16px | Inline with small text, compact UI elements |
| `IxSpinnerSize.xSmall` | 24px | Form inputs, small buttons |
| `IxSpinnerSize.small` | 32px | List items, cards |
| `IxSpinnerSize.medium` | 48px | Default loading states, dialogs |
| `IxSpinnerSize.large` | 64px | Full-page loading, splash screens |

### Size Examples

```dart
// Extra small for inline loading
Row(
  children: [
    const Text('Loading'),
    const SizedBox(width: 8),
    const IxSpinner(size: IxSpinnerSize.xSmall),
  ],
)

// Large for full-page loading
Center(
  child: const IxSpinner(size: IxSpinnerSize.large),
)
```

## Variants

### Standard (Default)
Uses the standard UI colors from the theme for subtle loading indicators.

```dart
const IxSpinner(variant: IxSpinnerVariant.standard)
```

### Primary
Uses the primary brand color for emphasized loading states.

```dart
const IxSpinner(variant: IxSpinnerVariant.primary)
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | `IxSpinnerSize` | `medium` | Physical size of the spinner |
| `variant` | `IxSpinnerVariant` | `standard` | Color scheme variant |
| `hideTrack` | `bool` | `false` | Hide the background track, showing only the animated arc |

## Common Patterns

### Loading Button Content

```dart
ElevatedButton(
  onPressed: isLoading ? null : _handleSubmit,
  child: isLoading
      ? const IxSpinner(
          size: IxSpinnerSize.small,
          hideTrack: true,
        )
      : const Text('Submit'),
)
```

### Loading Overlay

```dart
Stack(
  children: [
    // Your content
    MyContent(),
    
    // Loading overlay
    if (isLoading)
      Container(
        color: Colors.black54,
        child: const Center(
          child: IxSpinner(
            size: IxSpinnerSize.large,
            variant: IxSpinnerVariant.primary,
          ),
        ),
      ),
  ],
)
```

### Loading List Item

```dart
ListTile(
  title: const Text('Processing...'),
  trailing: const IxSpinner(size: IxSpinnerSize.small),
)
```

### Full-Screen Loading

```dart
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IxSpinner(
              size: IxSpinnerSize.large,
              variant: IxSpinnerVariant.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

## Theming

The spinner respects the `IxSpinnerTheme` extension in your theme. You can customize the appearance globally:

```dart
ThemeData(
  extensions: [
    IxSpinnerTheme(
      rotationDuration: Duration(seconds: 2),
      maskDuration: Duration(seconds: 3),
      ringInsetFraction: 0.0833,
      // Customize sizes and colors...
    ),
  ],
)
```

### Theme Properties

- **rotationDuration**: Controls the base rotation speed
- **maskDuration**: Controls the sweep animation speed  
- **ringInsetFraction**: Inset percentage from the spinner bounds
- **Size specifications**: Diameter and stroke width per size
- **Variant styles**: Colors for indicator and track per variant

## Accessibility

The spinner is purely visual and doesn't provide semantic loading information. For accessible loading states:

```dart
Semantics(
  label: 'Loading content',
  child: const IxSpinner(),
)

// Or use with a text label
Column(
  children: [
    const IxSpinner(),
    const SizedBox(height: 8),
    const Text('Loading...'),
  ],
)
```

## Best Practices

1. **Choose appropriate sizes**: Match spinner size to the UI context
2. **Use primary variant sparingly**: Reserve for important loading states
3. **Provide context**: Add descriptive text when the loading operation isn't obvious
4. **Consider performance**: Avoid rendering many spinners simultaneously
5. **Hide track for small sizes**: For inline spinners, `hideTrack: true` often looks better

## See Also

- [IxEmptyState](ix_empty_state.md) - For empty/loading states with messages
- [IxButton](ix_button.md) - Buttons with loading states
- [Theme System](copilot_colors.md) - Customizing spinner colors
