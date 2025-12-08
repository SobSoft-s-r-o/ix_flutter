import 'dart:async';

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ix_toast_data.dart';

/// Service to manage toast notifications.
class IxToastService extends ChangeNotifier {
  final List<IxToastData> _toasts = [];
  final Map<String, Timer> _timers = {};
  int _counter = 0;

  /// Current list of active toasts.
  List<IxToastData> get toasts => List.unmodifiable(_toasts);

  /// Shows a new toast notification.
  ///
  /// Returns the created [IxToastData].
  IxToastData show({
    IxToastType type = IxToastType.info,
    required String message,
    String? title,
    Duration? duration = const Duration(seconds: 5),
    bool autoClose = true,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? icon,
    Color? iconColor,
  }) {
    _counter++;
    final id = '${DateTime.now().millisecondsSinceEpoch}-$_counter';
    final toast = IxToastData(
      id: id,
      type: type,
      message: message,
      title: title,
      duration: duration,
      autoClose: autoClose,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon,
      iconColor: iconColor,
    );

    _toasts.add(toast);
    notifyListeners();

    if (autoClose && duration != null) {
      _timers[id] = Timer(duration, () {
        dismiss(id);
      });
    }

    return toast;
  }

  /// Dismisses a toast by its ID.
  void dismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _toasts.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Dismisses all active toasts.
  void dismissAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _toasts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    dismissAll();
    super.dispose();
  }
}
