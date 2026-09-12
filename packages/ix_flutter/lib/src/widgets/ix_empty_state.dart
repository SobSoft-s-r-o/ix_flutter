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
/// This legacy selector has no effect on rendering.
@Deprecated('Has no effect. Omit IxEmptyState.type. Removed in 2.0.')
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
    @Deprecated('Has no effect. Omit type. Removed in 2.0.')
    // ignore: deprecated_member_use_from_same_package
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

  /// Legacy semantic selector; has no effect on rendering.
  @Deprecated('Has no effect. Omit type. Removed in 2.0.')
  // ignore: deprecated_member_use_from_same_package
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final softTextColor =
        theme?.color(IxThemeColorToken.softText) ?? cs.onSurfaceVariant;

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

    // Text styling. Without an IxThemeBuilder theme, fall back to Material's
    // own text theme so the widget still renders a title/subtitle instead of
    // an empty box.
    final titleStyle =
        theme?.textStyle(
          layout == IxEmptyStateLayout.large
              ? IxTypographyVariant.h3
              : IxTypographyVariant.body,
        ) ??
        (layout == IxEmptyStateLayout.large ? tt.titleLarge! : tt.bodyMedium!);

    final subtitleStyle =
        (theme?.textStyle(IxTypographyVariant.body) ?? tt.bodyMedium!).copyWith(
          color: softTextColor,
        );

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
