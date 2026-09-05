/// Localizable strings rendered by `IxApplicationScaffold`.
///
/// [settings], [about] and [toggleTheme] repeat the upstream Siemens iX
/// English copy verbatim (`menu.tsx:144 i18nSettings`, `:139 i18nLegal`,
/// `:149 i18nToggleTheme`). [menuLabel], [expandSidebar] and
/// [collapseSidebar] fill the roles of `menu.tsx:125 i18nAriaLabelMenu`
/// ('Application Navigation'), `:154 i18nExpand` ('Expand') and `:159
/// i18nCollapse` ('Collapse') with wording of our own; the rest
/// ([openMenu], the theme names and [closePanel]) label parts that only
/// exist in this Flutter port and have no upstream counterpart.
///
/// Pass an instance to `IxApplicationScaffold.strings` to localize the
/// navigation menu without forking the widget:
///
/// ```dart
/// IxApplicationScaffold(
///   strings: const IxApplicationStrings(
///     settings: 'Einstellungen',
///     toggleTheme: 'Design wechseln',
///   ),
///   // ...
/// )
/// ```
class IxApplicationStrings {
  /// Creates a set of application-menu strings, defaulting to the upstream
  /// English copy.
  const IxApplicationStrings({
    this.menuLabel = 'Main navigation',
    this.openMenu = 'Open menu',
    this.expandSidebar = 'Expand sidebar',
    this.collapseSidebar = 'Collapse sidebar',
    this.settings = 'Settings',
    this.about = 'About & legal information',
    this.toggleTheme = 'Toggle theme',
    this.themeSystem = 'System',
    this.themeLight = 'Light',
    this.themeDark = 'Dark',
    this.closePanel = 'Close',
  });

  /// Accessible name of the navigation menu's `menuBar` landmark
  /// (upstream `menu.tsx:125 i18nAriaLabelMenu`, 'Application Navigation').
  final String menuLabel;

  /// Tooltip and accessible name of the app bar button that opens the
  /// navigation drawer on small screens.
  ///
  /// This replaces `MaterialLocalizations.openAppDrawerTooltip`, which
  /// Flutter localizes automatically -- a localized app should therefore set
  /// this string along with the rest.
  final String openMenu;

  /// Tooltip of the sidebar toggle while the menu is collapsed
  /// (upstream `menu.tsx:154 i18nExpand`, 'Expand').
  final String expandSidebar;

  /// Tooltip of the sidebar toggle while the menu is expanded
  /// (upstream `menu.tsx:159 i18nCollapse`, 'Collapse').
  final String collapseSidebar;

  /// Label of the built-in settings entry shown when
  /// `IxApplicationScaffold.settings` is set
  /// (upstream `menu.tsx:144 i18nSettings`).
  final String settings;

  /// Label of the built-in about entry shown when
  /// `IxApplicationScaffold.about` is set
  /// (upstream `menu.tsx:139 i18nLegal`).
  final String about;

  /// Label of the built-in theme-toggle entry
  /// (upstream `menu.tsx:149 i18nToggleTheme`).
  final String toggleTheme;

  /// Accessibility value and trailing label of the theme toggle while
  /// `ThemeMode.system` is active.
  final String themeSystem;

  /// Accessibility value and trailing label of the theme toggle while
  /// `ThemeMode.light` is active.
  final String themeLight;

  /// Accessibility value and trailing label of the theme toggle while
  /// `ThemeMode.dark` is active.
  final String themeDark;

  /// Tooltip and accessible name of the fly-out panel's close button.
  final String closePanel;
}
