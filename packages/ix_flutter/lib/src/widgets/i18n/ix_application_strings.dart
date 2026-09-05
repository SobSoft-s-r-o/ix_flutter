/// Localizable strings rendered by `IxApplicationScaffold`.
///
/// Defaults mirror the upstream Siemens iX web component's English copy in
/// `menu.tsx` (`i18nToggleTheme`, `i18nSettings`, `i18nLegal`,
/// `i18nExpandSidebar`, `i18nCollapseSidebar`). Pass an instance to
/// `IxApplicationScaffold.strings` to localize the navigation menu without
/// forking the widget:
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

  /// Accessible name of the navigation menu's `menuBar` landmark.
  final String menuLabel;

  /// Tooltip and accessible name of the app bar button that opens the
  /// navigation drawer on small screens.
  final String openMenu;

  /// Tooltip of the sidebar toggle while the menu is collapsed
  /// (upstream `i18nExpandSidebar`).
  final String expandSidebar;

  /// Tooltip of the sidebar toggle while the menu is expanded
  /// (upstream `i18nCollapseSidebar`).
  final String collapseSidebar;

  /// Label of the built-in settings entry shown when
  /// `IxApplicationScaffold.settings` is set (upstream `i18nSettings`).
  final String settings;

  /// Label of the built-in about entry shown when
  /// `IxApplicationScaffold.about` is set (upstream `i18nLegal`).
  final String about;

  /// Label of the built-in theme-toggle entry (upstream `i18nToggleTheme`).
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
