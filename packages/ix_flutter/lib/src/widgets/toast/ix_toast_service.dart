import 'dart:async';

import 'package:flutter/widgets.dart';

import 'ix_toast_data.dart';

part 'ix_toast_handle.dart';

/// Service to manage toast notifications.
class IxToastService extends ChangeNotifier {
  final List<IxToastData> _toasts = [];
  final Map<String, IxToastHandle> _handles = {};
  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _startTimes = {};
  final Map<String, Duration> _remainingTimes = {};
  final Set<String> _pausedIds = {};
  int _counter = 0;
  bool _disposed = false;

  /// The time source used to compute auto-close countdowns.
  ///
  /// Overridable so tests can drive `pauseTimer`/`resumeTimer` timing
  /// deterministically under `package:fake_async`'s `fakeAsync()` -- plain
  /// `DateTime.now()` is not zone-aware and ignores the fake clock. Assign
  /// `clock.now` (from the `clock` package, a dev dependency of this
  /// package) inside a `fakeAsync` callback, e.g. `service.now = clock.now;`.
  @visibleForTesting
  DateTime Function() now = DateTime.now;

  /// Current list of active toasts.
  List<IxToastData> get toasts => List.unmodifiable(_toasts);

  /// Shows a new toast notification.
  ///
  /// Returns the created [IxToastData]. Kept for 1.x compatibility --
  /// prefer [showToast], which returns an [IxToastHandle] that can be
  /// paused, resumed and awaited for its close result. Internally this
  /// just calls [showToast] and returns its [IxToastHandle.data].
  ///
  /// This overload's defaults (`dismissOnAction: true`) match `IxToast`'s
  /// 1.x behaviour; [showToast]'s own default is also `true` today (a
  /// planned 2.0 change flips [showToast]'s default to `false` -- `show`
  /// is unaffected).
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
    return showToast(
      type: type,
      message: message,
      title: title,
      autoCloseDelay: duration,
      autoClose: autoClose,
      actionLabel: actionLabel,
      onAction: onAction,
      icon: icon,
      iconColor: iconColor,
      dismissOnAction: true,
    ).data;
  }

  /// Shows a new toast notification and returns a live [IxToastHandle] for
  /// it.
  ///
  /// The handle can [IxToastHandle.pause]/[IxToastHandle.resume] the
  /// auto-close countdown, [IxToastHandle.close] the toast early with an
  /// optional result, and await [IxToastHandle.onClose] to learn when and
  /// how it was closed.
  IxToastHandle showToast({
    IxToastType type = IxToastType.info,
    required String message,
    String? title,
    Duration? autoCloseDelay = const Duration(seconds: 5),
    bool autoClose = true,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? action,
    Widget? icon,
    Color? iconColor,
    bool hideIcon = false,
    bool dismissOnAction = true,
  }) {
    _counter++;
    final id = '${DateTime.now().millisecondsSinceEpoch}-$_counter';
    final toast = IxToastData(
      id: id,
      type: type,
      message: message,
      title: title,
      duration: autoCloseDelay,
      autoClose: autoClose,
      actionLabel: actionLabel,
      onAction: onAction,
      action: action,
      icon: icon,
      iconColor: iconColor,
      hideIcon: hideIcon,
      dismissOnAction: dismissOnAction,
    );
    final handle = IxToastHandle._(this, toast);
    _handles[id] = handle;

    _toasts.add(toast);
    notifyListeners();

    if (autoClose && autoCloseDelay != null) {
      _startTimer(id, autoCloseDelay);
    }

    return handle;
  }

  void _startTimer(String id, Duration duration) {
    // Cancel first: a previous timer for this id must never be left running
    // (and thus orphaned once this map entry is overwritten below) --
    // without this, a redundant resumeTimer call could leave two live
    // Timers racing for the same id, the earlier of which a later
    // pauseTimer can no longer reach to cancel.
    _timers[id]?.cancel();
    _startTimes[id] = now();
    _remainingTimes[id] = duration;
    _timers[id] = Timer(duration, () {
      dismiss(id);
    });
  }

  /// Pauses the auto-close timer for a toast.
  ///
  /// The paused set is observable state ([isPaused]), so listeners are
  /// notified: the toast widget stops its own progress bar from it, rather
  /// than only knowing about the pauses it caused itself.
  void pauseTimer(String id) {
    final timer = _timers[id];
    if (timer != null && timer.isActive) {
      timer.cancel();
      _timers.remove(id);
      _pausedIds.add(id);
      _notifyListeners();

      final startTime = _startTimes[id];
      final initialDuration = _remainingTimes[id];

      if (startTime != null && initialDuration != null) {
        final elapsed = now().difference(startTime);
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
  ///
  /// A no-op unless [id] is currently paused and has no timer already
  /// running -- idempotent, so redundant calls (e.g. a mouse-hover exit
  /// arriving in the same frame as an unrelated pointer-up) never start a
  /// second, un-tracked timer racing the first.
  void resumeTimer(String id) {
    if (!_pausedIds.contains(id) || (_timers[id]?.isActive ?? false)) {
      return;
    }
    _pausedIds.remove(id);
    // Only resume if it's in the list (not dismissed) and has remaining time
    if (_toasts.any((t) => t.id == id) && _remainingTimes.containsKey(id)) {
      final remaining = _remainingTimes[id]!;
      _startTimer(id, remaining);
    }
    _notifyListeners();
  }

  /// Whether the auto-close countdown for toast [id] is currently paused
  /// (via [pauseTimer]/[IxToastHandle.pause], or by the toast widget's own
  /// hover/touch handling).
  bool isPaused(String id) => _pausedIds.contains(id);

  /// Dismisses a toast by its ID, completing its [IxToastHandle.onClose]
  /// with [result].
  /// A no-op for an id that is not live, and for a service that has already
  /// been disposed: an [IxToastHandle] outlives the toast it refers to (an
  /// app may keep one to close later), and a `ChangeNotifier` that has been
  /// disposed throws when it is notified.
  void dismiss(String id, [Object? result]) {
    if (_disposed ||
        !_handles.containsKey(id) && !_toasts.any((t) => t.id == id)) {
      return;
    }
    _timers[id]?.cancel();
    _timers.remove(id);
    _startTimes.remove(id);
    _remainingTimes.remove(id);
    _pausedIds.remove(id);
    _toasts.removeWhere((t) => t.id == id);
    _notifyListeners();
    _handles.remove(id)?._notifyClosed(result);
  }

  /// Dismisses all active toasts.
  void dismissAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _startTimes.clear();
    _remainingTimes.clear();
    _pausedIds.clear();
    _toasts.clear();
    _notifyListeners();
    // Every handle, not only the ones whose toast was still live: a handle
    // that outlived its toast still owes its owner a completed `onClose`.
    final handles = List<IxToastHandle>.from(_handles.values);
    _handles.clear();
    for (final handle in handles) {
      handle._notifyClosed(null);
    }
  }

  /// [notifyListeners], skipped once the service is disposed.
  void _notifyListeners() {
    if (_disposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    dismissAll();
    _disposed = true;
    super.dispose();
  }
}
