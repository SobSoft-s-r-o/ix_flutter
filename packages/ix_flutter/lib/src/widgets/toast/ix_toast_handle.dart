import 'dart:async';

import 'ix_toast_data.dart';
import 'ix_toast_service.dart';

/// A live reference to a single shown toast, returned by
/// [IxToastService.showToast].
///
/// Mirrors the upstream `toast.ct.ts` pause/resume/`isPaused` API and the
/// close-with-result contract implied by `toast.tsx:163-184,199-213`.
class IxToastHandle {
  /// Constructed by [IxToastService.showToast]. Application code receives
  /// instances from there and should not construct this directly.
  IxToastHandle(this._service, this.data);

  final IxToastService _service;
  final Completer<Object?> _completer = Completer<Object?>();

  /// The data the toast was created with.
  final IxToastData data;

  /// Completes once the toast leaves [IxToastService.toasts], with the
  /// `result` passed to [close] -- or `null` if it was removed some other
  /// way (auto-close, the close button, [IxToastService.dismiss] without a
  /// result, or [IxToastService.dismissAll]).
  Future<Object?> get onClose => _completer.future;

  /// Whether the auto-close countdown is currently paused, via [pause] or
  /// by the user hovering/touching the toast.
  bool get isPaused => _service.isPaused(data.id);

  /// Closes the toast, completing [onClose] with [result].
  void close([Object? result]) => _service.dismiss(data.id, result);

  /// Pauses the auto-close countdown -- the same effect as hovering the
  /// toast with a mouse.
  void pause() => _service.pauseTimer(data.id);

  /// Resumes a countdown paused by [pause] (or by hover).
  void resume() => _service.resumeTimer(data.id);

  /// Completes [onClose] with [result], unless it has already completed.
  ///
  /// Called by [IxToastService] once the toast has actually been removed
  /// from [IxToastService.toasts] -- through [close], the close button, the
  /// auto-close timer, or [IxToastService.dismissAll] -- so [onClose]
  /// resolves exactly once no matter which of those removed it. Not meant
  /// to be called by application code.
  void notifyClosed(Object? result) {
    if (!_completer.isCompleted) {
      _completer.complete(result);
    }
  }
}
