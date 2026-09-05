# IxToast

The `IxToast` component provides non-intrusive notifications to the user. It mirrors the Siemens iX `<ix-toast>` web component. Toasts are stacked and can be configured to auto-close or require user interaction.

## Features

*   **Toast Types**: Supports `info`, `success`, `warning` and `error` types with appropriate styling and icons (`critical`, `alarm` and `neutral` are deprecated aliases -- see [Deprecations](#deprecations)).
*   **Accessibility**: the message (and title) is a live region with `alert`/`status` role so assistive technology announces it as it appears; the close button has an accessible name (`IxToastStrings.closeToast`); every toast control is reachable by keyboard (Tab).
*   **Auto-close**: Configurable duration and auto-close behavior, pausable/resumable.
*   **Progress Bar**: Visual indicator for auto-closing toasts.
*   **Hover/touch pause**: Pauses the auto-close timer when the mouse hovers, or the toast is touched.
*   **Actions**: Supports an optional action button (`actionLabel`/`onAction`) or a fully custom `action` widget.
*   **Safe-area aware layout**: fixed 280px width (shrinks to fit narrower viewports with a 16px margin), positioned via `IxToastPosition`, safe-area padding added on top of its own margin.
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

Access the service and call `show()` to display a toast (kept for 1.x compatibility) or `showToast()` to get back a live `IxToastHandle`.

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

### 4. `showToast()` and `IxToastHandle`

`showToast()` returns an `IxToastHandle` you can hold onto to pause/resume the auto-close countdown, close the toast early with an optional result, and find out how/when it closed:

```dart
final handle = ToastProvider.of(context).showToast(
  type: IxToastType.warning,
  title: 'Uploading',
  message: 'This may take a moment.',
  actionLabel: 'Cancel',
  onAction: () => cancelUpload(),
  // showToast()'s default is true (same as show()); pass false here so
  // tapping the action keeps the toast open until you close it yourself
  // (e.g. once the upload finishes). A planned 2.0 release flips
  // showToast()'s own default to false.
  dismissOnAction: false,
);

handle.pause(); // e.g. while the app is backgrounded
handle.resume();

final result = await handle.onClose; // null unless closed with a result
handle.close('done'); // completes onClose with 'done'
```

`show()` is kept as a 1.x-compatible wrapper: it calls `showToast()` internally and returns just the created `IxToastData` (`showToast(...).data`), with `dismissOnAction` fixed to `true` to match `IxToast`'s original behaviour.

### 5. Positioning and strings

```dart
IxToastOverlay(
  service: _toastService,
  placement: IxToastPosition.bottomRight,
  strings: const IxToastStrings(closeToast: 'Zavrieť'),
)
```

## API Reference

### IxToastService

*   `show({IxToastType type, required String message, String? title, Duration? duration, bool autoClose, String? actionLabel, VoidCallback? onAction, Widget? icon, Color? iconColor})`: Shows a new toast; returns `IxToastData`. 1.x-compatible; internally calls `showToast()`.
*   `showToast({IxToastType type, required String message, String? title, Duration? autoCloseDelay, bool autoClose, String? actionLabel, VoidCallback? onAction, Widget? action, Widget? icon, Color? iconColor, bool hideIcon, bool dismissOnAction})`: Shows a new toast; returns a live `IxToastHandle`.
*   `dismiss(String id, [Object? result])`: Dismisses a specific toast, completing its handle's `onClose` with `result`.
*   `dismissAll()`: Dismisses all active toasts.
*   `pauseTimer(String id)` / `resumeTimer(String id)`: Pause/resume a toast's auto-close countdown.
*   `isPaused(String id)`: Whether a toast's countdown is currently paused.

### IxToastHandle

*   `data`: the `IxToastData` the toast was created with.
*   `onClose`: a `Future<Object?>` that completes once the toast is removed, with the `result` passed to `close()` (or `null` otherwise).
*   `isPaused`: whether the auto-close countdown is currently paused.
*   `close([Object? result])`: closes the toast, completing `onClose` with `result`.
*   `pause()` / `resume()`: pause/resume the auto-close countdown (same effect as hover/touch).

### IxToastType

*   `info` (default)
*   `success`
*   `warning`
*   `error`

### IxToastPosition

*   `topRight` -- `IxToastOverlay.placement`'s 1.x-compatible default.
*   `bottomRight` -- the 2.0 default.

### IxToastStrings

*   `closeToast` (default `'Close toast'`): accessible label and tooltip for the close button.

### IxToastOverlay

*   `service`: The `IxToastService` instance to listen to.
*   `placement`: An `IxToastPosition` -- which corner the toast stack anchors to (default: `IxToastPosition.topRight`; 2.0 default: `IxToastPosition.bottomRight`). Ignored when `position` is set to anything other than its own default.
*   `position` (deprecated -- use `placement`): an `Alignment`, defaulting to `Alignment.topRight`. Kept, and still fully functional exactly as before `placement` existed (both axes honoured), for 1.x callers; when set to anything other than its own default, it takes precedence over `placement`.
*   `strings`: `IxToastStrings`, forwarded to every toast.
*   `width`: target card width in logical pixels (default `280`); shrinks to fit narrower viewports with a 16px margin instead of overflowing.

### IxToastData (additions)

*   `action`: a fully custom action widget, shown under the message instead of the default `actionLabel`/`onAction` text button.
*   `hideIcon`: hides the type icon entirely.
*   `dismissOnAction`: whether tapping the default action button also closes the toast (default `true`, matching both `show()` and `showToast()`'s current default; a planned 2.0 release flips `showToast()`'s own default to `false`).

## Deprecations

*   `IxToastType.critical` / `.alarm` -- use `IxToastType.error` (both now render with the same styling as `error`).
*   `IxToastType.neutral` -- use `IxToastType.info`.
*   `IxToastOverlay.position` (`Alignment`) -- use `placement` (`IxToastPosition`).

## 2.0 default changes

`IxToastOverlay`'s `placement` currently defaults to `IxToastPosition.topRight` and `IxToastService.showToast()`'s `dismissOnAction` currently defaults to `true`, both to preserve 1.x behaviour. The planned 2.0 release changes these defaults to `IxToastPosition.bottomRight` and `dismissOnAction: false` respectively -- `show()`'s behaviour (`dismissOnAction: true`, unaffected by `showToast()`'s default) does not change.
