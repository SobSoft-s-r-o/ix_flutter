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
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget spinnerBasics() => const Column(
  children: [
    // Default medium spinner
    IxSpinner(),
    // Custom size
    IxSpinner(size: IxSpinnerSize.large),
    // Primary variant
    IxSpinner(variant: IxSpinnerVariant.primary),
    // Without track (just the animated arc)
    IxSpinner(hideTrack: true),
  ],
);
```

## Sizes

The spinner comes with five size presets:

| Size | Diameter | Use Case |
|------|----------|----------|
| `IxSpinnerSize.xxSmall` | 12px | Inline with small text, compact UI elements |
| `IxSpinnerSize.xSmall` | 20px | Form inputs, small buttons |
| `IxSpinnerSize.small` | 24px | List items, cards |
| `IxSpinnerSize.medium` | 48px | Default loading states, dialogs (note: medium becomes 32px in 2.0 -- tracked separately) |
| `IxSpinnerSize.large` | 96px | Full-page loading, splash screens |

### Size Examples

```dart
Widget inlineSpinner() => const Row(
  children: [
    Text('Loading'),
    SizedBox(width: 8),
    IxSpinner(size: IxSpinnerSize.xSmall),
  ],
);

Widget fullPageSpinner() =>
    const Center(child: IxSpinner(size: IxSpinnerSize.large));
```

## Variants

### Secondary (Default)
Uses the muted "soft" UI colors from the theme for subtle loading indicators.

```dart
Widget secondarySpinner() =>
    const IxSpinner(variant: IxSpinnerVariant.secondary);
```

`IxSpinnerVariant.standard` is a deprecated alias of `secondary` (same colors, kept for source compatibility) and will be removed in a future major version. Use `secondary` in new code.

### Primary
Uses the primary brand color for emphasized loading states.

```dart
Widget primarySpinner() => const IxSpinner(variant: IxSpinnerVariant.primary);
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | `IxSpinnerSize` | `medium` | Physical size of the spinner |
| `variant` | `IxSpinnerVariant` | `secondary` | Color scheme variant |
| `hideTrack` | `bool` | `false` | Hide the background track, showing only the animated arc |
| `semanticLabel` | `String?` | `'Loading'` | Label announced by assistive technologies on the spinner's status role |

## Common Patterns

### Loading Button Content

```dart
Widget submitButton({
  required bool isLoading,
  required VoidCallback onSubmit,
}) => FilledButton(
  onPressed: isLoading ? null : onSubmit,
  child: isLoading
      ? const IxSpinner(size: IxSpinnerSize.small, hideTrack: true)
      : const Text('Submit'),
);
```

### Loading Overlay

```dart
Widget loadingOverlay({required bool isLoading, required Widget content}) =>
    Stack(
      children: [
        content,
        if (isLoading)
          const ColoredBox(
            color: Colors.black54,
            child: Center(
              child: IxSpinner(
                size: IxSpinnerSize.large,
                variant: IxSpinnerVariant.primary,
              ),
            ),
          ),
      ],
    );
```

### Loading List Item

```dart
Widget loadingListItem() => const ListTile(
  title: Text('Processing...'),
  trailing: IxSpinner(size: IxSpinnerSize.small),
);
```

### Full-Screen Loading

```dart
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

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
            Text('Loading...', style: Theme.of(context).textTheme.titleMedium),
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
ThemeData withSpinnerOverrides(ThemeData base) {
  final spinner = base.extension<IxSpinnerTheme>();
  if (spinner == null) return base; // not an IxThemeBuilder theme
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...base.extensions.values,
      spinner.copyWith(
        rotationDuration: const Duration(seconds: 2),
        maskDuration: const Duration(seconds: 3),
        ringInsetFraction: 0.0833,
      ),
    ],
  );
}
```

### Theme Properties

- **rotationDuration**: Controls the base rotation speed
- **maskDuration**: Controls the sweep animation speed  
- **ringInsetFraction**: Inset percentage from the spinner bounds
- **Size specifications**: Diameter and stroke width per size
- **Variant styles**: Colors for indicator and track per variant

## Accessibility

`IxSpinner` exposes a `SemanticsRole.status` node labelled `'Loading'` by default, so assistive technologies announce the loading state without any extra wrapping. Override the announced text with `semanticLabel`:

```dart
Widget labelledSpinner() => const IxSpinner(semanticLabel: 'Loading content');

Widget spinnerWithVisibleLabel() => const Column(
  children: [IxSpinner(), SizedBox(height: 8), Text('Loading...')],
);
```

When the platform's reduced-motion accessibility setting is enabled (`MediaQuery.disableAnimations`), the spinner stops its repeating rotation/sweep animation entirely instead of just slowing it down.

## Best Practices

1. **Choose appropriate sizes**: Match spinner size to the UI context
2. **Use primary variant sparingly**: Reserve for important loading states
3. **Provide context**: Add descriptive text when the loading operation isn't obvious
4. **Consider performance**: Avoid rendering many spinners simultaneously
5. **Hide track for small sizes**: For inline spinners, `hideTrack: true` often looks better

## See Also

- [IxEmptyState](ix_empty_state.md) - For empty/loading states with messages
- [Density](density.md) - Hit areas and `IxIconButton`
- [Color tokens](tokens.md) - Every classic-theme color token
