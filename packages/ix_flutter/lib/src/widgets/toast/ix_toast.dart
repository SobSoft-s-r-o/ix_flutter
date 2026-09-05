import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// Fixed card width, in logical pixels, a toast tries to render at.
///
/// Upstream `toast.scss:20-22` (`17.5rem` at the web component's 16px root
/// font size). [IxToastOverlay] is the one that actually enforces this --
/// shrinking it on narrow viewports -- via its own `width`; this constant
/// only keeps a lone [IxToast] (rendered outside an [IxToastOverlay], e.g.
/// in a test or a custom host) from growing unbounded.
const double _kToastWidth = 280;

/// A widget that displays a single toast notification.
class IxToast extends StatefulWidget {
  const IxToast({
    super.key,
    required this.data,
    required this.onDismiss,
    this.onEnter,
    this.onExit,
    this.strings = const IxToastStrings(),
  });

  final IxToastData data;
  final VoidCallback onDismiss;
  final VoidCallback? onEnter;
  final VoidCallback? onExit;

  /// Localizable strings for this toast's chrome (currently just the close
  /// button's accessible name/tooltip).
  final IxToastStrings strings;

  @override
  State<IxToast> createState() => _IxToastState();
}

class _IxToastState extends State<IxToast> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  // The countdown is paused while the toast is hovered OR pressed, and only
  // resumes once neither holds -- a click inside a hovered toast must not
  // resume it out from under the still-present cursor (mouse), and a touch
  // that lifts must not resume it while a separate mouse hover is also
  // active (unlikely in practice, but the two states are tracked
  // independently either way; see IxToastService._startTimer/resumeTimer
  // for the service-side idempotency that backs this up).
  bool _hovered = false;
  bool _pointerDown = false;

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

  /// Maps deprecated [IxToastType] values onto the type that now owns their
  /// styling: `critical`/`alarm` render as [IxToastType.error],  `neutral`
  /// as [IxToastType.info].
  IxToastType _effectiveType(IxToastType type) => switch (type) {
    // ignore: deprecated_member_use_from_same_package
    IxToastType.critical || IxToastType.alarm => IxToastType.error,
    // ignore: deprecated_member_use_from_same_package
    IxToastType.neutral => IxToastType.info,
    _ => type,
  };

  Color _getColor(IxTheme theme, IxToastType type) {
    switch (_effectiveType(type)) {
      case IxToastType.info:
        return theme.color(IxThemeColorToken.info);
      case IxToastType.success:
        return theme.color(IxThemeColorToken.success);
      case IxToastType.warning:
        return theme.color(IxThemeColorToken.warning);
      default:
        return theme.color(IxThemeColorToken.alarm);
    }
  }

  Color _getIconColor(IxTheme theme, IxToastType type) {
    switch (_effectiveType(type)) {
      case IxToastType.info:
        return theme.color(IxThemeColorToken.stdText);
      case IxToastType.success:
        return theme.color(IxThemeColorToken.success);
      case IxToastType.warning:
        return theme.color(IxThemeColorToken.warningText);
      default:
        return theme.color(IxThemeColorToken.alarmText);
    }
  }

  Widget _getIcon(IxToastType type) {
    if (widget.data.icon != null) {
      return widget.data.icon!;
    }

    final iconKey = switch (_effectiveType(type)) {
      IxToastType.info => IxIconKey.info,
      IxToastType.success => IxIconKey.success,
      IxToastType.warning => IxIconKey.warning,
      _ => IxIconKey.error,
    };
    // Redundant with the type icon's meaning already carried by the live
    // region's role/color -- excluded so it doesn't add a second, competing
    // label next to the announced title/message.
    return IxIcon.key(
      iconKey,
      size: IxIconSize.s24,
      excludeFromSemantics: true,
    );
  }

  void _handleAction() {
    widget.data.onAction?.call();
    if (widget.data.dismissOnAction) {
      widget.onDismiss();
    }
  }

  /// Re-derives the paused/running state from [_hovered]/[_pointerDown] and
  /// applies it, idempotently -- safe to call on every pointer/hover event
  /// regardless of whether the combined state actually changed.
  void _applyPauseState() {
    if (!mounted) return; // A pointer event can arrive after dispose.
    if (!widget.data.autoClose || widget.data.duration == null) return;
    if (_hovered || _pointerDown) {
      _progressController.stop();
      widget.onEnter?.call();
    } else {
      // AnimationController.forward() is a no-op once already at 1.0, so
      // this is safe to call even if the countdown had already completed.
      _progressController.forward();
      widget.onExit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final cs = Theme.of(context).colorScheme;

    // Without an IxThemeBuilder theme there is no per-type semantic palette
    // (info/success/warning/... colors) to fall back to, so every toast
    // renders with the same neutral Material colors instead.
    final borderColor = theme != null
        ? _getColor(theme, widget.data.type)
        : cs.outlineVariant;
    final iconColor =
        widget.data.iconColor ??
        (theme != null ? _getIconColor(theme, widget.data.type) : cs.onSurface);
    final backgroundColor =
        theme?.color(IxThemeColorToken.component8) ?? cs.surface;
    final outerBorderColor =
        theme?.color(IxThemeColorToken.softBdr) ?? cs.outlineVariant;
    final closeButtonColor =
        theme?.color(IxThemeColorToken.softText) ?? cs.onSurface;
    final progressColor =
        theme?.color(IxThemeColorToken.softText) ?? cs.onSurface;
    final titleStyle = theme?.typography.h5 ?? IxTypography().h5;
    final bodyStyle = theme?.typography.body ?? IxTypography().body;

    final effectiveAction =
        widget.data.action ??
        (widget.data.actionLabel != null
            ? TextButton(
                // Material 3's default TextButton sizing (a 40px minimum
                // tap target) is meant for a standalone button, not an
                // inline link under a message inside a fixed-height card --
                // shrink it to its text's own intrinsic size so it doesn't
                // blow the toast's height budget (upstream toast.tsx has no
                // equivalent min-height on its `<button>` action slot).
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _handleAction,
                child: Text(widget.data.actionLabel!),
              )
            : null);

    // A node can't carry both an explicit `role` and `liveRegion: true` --
    // Flutter treats `SemanticsRole.alert`/`.status` as already implying
    // live-region behaviour and asserts against the redundant combination
    // (verified empirically: "A node can not have SemanticsRole.status and
    // be live region at the same time"). So the role (`_toastRole` below)
    // is applied to the toast's outer wrapper instead, one boundary node up
    // from this one -- toast.ct.ts:33-53 (live region) and
    // toast.tsx:53-58 (role) both still apply, just to two different nodes.
    final content = Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.data.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(widget.data.title!, style: titleStyle),
            ),
          Text(widget.data.message, style: bodyStyle),
        ],
      ),
    );

    final effectiveType = _effectiveType(widget.data.type);
    final toastRole =
        effectiveType == IxToastType.error ||
            effectiveType == IxToastType.warning
        ? SemanticsRole.alert
        : SemanticsRole.status;

    return Listener(
      // Touch has no hover concept, so a tap only pauses for as long as the
      // pointer is actually down. Releasing (or the gesture being
      // cancelled, e.g. the pointer sliding off-screen) only resumes if the
      // toast also isn't currently hovered by a mouse -- otherwise clicking
      // inside an already-hovered toast would resume it out from under the
      // still-present cursor.
      onPointerDown: (_) {
        _pointerDown = true;
        _applyPauseState();
      },
      onPointerUp: (_) {
        _pointerDown = false;
        _applyPauseState();
      },
      onPointerCancel: (_) {
        _pointerDown = false;
        _applyPauseState();
      },
      child: MouseRegion(
        onEnter: (_) {
          _hovered = true;
          _applyPauseState();
        },
        onExit: (_) {
          _hovered = false;
          _applyPauseState();
        },
        child: Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kToastWidth),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: outerBorderColor),
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
                          child: Semantics(
                            container: true,
                            role: toastRole,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!widget.data.hideIcon) ...[
                                    IconTheme(
                                      data: IconThemeData(color: iconColor),
                                      child: _getIcon(widget.data.type),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        content,
                                        if (effectiveAction != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: effectiveAction,
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    iconSize: 16,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 24,
                                      height: 24,
                                    ),
                                    padding: EdgeInsets.zero,
                                    tooltip: widget.strings.closeToast,
                                    onPressed: widget.onDismiss,
                                    color: closeButtonColor,
                                    // IconButton's own `tooltip:` only sets
                                    // SemanticsData.tooltip, not `.label` (see
                                    // IxIconButton's doc comment) -- merge an
                                    // explicit label into the icon (a
                                    // non-boundary descendant of the button's
                                    // own Semantics(container: true, button:
                                    // true) node) so the button still has a
                                    // spoken accessible name.
                                    icon: Semantics(
                                      label: widget.strings.closeToast,
                                      excludeSemantics: true,
                                      child: IxIcon.key(
                                        IxIconKey.close,
                                        size: IxIconSize.s16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                            progressColor,
                          ),
                          minHeight: 2,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
