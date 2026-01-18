import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:ix_flutter/src/ix_icons/ix_icons.dart';

/// A widget that displays a single toast notification.
class IxToast extends StatefulWidget {
  const IxToast({
    super.key,
    required this.data,
    required this.onDismiss,
    this.onEnter,
    this.onExit,
  });

  final IxToastData data;
  final VoidCallback onDismiss;
  final VoidCallback? onEnter;
  final VoidCallback? onExit;

  @override
  State<IxToast> createState() => _IxToastState();
}

class _IxToastState extends State<IxToast> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.data.duration ?? Duration.zero,
    );

    if (widget.data.autoClose && widget.data.duration != null) {
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color _getColor(IxTheme theme, IxToastType type) {
    switch (type) {
      case IxToastType.info:
        return theme.color(IxThemeColorToken.info);
      case IxToastType.success:
        return theme.color(IxThemeColorToken.success);
      case IxToastType.warning:
        return theme.color(IxThemeColorToken.warning);
      case IxToastType.critical:
        return theme.color(IxThemeColorToken.critical);
      case IxToastType.alarm:
        return theme.color(IxThemeColorToken.alarm);
      case IxToastType.neutral:
        return theme.color(IxThemeColorToken.neutral);
    }
  }

  Color _getIconColor(IxTheme theme, IxToastType type) {
    // Based on iX design, icons usually have specific colors.
    // For filled toasts, it might be contrast color.
    // But iX toasts are usually white background with colored border/icon.
    // Let's check the web component styles again.
    // The web component has `toast-icon` with `color-std-text` for info, `color-alarm` for error, etc.

    switch (type) {
      case IxToastType.info:
        return theme.color(IxThemeColorToken.stdText); // or info?
      case IxToastType.success:
        return theme.color(IxThemeColorToken.success);
      case IxToastType.warning:
        return theme.color(IxThemeColorToken.warningText); // or warning?
      case IxToastType.critical:
        return theme.color(IxThemeColorToken.critical);
      case IxToastType.alarm:
        return theme.color(IxThemeColorToken.alarmText); // or alarm?
      case IxToastType.neutral:
        return theme.color(IxThemeColorToken.stdText);
    }
  }

  Widget _getIcon(IxTheme theme) {
    if (widget.data.icon != null) {
      return widget.data.icon!;
    }

    switch (widget.data.type) {
      case IxToastType.info:
        return IxIcons.info;
      case IxToastType.success:
        return IxIcons.success;
      case IxToastType.warning:
        return IxIcons.warning;
      case IxToastType.critical:
        return IxIcons.error; // Critical maps to error icon usually
      case IxToastType.alarm:
        return IxIcons.alarm;
      case IxToastType.neutral:
        return IxIcons.info; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    if (theme == null) return const SizedBox.shrink();

    final borderColor = _getColor(theme, widget.data.type);
    final iconColor =
        widget.data.iconColor ?? _getIconColor(theme, widget.data.type);

    return MouseRegion(
      onEnter: (_) {
        if (widget.data.autoClose && widget.data.duration != null) {
          _progressController.stop();
          widget.onEnter?.call();
        }
      },
      onExit: (_) {
        if (widget.data.autoClose && widget.data.duration != null) {
          // Only resume if we haven't completed yet.
          // If we stopped at 1.0 (completed), we shouldn't restart unless we reset.
          // But usually we stop *before* completion.
          // However, if the user hovers, we want to keep it open.
          // When they leave, we resume the countdown.
          _progressController.forward();
          widget.onExit?.call();
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 320, // Standard width for toasts
          decoration: BoxDecoration(
            color: theme.color(IxThemeColorToken.component8), // Background
            border: Border.all(color: theme.color(IxThemeColorToken.softBdr)),
            borderRadius: BorderRadius.circular(4), // Standard radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.16,
                ), // shadow-2 approximation
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left border strip
                    Container(width: 4, color: borderColor),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            IconTheme(
                              data: IconThemeData(color: iconColor, size: 24),
                              child: _getIcon(theme),
                            ),
                            const SizedBox(width: 16),
                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.data.title != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Text(
                                        widget.data.title!,
                                        style: theme.typography.h5,
                                      ),
                                    ),
                                  Text(
                                    widget.data.message,
                                    style: theme.typography.body,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Action & Close
                    if (widget.data.actionLabel != null ||
                        true) // Always show close button
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (widget.data.actionLabel != null)
                                TextButton(
                                  onPressed: () {
                                    widget.data.onAction?.call();
                                    // Should action close the toast? Usually yes.
                                    widget.onDismiss();
                                  },
                                  child: Text(widget.data.actionLabel!),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                ), // Use IxIcons.close if available
                                onPressed: widget.onDismiss,
                                color: theme.color(IxThemeColorToken.softText),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Progress Bar
              if (widget.data.autoClose && widget.data.duration != null)
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: 1.0 - _progressController.value,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.color(IxThemeColorToken.softText),
                      ),
                      minHeight: 2,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
