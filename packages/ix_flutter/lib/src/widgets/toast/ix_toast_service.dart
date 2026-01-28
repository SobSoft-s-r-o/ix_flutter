import 'dart:async';

import 'package:flutter/widgets.dart';

import 'ix_toast_data.dart';

/// Service to manage toast notifications.
class IxToastService extends ChangeNotifier {
  final List<IxToastData> _toasts = [];
  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _startTimes = {};
  final Map<String, Duration> _remainingTimes = {};
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
      _startTimer(id, duration);
    }

    return toast;
  }

  void _startTimer(String id, Duration duration) {
    _startTimes[id] = DateTime.now();
    _remainingTimes[id] = duration;
    _timers[id] = Timer(duration, () {
      dismiss(id);
    });
  }

  /// Pauses the auto-close timer for a toast.
  void pauseTimer(String id) {
    final timer = _timers[id];
    if (timer != null && timer.isActive) {
      timer.cancel();
      _timers.remove(id);

      final startTime = _startTimes[id];
      final initialDuration = _remainingTimes[id];

      if (startTime != null && initialDuration != null) {
        final elapsed = DateTime.now().difference(startTime);
        final remaining = initialDuration - elapsed;
        if (remaining > Duration.zero) {
          _remainingTimes[id] = remaining;
        } else {
          // Should have fired already, but just in case
          dismiss(id);
        }
      }
    }
  }

  /// Resumes the auto-close timer for a toast.
  void resumeTimer(String id) {
    // Only resume if it's in the list (not dismissed) and has remaining time
    if (_toasts.any((t) => t.id == id) && _remainingTimes.containsKey(id)) {
      final remaining = _remainingTimes[id]!;
      _startTimer(id, remaining);
    }
  }

  /// Dismisses a toast by its ID.
  void dismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _startTimes.remove(id);
    _remainingTimes.remove(id);
    _toasts.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// Dismisses all active toasts.
  void dismissAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _startTimes.clear();
    _remainingTimes.clear();
    _toasts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    dismissAll();
    super.dispose();
  }
}
