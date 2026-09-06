import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_key.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_size.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_breadcrumb_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_button_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_dropdown_theme.dart';
import 'package:ix_flutter/src/widgets/ix_breadcrumb_strings.dart';

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
    this.onItemClick,
    this.onNextItemPressed,
    this.onNextClick,
    this.homeIcon,
    this.homeMenuLabel = 'Navigate to level',
    this.showHomeLabel = false,
    this.showNavigationMenu = true,
    this.strings = const IxBreadcrumbStrings(),
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

  /// Fired with a stable [IxBreadcrumbClick] payload whenever a visible or
  /// overflow breadcrumb item is activated, in addition to [onItemPressed].
  ///
  /// Uses [IxBreadcrumbItemData.effectiveKey], so two items that share the
  /// same [IxBreadcrumbItemData.label] remain distinguishable.
  final ValueChanged<IxBreadcrumbClick>? onItemClick;

  /// Fired whenever a trailing "next" menu item is tapped.
  final ValueChanged<IxBreadcrumbMenuItem>? onNextItemPressed;

  /// Fired with a stable [IxBreadcrumbClick] payload whenever a trailing
  /// "next" menu item is activated, in addition to [onNextItemPressed].
  final ValueChanged<IxBreadcrumbClick>? onNextClick;

  /// Optional replacement for the root home icon.
  final Widget? homeIcon;

  /// Optional override for the navigation menu semantics. Falls back to
  /// [previousItemsLabel] when empty.
  final String homeMenuLabel;

  /// Displays the textual label next to the home icon when true.
  final bool showHomeLabel;

  /// Whether tapping the home button should surface the navigation menu.
  final bool showNavigationMenu;

  /// Localizable strings for the root landmark, the overflow trigger and
  /// the current-page hint.
  final IxBreadcrumbStrings strings;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final breadcrumbTheme =
        themeData.extension<IxBreadcrumbTheme>() ??
        IxBreadcrumbTheme.fallback(themeData);
    final ixButtonTheme = themeData.extension<IxButtonTheme>();
    final dropdownTheme =
        themeData.extension<IxDropdownTheme>() ??
        IxDropdownTheme.fallback(themeData);
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

    // The navigation landmark wraps the LayoutBuilder (rather than being
    // returned from inside its `builder`) so `IxBreadcrumb`'s own element
    // resolves directly to this node: `WidgetController.find()` walks
    // *upward* from `element.findRenderObject()` to the nearest
    // `debugSemantics`-owning render object, and a `Semantics` built inside
    // a descendant `builder` callback sits *below* that render object, out
    // of reach of that walk (it would otherwise resolve to an ancestor
    // route-scope node instead of this landmark). The label/role here don't
    // depend on `constraints`, so hoisting it costs nothing.
    return Semantics(
      container: true,
      role: SemanticsRole.navigation,
      label: semanticLabel ?? strings.breadcrumbs,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visibleSlots = math.max(0, visibleItemCount - 1);
          var overflowCount = math.max(
            0,
            navigationItems.length - visibleSlots,
          );

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
              dropdownTheme: dropdownTheme,
              buttonStyle: buttonStyle,
              homeIcon:
                  homeIcon ??
                  rootItem.icon ??
                  // No `size:`: the home slot styles its icon at 18px (the
                  // width `_homeButtonWidth` reserves for it).
                  const IxIcon.key(IxIconKey.home),
              menuItems: items,
              menuLabel: menuSemanticLabel,
              showNavigationMenu: showNavigationMenu && items.length > 1,
              showLabel: showHomeLabel,
              onItemPressed: onItemPressed,
              onItemClick: onItemClick,
              showOverflowBadge: overflowCount > 0,
              labelTextStyle: interactiveLabelStyle,
              iconColor: resolvedIconColor,
              strings: strings,
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
                dropdownTheme: dropdownTheme,
                buttonStyle: buttonStyle,
                labelTextStyle: interactiveLabelStyle,
                iconColor: resolvedIconColor,
                showChevron: !isLast,
                menuItems: shouldShowNextMenu
                    ? nextItems
                    : const <IxBreadcrumbMenuItem>[],
                isCurrentLocation: isLast && !shouldShowNextMenu,
                onItemPressed: onItemPressed,
                onItemClick: onItemClick,
                onNextItemPressed: onNextItemPressed,
                onNextClick: onNextClick,
                strings: strings,
              ),
            );

            if (i != visibleItems.length - 1) {
              rowChildren.add(SizedBox(width: breadcrumbTheme.itemSpacing));
            }
          }

          return SizedBox(
            height: breadcrumbTheme.height,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
            ),
          );
        },
      ),
    );
  }
}

/// The payload delivered to [IxBreadcrumb.onItemClick]/
/// [IxBreadcrumb.onNextClick].
@immutable
class IxBreadcrumbClick {
  /// Creates a breadcrumb click payload.
  const IxBreadcrumbClick({required this.breadcrumbKey, this.label});

  /// Stable identifier of the activated item or menu entry: see
  /// [IxBreadcrumbItemData.effectiveKey] / [IxBreadcrumbMenuItem.effectiveKey].
  ///
  /// Safe to switch on even when two items share the same [label].
  final String breadcrumbKey;

  /// The activated item's display label, when available.
  final String? label;
}

/// Labels already warned about by [_effectiveBreadcrumbKey], so the notice
/// it emits fires at most once per label for the lifetime of the process.
final Set<String> _breadcrumbKeyFallbackWarned = <String>{};

/// Resolves the effective key for an item/menu entry with no explicit
/// `breadcrumbKey`: falls back to [label], after emitting a one-time debug
/// notice (per unique label) that `breadcrumbKey` becomes required in 2.0.
String _effectiveBreadcrumbKey(
  String typeName,
  String label,
  String? breadcrumbKey,
) {
  final key = breadcrumbKey;
  if (key != null) {
    return key;
  }
  assert(() {
    final message =
        '$typeName("$label") has no breadcrumbKey; label is used as key '
        '(required in 2.0)';
    if (_breadcrumbKeyFallbackWarned.add(message)) {
      debugPrint(message);
    }
    return true;
  }());
  return label;
}

/// Describes an individual breadcrumb item.
@immutable
class IxBreadcrumbItemData {
  const IxBreadcrumbItemData({
    required this.label,
    this.breadcrumbKey,
    this.onPressed,
    this.icon,
    this.semanticLabel,
  });

  final String label;

  /// Stable identifier reported through [IxBreadcrumbClick.breadcrumbKey].
  ///
  /// Falls back to [label] when omitted -- which is only safe as long as no
  /// two items share the same label -- and prints a one-time [debugPrint]
  /// notice per label, since `breadcrumbKey` becomes required starting with
  /// ix_flutter 2.0.
  final String? breadcrumbKey;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? semanticLabel;

  /// The key to report through [IxBreadcrumbClick.breadcrumbKey]:
  /// [breadcrumbKey] when set, otherwise [label].
  String get effectiveKey =>
      _effectiveBreadcrumbKey('IxBreadcrumbItemData', label, breadcrumbKey);
}

/// Describes a dropdown entry either surfaced from overflow or exposed as a
/// "next" item on the trailing breadcrumb.
@immutable
class IxBreadcrumbMenuItem {
  const IxBreadcrumbMenuItem({
    required this.label,
    this.breadcrumbKey,
    this.onPressed,
    this.icon,
    this.semanticLabel,
  });

  final String label;

  /// Stable identifier reported through [IxBreadcrumbClick.breadcrumbKey].
  ///
  /// See [IxBreadcrumbItemData.breadcrumbKey].
  final String? breadcrumbKey;
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? semanticLabel;

  /// The key to report through [IxBreadcrumbClick.breadcrumbKey]:
  /// [breadcrumbKey] when set, otherwise [label].
  String get effectiveKey =>
      _effectiveBreadcrumbKey('IxBreadcrumbMenuItem', label, breadcrumbKey);
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
    required this.dropdownTheme,
    required this.buttonStyle,
    required this.labelTextStyle,
    required this.iconColor,
    required this.showChevron,
    required this.menuItems,
    required this.isCurrentLocation,
    required this.onItemPressed,
    required this.onItemClick,
    required this.onNextItemPressed,
    required this.onNextClick,
    required this.strings,
  });

  final IxBreadcrumbItemData item;
  final IxBreadcrumbTheme theme;
  final IxDropdownTheme dropdownTheme;
  final ButtonStyle buttonStyle;
  final TextStyle labelTextStyle;
  final Color iconColor;
  final bool showChevron;
  final List<IxBreadcrumbMenuItem> menuItems;
  final bool isCurrentLocation;
  final ValueChanged<IxBreadcrumbItemData>? onItemPressed;
  final ValueChanged<IxBreadcrumbClick>? onItemClick;
  final ValueChanged<IxBreadcrumbMenuItem>? onNextItemPressed;
  final ValueChanged<IxBreadcrumbClick>? onNextClick;
  final IxBreadcrumbStrings strings;

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

    final hasPressCallback =
        onItemPressed != null || item.onPressed != null || onItemClick != null;

    if (isCurrentLocation && !hasPressCallback) {
      // 1.x kept the trailing crumb interactive whenever a press callback
      // was wired up for it; this is preserved above. Otherwise -- no
      // caller is listening for a press on it -- it becomes the
      // non-interactive "current page" node (WCAG 4.1.2, upstream
      // `breadcrumb-item.tsx:129` `aria-current="page"`), so it carries no
      // button role at all rather than a disabled one (a disabled
      // `TextButton` would still announce as a dimmed button).
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: theme.maxItemWidth),
        child: Semantics(
          container: true,
          selected: true,
          hint: strings.currentPage,
          label: item.semanticLabel ?? item.label,
          child: ExcludeSemantics(
            // A minimum (not exact) height mirrors the interactive
            // TextButton's own `minimumSize`; `content` is a
            // `mainAxisSize: MainAxisSize.min` Row, so -- unlike wrapping
            // it in `Align`, which would expand to this box's full
            // *width* inside the row's unbounded-width scroll axis --
            // this only affects height, and Row's default
            // `CrossAxisAlignment.center` still centers `content`
            // vertically within it.
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: theme.height),
              child: Padding(padding: theme.itemPadding, child: content),
            ),
          ),
        ),
      );
    }

    return Builder(
      builder: (triggerContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.maxItemWidth),
          child: TextButton(
            style: buttonStyle,
            onPressed: () async {
              if (_isDropdownTrigger) {
                final selection = await _showIxMenu<IxBreadcrumbMenuItem>(
                  triggerContext: triggerContext,
                  theme: theme,
                  dropdownTheme: dropdownTheme,
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
                  onNextClick?.call(
                    IxBreadcrumbClick(
                      breadcrumbKey: selection.effectiveKey,
                      label: selection.label,
                    ),
                  );
                }
              } else {
                item.onPressed?.call();
                onItemPressed?.call(item);
                onItemClick?.call(
                  IxBreadcrumbClick(
                    breadcrumbKey: item.effectiveKey,
                    label: item.label,
                  ),
                );
              }
            },
            child: Semantics(
              excludeSemantics: true,
              label: item.semanticLabel ?? item.label,
              child: content,
            ),
          ),
        );
      },
    );
  }
}

class _HomeMenuButton extends StatefulWidget {
  const _HomeMenuButton({
    required this.item,
    required this.theme,
    required this.dropdownTheme,
    required this.buttonStyle,
    required this.homeIcon,
    required this.menuItems,
    required this.menuLabel,
    required this.showNavigationMenu,
    required this.showLabel,
    required this.onItemPressed,
    required this.onItemClick,
    required this.showOverflowBadge,
    required this.labelTextStyle,
    required this.iconColor,
    required this.strings,
  });

  final IxBreadcrumbItemData item;
  final IxBreadcrumbTheme theme;
  final IxDropdownTheme dropdownTheme;
  final ButtonStyle buttonStyle;
  final Widget homeIcon;
  final List<IxBreadcrumbItemData> menuItems;
  final String menuLabel;
  final bool showNavigationMenu;
  final bool showLabel;
  final ValueChanged<IxBreadcrumbItemData>? onItemPressed;
  final ValueChanged<IxBreadcrumbClick>? onItemClick;
  final bool showOverflowBadge;
  final TextStyle labelTextStyle;
  final Color iconColor;
  final IxBreadcrumbStrings strings;

  @override
  State<_HomeMenuButton> createState() => _HomeMenuButtonState();
}

class _HomeMenuButtonState extends State<_HomeMenuButton> {
  /// Whether the navigation menu opened from this trigger is currently
  /// showing, surfaced as `Semantics(expanded:)` on the trigger itself.
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (triggerContext) {
        final hasMenu =
            widget.showNavigationMenu && widget.menuItems.length > 1;
        final hasAction =
            hasMenu ||
            widget.item.onPressed != null ||
            widget.onItemPressed != null ||
            widget.onItemClick != null;
        // While the trigger also carries the "collapsed items" overflow
        // badge, its accessible name switches from the item's own label to
        // describing that dual purpose (upstream `breadcrumb.ct.ts:141-180`
        // "previous items" keyboard case) -- otherwise a screen-reader user
        // would have no way to know activating "Home" also reveals hidden
        // levels.
        final accessibleLabel = hasMenu && widget.showOverflowBadge
            ? widget.strings.previousItems
            : (widget.item.semanticLabel ?? widget.item.label);

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.theme.maxItemWidth),
          child: TextButton(
            style: widget.buttonStyle,
            onPressed: hasAction
                ? () async {
                    if (hasMenu) {
                      setState(() => _isOpen = true);
                      final selection = await _showIxMenu<IxBreadcrumbItemData>(
                        triggerContext: triggerContext,
                        theme: widget.theme,
                        dropdownTheme: widget.dropdownTheme,
                        entries: widget.menuItems,
                        builder: (entry) => _MenuEntryContent(
                          label: entry.label,
                          icon: entry.icon,
                          theme: widget.theme,
                        ),
                        semanticFallback: widget.menuLabel,
                      );
                      if (mounted) {
                        setState(() => _isOpen = false);
                      }
                      if (selection != null) {
                        selection.onPressed?.call();
                        widget.onItemPressed?.call(selection);
                        widget.onItemClick?.call(
                          IxBreadcrumbClick(
                            breadcrumbKey: selection.effectiveKey,
                            label: selection.label,
                          ),
                        );
                      }
                    } else {
                      widget.item.onPressed?.call();
                      widget.onItemPressed?.call(widget.item);
                      widget.onItemClick?.call(
                        IxBreadcrumbClick(
                          breadcrumbKey: widget.item.effectiveKey,
                          label: widget.item.label,
                        ),
                      );
                    }
                  }
                : null,
            child: Semantics(
              excludeSemantics: true,
              label: accessibleLabel,
              expanded: hasMenu ? _isOpen : null,
              child: _HomeButtonContent(
                theme: widget.theme,
                icon: widget.homeIcon,
                label: widget.showLabel ? widget.item.label : null,
                labelTextStyle: widget.labelTextStyle,
                iconColor: widget.iconColor,
                indicateMenu: hasMenu,
                showOverflowBadge: widget.showOverflowBadge,
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
            child: const IxIcon.key(
              IxIconKey.chevronRightSmall,
              size: IxIconSize.s16,
            ),
          ),
        ),
      );
    } else if (dropdownIndicator) {
      children.add(
        Padding(
          padding: EdgeInsets.only(left: theme.itemSpacing / 2),
          child: IconTheme.merge(
            data: IconThemeData(color: theme.separatorColor, size: 16),
            child: const IxIcon.key(
              IxIconKey.chevronDownSmall,
              size: IxIconSize.s16,
            ),
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
      child: const IxIcon.key(
        IxIconKey.chevronRightSmall,
        size: IxIconSize.s16,
      ),
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
      child: const IxIcon.key(IxIconKey.chevronDownSmall, size: IxIconSize.s16),
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
  required IxDropdownTheme dropdownTheme,
  required List<T> entries,
  required Widget Function(T entry) builder,
  required String semanticFallback,
}) async {
  if (entries.isEmpty) {
    return null;
  }

  final overlay = Overlay.of(triggerContext);

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
    // Background and corner radius are styled by the shared IxDropdownTheme
    // -- the same surface every other Siemens IX dropdown menu in the app
    // uses -- unless IxBreadcrumbTheme's own (deprecated, removed in 2.0)
    // `dropdownBackground`/`dropdownBorderRadius` were explicitly set, which
    // then still wins. IxDropdownTheme.borderRadius is a plain radius
    // (shared with plain-radius consumers); IxBreadcrumbTheme's own field
    // is a full BorderRadius, so the fallback wraps it into one.
    // ignore: deprecated_member_use_from_same_package
    color: theme.dropdownBackground ?? dropdownTheme.background,
    elevation: theme.dropdownElevation,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      // ignore: deprecated_member_use_from_same_package
      borderRadius:
          theme.dropdownBorderRadius ??
          BorderRadius.all(Radius.circular(dropdownTheme.borderRadius)),
    ),
    items: [
      for (final entry in entries)
        PopupMenuItem<T>(
          value: entry,
          height: dropdownTheme.itemHeight,
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
