import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_core/ix_focus_ring.dart';
import 'package:ix_flutter/src/ix_core/ix_motion.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_key.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_size.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_app_menu_theme.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_sidebar_theme.dart';
import 'package:ix_flutter/src/widgets/i18n/ix_application_strings.dart';
import 'package:ix_flutter/src/widgets/ix_icon_button.dart';
import 'package:ix_flutter/src/widgets/ix_menu_flyout.dart';

/// Identifies the navigation menu's `menuBar` landmark for widget tests.
const Key _kMenuBarKey = Key('ix-menu-bar');

/// Entry ids whose built-in bottom-bar behaviour is still honoured in 1.x.
///
/// Using one of them logs a one-time debug notice pointing at the
/// [IxApplicationScaffold.settings], [IxApplicationScaffold.about] and
/// [IxApplicationScaffold.enableToggleTheme] replacements; in 2.0 they
/// become ordinary entries that simply report through `onNavigate`.
const Set<String> _kReservedEntryIds = {
  'settings',
  'theme-toggle',
  'about-legal',
};

/// Id of the built-in settings entry contributed by
/// [IxApplicationScaffold.settings].
const String _kSettingsEntryId = '__ix_settings';

/// Id of the built-in theme toggle contributed by
/// [IxApplicationScaffold.enableToggleTheme].
const String _kThemeEntryId = '__ix_theme';

/// Id of the built-in about entry contributed by
/// [IxApplicationScaffold.about].
const String _kAboutEntryId = '__ix_about';

/// Width the fly-out panel prefers, before it is clamped to the room left
/// beside the menu.
const double _kFlyoutWidth = 320;

/// Gap kept between the fly-out panel and the viewport edges.
const double _kFlyoutMargin = IxCommonGeometry.space1;

/// Below this much room beside the menu, the fly-out is placed over the menu
/// instead of next to it (see `_buildFlyout`).
const double _kFlyoutMinSideRoom = 200;

/// Resolves the focus node and traversal order assigned to the menu tile of
/// a given entry id.
typedef _TileFocusOf = ({FocusNode node, double order}) Function(String id);

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
///
/// ## Keyboard
///
/// The menu is a `menuBar` landmark: `Tab` moves into it once (onto the
/// sidebar toggle, then the first entry), `ArrowDown`/`ArrowUp` move between
/// entries without wrapping, `Home`/`End` jump to the first/last entry, and
/// `Enter`/`Space` activate the focused entry. A fly-out panel closes on
/// `Escape` and hands focus back to the entry that opened it.
///
/// ## Built-in entries
///
/// Set [settings] and/or [about] to get the upstream `<ix-menu-settings>` /
/// `<ix-menu-about>` entries at the bottom of the menu; their widget is
/// shown in a fly-out panel next to the menu. [enableToggleTheme] adds the
/// upstream theme toggle whenever [onThemeModeChanged] is set. Every string
/// they render comes from [strings].
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
    @Deprecated(
      'Use settings:/about:/enableToggleTheme instead. Removed in 2.0.',
    )
    this.showSettings = true,
    @Deprecated(
      'Use settings:/about:/enableToggleTheme instead. Removed in 2.0.',
    )
    this.showThemeToggle = true,
    @Deprecated(
      'Use settings:/about:/enableToggleTheme instead. Removed in 2.0.',
    )
    this.showAboutLegal = true,
    @Deprecated('Use settings:/about: instead. Removed in 2.0.')
    this.onOpenSettings,
    @Deprecated('Use settings:/about: instead. Removed in 2.0.')
    this.onOpenAboutLegal,
    this.strings = const IxApplicationStrings(),
    this.settings,
    this.about,
    this.enableToggleTheme = true,
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

  /// Whether the reserved built-in entry is shown.
  @Deprecated('Use settings:/about:/enableToggleTheme instead. Removed in 2.0.')
  final bool showSettings;

  /// Whether the reserved built-in entry is shown.
  @Deprecated('Use settings:/about:/enableToggleTheme instead. Removed in 2.0.')
  final bool showThemeToggle;

  /// Whether the reserved built-in entry is shown.
  @Deprecated('Use settings:/about:/enableToggleTheme instead. Removed in 2.0.')
  final bool showAboutLegal;

  /// Called when the reserved built-in entry is activated.
  @Deprecated('Use settings:/about: instead. Removed in 2.0.')
  final VoidCallback? onOpenSettings;

  /// Called when the reserved built-in entry is activated.
  @Deprecated('Use settings:/about: instead. Removed in 2.0.')
  final VoidCallback? onOpenAboutLegal;

  /// Every user-facing string the menu renders, including the accessible
  /// names of its buttons.
  final IxApplicationStrings strings;

  /// Content of the built-in settings panel (upstream `<ix-menu-settings>`).
  ///
  /// When set, a settings entry is appended to the bottom of the menu; it
  /// opens this widget in a fly-out panel anchored to the menu.
  final Widget? settings;

  /// Content of the built-in about panel (upstream `<ix-menu-about>`).
  ///
  /// When set, an about entry is appended to the bottom of the menu; it
  /// opens this widget in a fly-out panel anchored to the menu.
  final Widget? about;

  /// Whether the built-in theme toggle is shown (upstream
  /// `ix-menu.enableToggleTheme`).
  ///
  /// The entry only appears when [onThemeModeChanged] is also set, since the
  /// scaffold does not own the app's [ThemeMode].
  final bool enableToggleTheme;

  /// Forgets which reserved menu entry ids have already been reported, so a
  /// test that asserts on the one-time debug notice starts from a clean
  /// slate. Call it from `addTearDown`.
  @visibleForTesting
  static void debugResetReservedIdWarnings() {
    _IxApplicationScaffoldState._warnedIds.clear();
  }

  @override
  State<IxApplicationScaffold> createState() => _IxApplicationScaffoldState();
}

class _IxApplicationScaffoldState extends State<IxApplicationScaffold> {
  static const double _mobileBreakpoint = 1024;

  /// Reserved ids already reported by [_warnReservedIdOnce]. Static so an
  /// app that rebuilds (or remounts) its scaffold is told exactly once.
  static final Set<String> _warnedIds = <String>{};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, bool> _categoryExpansion = <String, bool>{};

  /// Measures the menu rail, so the fly-out can be clamped to the room left
  /// beside it.
  final GlobalKey _menuKey = GlobalKey(
    debugLabel: 'IxApplicationScaffold.menu',
  );
  final OverlayPortalController _flyoutPortal = OverlayPortalController(
    debugLabel: 'IxApplicationScaffold.flyout',
  );

  /// Shared tap group of the menu and its fly-out, so tapping a menu tile is
  /// never a "tap outside" that would close the panel it just opened.
  final Object _tapRegionGroupId = Object();

  /// Focus nodes of the menu tiles, keyed by entry id. Owned here rather
  /// than by the navigation panel so a fly-out can hand focus back to the
  /// tile that opened it.
  final Map<String, FocusNode> _tileNodes = <String, FocusNode>{};

  late bool _isExpanded;

  /// The entry hosting this scaffold when it is built without an [Overlay]
  /// ancestor; created once so it survives rebuilds.
  OverlayEntry? _selfHostedEntry;

  /// Id of the tile whose fly-out is open (a category, or one of the
  /// built-in settings/about entries), or `null` when no panel is open.
  ///
  /// The panel's title and content are derived from this id on every build,
  /// so a rebuilt [IxApplicationScaffold.settings]/[IxApplicationScaffold.about]
  /// widget reaches an already open panel.
  String? _openFlyoutId;

  IxApplicationStrings get _strings => widget.strings;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _syncCategoryExpansion(widget.entries);
  }

  /// Whether the tile a fly-out with [anchorId] hangs off is still there.
  bool _hasFlyoutAnchor(String anchorId) {
    switch (anchorId) {
      case _kSettingsEntryId:
        return widget.settings != null;
      case _kAboutEntryId:
        return widget.about != null;
      default:
        return _findEntry(widget.entries, anchorId) != null;
    }
  }

  @override
  void dispose() {
    for (final node in _tileNodes.values) {
      node.dispose();
    }
    _tileNodes.clear();
    // `OverlayEntry` is a `ChangeNotifier`, so the self-hosted entry has to
    // be disposed too or leak-tracking suites report it. The Overlay that
    // hosts it is this state's own child and unmounts first, but unmounting
    // does not clear the entry's back-reference to it -- `remove()` is what
    // does, and it is a no-op on an already unmounted Overlay. Same order
    // Flutter's own `_WrappingOverlayState.dispose` uses.
    _selfHostedEntry
      ?..remove()
      ..dispose();
    _selfHostedEntry = null;
    super.dispose();
  }

  /// Reports a menu entry that still relies on a reserved 1.x id, once per
  /// id and only in debug builds.
  void _warnReservedIdOnce(String id) {
    assert(() {
      if (_warnedIds.add(id)) {
        debugPrint(
          'IxApplicationScaffold: menu entry id "$id" is reserved in 1.x '
          '(settings/theme-toggle/about-legal). Use the settings:, about: '
          'and enableToggleTheme parameters instead; reserved ids become '
          'ordinary menu entries in 2.0.',
        );
      }
      return true;
    }());
  }

  /// Returns the focus node of the tile rendering [id], creating it on first
  /// use.
  FocusNode _tileNode(String id) => _tileNodes.putIfAbsent(
    id,
    () => FocusNode(debugLabel: 'IxApplicationScaffold.tile[$id]'),
  );

  @override
  void didUpdateWidget(covariant IxApplicationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded &&
        widget.initiallyExpanded != _isExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
    _syncCategoryExpansion(widget.entries);
    final anchor = _openFlyoutId;
    if (anchor != null && !_hasFlyoutAnchor(anchor)) {
      // The panel's anchor is gone -- `settings:` was set back to null, or
      // the category was removed -- so the portal would keep showing an
      // empty child and re-open by itself later. Focus cannot go back to a
      // tile that no longer exists.
      _closeFlyout(returnFocus: false);
    }
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

  /// The app's own bottom entries -- reserved ids included, so 1.x apps keep
  /// their built-in behaviour -- followed by the entries contributed by
  /// [IxApplicationScaffold.settings], [IxApplicationScaffold.enableToggleTheme]
  /// and [IxApplicationScaffold.about].
  List<IxMenuEntry> get _bottomEntries {
    final entries = <IxMenuEntry>[];
    for (final entry in widget.entries) {
      if (!entry.isBottom) {
        continue;
      }
      if (_kReservedEntryIds.contains(entry.id)) {
        _warnReservedIdOnce(entry.id);
      }
      if (_isBottomEntryVisible(entry)) {
        entries.add(entry);
      }
    }
    return entries..addAll(_builtInBottomEntries);
  }

  /// The built-in bottom entries, in the upstream `ix-menu` order
  /// (`menu.tsx:1038-1082`).
  ///
  /// Each one is suppressed when its 1.x `show*` opt-out is `false` or when
  /// the app still supplies the reserved entry that fills the same role, so
  /// a menu never shows two settings, theme or about rows.
  List<IxMenuEntry> get _builtInBottomEntries {
    bool hasReserved(String id) =>
        widget.entries.any((entry) => entry.isBottom && entry.id == id);

    return [
      if (widget.settings != null &&
          // ignore: deprecated_member_use_from_same_package
          widget.showSettings &&
          !hasReserved('settings'))
        IxMenuEntry(
          id: _kSettingsEntryId,
          type: IxMenuEntryType.item,
          label: _strings.settings,
          iconWidget: const IxIcon.key(IxIconKey.cogwheel),
          isBottom: true,
        ),
      if (widget.enableToggleTheme &&
          // ignore: deprecated_member_use_from_same_package
          widget.showThemeToggle &&
          widget.onThemeModeChanged != null &&
          !hasReserved('theme-toggle'))
        IxMenuEntry(
          id: _kThemeEntryId,
          type: IxMenuEntryType.custom,
          label: _strings.toggleTheme,
          iconWidget: const IxIcon.key(IxIconKey.lightDark),
          isBottom: true,
        ),
      if (widget.about != null &&
          // ignore: deprecated_member_use_from_same_package
          widget.showAboutLegal &&
          !hasReserved('about-legal'))
        IxMenuEntry(
          id: _kAboutEntryId,
          type: IxMenuEntryType.item,
          label: _strings.about,
          iconWidget: const IxIcon.key(IxIconKey.about),
          isBottom: true,
        ),
    ];
  }

  bool _isBottomEntryVisible(IxMenuEntry entry) {
    switch (entry.id) {
      case 'settings':
        // ignore: deprecated_member_use_from_same_package
        return widget.showSettings;
      case 'theme-toggle':
        // ignore: deprecated_member_use_from_same_package
        return widget.showThemeToggle;
      case 'about-legal':
        // ignore: deprecated_member_use_from_same_package
        return widget.showAboutLegal;
      default:
        return true;
    }
  }

  bool get _useDrawerLayout {
    final width = MediaQuery.sizeOf(context).width;
    return width < _mobileBreakpoint;
  }

  /// [widget.animationDuration] resolved against the ambient reduced-motion
  /// preference. Computed once here and threaded down to every navigation
  /// panel widget that animates on it, so none of them need their own
  /// `MediaQuery` lookup.
  Duration get _effectiveAnimationDuration =>
      IxMotion.of(context, widget.animationDuration);

  @override
  Widget build(BuildContext context) {
    // Placed above the Navigator (a persistent shell in
    // `MaterialApp.builder`) there is no Overlay to host the fly-out, so the
    // scaffold brings its own. The lookup is only reached on a rebuild of
    // this widget, and the answer is stable for a given placement.
    if (Overlay.maybeOf(context) == null) {
      return Overlay(
        initialEntries: [
          _selfHostedEntry ??= OverlayEntry(builder: (_) => _buildPortal()),
        ],
      );
    }
    return _buildPortal();
  }

  /// A single portal for both layouts: only one of them is mounted at a
  /// time, and the fly-out has to escape the menu's own clip and width.
  Widget _buildPortal() {
    return OverlayPortal(
      controller: _flyoutPortal,
      overlayChildBuilder: _buildFlyout,
      child: _useDrawerLayout
          ? _buildDrawerLayout()
          : _buildSideNavigationLayout(),
    );
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
                return IxIconButton(
                  icon: const IxIcon.key(IxIconKey.apps),
                  tooltip: _strings.openMenu,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
      drawer: Drawer(
        child: SafeArea(
          child: _menuTapRegion(
            KeyedSubtree(
              key: _menuKey,
              child: _buildNavigationPanel(
                isExpanded: true,
                showCollapseAction: false,
                closeDrawer: true,
              ),
            ),
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
          _menuTapRegion(
            KeyedSubtree(
              key: _menuKey,
              child: AnimatedContainer(
                duration: _effectiveAnimationDuration,
                width: _isExpanded
                    ? widget.expandedWidth
                    : widget.collapsedWidth,
                child: _buildNavigationPanel(
                  isExpanded: _isExpanded,
                  showCollapseAction: true,
                  closeDrawer: false,
                ),
              ),
            ),
          ),
          // const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  /// The navigation panel both layouts render; they differ only in whether
  /// the menu can be collapsed and whether tapping an entry also closes the
  /// drawer.
  Widget _buildNavigationPanel({
    required bool isExpanded,
    required bool showCollapseAction,
    required bool closeDrawer,
  }) {
    return _NavigationPanel(
      appTitle: widget.appTitle,
      entries: _topEntries,
      bottomEntries: _bottomEntries,
      isExpanded: isExpanded,
      showCollapseAction: showCollapseAction,
      animationDuration: _effectiveAnimationDuration,
      expandedWidth: widget.expandedWidth,
      collapsedWidth: widget.collapsedWidth,
      themeMode: widget.themeMode,
      onThemeModeChanged: widget.onThemeModeChanged,
      strings: _strings,
      openFlyoutId: _openFlyoutId,
      focusNodeOf: _tileNode,
      onEntryTap: (entry) => _handleEntryTap(entry, closeDrawer: closeDrawer),
      onBottomEntryTap: (entry) =>
          _handleBottomEntryTap(entry, closeDrawer: closeDrawer),
      onToggleCollapse: _toggleExpandedState,
      isCategoryExpanded: _isCategoryExpanded,
      onCategoryExpansionChanged: _toggleCategory,
      onOpenFlyout: (entry) => _toggleFlyout(entry.id),
    );
  }

  /// Puts the menu in the same [TapRegion] group as its fly-out, so tapping
  /// a menu tile never registers as a tap outside the panel.
  Widget _menuTapRegion(Widget child) =>
      TapRegion(groupId: _tapRegionGroupId, child: child);

  /// Builds the fly-out overlay: the built-in settings/about panel when one
  /// is open, otherwise the children of the open category.
  Widget _buildFlyout(BuildContext context) {
    final anchorId = _openFlyoutId;
    if (anchorId == null) {
      return const SizedBox.shrink();
    }

    final Widget? content;
    final String title;
    if (anchorId == _kSettingsEntryId) {
      content = widget.settings;
      title = _strings.settings;
    } else if (anchorId == _kAboutEntryId) {
      content = widget.about;
      title = _strings.about;
    } else {
      final category = _findEntry(widget.entries, anchorId);
      content = category == null ? null : _flyoutCategoryList(category);
      title = category?.label ?? _strings.menuLabel;
    }
    if (content == null) {
      return const SizedBox.shrink();
    }

    // The panel is anchored to the menu's trailing edge, so it has to be
    // clamped to what is left of the viewport: a Drawer in particular
    // starts at the very top and leaves less room than the side rail.
    // (Flipping to the other side is B-5's redesign, not this clamp.)
    //
    // Everything below is in the target `Overlay`'s coordinate space, which
    // the panel is laid out in. Positioned by hand rather than by a
    // `CompositedTransformFollower`: a follower layer makes the paint
    // transform of everything under it incomputable, and
    // `OverlayPortal.overlayChildLayoutBuilder` needs exactly that -- so an
    // `IxDropdownButton` inside a `settings:` panel threw the moment it was
    // opened.
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    final viewport = overlayBox != null && overlayBox.hasSize
        ? overlayBox.size
        : MediaQuery.sizeOf(context);
    final anchor = _menuRectIn(overlayBox);
    final appBarBottom =
        (widget.appBar?.preferredSize.height ?? kToolbarHeight) +
        MediaQuery.paddingOf(context).top;
    final anchorTop = anchor?.top ?? appBarBottom;
    final top = math.max(anchorTop, appBarBottom);
    // The panel opens away from the menu rail, which in RTL means leftwards
    // from the anchor's leading (left) edge, so the room left for the panel
    // is measured from the opposite side there.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final available = anchor == null
        ? _kFlyoutWidth
        : (isRtl ? anchor.left : viewport.width - anchor.right) -
              _kFlyoutMargin;

    // On a phone the drawer leaves next to nothing beside it (304px of a
    // 360px viewport), and a 48px-wide panel is unreadable -- its own header
    // row overflows. Below `_kFlyoutMinSideRoom` the panel is placed over
    // the menu instead of beside it, flush to the far edge of the viewport.
    final double width;
    final double left;
    if (anchor != null && available < _kFlyoutMinSideRoom) {
      width = math.min(
        _kFlyoutWidth,
        math.max(0.0, viewport.width - 2 * _kFlyoutMargin),
      );
      left = isRtl
          ? math.max(_kFlyoutMargin, 0.0)
          : math.max(_kFlyoutMargin, viewport.width - _kFlyoutMargin - width);
    } else {
      width = available <= 0
          ? _kFlyoutWidth
          : math.min(_kFlyoutWidth, available);
      final anchorEdge = anchor == null
          ? (isRtl ? viewport.width : 0.0)
          : (isRtl ? anchor.left : anchor.right);
      left = isRtl ? math.max(0.0, anchorEdge - width) : anchorEdge;
    }

    // The overlay lays its children out at its own full size, so the panel
    // is pushed to its place with padding and pinned to the top-left corner
    // of what is left.
    return Padding(
      padding: EdgeInsets.only(left: math.max(0.0, left), top: top),
      child: Align(
        alignment: Alignment.topLeft,
        child: IxMenuFlyout(
          title: title,
          strings: _strings,
          groupId: _tapRegionGroupId,
          width: width,
          maxHeight: math.max(0.0, viewport.height - top - _kFlyoutMargin),
          returnFocusTo: _tileNodes[anchorId],
          onClose: _closeFlyout,
          child: content,
        ),
      ),
    );
  }

  /// The rows of a category fly-out: the same tiles the menu renders when
  /// it is expanded.
  Widget _flyoutCategoryList(IxMenuEntry category) {
    final theme = Theme.of(context);
    final sidebarTheme = _resolveSidebarTheme(theme);
    final appMenuTheme = theme.extension<IxAppMenuTheme>();
    final duration = _effectiveAnimationDuration;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        IxCommonGeometry.space1,
        0,
        IxCommonGeometry.space1,
        IxCommonGeometry.space1,
      ),
      children: [
        for (var i = 0; i < category.children.length; i++)
          _NavigationEntry(
            entry: category.children[i],
            depth: 0,
            isExpanded: true,
            sidebarTheme: sidebarTheme,
            appMenuTheme: appMenuTheme,
            animationDuration: duration,
            strings: _strings,
            isCategoryExpanded: _isCategoryExpanded(category.children[i].id),
            openFlyoutId: _openFlyoutId,
            focusOf: (id) => (node: _tileNode(id), order: i.toDouble()),
            onCategoryExpansionChanged: _toggleCategory,
            onEntryTap: _handleFlyoutEntryTap,
            onOpenFlyout: (entry) => _toggleFlyout(entry.id),
          ),
      ],
    );
  }

  /// The menu rail's rect in [ancestor]'s coordinate space (global when it is
  /// `null`), as of the frame already on screen; `null` before the menu has
  /// been laid out once.
  Rect? _menuRectIn(RenderBox? ancestor) {
    final box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return null;
    }
    if (ancestor != null && !ancestor.attached) {
      return null;
    }
    return box.localToGlobal(Offset.zero, ancestor: ancestor) & box.size;
  }

  /// Depth-first lookup of the entry carrying [id].
  IxMenuEntry? _findEntry(List<IxMenuEntry> entries, String id) {
    for (final entry in entries) {
      if (entry.id == id) {
        return entry;
      }
      final match = _findEntry(entry.children, id);
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  /// Opens the fly-out anchored to the tile of [anchorId], or closes it
  /// again when it is already the open one.
  ///
  /// The [OverlayPortal] is only shown while a panel is open: a hidden
  /// portal never resolves an [Overlay], so a scaffold that shows no
  /// fly-out works anywhere -- including above the `Navigator`, in
  /// `MaterialApp.builder`.
  void _toggleFlyout(String anchorId) {
    if (_openFlyoutId == anchorId) {
      // Re-tapping the anchor is a close like any other, so it goes through
      // the same path -- which hands the focus back to the anchor tile
      // instead of dropping it into the root scope.
      _closeFlyout();
      return;
    }
    setState(() => _openFlyoutId = anchorId);
    _flyoutPortal.show();
  }

  /// Hides the portal, if it is showing at all.
  ///
  /// `hide()` asserts when it is called during a build, which
  /// [didUpdateWidget] is. The panel is already gone from that frame's tree
  /// (the portal builds nothing once `_openFlyoutId` is null), so the hide
  /// itself waits for the frame to end.
  void _hideFlyoutPortal() {
    if (!_flyoutPortal.isShowing) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _openFlyoutId == null) {
          _hideFlyoutPortal();
        }
      });
      return;
    }
    _flyoutPortal.hide();
  }

  /// Closes the open fly-out.
  ///
  /// [returnFocus] hands the keyboard focus back to the tile that opened the
  /// panel, post-frame (the panel's own focus scope is still unwinding).
  /// It is switched off when the caller is about to move the focus itself,
  /// or when the tile is going away with the panel.
  void _closeFlyout({bool returnFocus = true}) {
    final anchor = _openFlyoutId;
    if (anchor == null) {
      return;
    }
    // Assigned rather than `setState`-ed when this runs from
    // `didUpdateWidget`: the build that reads it is the very next thing the
    // framework does.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _openFlyoutId = null;
    } else {
      setState(() => _openFlyoutId = null);
    }
    _hideFlyoutPortal();
    if (!returnFocus) {
      return;
    }
    final node = _tileNodes[anchor];
    if (node == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && node.context != null && node.canRequestFocus) {
        node.requestFocus();
      }
    });
  }

  void _toggleExpandedState() {
    // The panel is anchored to the rail whose width is about to change, and
    // a collapsed category expands inline once the menu is open -- so the
    // fly-out closes, through the path that returns the focus to its anchor.
    _closeFlyout();
    setState(() => _isExpanded = !_isExpanded);
  }

  /// Closes the drawer this scaffold owns.
  ///
  /// Through its own [ScaffoldState], not `Navigator.maybePop()`: the drawer
  /// route belongs to the `Scaffold` below, and a scaffold placed *above* the
  /// `Navigator` (a persistent shell in `MaterialApp.builder`) has no
  /// navigator in its context at all, so popping threw instead of closing.
  void _closeDrawer() {
    final scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
    }
  }

  void _handleEntryTap(IxMenuEntry entry, {bool closeDrawer = false}) {
    // A fly-out anchored in the menu belongs to the menu; navigating away
    // leaves nothing to anchor it to.
    _closeFlyout();
    widget.onNavigate(entry.id);
    if (closeDrawer) {
      _closeDrawer();
    }
  }

  /// Navigating from inside a fly-out closes it and hands focus back to the
  /// category tile that opened it.
  void _handleFlyoutEntryTap(IxMenuEntry entry) {
    final anchor = _openFlyoutId;
    _closeFlyout(returnFocus: false);
    widget.onNavigate(entry.id);
    final node = anchor == null ? null : _tileNodes[anchor];
    if (node != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (node.context != null) {
          node.requestFocus();
        }
      });
    }
  }

  void _handleBottomEntryTap(IxMenuEntry entry, {bool closeDrawer = false}) {
    switch (entry.id) {
      case _kSettingsEntryId:
      case _kAboutEntryId:
        // Built-in panels open next to the menu, so the drawer stays put.
        _toggleFlyout(entry.id);
        return;
      case _kThemeEntryId:
        widget.onThemeModeChanged?.call(_nextThemeMode(widget.themeMode));
        return;
      case 'settings':
        // ignore: deprecated_member_use_from_same_package
        if (widget.showSettings) {
          // ignore: deprecated_member_use_from_same_package
          widget.onOpenSettings?.call();
        }
        break;
      case 'theme-toggle':
        // Switching the theme never closes the drawer: the menu is where
        // the switch lives, so 1.x users stay in it.
        // ignore: deprecated_member_use_from_same_package
        if (widget.showThemeToggle) {
          final nextMode = _nextThemeMode(widget.themeMode);
          widget.onThemeModeChanged?.call(nextMode);
        }
        return;
      case 'about-legal':
        // ignore: deprecated_member_use_from_same_package
        if (widget.showAboutLegal) {
          // ignore: deprecated_member_use_from_same_package
          widget.onOpenAboutLegal?.call();
        }
        break;
      default:
        widget.onNavigate(entry.id);
        break;
    }

    _closeFlyout();
    if (closeDrawer) {
      _closeDrawer();
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
    required this.strings,
    required this.openFlyoutId,
    required this.focusNodeOf,
    required this.onEntryTap,
    required this.onBottomEntryTap,
    required this.onToggleCollapse,
    required this.isCategoryExpanded,
    required this.onCategoryExpansionChanged,
    required this.onOpenFlyout,
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
  final IxApplicationStrings strings;
  final String? openFlyoutId;
  final FocusNode Function(String id) focusNodeOf;
  final ValueChanged<IxMenuEntry> onEntryTap;
  final ValueChanged<IxMenuEntry> onBottomEntryTap;
  final VoidCallback onToggleCollapse;
  final bool Function(String id) isCategoryExpanded;
  final ValueChanged<String> onCategoryExpansionChanged;
  final ValueChanged<IxMenuEntry> onOpenFlyout;

  @override
  State<_NavigationPanel> createState() => _NavigationPanelState();
}

/// Moves menu focus by [delta] entries.
class _MoveFocusIntent extends Intent {
  const _MoveFocusIntent(this.delta);

  final int delta;
}

/// Moves menu focus to the first or last entry.
class _JumpFocusIntent extends Intent {
  const _JumpFocusIntent({required this.first});

  final bool first;
}

class _NavigationPanelState extends State<_NavigationPanel> {
  late final ScrollController _scrollController;
  bool _showTopShadow = false;
  bool _showBottomShadow = false;

  /// The focus nodes of every currently rendered tile, in visual order.
  ///
  /// Rebuilt on every build (expanding a category or collapsing the menu
  /// changes which tiles exist) and read by the arrow-key actions below.
  final List<FocusNode> _order = <FocusNode>[];

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

  /// Focuses [node] and scrolls the menu just far enough to show it.
  ///
  /// Every tile is built eagerly (the menu uses a `SingleChildScrollView`,
  /// not a lazy list -- see the comment at its construction), so the node
  /// always has a context to reveal; without this a tile below the fold
  /// would take focus while staying off screen, which is exactly what the
  /// focus ring is there to prevent.
  void _focusTile(FocusNode node, {required bool forward}) {
    node.requestFocus();
    final context = node.context;
    // `mounted` as well as non-null: a node whose tile has been unmounted
    // (a category collapsed under it, say) keeps its defunct element until
    // it is reattached, and `ensureVisible` asserts on one.
    if (context == null || !context.mounted) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      alignment: forward ? 1.0 : 0.0,
      alignmentPolicy: forward
          ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
          : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      duration: IxMotion.of(context, IxMotion.defaultTime),
    );
  }

  /// Moves focus [delta] tiles along [_order], clamped at both ends.
  ///
  /// Upstream's `menu.tsx:887-899` wraps around; the programme constraints
  /// prescribe clamping for the 1.x menu instead.
  ///
  /// A disabled tile is in [_order] -- it is rendered, and the eye walks past
  /// it -- but its `InkWell` refuses focus, so landing on one used to stop
  /// the arrow keys dead. Disabled tiles are stepped over instead, and the
  /// clamp applies to the tiles that can actually take the focus.
  void _move(int delta) {
    final index = _order.indexWhere((node) => node.hasFocus);
    if (index < 0) {
      return;
    }
    final step = delta.sign;
    final target = _focusableFrom(index + delta, step);
    if (target == null) {
      return;
    }
    _focusTile(_order[target], forward: target >= index);
  }

  /// The first index at or after [from] (walking in direction [step]) whose
  /// tile can take the focus, or `null` when there is none in that
  /// direction.
  int? _focusableFrom(int from, int step) {
    final clamped = from.clamp(0, _order.length - 1);
    for (var i = clamped; i >= 0 && i < _order.length; i += step) {
      if (_order[i].canRequestFocus) {
        return i;
      }
    }
    // Nothing beyond the requested end: fall back to the nearest focusable
    // tile on the way back, so a run of disabled entries at one edge does
    // not swallow the key press.
    for (var i = clamped; i >= 0 && i < _order.length; i -= step) {
      if (_order[i].canRequestFocus) {
        return i;
      }
    }
    return null;
  }

  /// Moves focus to the first or last tile that can take it (`Home`/`End`,
  /// `menu.tsx:901-910`).
  void _jump({required bool first}) {
    if (_order.isEmpty) {
      return;
    }
    final target = first
        ? _focusableFrom(0, 1)
        : _focusableFrom(_order.length - 1, -1);
    if (target == null) {
      return;
    }
    _focusTile(_order[target], forward: !first);
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

        // The tiles that are actually on screen, in the order the eye (and
        // therefore the arrow keys and Tab) walks them.
        final visible = <IxMenuEntry>[];
        // `depth`, because only a top-level category renders its children
        // inline: `_NavigationEntry` builds a nested one with
        // `isCategoryExpanded: false`, so its grandchildren are never
        // mounted. Collecting them anyway put focus nodes with no element
        // into the traversal order -- a dead stop for the arrow keys, and a
        // defunct context for `Scrollable.ensureVisible`.
        void collect(List<IxMenuEntry> nodes, int depth) {
          for (final entry in nodes) {
            visible.add(entry);
            if (entry.type == IxMenuEntryType.category &&
                isPanelExpanded &&
                depth == 0 &&
                widget.isCategoryExpanded(entry.id)) {
              collect(entry.children, depth + 1);
            }
          }
        }

        collect(widget.entries, 0);
        visible.addAll(widget.bottomEntries);

        // Traversal order 0 belongs to the sidebar toggle in the header, so
        // the tiles start at 1.
        final orderOf = <String, double>{};
        _order.clear();
        for (var i = 0; i < visible.length; i++) {
          orderOf[visible[i].id] = i + 1.0;
          _order.add(widget.focusNodeOf(visible[i].id));
        }
        ({FocusNode node, double order}) focusOf(String id) => (
          node: widget.focusNodeOf(id),
          order: orderOf[id] ?? visible.length + 1.0,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: sidebarTheme.backgroundColor,
            // border: Border(
            //   right: BorderSide(color: sidebarTheme.borderColor, width: 1),
            // ),
          ),
          child: SafeArea(
            child: Semantics(
              key: _kMenuBarKey,
              container: true,
              explicitChildNodes: true,
              role: SemanticsRole.menuBar,
              label: widget.strings.menuLabel,
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Shortcuts(
                  shortcuts: const <ShortcutActivator, Intent>{
                    SingleActivator(LogicalKeyboardKey.arrowDown):
                        _MoveFocusIntent(1),
                    SingleActivator(LogicalKeyboardKey.arrowUp):
                        _MoveFocusIntent(-1),
                    SingleActivator(LogicalKeyboardKey.home): _JumpFocusIntent(
                      first: true,
                    ),
                    SingleActivator(LogicalKeyboardKey.end): _JumpFocusIntent(
                      first: false,
                    ),
                  },
                  child: Actions(
                    actions: <Type, Action<Intent>>{
                      _MoveFocusIntent: CallbackAction<_MoveFocusIntent>(
                        onInvoke: (intent) {
                          _move(intent.delta);
                          return null;
                        },
                      ),
                      _JumpFocusIntent: CallbackAction<_JumpFocusIntent>(
                        onInvoke: (intent) {
                          _jump(first: intent.first);
                          return null;
                        },
                      ),
                    },
                    child: Column(
                      children: [
                        _NavigationHeader(
                          title: widget.appTitle,
                          isExpanded: isPanelExpanded,
                          showCollapseAction: widget.showCollapseAction,
                          onToggleCollapse: widget.onToggleCollapse,
                          animationDuration: widget.animationDuration,
                          collapsedSlotWidth: widget.collapsedWidth,
                          strings: widget.strings,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Stack(
                            children: [
                              // Eager children rather than a lazy
                              // `ListView`: every entry belongs to the
                              // menu's ordered traversal, so every tile's
                              // focus node has to be attached -- a lazily
                              // built one can be neither focused nor
                              // revealed. (`cacheExtent: double.infinity`
                              // would do the same but trips the
                              // framework's `value.isFinite` assertion.)
                              SingleChildScrollView(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (final entry in widget.entries)
                                      _NavigationEntry(
                                        entry: entry,
                                        depth: 0,
                                        isExpanded: isPanelExpanded,
                                        sidebarTheme: sidebarTheme,
                                        appMenuTheme: appMenuTheme,
                                        animationDuration:
                                            widget.animationDuration,
                                        strings: widget.strings,
                                        isCategoryExpanded: widget
                                            .isCategoryExpanded(entry.id),
                                        openFlyoutId: widget.openFlyoutId,
                                        focusOf: focusOf,
                                        onCategoryExpansionChanged:
                                            widget.onCategoryExpansionChanged,
                                        onEntryTap: widget.onEntryTap,
                                        onOpenFlyout: widget.onOpenFlyout,
                                      ),
                                  ],
                                ),
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
                                    onThemeModeChanged:
                                        widget.onThemeModeChanged,
                                    strings: widget.strings,
                                    focusOf: focusOf,
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
    required this.strings,
  });

  final String title;
  final bool isExpanded;
  final bool showCollapseAction;
  final VoidCallback onToggleCollapse;
  final Duration animationDuration;
  final double collapsedSlotWidth;
  final IxApplicationStrings strings;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final button = showCollapseAction
        ? FocusTraversalOrder(
            // The sidebar toggle is the menu's first stop, ahead of every
            // tile (which are ordered from 1 upwards).
            order: const NumericFocusOrder(0),
            child: IxIconButton(
              icon: AnimatedRotation(
                turns: isExpanded ? 0 : 0.5,
                duration: animationDuration,
                child: const IxIcon.key(IxIconKey.doubleChevronLeft),
              ),
              tooltip: isExpanded
                  ? strings.collapseSidebar
                  : strings.expandSidebar,
              onPressed: onToggleCollapse,
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
    required this.strings,
    required this.isCategoryExpanded,
    required this.openFlyoutId,
    required this.focusOf,
    required this.onCategoryExpansionChanged,
    required this.onEntryTap,
    required this.onOpenFlyout,
  });

  final IxMenuEntry entry;
  final int depth;
  final bool isExpanded;
  final IxSidebarTheme sidebarTheme;
  final IxAppMenuTheme? appMenuTheme;
  final Duration animationDuration;
  final IxApplicationStrings strings;
  final bool isCategoryExpanded;
  final String? openFlyoutId;
  final _TileFocusOf focusOf;
  final ValueChanged<String> onCategoryExpansionChanged;
  final ValueChanged<IxMenuEntry> onEntryTap;
  final ValueChanged<IxMenuEntry> onOpenFlyout;

  @override
  Widget build(BuildContext context) {
    final focus = focusOf(entry.id);

    if (entry.type == IxMenuEntryType.category) {
      final hasSelectedChild = entry.children.any((child) => child.selected);
      // A collapsed menu has no room for inline children, so the category
      // reveals them in a fly-out panel next to the rail instead.
      final usesFlyout = !isExpanded;
      final showChildren = isExpanded && isCategoryExpanded;
      final isOpen = usesFlyout ? openFlyoutId == entry.id : isCategoryExpanded;

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
            expanded: isOpen,
            focusNode: focus.node,
            traversalOrder: focus.order,
            trailing: AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: animationDuration,
              child: const IxIcon.key(
                IxIconKey.chevronDownSmall,
                size: IxIconSize.s16,
              ),
            ),
            onTap: !entry.enabled
                ? null
                : usesFlyout
                ? () => onOpenFlyout(entry)
                : () => onCategoryExpansionChanged(entry.id),
          ),
          _CategoryChildren(
            expanded: showChildren,
            duration: animationDuration,
            tileFocusNode: focus.node,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in entry.children)
                  _NavigationEntry(
                    entry: child,
                    depth: depth + 1,
                    isExpanded: isExpanded,
                    sidebarTheme: sidebarTheme,
                    appMenuTheme: appMenuTheme,
                    animationDuration: animationDuration,
                    strings: strings,
                    isCategoryExpanded: false,
                    openFlyoutId: openFlyoutId,
                    focusOf: focusOf,
                    onCategoryExpansionChanged: onCategoryExpansionChanged,
                    onEntryTap: onEntryTap,
                    onOpenFlyout: onOpenFlyout,
                  ),
              ],
            ),
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
      focusNode: focus.node,
      traversalOrder: focus.order,
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
    required this.strings,
    required this.focusOf,
    required this.onTap,
  });

  final IxMenuEntry entry;
  final bool isExpanded;
  final IxSidebarTheme sidebarTheme;
  final IxAppMenuTheme? appMenuTheme;
  final Duration animationDuration;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final IxApplicationStrings strings;
  final _TileFocusOf focusOf;
  final ValueChanged<IxMenuEntry> onTap;

  /// Both the built-in toggle and the reserved 1.x `theme-toggle` entry
  /// render the theme indicator.
  bool get _isThemeToggle =>
      entry.id == _kThemeEntryId ||
      (entry.type == IxMenuEntryType.custom && entry.id == 'theme-toggle');

  @override
  Widget build(BuildContext context) {
    final focus = focusOf(entry.id);

    if (_isThemeToggle) {
      final enabled = entry.enabled && onThemeModeChanged != null;
      return _NavigationTile(
        entry: entry,
        depth: 0,
        isExpanded: isExpanded,
        sidebarTheme: sidebarTheme,
        appMenuTheme: appMenuTheme,
        animationDuration: animationDuration,
        selected: false,
        enabled: enabled,
        toggled: themeMode == ThemeMode.dark,
        value: _themeModeLabel(strings, themeMode),
        focusNode: focus.node,
        traversalOrder: focus.order,
        trailing: _ThemeModeIndicator(
          isExpanded: isExpanded,
          themeMode: themeMode,
          sidebarTheme: sidebarTheme,
          strings: strings,
        ),
        onTap: enabled ? () => onTap(entry) : null,
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
      focusNode: focus.node,
      traversalOrder: focus.order,
      onTap: entry.enabled ? () => onTap(entry) : null,
    );
  }
}

/// The animated container for an expanded category's child entries.
///
/// Drives the reveal with its own [AnimationController] and a
/// [SizeTransition] rather than an `AnimatedSize`, for the same two reasons
/// `IxBlind` does (see `ix_blind.dart`): under reduced motion the duration
/// is [Duration.zero], and a zero-duration `RenderAnimatedSize` asked to
/// animate an actual size change re-dirties itself from inside its own
/// `performLayout()`. That is reachable here through public API --
/// [IxMenuEntry.children] and each child's [IxMenuEntry.iconWidget] are
/// consumer-supplied, so an open category *can* change height on its own --
/// and the alternative workaround (re-keying while the duration is zero)
/// remounts the whole child subtree whenever the platform's reduce-motion
/// setting flips, destroying any state those widgets hold.
///
/// A controller keeps the subtree's shape and elements identical whatever
/// the duration is, and snaps synchronously *outside* layout when the
/// duration is zero.
class _CategoryChildren extends StatefulWidget {
  const _CategoryChildren({
    required this.expanded,
    required this.duration,
    required this.tileFocusNode,
    required this.child,
  });

  /// Whether the category is currently open. The state is owned by the
  /// scaffold, so this widget is purely controlled.
  final bool expanded;

  /// The category tile's own focus node: where the focus goes when the
  /// entry holding it is collapsed away.
  final FocusNode tileFocusNode;

  /// The scaffold's [IxApplicationScaffold.animationDuration], already
  /// resolved against the ambient reduced-motion preference by
  /// `_IxApplicationScaffoldState._effectiveAnimationDuration`.
  final Duration duration;

  /// The child entries, built unconditionally by the caller: this widget
  /// decides when they are in the tree.
  final Widget child;

  @override
  State<_CategoryChildren> createState() => _CategoryChildrenState();
}

class _CategoryChildrenState extends State<_CategoryChildren>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expansion;
  late final CurvedAnimation _heightFactor;

  /// A non-focusable, non-traversable ancestor of the children: the
  /// `ExcludeFocus` that keeps traversal out of a collapsed (or still
  /// collapsing) subtree, held as a node so [didUpdateWidget] can also ask
  /// whether the focus is inside it.
  final FocusNode _childrenFocus = FocusNode(
    debugLabel: 'IxApplicationScaffold.categoryChildren',
    skipTraversal: true,
    canRequestFocus: false,
  );

  @override
  void initState() {
    super.initState();
    _expansion = AnimationController(
      vsync: this,
      value: widget.expanded ? 1.0 : 0.0,
    );
    _heightFactor = CurvedAnimation(
      parent: _expansion,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The duration arrives as a widget property rather than being read from
    // `MediaQuery` here, so that a consumer's own
    // `IxApplicationScaffold.animationDuration` keeps working; the scaffold
    // has already run it through `IxMotion.of`, and it rebuilds (passing a
    // new one down to `didUpdateWidget` below) when reduced motion flips.
    _expansion.duration = widget.duration;
  }

  @override
  void didUpdateWidget(covariant _CategoryChildren oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _expansion.duration = widget.duration;
    }
    if (widget.expanded == oldWidget.expanded) {
      return;
    }
    if (widget.expanded) {
      _expansion.forward();
      return;
    }
    // The children are about to stop being focusable (and, once the
    // transition ends, to leave the tree). Hand the focus to the category
    // tile they belong to rather than letting the framework drop it into
    // the enclosing scope, so the next Tab continues from the category
    // instead of restarting at the top of the page (WCAG 2.4.3). Same
    // rescue `IxBlind` does for its header.
    if (_childrenFocus.hasFocus) {
      widget.tileFocusNode.requestFocus();
    }
    _expansion.reverse().whenComplete(() {
      if (!mounted) {
        return;
      }
      // Rebuild so the now fully collapsed children leave the tree; the
      // controller alone only repaints the transition.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _heightFactor.dispose();
    _expansion.dispose();
    _childrenFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Collapsed children stay out of the tree, but only once the collapse
    // has actually finished -- otherwise there would be nothing to shrink.
    final hasChildren = widget.expanded || !_expansion.isDismissed;
    return SizeTransition(
      sizeFactor: _heightFactor,
      alignment: Alignment.topCenter,
      // A *collapsing* subtree is still mounted (it is what the transition
      // shrinks) and still painted, clipped, until the last frame. Until it
      // is fully open again it must not be announced or reachable by Tab,
      // or the focus would land on an entry that is about to be unmounted.
      //
      // `ExcludeFocus`, spelled out as the `Focus` it is so the state holds
      // the node too -- see [_childrenFocus].
      child: Focus(
        focusNode: _childrenFocus,
        canRequestFocus: false,
        skipTraversal: true,
        descendantsAreFocusable: widget.expanded,
        child: ExcludeSemantics(
          excluding: !widget.expanded,
          child: hasChildren
              ? widget.child
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ),
    );
  }
}

/// A single menu row.
///
/// Publishes exactly one semantics node -- its own -- so a screen reader
/// announces the entry once, with the state that applies to it: `selected`
/// for a plain entry, `expanded` for a category, `toggled` plus the theme
/// name as `value` for the theme switch. The visible [Tooltip] is excluded
/// from semantics for the same reason (it would otherwise duplicate the
/// label), and the entry's own [IxMenuEntry.tooltip] is surfaced as a hint.
class _NavigationTile extends StatefulWidget {
  const _NavigationTile({
    required this.entry,
    required this.depth,
    required this.isExpanded,
    required this.sidebarTheme,
    required this.appMenuTheme,
    required this.animationDuration,
    required this.selected,
    required this.enabled,
    this.expanded,
    this.toggled,
    this.value,
    this.focusNode,
    this.traversalOrder,
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

  /// Expanded state of a category tile; `null` for every other tile.
  final bool? expanded;

  /// Toggled state of the theme switch; `null` for every other tile.
  final bool? toggled;

  /// Accessibility value, used by the theme switch for the active mode.
  final String? value;

  /// Focus node owned by the scaffold, so a fly-out can return focus here.
  final FocusNode? focusNode;

  /// Position of this tile in the menu's ordered traversal group.
  final double? traversalOrder;

  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<_NavigationTile> createState() => _NavigationTileState();
}

class _NavigationTileState extends State<_NavigationTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{};
    if (widget.selected) {
      states.add(WidgetState.selected);
    }
    if (!widget.enabled) {
      states.add(WidgetState.disabled);
    }

    final backgroundColor =
        widget.sidebarTheme.itemBackground.resolve(states) ??
        Colors.transparent;
    final foregroundColor =
        widget.sidebarTheme.itemForeground.resolve(states) ??
        Theme.of(context).colorScheme.onSurface;
    final iconColor =
        widget.sidebarTheme.itemIconColor.resolve(states) ??
        foregroundColor.withValues(alpha: 0.9);
    final badgeBackground =
        widget.appMenuTheme?.badgeBackgroundColor ??
        Theme.of(context).colorScheme.error;
    final badgeForeground =
        widget.appMenuTheme?.badgeForegroundColor ??
        Theme.of(context).colorScheme.onError;

    final badgeCount = widget.entry.notificationCount;
    final indicatorColor = Theme.of(context).colorScheme.primary;

    final iconWidget =
        widget.entry.iconWidget ??
        (widget.entry.icon != null
            ? Icon(
                widget.entry.icon,
                color: iconColor,
                size: widget.isExpanded ? 22 : 18,
              )
            : IxIcon.key(
                IxIconKey.document,
                size: widget.isExpanded ? IxIconSize.s24 : IxIconSize.s16,
                color: iconColor,
              ));

    final gap = widget.isExpanded ? 12.0 : 4.0;

    final Widget tile = Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      // `aria-selected` only applies to a plain entry: a category is
      // described by its expanded state and the theme switch by its
      // toggled state, so those tiles must not claim a selected state too.
      selected: widget.expanded == null && widget.toggled == null
          ? widget.selected
          : null,
      expanded: widget.expanded,
      toggled: widget.toggled,
      // A disabled tile drops out of the traversal order, so it must not
      // claim to be focusable either.
      focusable: widget.enabled,
      // `excludeSemantics` drops the InkWell's own focused flag, so the
      // state the focus ring already tracks is republished here -- without
      // it assistive technology cannot follow the arrow keys.
      //
      // `null`, not `false`, while disabled: `focusable` and `focused` share
      // one tristate flag and `focused` is applied *after* `focusable`, so an
      // explicit `focused: false` would undo the line above and put a
      // disabled tile back into the traversal order.
      focused: widget.enabled ? _focused : null,
      label: widget.entry.label,
      value: widget.value,
      hint: widget.entry.tooltip,
      onTap: widget.enabled ? widget.onTap : null,
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: widget.depth * 16.0),
        child: IxFocusRing(
          focused: _focused,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            focusNode: widget.focusNode,
            borderRadius: BorderRadius.circular(12),
            onTap: widget.enabled ? widget.onTap : null,
            focusColor: Colors.transparent,
            onFocusChange: (focused) => setState(() => _focused = focused),
            child: Tooltip(
              message: widget.entry.tooltip ?? widget.entry.label,
              // Interaction delays (this hover wait, and the toast auto-close
              // delay in IxToastData) are deliberately not IxMotion tokens: they
              // gate *when* something happens on user input timing, not how long a
              // rendered transition takes, so reduced motion must not shorten them.
              waitDuration: const Duration(milliseconds: 500),
              excludeFromSemantics: true,
              child: AnimatedContainer(
                duration: widget.animationDuration,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isExpanded ? 12 : 8,
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
                      duration: widget.animationDuration,
                      width: 4,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.selected
                            ? indicatorColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: gap),
                    if (widget.isExpanded) ...[
                      iconWidget,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.entry.label,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: foregroundColor,
                                fontWeight: widget.selected
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
                      if (widget.trailing != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: widget.trailing!,
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
      ),
    );

    if (widget.traversalOrder == null) {
      return tile;
    }
    return FocusTraversalOrder(
      order: NumericFocusOrder(widget.traversalOrder!),
      child: tile,
    );
  }
}

class _ThemeModeIndicator extends StatelessWidget {
  const _ThemeModeIndicator({
    required this.isExpanded,
    required this.themeMode,
    required this.sidebarTheme,
    required this.strings,
  });

  final bool isExpanded;
  final ThemeMode themeMode;
  final IxSidebarTheme sidebarTheme;
  final IxApplicationStrings strings;

  @override
  Widget build(BuildContext context) {
    final label = _themeModeLabel(strings, themeMode);
    final color =
        sidebarTheme.itemForeground.resolve(<WidgetState>{}) ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final icon = IxIcon.key(
      _themeModeIconKey(themeMode),
      size: IxIconSize.s16,
      color: color,
    );

    if (!isExpanded) {
      return icon;
    }

    return AnimatedSwitcher(
      duration: IxMotion.of(context, IxMotion.defaultTime),
      child: Row(
        key: ValueKey(label),
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// The [IxApplicationStrings] label describing [mode].
String _themeModeLabel(IxApplicationStrings strings, ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return strings.themeSystem;
    case ThemeMode.light:
      return strings.themeLight;
    case ThemeMode.dark:
      return strings.themeDark;
  }
}

/// The icon describing [mode].
IxIconKey _themeModeIconKey(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return IxIconKey.lightDark;
    case ThemeMode.light:
      return IxIconKey.sun;
    case ThemeMode.dark:
      return IxIconKey.moon;
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
