import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_core/ix_focus_ring.dart';
import 'package:ix_flutter/src/ix_core/ix_motion.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';
import 'package:ix_flutter/src/ix_icons/ix_icons.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_blind_theme.dart';
import 'package:ix_flutter/src/ix_theme/ix_theme_builder.dart';

export 'package:ix_flutter/src/ix_theme/components/ix_blind_theme.dart'
    show IxBlindVariant;

/// A collapsible container that mirrors the Siemens iX `<ix-blind>` component.
///
/// A blind consists of a header area (chevron, label, optional icon, optional sublabel,
/// optional header actions) and a content area.
///
/// See also:
/// * [IxBlindVariant], which defines the visual style of the blind.
class IxBlind extends StatefulWidget {
  /// Creates a Siemens iX blind.
  const IxBlind({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = IxBlindVariant.filled,
    this.icon,
    this.headerActions,
    this.expanded = false,
    this.onExpandedChanged,
    this.disabled = false,
    required this.child,
  });

  /// The main label of the blind.
  final String title;

  /// An optional secondary label displayed below the title.
  final String? subtitle;

  /// The visual variant of the blind.
  final IxBlindVariant variant;

  /// An optional icon displayed before the title.
  ///
  /// Typically an [IxIcons] widget.
  final Widget? icon;

  /// Optional widgets to display on the right side of the header.
  final Widget? headerActions;

  /// Whether the blind content is visible.
  final bool expanded;

  /// Called when the user taps the header to toggle the expanded state.
  ///
  /// If null, the blind is interactive but will not toggle (unless handled externally,
  /// but typically this callback is required for interaction).
  final ValueChanged<bool>? onExpandedChanged;

  /// Whether the blind is disabled.
  final bool disabled;

  /// The content to display when the blind is expanded.
  final Widget child;

  @override
  State<IxBlind> createState() => _IxBlindState();
}

class _IxBlindState extends State<IxBlind> {
  // Tracks whether the header's InkWell currently has keyboard focus, so the
  // focus ring can be painted around the *whole* blind (see build() below)
  // rather than clipped away by the outer Container's `Clip.antiAlias`.
  bool _headerFocused = false;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final blindTheme =
        themeData.extension<IxBlindTheme>() ?? IxBlindTheme.fallback(themeData);
    final style = blindTheme.style(widget.variant);

    // Resolve colors based on state (hover, active handled by InkWell/Material)
    // But we need to set the base style.
    // Since we use InkWell, we can rely on its splash/highlight, but we need
    // to set the container background and border.

    // The ring wraps the whole Container (not just the header) because the
    // header sits flush against the Container's own edge: a ring painted
    // around the header alone would extend past that edge and be clipped
    // away by the Container's `Clip.antiAlias`.
    return IxFocusRing(
      focused: _headerFocused,
      borderRadius: BorderRadius.circular(blindTheme.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: style.background,
          border: Border.all(
            color: style.borderColor,
            width: blindTheme.borderWidth,
          ),
          borderRadius: BorderRadius.circular(blindTheme.borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IxBlindHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              headerActions: widget.headerActions,
              expanded: widget.expanded,
              onTap: widget.disabled
                  ? null
                  : () => widget.onExpandedChanged?.call(!widget.expanded),
              style: style,
              disabled: widget.disabled,
              onFocusChanged: (focused) =>
                  setState(() => _headerFocused = focused),
            ),
            AnimatedSize(
              duration: IxMotion.of(context, IxMotion.defaultTime),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: widget.expanded
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: style.borderColor,
                            width: blindTheme.borderWidth,
                          ),
                        ),
                      ),
                      child: widget.child,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _IxBlindHeader extends StatelessWidget {
  const _IxBlindHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.headerActions,
    required this.expanded,
    this.onTap,
    required this.style,
    required this.disabled,
    this.onFocusChanged,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? headerActions;
  final bool expanded;
  final VoidCallback? onTap;
  final IxBlindStyle style;
  final bool disabled;
  final ValueChanged<bool>? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    final ixTypography = IxTheme.maybeOf(context)?.typography ?? IxTypography();

    // Determine foreground color
    final foregroundColor = style.foreground;

    return Material(
      color: Colors.transparent, // Container handles background
      child: InkWell(
        onTap: onTap,
        focusColor: Colors.transparent,
        onFocusChange: onFocusChanged,
        hoverColor: style.hoverBackground.withValues(
          alpha: style.hoverBackground.a * 0.1,
        ), // Use a subtle overlay

        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: IxCommonGeometry.space3, // 1rem
            vertical: IxCommonGeometry.space1, // 0.5rem
          ),
          constraints: const BoxConstraints(minHeight: 48.0), // 3rem
          child: Row(
            children: [
              // Chevron
              AnimatedRotation(
                turns: expanded ? 0.25 : 0.0,
                duration: IxMotion.of(context, IxMotion.defaultTime),
                child: IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 24),
                  child: IxIcons.chevronRight,
                ),
              ),
              const SizedBox(width: IxCommonGeometry.space1), // 0.5rem
              // Optional Icon
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 24),
                  child: icon!,
                ),
                const SizedBox(width: IxCommonGeometry.space1),
              ],

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: ixTypography.label.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: ixTypography.bodySm.copyWith(
                          color: foregroundColor.withValues(
                            alpha: foregroundColor.a * 0.8,
                          ), // Slightly lighter
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Header Actions
              if (headerActions != null) ...[
                const SizedBox(width: 8.0),
                // Prevent header actions from triggering the blind toggle?
                // The user said: "except where header actions might intercept the event".
                // If headerActions contains buttons, they will intercept taps if they handle them.
                headerActions!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A helper widget to display a list of blinds with proper spacing.
class IxBlindAccordion extends StatelessWidget {
  const IxBlindAccordion({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8.0), // 0.5rem spacing
          children[i],
        ],
      ],
    );
  }
}
