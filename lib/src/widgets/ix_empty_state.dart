import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// The layout variant of the [IxEmptyState].
enum IxEmptyStateLayout {
  /// Large layout with centered content and large icon.
  large,

  /// Compact layout with horizontal alignment.
  compact,

  /// Compact layout with horizontal alignment but content breaks to new line.
  compactBreak,
}

/// The semantic variant of the [IxEmptyState].
///
/// Note: The web component `<ix-empty-state>` does not currently support
/// semantic variants (like error, warning, etc.) via a property.
/// This enum is provided for future compatibility and API consistency.
enum IxEmptyStateType { neutral, info, warning, error, success }

/// A widget that mirrors the Siemens iX `<ix-empty-state>` component.
///
/// An empty state is used to communicate that there is currently no data,
/// content, or result for a given view or context.
class IxEmptyState extends StatelessWidget {
  const IxEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.type = IxEmptyStateType.neutral,
    this.layout = IxEmptyStateLayout.large,
    this.primaryAction,
    this.secondaryAction,
  });

  /// Optional icon or illustration to show above the text.
  final Widget? icon;

  /// Main headline/title text.
  final String title;

  /// Optional subtitle/description text.
  final String? subtitle;

  /// Visual/semantic variant (maps to iX empty state variants).
  final IxEmptyStateType type;

  /// The layout variant of the empty state.
  final IxEmptyStateLayout layout;

  /// Optional primary action widget (usually a button).
  final Widget? primaryAction;

  /// Optional secondary action widget (e.g. text button or link).
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    if (theme == null) return const SizedBox.shrink();

    final softTextColor = theme.color(IxThemeColorToken.softText);

    // Icon styling
    Widget? styledIcon;
    if (icon != null) {
      // Web component scales icon by 1.75 for large layout.
      // Base size is 32px (space5).
      // Large size: 32 * 1.75 = 56px.
      final double iconSize = layout == IxEmptyStateLayout.large ? 56.0 : 32.0;

      styledIcon = IconTheme(
        data: IconThemeData(size: iconSize, color: softTextColor),
        child: icon!,
      );
    }

    // Text styling
    final titleStyle = theme.textStyle(
      layout == IxEmptyStateLayout.large
          ? IxTypographyVariant.h3
          : IxTypographyVariant.body,
    );

    final subtitleStyle = theme
        .textStyle(IxTypographyVariant.body)
        .copyWith(color: softTextColor);

    // Spacing
    final double iconGap = IxCommonGeometry.space3; // 16px (default-space)
    final double contentGap = layout == IxEmptyStateLayout.large
        ? IxCommonGeometry
              .space5 // 32px (large-space)
        : IxCommonGeometry.space3; // 16px (default-space)
    final double labelGap = IxCommonGeometry.space1; // 8px (small-space)

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: layout == IxEmptyStateLayout.compactBreak
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: layout == IxEmptyStateLayout.compactBreak
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: titleStyle,
              textAlign: layout == IxEmptyStateLayout.compactBreak
                  ? TextAlign.start
                  : TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: labelGap),
              Text(
                subtitle!,
                style: subtitleStyle,
                textAlign: layout == IxEmptyStateLayout.compactBreak
                    ? TextAlign.start
                    : TextAlign.center,
              ),
            ],
          ],
        ),
        if (primaryAction != null || secondaryAction != null) ...[
          SizedBox(height: contentGap),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: layout == IxEmptyStateLayout.compactBreak
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (primaryAction != null) primaryAction!,
              if (primaryAction != null && secondaryAction != null)
                const SizedBox(width: 16), // Spacing between actions
              if (secondaryAction != null) secondaryAction!,
            ],
          ),
        ],
      ],
    );

    if (layout == IxEmptyStateLayout.large) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (styledIcon != null) ...[styledIcon, SizedBox(height: iconGap)],
          content,
        ],
      );
    } else {
      // compact and compactBreak
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: layout == IxEmptyStateLayout.compactBreak
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (styledIcon != null) ...[styledIcon, SizedBox(width: iconGap)],
          Flexible(child: content),
        ],
      );
    }
  }
}
