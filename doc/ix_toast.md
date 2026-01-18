# IxToast

The `IxToast` component provides non-intrusive notifications to the user. It mirrors the Siemens iX `<ix-toast>` web component. Toasts are stacked and can be configured to auto-close or require user interaction.

## Features

*   **Toast Types**: Supports `info`, `success`, `warning`, `critical`, `alarm`, and `neutral` types with appropriate styling and icons.
*   **Auto-close**: Configurable duration and auto-close behavior.
*   **Progress Bar**: Visual indicator for auto-closing toasts.
*   **Hover Pause**: Pauses the auto-close timer when the mouse hovers over the toast.
*   **Actions**: Supports an optional action button.
*   **Theming**: Fully integrated with `IxTheme` for consistent styling.

## Usage

To use toasts in your application, you need to set up the `IxToastService` and `IxToastOverlay`.

### 1. Setup

Initialize the `IxToastService` and place the `IxToastOverlay` in your application's widget tree, typically in the `builder` of your `MaterialApp` to ensure it floats above all other content.

It is recommended to use an `InheritedWidget` or a state management solution (like Provider or Riverpod) to make the `IxToastService` accessible throughout your app.

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

// Simple InheritedWidget to provide the service
class ToastProvider extends InheritedWidget {
  const ToastProvider({super.key, required this.service, required super.child});

  final IxToastService service;

  static IxToastService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ToastProvider>();
    if (provider == null) throw FlutterError('ToastProvider not found');
    return provider.service;
  }

  @override
  bool updateShouldNotify(ToastProvider oldWidget) => service != oldWidget.service;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _toastService = IxToastService();

  @override
  void dispose() {
    _toastService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastProvider(
      service: _toastService,
      child: MaterialApp(
        title: 'IxToast Demo',
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              // Place the overlay on top
              IxToastOverlay(service: _toastService),
            ],
          );
        },
        home: const HomePage(),
      ),
    );
  }
}
```

### 2. Showing Toasts

Access the service and call `show()` to display a toast.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                ToastProvider.of(context).show(
                  message: 'This is a basic toast message.',
                );
              },
              child: const Text('Show Toast'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ToastProvider.of(context).show(
                  type: IxToastType.success,
                  title: 'Success',
                  message: 'Operation completed successfully.',
                );
              },
              child: const Text('Show Success Toast'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Toast with Action

You can add an action button to the toast.

```dart
ToastProvider.of(context).show(
  message: 'Item deleted.',
  actionLabel: 'Undo',
  onAction: () {
    // Handle undo action
    print('Undo clicked');
  },
);
```

## API Reference

### IxToastService

*   `show({IxToastType type, required String message, String? title, Duration? duration, bool autoClose, String? actionLabel, VoidCallback? onAction})`: Shows a new toast.
*   `dismiss(String id)`: Dismisses a specific toast.
*   `dismissAll()`: Dismisses all active toasts.

### IxToastType

*   `info` (default)
*   `success`
*   `warning`
*   `critical`
*   `alarm`
*   `neutral`

### IxToastOverlay

*   `service`: The `IxToastService` instance to listen to.
*   `position`: The alignment of the toast stack (default: `Alignment.topRight`).
