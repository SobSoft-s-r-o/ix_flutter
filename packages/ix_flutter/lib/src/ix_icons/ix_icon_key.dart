/// Identifies one of the icons the `ix_flutter` library itself relies on for
/// its built-in widgets.
///
/// Every value is guaranteed to resolve via [IxIconResolver] — the built-in
/// [IxIconResolver.material] factory maps all of them to a Material glyph,
/// and the generated `@siemens/ix-icons` resolver (bundled separately, see
/// `UPSTREAM.md`) maps all of them to the matching Siemens iX SVG. Library
/// widgets always request icons through `IxIcon.key(IxIconKey.x)`, never a
/// hardcoded [IxIconData].
enum IxIconKey {
  /// Large chevron pointing left (navigation, "previous").
  chevronLeft,

  /// Large chevron pointing right (navigation, "next").
  chevronRight,

  /// Large chevron pointing up (expand/collapse, "collapse").
  chevronUp,

  /// Large chevron pointing down (expand/collapse, "expand").
  chevronDown,

  /// Small chevron pointing left, for compact controls.
  chevronLeftSmall,

  /// Small chevron pointing right, for compact controls.
  chevronRightSmall,

  /// Small chevron pointing up, for compact controls.
  chevronUpSmall,

  /// Small chevron pointing down, for compact controls.
  chevronDownSmall,

  /// Close/dismiss glyph ("x").
  close,

  /// Small variant of the close/dismiss glyph.
  closeSmall,

  /// App launcher grid glyph.
  apps,

  /// Overflow/"more actions" menu glyph (vertical ellipsis).
  moreMenu,

  /// Search/magnifying-glass glyph.
  search,

  /// Informational glyph, used for inline hints.
  info,

  /// Informational glyph, used for "about" entry points.
  about,

  /// Success/positive status glyph.
  success,

  /// Warning status glyph.
  warning,

  /// Error status glyph.
  error,

  /// Alarm/notification status glyph.
  alarm,

  /// Home/start page glyph.
  home,

  /// Document/file glyph.
  document,

  /// Settings/cogwheel glyph.
  cogwheel,

  /// Light/dark theme toggle glyph.
  lightDark,

  /// Double chevron pointing left (navigation, "first page"/"collapse all").
  doubleChevronLeft,

  /// Double chevron pointing right (navigation, "last page"/"expand all").
  doubleChevronRight,

  /// Sun glyph, used for the light theme option.
  sun,

  /// Moon glyph, used for the dark theme option.
  moon,

  /// Filter/funnel glyph.
  filter,
}
