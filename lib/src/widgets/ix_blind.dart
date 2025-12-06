import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_typography.dart';
import 'package:siemens_ix_flutter/src/ix_icons/ix_icons.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_blind_theme.dart';

export 'package:siemens_ix_flutter/src/ix_theme/components/ix_blind_theme.dart'
    show IxBlindVariant;

/// A collapsible container that mirrors the Siemens iX `<ix-blind>` component.
///
/// A blind consists of a header area (chevron, label, optional icon, optional sublabel,
/// optional header actions) and a content area.
///
/// See also:
/// * [IxBlindVariant], which defines the visual style of the blind.
class IxBlind extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final blindTheme =
        themeData.extension<IxBlindTheme>() ?? IxBlindTheme.fallback(themeData);
    final style = blindTheme.style(variant);

    // Resolve colors based on state (hover, active handled by InkWell/Material)
    // But we need to set the base style.
    // Since we use InkWell, we can rely on its splash/highlight, but we need
    // to set the container background and border.

    return Container(
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
            title: title,
            subtitle: subtitle,
            icon: icon,
            headerActions: headerActions,
            expanded: expanded,
            onTap: disabled ? null : () => onExpandedChanged?.call(!expanded),
            style: style,
            disabled: disabled,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: style.borderColor,
                          width: blindTheme.borderWidth,
                        ),
                      ),
                    ),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _IxBlindHeader extends StatefulWidget {
  const _IxBlindHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.headerActions,
    required this.expanded,
    this.onTap,
    required this.style,
    required this.disabled,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? headerActions;
  final bool expanded;
  final VoidCallback? onTap;
  final IxBlindStyle style;
  final bool disabled;

  @override
  State<_IxBlindHeader> createState() => _IxBlindHeaderState();
}

class _IxBlindHeaderState extends State<_IxBlindHeader> {
  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final ixTypography = themeData.extension<IxTypography>() ?? IxTypography();

    // Determine foreground color
    final foregroundColor = widget.style.foreground;

    return Material(
      color: Colors.transparent, // Container handles background
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: widget.style.hoverBackground.withOpacity(
          0.1,
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
                turns: widget.expanded ? 0.25 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 24),
                  child: IxIcons.chevronRight,
                ),
              ),
              const SizedBox(width: IxCommonGeometry.space1), // 0.5rem
              // Optional Icon
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: foregroundColor, size: 24),
                  child: widget.icon!,
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
                      widget.title,
                      style: ixTypography.label.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: ixTypography.bodySm.copyWith(
                          color: foregroundColor.withOpacity(
                            0.8,
                          ), // Slightly lighter
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Header Actions
              if (widget.headerActions != null) ...[
                const SizedBox(width: 8.0),
                // Prevent header actions from triggering the blind toggle?
                // The user said: "except where header actions might intercept the event".
                // If headerActions contains buttons, they will intercept taps if they handle them.
                widget.headerActions!,
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
