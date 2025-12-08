import 'package:flutter/widgets.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class ToastProvider extends InheritedWidget {
  const ToastProvider({super.key, required this.service, required super.child});

  final IxToastService service;

  static IxToastService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ToastProvider>();
    if (provider == null) {
      throw FlutterError('ToastProvider not found in context');
    }
    return provider.service;
  }

  @override
  bool updateShouldNotify(ToastProvider oldWidget) =>
      service != oldWidget.service;
}
