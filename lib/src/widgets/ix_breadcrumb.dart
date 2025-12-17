import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:siemens_ix_flutter/src/ix_icons/ix_icons.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_breadcrumb_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_button_theme.dart';

/// Available visual treatments for breadcrumb buttons.
enum IxBreadcrumbButtonAppearance { tertiary, subtlePrimary }

const double _separatorIconExtent = 16.0;

/// Adaptive Siemens IX breadcrumb navigation that matches the web behavior.
class IxBreadcrumb extends StatelessWidget {
  const IxBreadcrumb({
    super.key,
    required this.items,
    this.visibleItemCount = 9,
    this.buttonAppearance = IxBreadcrumbButtonAppearance.tertiary,
    this.nextItems = const <IxBreadcrumbMenuItem>[],
    this.previousItemsLabel = 'Previous levels',
    this.semanticLabel,
    this.onItemPressed,
    this.onNextItemPressed,
    this.homeIcon,
    this.homeMenuLabel = 'Navigate to level',
    this.showHomeLabel = false,
    this.showNavigationMenu = true,
  }) : assert(visibleItemCount > 0, 'visibleItemCount must be positive');

  /// Ordered breadcrumb path. Items beyond [visibleItemCount] collapse
  /// into the overflow dropdown at the beginning of the path.
  final List<IxBreadcrumbItemData> items;

  /// Maximum number of path items that remain visible.
  final int visibleItemCount;

  /// Controls which Siemens IX button appearance the breadcrumbs adopt.
  final IxBreadcrumbButtonAppearance buttonAppearance;

  /// Optional dropdown entries attached to the last breadcrumb, representing
  /// child destinations.
  final List<IxBreadcrumbMenuItem> nextItems;

  /// Semantic label used for the navigation menu wired to the home button.
  final String previousItemsLabel;

  /// Optional semantic description applied to the entire breadcrumb widget.
  final String? semanticLabel;

  /// Fired whenever a visible or overflow breadcrumb item is tapped.
  final ValueChanged<IxBreadcrumbItemData>? onItemPressed;

  /// Fired whenever a trailing "next" menu item is tapped.
  final ValueChanged<IxBreadcrumbMenuItem>? onNextItemPressed;

  /// Optional replacement for the root home icon.
  final Widget? homeIcon;

  /// Optional override for the navigation menu semantics. Falls back to
  /// [previousItemsLabel] when empty.
  final String homeMenuLabel;

  /// Displays the textual label next to the home icon when true.
  final bool showHomeLabel;

  /// Whether tapping the home button should surface the navigation menu.
  final bool showNavigationMenu;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final breadcrumbTheme =
        themeData.extension<IxBreadcrumbTheme>() ??
        IxBreadcrumbTheme.fallback(themeData);
    final ixButtonTheme = themeData.extension<IxButtonTheme>();
    final baseButtonStyle = switch (buttonAppearance) {
      IxBreadcrumbButtonAppearance.subtlePrimary =>
        ixButtonTheme?.subtlePrimary,
      IxBreadcrumbButtonAppearance.tertiary => ixButtonTheme?.tertiary,
    };
    final buttonStyle = _resolveButtonStyle(baseButtonStyle, breadcrumbTheme);
    final defaultStates = const <WidgetState>{};
    final resolvedTextColor = buttonStyle.foregroundColor?.resolve(
      defaultStates,
    );
    final resolvedIconColor =
        buttonStyle.iconColor?.resolve(defaultStates) ??
        resolvedTextColor ??
        breadcrumbTheme.iconColor;
    final interactiveLabelStyle = breadcrumbTheme.labelStyle.copyWith(
      color: resolvedTextColor ?? breadcrumbTheme.labelStyle.color,
    );

    if (items.isEmpty) {
      return SizedBox(height: breadcrumbTheme.height);
    }

    final rootItem = items.first;
    final navigationItems = items.length > 1
        ? List<IxBreadcrumbItemData>.unmodifiable(items.sublist(1))
        : const <IxBreadcrumbItemData>[];
    final textDirection = Directionality.of(context);
    final menuSemanticLabel = homeMenuLabel.isEmpty
        ? previousItemsLabel
        : homeMenuLabel;

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleSlots = math.max(0, visibleItemCount - 1);
        var overflowCount = math.max(0, navigationItems.length - visibleSlots);

        if (constraints.maxWidth.isFinite) {
          final homeWidth = _homeButtonWidth(
            theme: breadcrumbTheme,
            textDirection: textDirection,
            label: rootItem.label,
            showNavigationMenu: showNavigationMenu && items.length > 1,
            showHomeLabel: showHomeLabel,
          );
          var remainingWidth = constraints.maxWidth - homeWidth;
          if (navigationItems.isNotEmpty) {
            remainingWidth -=
                breadcrumbTheme.itemSpacing * 2 + _separatorIconExtent;
          }

          overflowCount = _expandOverflowToFit(
            initialOverflow: overflowCount,
            maxWidth: remainingWidth,
            items: navigationItems,
            nextItems: nextItems,
            theme: breadcrumbTheme,
            textDirection: textDirection,
          );
        }

        final visibleItems = overflowCount >= navigationItems.length
            ? const <IxBreadcrumbItemData>[]
            : List<IxBreadcrumbItemData>.unmodifiable(
                navigationItems.skip(overflowCount).toList(),
              );

        final rowChildren = <Widget>[
          _HomeMenuButton(
            item: rootItem,
            theme: breadcrumbTheme,
            buttonStyle: buttonStyle,
            homeIcon: homeIcon ?? rootItem.icon ?? IxIcons.home,
            menuItems: items,
            menuLabel: menuSemanticLabel,
            showNavigationMenu: showNavigationMenu && items.length > 1,
            showLabel: showHomeLabel,
            onItemPressed: onItemPressed,
            showOverflowBadge: overflowCount > 0,
            labelTextStyle: interactiveLabelStyle,
            iconColor: resolvedIconColor,
          ),
        ];

        if (visibleItems.isNotEmpty) {
          rowChildren.addAll([
            SizedBox(width: breadcrumbTheme.itemSpacing),
            _BreadcrumbSeparator(theme: breadcrumbTheme),
            SizedBox(width: breadcrumbTheme.itemSpacing),
          ]);
        }

        for (var i = 0; i < visibleItems.length; i++) {
          final entry = visibleItems[i];
          final isLast = i == visibleItems.length - 1;
          final shouldShowNextMenu = isLast && nextItems.isNotEmpty;

          rowChildren.add(
            _BreadcrumbSegment(
              item: entry,
              theme: breadcrumbTheme,
              buttonStyle: buttonStyle,
              labelTextStyle: interactiveLabelStyle,
              iconColor: resolvedIconColor,
              showChevron: !isLast,
              menuItems: shouldShowNextMenu
                  ? nextItems
                  : const <IxBreadcrumbMenuItem>[],
              isCurrentLocation: isLast && !shouldShowNextMenu,
              onItemPressed: onItemPressed,
              onNextItemPressed: onNextItemPressed,
            ),
          );

          if (i != visibleItems.length - 1) {
            rowChildren.add(SizedBox(width: breadcrumbTheme.itemSpacing));
          }
        }

        return Semantics(
          label: semanticLabel ?? 'Breadcrumb',
          container: true,
          child: SizedBox(
            height: breadcrumbTheme.height,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
            ),
          ),
        );
      },
    );
  }
}

/// Describes an individual breadcrumb item.
@immutable
class IxBreadcrumbItemData {
  const IxBreadcrumbItemData({
    required this.label,
    this.onPressed,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? semanticLabel;
}

/// Describes a dropdown entry either surfaced from overflow or exposed as a
/// "next" item on the trailing breadcrumb.
@immutable
class IxBreadcrumbMenuItem {
  const IxBreadcrumbMenuItem({
    required this.label,
    this.onPressed,
    this.icon,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? semanticLabel;
}

ButtonStyle _resolveButtonStyle(
  ButtonStyle? baseStyle,
  IxBreadcrumbTheme theme,
) {
  final fallback = TextButton.styleFrom(
    padding: theme.itemPadding,
    minimumSize: Size(0, theme.height),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    alignment: Alignment.centerLeft,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(IxCommonGeometry.smallBorderRadius),
    ),
    visualDensity: VisualDensity.compact,
  );

  final resolved = fallback.merge(baseStyle);
  return resolved.copyWith(
    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(theme.itemPadding),
    minimumSize: WidgetStatePropertyAll<Size>(Size(0, theme.height)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    alignment: Alignment.centerLeft,
    visualDensity: VisualDensity.compact,
  );
}

class _BreadcrumbSegment extends StatelessWidget {
  const _BreadcrumbSegment({
    required this.item,
    required this.theme,
    required this.buttonStyle,
    required this.labelTextStyle,
    required this.iconColor,
    required this.showChevron,
    required this.menuItems,
    required this.isCurrentLocation,
    required this.onItemPressed,
    required this.onNextItemPressed,
  });

  final IxBreadcrumbItemData item;
  final IxBreadcrumbTheme theme;
  final ButtonStyle buttonStyle;
  final TextStyle labelTextStyle;
  final Color iconColor;
  final bool showChevron;
  final List<IxBreadcrumbMenuItem> menuItems;
  final bool isCurrentLocation;
  final ValueChanged<IxBreadcrumbItemData>? onItemPressed;
  final ValueChanged<IxBreadcrumbMenuItem>? onNextItemPressed;

  bool get _isDropdownTrigger => menuItems.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final content = _BreadcrumbContent(
      item: item,
      theme: theme,
      textStyle: isCurrentLocation ? theme.currentItemStyle : labelTextStyle,
      iconColor: iconColor,
      showChevron: showChevron && !_isDropdownTrigger,
      dropdownIndicator: _isDropdownTrigger,
    );

    return Builder(
      builder: (triggerContext) {
        return Semantics(
          button: true,
          label: item.semanticLabel ?? item.label,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: theme.maxItemWidth),
            child: TextButton(
              style: buttonStyle,
              onPressed: () async {
                if (_isDropdownTrigger) {
                  final selection = await _showIxMenu<IxBreadcrumbMenuItem>(
                    triggerContext: triggerContext,
                    theme: theme,
                    entries: menuItems,
                    builder: (entry) => _MenuEntryContent(
                      label: entry.label,
                      icon: entry.icon,
                      theme: theme,
                    ),
                    semanticFallback: item.semanticLabel ?? item.label,
                  );
                  if (selection != null) {
                    selection.onPressed?.call();
                    onNextItemPressed?.call(selection);
                  }
                } else {
                  item.onPressed?.call();
                  onItemPressed?.call(item);
                }
              },
              child: content,
            ),
          ),
        );
      },
    );
  }
}

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton({
    required this.item,
    required this.theme,
    required this.buttonStyle,
    required this.homeIcon,
    required this.menuItems,
    required this.menuLabel,
    required this.showNavigationMenu,
    required this.showLabel,
    required this.onItemPressed,
    required this.showOverflowBadge,
    required this.labelTextStyle,
    required this.iconColor,
  });

  final IxBreadcrumbItemData item;
  final IxBreadcrumbTheme theme;
  final ButtonStyle buttonStyle;
  final Widget homeIcon;
  final List<IxBreadcrumbItemData> menuItems;
  final String menuLabel;
  final bool showNavigationMenu;
  final bool showLabel;
  final ValueChanged<IxBreadcrumbItemData>? onItemPressed;
  final bool showOverflowBadge;
  final TextStyle labelTextStyle;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (triggerContext) {
        final hasMenu = showNavigationMenu && menuItems.length > 1;
        final hasAction =
            hasMenu || item.onPressed != null || onItemPressed != null;

        return Semantics(
          button: true,
          label: item.semanticLabel ?? item.label,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: theme.maxItemWidth),
            child: TextButton(
              style: buttonStyle,
              onPressed: hasAction
                  ? () async {
                      if (hasMenu) {
                        final selection =
                            await _showIxMenu<IxBreadcrumbItemData>(
                              triggerContext: triggerContext,
                              theme: theme,
                              entries: menuItems,
                              builder: (entry) => _MenuEntryContent(
                                label: entry.label,
                                icon: entry.icon,
                                theme: theme,
                              ),
                              semanticFallback: menuLabel,
                            );
                        if (selection != null) {
                          selection.onPressed?.call();
                          onItemPressed?.call(selection);
                        }
                      } else {
                        item.onPressed?.call();
                        onItemPressed?.call(item);
                      }
                    }
                  : null,
              child: _HomeButtonContent(
                theme: theme,
                icon: homeIcon,
                label: showLabel ? item.label : null,
                labelTextStyle: labelTextStyle,
                iconColor: iconColor,
                indicateMenu: hasMenu,
                showOverflowBadge: showOverflowBadge,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BreadcrumbContent extends StatelessWidget {
  const _BreadcrumbContent({
    required this.item,
    required this.theme,
    required this.textStyle,
    required this.iconColor,
    this.showChevron = false,
    this.dropdownIndicator = false,
  });

  final IxBreadcrumbItemData item;
  final IxBreadcrumbTheme theme;
  final TextStyle textStyle;
  final Color iconColor;
  final bool showChevron;
  final bool dropdownIndicator;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (item.icon != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(right: theme.itemSpacing / 2),
          child: IconTheme.merge(
            data: IconThemeData(size: 16, color: iconColor),
            child: item.icon!,
          ),
        ),
      );
    }

    children.add(
      Flexible(
        child: Text(
          item.label,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    );

    if (showChevron) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: theme.itemSpacing / 2),
          child: IconTheme.merge(
            data: IconThemeData(color: theme.separatorColor, size: 16),
            child: IxIcons.chevronRightSmall,
          ),
        ),
      );
    } else if (dropdownIndicator) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: theme.itemSpacing / 2),
          child: IconTheme.merge(
            data: IconThemeData(color: theme.separatorColor, size: 16),
            child: IxIcons.chevronDownSmall,
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  const _BreadcrumbSeparator({required this.theme});

  final IxBreadcrumbTheme theme;

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: IconThemeData(
        color: theme.separatorColor,
        size: _separatorIconExtent,
      ),
      child: IxIcons.chevronRightSmall,
    );
  }
}

class _HomeButtonContent extends StatelessWidget {
  const _HomeButtonContent({
    required this.theme,
    required this.icon,
    required this.labelTextStyle,
    required this.iconColor,
    this.label,
    required this.indicateMenu,
    required this.showOverflowBadge,
  });

  final IxBreadcrumbTheme theme;
  final Widget icon;
  final TextStyle labelTextStyle;
  final Color iconColor;
  final String? label;
  final bool indicateMenu;
  final bool showOverflowBadge;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      IconTheme.merge(
        data: IconThemeData(size: 18, color: iconColor),
        child: icon,
      ),
    ];

    if (label != null) {
      children
        ..add(SizedBox(width: theme.itemSpacing / 2))
        ..add(
          Flexible(
            child: Text(
              label!,
              overflow: TextOverflow.ellipsis,
              style: labelTextStyle,
            ),
          ),
        );
    }

    if (indicateMenu) {
      children
        ..add(SizedBox(width: theme.itemSpacing / 2))
        ..add(
          _HomeMenuIndicator(
            theme: theme,
            showOverflowBadge: showOverflowBadge,
          ),
        );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _HomeMenuIndicator extends StatelessWidget {
  const _HomeMenuIndicator({
    required this.theme,
    required this.showOverflowBadge,
  });

  final IxBreadcrumbTheme theme;
  final bool showOverflowBadge;

  @override
  Widget build(BuildContext context) {
    final indicator = IconTheme.merge(
      data: IconThemeData(color: theme.separatorColor, size: 16),
      child: IxIcons.chevronDownSmall,
    );

    if (!showOverflowBadge) {
      return indicator;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        indicator,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.separatorColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuEntryContent extends StatelessWidget {
  const _MenuEntryContent({
    required this.label,
    required this.theme,
    this.icon,
  });

  final String label;
  final IxBreadcrumbTheme theme;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: theme.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: theme.itemSpacing / 2),
              child: IconTheme.merge(
                data: IconThemeData(size: 16, color: theme.iconColor),
                child: icon!,
              ),
            ),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.dropdownTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

Future<T?> _showIxMenu<T>({
  required BuildContext triggerContext,
  required IxBreadcrumbTheme theme,
  required List<T> entries,
  required Widget Function(T entry) builder,
  required String semanticFallback,
}) async {
  if (entries.isEmpty) {
    return null;
  }

  final overlay = Overlay.of(triggerContext);
  if (overlay == null) {
    return null;
  }

  final overlayBox = overlay.context.findRenderObject() as RenderBox?;
  final box = triggerContext.findRenderObject() as RenderBox?;
  if (overlayBox == null || box == null) {
    return null;
  }

  final triggerRect = Rect.fromPoints(
    box.localToGlobal(Offset.zero, ancestor: overlayBox),
    box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlayBox),
  );

  return showMenu<T>(
    context: triggerContext,
    position: RelativeRect.fromRect(triggerRect, Offset.zero & overlayBox.size),
    color: theme.dropdownBackground,
    elevation: theme.dropdownElevation,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: theme.dropdownBorderRadius),
    items: [
      for (final entry in entries)
        PopupMenuItem<T>(
          value: entry,
          height: theme.height,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: theme.maxItemWidth + theme.dropdownPadding.horizontal,
            child: Padding(
              padding: theme.dropdownPadding,
              child: builder(entry),
            ),
          ),
        ),
    ],
    semanticLabel: semanticFallback,
  );
}

int _expandOverflowToFit({
  required int initialOverflow,
  required double maxWidth,
  required List<IxBreadcrumbItemData> items,
  required List<IxBreadcrumbMenuItem> nextItems,
  required IxBreadcrumbTheme theme,
  required TextDirection textDirection,
}) {
  if (items.isEmpty) {
    return 0;
  }

  if (!maxWidth.isFinite) {
    return initialOverflow.clamp(0, items.length);
  }

  if (maxWidth <= 0) {
    return items.length;
  }

  final maxOverflow = items.length;
  var overflow = initialOverflow.clamp(0, maxOverflow);

  var rowWidth = _computeRowWidth(
    overflowCount: overflow,
    items: items,
    nextItems: nextItems,
    theme: theme,
    textDirection: textDirection,
  );

  while (rowWidth > maxWidth && overflow < maxOverflow) {
    overflow++;
    rowWidth = _computeRowWidth(
      overflowCount: overflow,
      items: items,
      nextItems: nextItems,
      theme: theme,
      textDirection: textDirection,
    );
  }

  return overflow;
}

double _computeRowWidth({
  required int overflowCount,
  required List<IxBreadcrumbItemData> items,
  required List<IxBreadcrumbMenuItem> nextItems,
  required IxBreadcrumbTheme theme,
  required TextDirection textDirection,
}) {
  if (items.isEmpty || overflowCount >= items.length) {
    return 0;
  }

  double width = 0;
  final visibleItems = items.skip(overflowCount).toList();
  for (var i = 0; i < visibleItems.length; i++) {
    final isLast = i == visibleItems.length - 1;
    final shouldShowNextMenu = isLast && nextItems.isNotEmpty;
    final showChevron = !isLast;
    final isCurrent = isLast && !shouldShowNextMenu;

    width += _segmentWidth(
      theme: theme,
      item: visibleItems[i],
      textDirection: textDirection,
      showChevron: showChevron,
      dropdownIndicator: shouldShowNextMenu,
      isCurrent: isCurrent,
    );

    if (i != visibleItems.length - 1) {
      width += theme.itemSpacing;
    }
  }

  return width;
}

double _segmentWidth({
  required IxBreadcrumbTheme theme,
  required IxBreadcrumbItemData item,
  required TextDirection textDirection,
  required bool showChevron,
  required bool dropdownIndicator,
  required bool isCurrent,
}) {
  final textStyle = isCurrent ? theme.currentItemStyle : theme.labelStyle;
  final iconWidth = item.icon != null ? 16.0 : 0.0;
  final iconSpacing = item.icon != null ? theme.itemSpacing / 2 : 0.0;
  final chevronWidth = showChevron || dropdownIndicator
      ? _separatorIconExtent
      : 0.0;
  final chevronSpacing = showChevron || dropdownIndicator
      ? theme.itemSpacing / 2
      : 0.0;

  final baseContentWidth =
      iconWidth + iconSpacing + chevronWidth + chevronSpacing;
  final availableForText = math.max(
    0,
    theme.maxItemWidth - theme.itemPadding.horizontal - baseContentWidth,
  );
  final measuredText = _measureText(item.label, textStyle, textDirection);
  final clampedText = math.min(measuredText, availableForText);

  final totalWidth =
      baseContentWidth + clampedText + theme.itemPadding.horizontal;
  return math.min(theme.maxItemWidth, totalWidth);
}

double _measureText(String text, TextStyle style, TextDirection textDirection) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: textDirection,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return painter.size.width;
}

double _homeButtonWidth({
  required IxBreadcrumbTheme theme,
  required TextDirection textDirection,
  required String label,
  required bool showNavigationMenu,
  required bool showHomeLabel,
}) {
  final iconWidth = 18.0;
  final labelWidth = showHomeLabel
      ? _measureText(label, theme.labelStyle, textDirection)
      : 0.0;
  final labelSpacing = showHomeLabel ? theme.itemSpacing / 2 : 0.0;
  final indicatorWidth = showNavigationMenu ? _separatorIconExtent : 0.0;
  final indicatorSpacing = showNavigationMenu ? theme.itemSpacing / 2 : 0.0;

  final computed =
      iconWidth +
      labelSpacing +
      labelWidth +
      indicatorSpacing +
      indicatorWidth +
      theme.itemPadding.horizontal;

  final clamped = math.min(theme.maxItemWidth, computed);
  return math.max(theme.height, clamped);
}
