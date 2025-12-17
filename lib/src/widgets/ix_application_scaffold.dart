import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:siemens_ix_flutter/src/ix_icons/ix_icons.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_app_menu_theme.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_sidebar_theme.dart';

/// Describes the type of entry that can appear inside the Siemens IX application
/// menu scaffold.
enum IxMenuEntryType { item, category, custom }

/// Data model describing items rendered inside [IxApplicationScaffold].
@immutable
class IxMenuEntry {
  const IxMenuEntry({
    required this.id,
    required this.type,
    required this.label,
    this.icon,
    this.iconWidget,
    this.tooltip,
    this.notificationCount,
    this.selected = false,
    this.enabled = true,
    this.children = const [],
    this.isBottom = false,
  });

  final String id;
  final IxMenuEntryType type;
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final String? tooltip;
  final int? notificationCount;
  final bool selected;
  final bool enabled;
  final List<IxMenuEntry> children;
  final bool isBottom;

  IxMenuEntry copyWith({
    IconData? icon,
    Widget? iconWidget,
    String? label,
    String? tooltip,
    int? notificationCount,
    bool? selected,
    bool? enabled,
    List<IxMenuEntry>? children,
    bool? isBottom,
  }) {
    return IxMenuEntry(
      id: id,
      type: type,
      icon: icon ?? this.icon,
      iconWidget: iconWidget ?? this.iconWidget,
      label: label ?? this.label,
      tooltip: tooltip ?? this.tooltip,
      notificationCount: notificationCount ?? this.notificationCount,
      selected: selected ?? this.selected,
      enabled: enabled ?? this.enabled,
      children: children ?? this.children,
      isBottom: isBottom ?? this.isBottom,
    );
  }
}

/// Scaffold that mirrors the Siemens IX application menu (AppBar + Drawer /
/// permanent side navigation) while remaining idiomatic for Flutter layouts.
class IxApplicationScaffold extends StatefulWidget {
  const IxApplicationScaffold({
    super.key,
    required this.appTitle,
    required this.entries,
    required this.onNavigate,
    required this.body,
    this.appBar,
    this.initiallyExpanded = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.expandedWidth = 320,
    this.collapsedWidth = 72,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
    this.showSettings = true,
    this.showThemeToggle = true,
    this.showAboutLegal = true,
    this.onOpenSettings,
    this.onOpenAboutLegal,
  }) : assert(
         expandedWidth > collapsedWidth && collapsedWidth >= 56,
         'Expanded width must be larger than collapsed width.',
       );

  final String appTitle;
  final PreferredSizeWidget? appBar;
  final List<IxMenuEntry> entries;
  final ValueChanged<String> onNavigate;
  final Widget body;
  final bool initiallyExpanded;
  final Duration animationDuration;
  final double expandedWidth;
  final double collapsedWidth;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final bool showSettings;
  final bool showThemeToggle;
  final bool showAboutLegal;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenAboutLegal;

  @override
  State<IxApplicationScaffold> createState() => _IxApplicationScaffoldState();
}

class _IxApplicationScaffoldState extends State<IxApplicationScaffold> {
  static const double _mobileBreakpoint = 1024;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, bool> _categoryExpansion = <String, bool>{};
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _syncCategoryExpansion(widget.entries);
  }

  @override
  void didUpdateWidget(covariant IxApplicationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded &&
        widget.initiallyExpanded != _isExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
    _syncCategoryExpansion(widget.entries);
  }

  void _syncCategoryExpansion(List<IxMenuEntry> entries) {
    final seen = <String>{};

    void visit(List<IxMenuEntry> nodes) {
      for (final entry in nodes) {
        if (entry.type == IxMenuEntryType.category) {
          seen.add(entry.id);
          _categoryExpansion.putIfAbsent(entry.id, () => false);
          visit(entry.children);
        }
      }
    }

    visit(entries);
    final removable = _categoryExpansion.keys
        .where((key) => !seen.contains(key))
        .toList(growable: false);
    for (final key in removable) {
      _categoryExpansion.remove(key);
    }
  }

  bool _isCategoryExpanded(String id) => _categoryExpansion[id] ?? false;

  void _toggleCategory(String id) {
    setState(() {
      final current = _categoryExpansion[id] ?? false;
      _categoryExpansion[id] = !current;
    });
  }

  List<IxMenuEntry> get _topEntries =>
      widget.entries.where((entry) => !entry.isBottom).toList();

  List<IxMenuEntry> get _bottomEntries => widget.entries
      .where((entry) => entry.isBottom && _isBottomEntryVisible(entry))
      .toList();

  bool _isBottomEntryVisible(IxMenuEntry entry) {
    switch (entry.id) {
      case 'settings':
        return widget.showSettings;
      case 'theme-toggle':
        return widget.showThemeToggle;
      case 'about-legal':
        return widget.showAboutLegal;
      default:
        return true;
    }
  }

  bool get _useDrawerLayout {
    final width = MediaQuery.sizeOf(context).width;
    return width < _mobileBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    if (_useDrawerLayout) {
      return _buildDrawerLayout();
    }
    return _buildSideNavigationLayout();
  }

  Widget _buildDrawerLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar:
          widget.appBar ??
          AppBar(
            title: Text(widget.appTitle),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: IxIcons.appMenu,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).openAppDrawerTooltip,
                );
              },
            ),
          ),
      drawer: Drawer(
        child: SafeArea(
          child: _NavigationPanel(
            appTitle: widget.appTitle,
            entries: _topEntries,
            bottomEntries: _bottomEntries,
            isExpanded: true,
            showCollapseAction: false,
            animationDuration: widget.animationDuration,
            expandedWidth: widget.expandedWidth,
            collapsedWidth: widget.collapsedWidth,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
            onEntryTap: (entry) => _handleEntryTap(entry, closeDrawer: true),
            onBottomEntryTap: (entry) =>
                _handleBottomEntryTap(entry, closeDrawer: true),
            onToggleCollapse: _toggleExpandedState,
            isCategoryExpanded: _isCategoryExpanded,
            onCategoryExpansionChanged: _toggleCategory,
          ),
        ),
      ),
      body: widget.body,
    );
  }

  Widget _buildSideNavigationLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.appBar ?? AppBar(title: Text(widget.appTitle)),
      body: Row(
        children: [
          AnimatedContainer(
            duration: widget.animationDuration,
            width: _isExpanded ? widget.expandedWidth : widget.collapsedWidth,
            child: _NavigationPanel(
              appTitle: widget.appTitle,
              entries: _topEntries,
              bottomEntries: _bottomEntries,
              isExpanded: _isExpanded,
              showCollapseAction: true,
              animationDuration: widget.animationDuration,
              expandedWidth: widget.expandedWidth,
              collapsedWidth: widget.collapsedWidth,
              themeMode: widget.themeMode,
              onThemeModeChanged: widget.onThemeModeChanged,
              onEntryTap: _handleEntryTap,
              onBottomEntryTap: _handleBottomEntryTap,
              onToggleCollapse: _toggleExpandedState,
              isCategoryExpanded: _isCategoryExpanded,
              onCategoryExpansionChanged: _toggleCategory,
            ),
          ),
          // const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  void _toggleExpandedState() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _handleEntryTap(IxMenuEntry entry, {bool closeDrawer = false}) {
    widget.onNavigate(entry.id);
    if (closeDrawer) {
      Navigator.of(context).maybePop();
    }
  }

  void _handleBottomEntryTap(IxMenuEntry entry, {bool closeDrawer = false}) {
    switch (entry.id) {
      case 'settings':
        if (widget.showSettings) {
          widget.onOpenSettings?.call();
        }
        break;
      case 'theme-toggle':
        if (widget.showThemeToggle) {
          final nextMode = _nextThemeMode(widget.themeMode);
          widget.onThemeModeChanged?.call(nextMode);
        }
        break;
      case 'about-legal':
        if (widget.showAboutLegal) {
          widget.onOpenAboutLegal?.call();
        }
        break;
      default:
        widget.onNavigate(entry.id);
        break;
    }

    if (closeDrawer) {
      Navigator.of(context).maybePop();
    }
  }

  ThemeMode _nextThemeMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }
}

class _NavigationPanel extends StatefulWidget {
  const _NavigationPanel({
    required this.appTitle,
    required this.entries,
    required this.bottomEntries,
    required this.isExpanded,
    required this.showCollapseAction,
    required this.animationDuration,
    required this.expandedWidth,
    required this.collapsedWidth,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onEntryTap,
    required this.onBottomEntryTap,
    required this.onToggleCollapse,
    required this.isCategoryExpanded,
    required this.onCategoryExpansionChanged,
  });

  final String appTitle;
  final List<IxMenuEntry> entries;
  final List<IxMenuEntry> bottomEntries;
  final bool isExpanded;
  final bool showCollapseAction;
  final Duration animationDuration;
  final double expandedWidth;
  final double collapsedWidth;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<IxMenuEntry> onEntryTap;
  final ValueChanged<IxMenuEntry> onBottomEntryTap;
  final VoidCallback onToggleCollapse;
  final bool Function(String id) isCategoryExpanded;
  final ValueChanged<String> onCategoryExpansionChanged;

  @override
  State<_NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<_NavigationPanel> {
  late final ScrollController _scrollController;
  bool _showTopShadow = false;
  bool _showBottomShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateShadows);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateShadows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateShadows() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final showTop = position.pixels > 0;
    final showBottom = position.pixels < position.maxScrollExtent;
    if (showTop != _showTopShadow || showBottom != _showBottomShadow) {
      setState(() {
        _showTopShadow = showTop;
        _showBottomShadow = showBottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarTheme = _resolveSidebarTheme(theme);
    final appMenuTheme = theme.extension<IxAppMenuTheme>();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double tolerance = 8;
        final bool isPanelExpanded =
            widget.isExpanded &&
            (!widget.showCollapseAction ||
                constraints.maxWidth >= widget.expandedWidth - tolerance);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: sidebarTheme.backgroundColor,
            // border: Border(
            //   right: BorderSide(color: sidebarTheme.borderColor, width: 1),
            // ),
          ),
          child: SafeArea(
            child: FocusTraversalGroup(
              child: Column(
                children: [
                  _NavigationHeader(
                    title: widget.appTitle,
                    isExpanded: isPanelExpanded,
                    showCollapseAction: widget.showCollapseAction,
                    onToggleCollapse: widget.onToggleCollapse,
                    animationDuration: widget.animationDuration,
                    collapsedSlotWidth: widget.collapsedWidth,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          children: [
                            for (final entry in widget.entries)
                              _NavigationEntry(
                                entry: entry,
                                depth: 0,
                                isExpanded: isPanelExpanded,
                                sidebarTheme: sidebarTheme,
                                appMenuTheme: appMenuTheme,
                                animationDuration: widget.animationDuration,
                                isCategoryExpanded: widget.isCategoryExpanded(
                                  entry.id,
                                ),
                                onCategoryExpansionChanged:
                                    widget.onCategoryExpansionChanged,
                                onEntryTap: widget.onEntryTap,
                              ),
                          ],
                        ),
                        _ScrollShadow(
                          showShadow: _showTopShadow,
                          isTop: true,
                          color: sidebarTheme.backgroundColor,
                          animationDuration: widget.animationDuration,
                        ),
                        _ScrollShadow(
                          showShadow: _showBottomShadow,
                          isTop: false,
                          color: sidebarTheme.backgroundColor,
                          animationDuration: widget.animationDuration,
                        ),
                      ],
                    ),
                  ),
                  if (widget.bottomEntries.isNotEmpty) ...[
                    // const Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isPanelExpanded ? 12 : 8,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          for (final entry in widget.bottomEntries)
                            _BottomNavigationEntry(
                              entry: entry,
                              isExpanded: isPanelExpanded,
                              sidebarTheme: sidebarTheme,
                              appMenuTheme: appMenuTheme,
                              animationDuration: widget.animationDuration,
                              themeMode: widget.themeMode,
                              onThemeModeChanged: widget.onThemeModeChanged,
                              onTap: widget.onBottomEntryTap,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavigationHeader extends StatelessWidget {
  const _NavigationHeader({
    required this.title,
    required this.isExpanded,
    required this.showCollapseAction,
    required this.onToggleCollapse,
    required this.animationDuration,
    required this.collapsedSlotWidth,
  });

  final String title;
  final bool isExpanded;
  final bool showCollapseAction;
  final VoidCallback onToggleCollapse;
  final Duration animationDuration;
  final double collapsedSlotWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final button = showCollapseAction
        ? Tooltip(
            message: isExpanded ? 'Collapse navigation' : 'Expand navigation',
            child: IconButton(
              onPressed: onToggleCollapse,
              splashRadius: 20,
              icon: AnimatedRotation(
                turns: isExpanded ? 0 : 0.5,
                duration: animationDuration,
                child: const Icon(Icons.keyboard_double_arrow_left),
              ),
            ),
          )
        : const SizedBox.shrink();

    final slotWidth = (collapsedSlotWidth - 8)
        .clamp(0, collapsedSlotWidth)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
      child: Row(
        children: [
          SizedBox(
            width: slotWidth,
            child: Align(alignment: Alignment.center, child: button),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavigationEntry extends StatelessWidget {
  const _NavigationEntry({
    required this.entry,
    required this.depth,
    required this.isExpanded,
    required this.sidebarTheme,
    required this.appMenuTheme,
    required this.animationDuration,
    required this.isCategoryExpanded,
    required this.onCategoryExpansionChanged,
    required this.onEntryTap,
  });

  final IxMenuEntry entry;
  final int depth;
  final bool isExpanded;
  final IxSidebarTheme sidebarTheme;
  final IxAppMenuTheme? appMenuTheme;
  final Duration animationDuration;
  final bool isCategoryExpanded;
  final ValueChanged<String> onCategoryExpansionChanged;
  final ValueChanged<IxMenuEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    if (entry.type == IxMenuEntryType.category) {
      final hasSelectedChild = entry.children.any((child) => child.selected);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NavigationTile(
            entry: entry,
            depth: depth,
            isExpanded: isExpanded,
            sidebarTheme: sidebarTheme,
            appMenuTheme: appMenuTheme,
            animationDuration: animationDuration,
            selected: hasSelectedChild || entry.selected,
            enabled: entry.enabled,
            trailing: Icon(
              isCategoryExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => onCategoryExpansionChanged(entry.id),
          ),
          AnimatedCrossFade(
            duration: animationDuration,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                for (final child in entry.children)
                  _NavigationEntry(
                    entry: child,
                    depth: depth + 1,
                    isExpanded: isExpanded,
                    sidebarTheme: sidebarTheme,
                    appMenuTheme: appMenuTheme,
                    animationDuration: animationDuration,
                    isCategoryExpanded: false,
                    onCategoryExpansionChanged: onCategoryExpansionChanged,
                    onEntryTap: onEntryTap,
                  ),
              ],
            ),
            crossFadeState: isExpanded && isCategoryExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      );
    }

    return _NavigationTile(
      entry: entry,
      depth: depth,
      isExpanded: isExpanded,
      sidebarTheme: sidebarTheme,
      appMenuTheme: appMenuTheme,
      animationDuration: animationDuration,
      selected: entry.selected,
      enabled: entry.enabled,
      onTap: entry.enabled ? () => onEntryTap(entry) : null,
    );
  }
}

class _BottomNavigationEntry extends StatelessWidget {
  const _BottomNavigationEntry({
    required this.entry,
    required this.isExpanded,
    required this.sidebarTheme,
    required this.appMenuTheme,
    required this.animationDuration,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onTap,
  });

  final IxMenuEntry entry;
  final bool isExpanded;
  final IxSidebarTheme sidebarTheme;
  final IxAppMenuTheme? appMenuTheme;
  final Duration animationDuration;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<IxMenuEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (entry.type == IxMenuEntryType.custom && entry.id == 'theme-toggle') {
      return _NavigationTile(
        entry: entry,
        depth: 0,
        isExpanded: isExpanded,
        sidebarTheme: sidebarTheme,
        appMenuTheme: appMenuTheme,
        animationDuration: animationDuration,
        selected: false,
        enabled: entry.enabled && onThemeModeChanged != null,
        trailing: _ThemeModeIndicator(
          isExpanded: isExpanded,
          themeMode: themeMode,
          sidebarTheme: sidebarTheme,
        ),
        onTap: onThemeModeChanged == null
            ? null
            : () => onThemeModeChanged!(_nextThemeMode(themeMode)),
      );
    }

    return _NavigationTile(
      entry: entry,
      depth: 0,
      isExpanded: isExpanded,
      sidebarTheme: sidebarTheme,
      appMenuTheme: appMenuTheme,
      animationDuration: animationDuration,
      selected: entry.selected,
      enabled: entry.enabled,
      onTap: entry.enabled ? () => onTap(entry) : null,
    );
  }

  ThemeMode _nextThemeMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.system:
        return ThemeMode.light;
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
    }
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.entry,
    required this.depth,
    required this.isExpanded,
    required this.sidebarTheme,
    required this.appMenuTheme,
    required this.animationDuration,
    required this.selected,
    required this.enabled,
    this.trailing,
    this.onTap,
  });

  final IxMenuEntry entry;
  final int depth;
  final bool isExpanded;
  final IxSidebarTheme sidebarTheme;
  final IxAppMenuTheme? appMenuTheme;
  final Duration animationDuration;
  final bool selected;
  final bool enabled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{};
    if (selected) {
      states.add(WidgetState.selected);
    }
    if (!enabled) {
      states.add(WidgetState.disabled);
    }

    final backgroundColor =
        sidebarTheme.itemBackground.resolve(states) ?? Colors.transparent;
    final foregroundColor =
        sidebarTheme.itemForeground.resolve(states) ??
        Theme.of(context).colorScheme.onSurface;
    final iconColor =
        sidebarTheme.itemIconColor.resolve(states) ??
        foregroundColor.withValues(alpha: 0.9);
    final badgeBackground =
        appMenuTheme?.badgeBackgroundColor ??
        Theme.of(context).colorScheme.error;
    final badgeForeground =
        appMenuTheme?.badgeForegroundColor ??
        Theme.of(context).colorScheme.onError;

    final badgeCount = entry.notificationCount;
    final indicatorColor = Theme.of(context).colorScheme.primary;

    final iconWidget =
        entry.iconWidget ??
        Icon(
          entry.icon ?? Icons.circle_outlined,
          color: iconColor,
          size: isExpanded ? 22 : 18,
        );

    final gap = isExpanded ? 12.0 : 4.0;

    return Tooltip(
      message: entry.tooltip ?? entry.label,
      waitDuration: const Duration(milliseconds: 500),
      child: Semantics(
        button: onTap != null,
        enabled: enabled,
        selected: selected,
        label: entry.label,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: depth * 16.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? onTap : null,
            child: AnimatedContainer(
              duration: animationDuration,
              padding: EdgeInsets.symmetric(
                horizontal: isExpanded ? 12 : 8,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(
                  IxCommonGeometry.smallBorderRadius,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: animationDuration,
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? indicatorColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: gap),
                  if (isExpanded) ...[
                    iconWidget,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foregroundColor,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeCount != null && badgeCount > 0)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: _NotificationBadge(
                          count: badgeCount,
                          background: badgeBackground,
                          foreground: badgeForeground,
                        ),
                      ),
                    if (trailing != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: trailing!,
                      ),
                  ] else ...[
                    _CollapsedIconBadge(
                      icon: iconWidget,
                      badgeCount: badgeCount,
                      badgeBackground: badgeBackground,
                      badgeForeground: badgeForeground,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeModeIndicator extends StatelessWidget {
  const _ThemeModeIndicator({
    required this.isExpanded,
    required this.themeMode,
    required this.sidebarTheme,
  });

  final bool isExpanded;
  final ThemeMode themeMode;
  final IxSidebarTheme sidebarTheme;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForMode(themeMode);
    final label = _labelForMode(themeMode);
    final color =
        sidebarTheme.itemForeground.resolve(<WidgetState>{}) ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    if (!isExpanded) {
      return Icon(icon, size: 20, color: color);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Row(
        key: ValueKey(label),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  IconData _iconForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.auto_mode_outlined;
      case ThemeMode.light:
        return Icons.wb_sunny_outlined;
      case ThemeMode.dark:
        return Icons.nightlight_round_outlined;
    }
  }

  String _labelForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.count,
    required this.background,
    required this.foreground,
  });

  final int count;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final capped = math.min(count, 99);
    final label = count > 99 ? '$capped+' : '$capped';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CollapsedIconBadge extends StatelessWidget {
  const _CollapsedIconBadge({
    required this.icon,
    required this.badgeCount,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  final Widget icon;
  final int? badgeCount;
  final Color badgeBackground;
  final Color badgeForeground;

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount != null && badgeCount! > 0;
    final capped = showBadge ? math.min(badgeCount!, 99) : 0;
    final label = !showBadge
        ? ''
        : badgeCount! > 99
        ? '$capped+'
        : '$capped';

    return SizedBox(
      width: 22,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: icon),
          if (showBadge)
            Positioned(
              right: -2,
              top: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.5,
                  vertical: 0.5,
                ),
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: badgeForeground,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScrollShadow extends StatelessWidget {
  const _ScrollShadow({
    required this.showShadow,
    required this.isTop,
    required this.color,
    required this.animationDuration,
  });

  final bool showShadow;
  final bool isTop;
  final Color color;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: isTop ? Alignment.topCenter : Alignment.bottomCenter,
      end: isTop ? Alignment.bottomCenter : Alignment.topCenter,
      colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.0)],
    );

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: animationDuration,
          opacity: showShadow ? 1 : 0,
          child: Container(
            height: 18,
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
      ),
    );
  }
}

IxSidebarTheme _resolveSidebarTheme(ThemeData theme) {
  final extension = theme.extension<IxSidebarTheme>();
  if (extension != null) {
    return extension;
  }

  final colorScheme = theme.colorScheme;
  return IxSidebarTheme(
    backgroundColor: colorScheme.surface,
    borderColor: colorScheme.outlineVariant,
    dividerColor: colorScheme.outlineVariant,
    focusOutlineColor: colorScheme.primary,
    sectionHeaderTextStyle:
        theme.textTheme.labelSmall ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    itemTextStyle:
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    itemBackground: WidgetStatePropertyAll(colorScheme.surfaceContainerHighest),
    itemForeground: WidgetStatePropertyAll(colorScheme.onSurface),
    itemIconColor: WidgetStatePropertyAll(colorScheme.onSurfaceVariant),
    width: 280,
    navigationRailTheme: const NavigationRailThemeData(),
  );
}
