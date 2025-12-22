import 'package:flutter/widgets.dart';

/// Defines the semantic type of a toast notification.
enum IxToastType {
  /// Informational message (default).
  info,

  /// Success message.
  success,

  /// Warning message.
  warning,

  /// Critical error message.
  critical,

  /// Alarm message.
  alarm,

  /// Neutral message.
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
    this.icon,
    this.iconColor,
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

  /// Label for the action button.
  final String? actionLabel;

  /// Callback for the action button.
  final VoidCallback? onAction;

  /// Custom icon widget. If null, a default icon based on [type] is used.
  final Widget? icon;

  /// Custom icon color.
  final Color? iconColor;
}
