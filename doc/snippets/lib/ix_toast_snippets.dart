import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

// Simple InheritedWidget to provide the service
class ToastProvider extends InheritedWidget {
  const ToastProvider({super.key, required this.service, required super.child});

  final IxToastService service;

  static IxToastService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ToastProvider>();
    if (provider == null) throw FlutterError('ToastProvider not found');
    return provider.service;
  }

  @override
  bool updateShouldNotify(ToastProvider oldWidget) =>
      service != oldWidget.service;
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
              ?child,
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
                ToastProvider.of(
                  context,
                ).showToast(message: 'This is a basic toast message.');
              },
              child: const Text('Show Toast'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ToastProvider.of(context).showToast(
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

void showToastWithAction(BuildContext context, {required VoidCallback onUndo}) {
  ToastProvider.of(
    context,
  ).showToast(message: 'Item deleted.', actionLabel: 'Undo', onAction: onUndo);
}

Future<Object?> showUploadToast(
  BuildContext context, {
  required VoidCallback cancelUpload,
}) async {
  final handle = ToastProvider.of(context).showToast(
    type: IxToastType.warning,
    title: 'Uploading',
    message: 'This may take a moment.',
    actionLabel: 'Cancel',
    onAction: cancelUpload,
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
  return result;
}

Widget bottomRightToastOverlay(IxToastService service) => IxToastOverlay(
  service: service,
  placement: IxToastPosition.bottomRight,
  strings: const IxToastStrings(closeToast: 'Dismiss'),
);
