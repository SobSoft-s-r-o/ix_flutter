import 'package:flutter/widgets.dart';

/// Defines the semantic type of a toast notification.
enum IxToastType {
  /// Informational message (default).
  info,

  /// Success message.
  success,

  /// Warning message.
  warning,

  /// Error message.
  error,

  /// Critical error message.
  @Deprecated('Use error. Removed in 2.0.')
  critical,

  /// Alarm message.
  @Deprecated('Use error. Removed in 2.0.')
  alarm,

  /// Neutral message.
  @Deprecated('Use info. Removed in 2.0.')
  neutral,
}

/// Data model representing a single toast notification.
class IxToastData {
  IxToastData({
    required this.id,
    required this.type,
    required this.message,
    this.title,
    this.duration = const Duration(seconds: 5),
    this.autoClose = true,
    this.actionLabel,
    this.onAction,
    this.action,
    this.icon,
    this.iconColor,
    this.hideIcon = false,
    this.dismissOnAction = true,
  });

  /// Unique identifier for the toast.
  final String id;

  /// The semantic type of the toast.
  final IxToastType type;

  /// The main message text.
  final String message;

  /// Optional title/headline.
  final String? title;

  /// Duration before auto-dismissing. Defaults to 5 seconds.
  final Duration? duration;

  /// Whether the toast should auto-close. Defaults to true.
  final bool autoClose;

  /// Label for the default action button. Ignored when [action] is set.
  final String? actionLabel;

  /// Callback for the default action button. Ignored when [action] is set.
  final VoidCallback? onAction;

  /// A fully custom action widget, shown under the message instead of the
  /// default [actionLabel]/[onAction] text button when set.
  final Widget? action;

  /// Custom icon widget. If null, a default icon based on [type] is used.
  final Widget? icon;

  /// Custom icon color.
  final Color? iconColor;

  /// When true, hides the type icon entirely (the message still gets the
  /// full content width).
  final bool hideIcon;

  /// Whether tapping [actionLabel]/[onAction] also closes the toast.
  ///
  /// Defaults to `true`, matching [IxToastService.show]'s 1.x-compatible
  /// behaviour and [IxToastService.showToast]'s current default (the
  /// planned 2.0 release changes [IxToastService.showToast]'s own default
  /// to `false`; [IxToastService.show] is unaffected). Only applies to the
  /// default action button -- a fully custom [action] widget controls its
  /// own dismissal.
  final bool dismissOnAction;
}
