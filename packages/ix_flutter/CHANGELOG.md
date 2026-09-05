# Changelog

All notable changes to the ix_flutter project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Public exports for `IxPaginationBar` and `IxBottomSheetTheme` from the package barrel
- `IxTheme.of`/`IxTheme.maybeOf` static accessors for reading the Siemens IX theme extension from a `BuildContext`
- `IxFocusRing`, the shared 1px focus indicator used by the iX controls and available for wrapping custom focusables
- `IxUpstream` exported from the package barrel (the `@Upstream` traceability annotation)
- Work Sans (OFL) declared as an opt-in bundled UI font, `IxFonts.workSans`, `buttonLabel`/`caption`/`textDefault` styles, `liga`/`clig` disabled on every typography variant
- `IxTypography(package:, monospacePackage:)` for pointing the UI/monospace families at a font shipped by another package (pass `monospacePackage: null` to force-disable the built-in package prefix)
- `IxIcon`, `IxIconData`, `IxIconKey`, `IxIconResolver`, `IxIconSize` public icon contract; `IxThemeBuilder(icons:)` resolver override (defaults to `IxIconResolver.material()`); `IxIconData.fallback` plus SVG asset support (`IxIconData.asset`/`.packageAsset`) that falls back to the `fallback` glyph when an asset fails to load and reports the failure through `FlutterError.reportError` in debug builds
- `IxMotion` tokens with reduced-motion support, `IxSpinner.semanticLabel` + status role, `IxSpinnerVariant.secondary`
- `IxDensity` (adaptive touch/pointer hit areas), `IxDensity.resolvePlatform`, `IxDensityScope`, `IxThemeBuilder(density:)`, `IxIconButton` (32/24/16)
- `IxDropdownButton` keyboard model (Arrow/Home/End/Enter/Space to open and navigate, Escape/Tab to close), menu semantics (`menu`/`menuItem` roles, expanded state on the trigger), controlled `isOpen`/`onOpenChanged`/`onWillOpen`, `closeBehavior`, content-sized scrollable overlay (`maxHeight`), `semanticLabel`, `IxDropdownMenuItem.checked`, `buttonVariant` and the `IxDropdownTheme` theme extension
- IxBlind uncontrolled mode (`expanded: null` + `initiallyExpanded`), button/expanded semantics, header actions kept outside the header's own semantics node
- `IxToastService.showToast()` returning an `IxToastHandle` (`onClose`/`close`/`pause`/`resume`/`isPaused`), `IxToastType.error`, `IxToastPosition`, `IxToastStrings`, toast live region + labelled close, 280px width, safe-area aware overlay
- `IxBreadcrumb` `breadcrumbKey` + `IxBreadcrumbClick` callbacks (`onItemClick`/`onNextClick`), navigation landmark, current-page state, `IxBreadcrumbStrings`
- `IxPaginationStrings`, keyboard-focusable RDV headers/rows/cards with sort semantics, wrap-capable pagination bar with 32px chevrons and labelled page-size trigger
- `IxApplicationStrings`, `IxApplicationScaffold` `settings`/`about`/`enableToggleTheme` API, menu keyboard navigation (Arrow/Home/End), `menuBar` landmark with a single semantics node per tile, and a category fly-out in the collapsed rail
- `IxThemeName` and `IxColorSchema` (the upstream `data-ix-theme`/`data-ix-color-schema` model), `IxThemeController` (resolves the `system` schema at runtime, `themeChanged` stream, `updatePlatformBrightness`, and forwards `icons:`/`density:` to both built themes), `IxThemeBuilder.light()`/`IxThemeBuilder.dark()` plus `IxThemeBuilder(theme:/brightness:)`, `IxTheme.themeName`/`IxTheme.colorSchema`, `IxCustomPalette.partial()`/`IxCustomPalette.copyWith()` -- see `doc/theming.md`

### Changed
- `IxThemeBuilder.build()` now bakes the static tap-target density from the platform the way Material derives `materialTapTargetSize` itself: touch platforms (Android/iOS/Fuchsia) get 48x48 hit areas (`IxDensity.comfortable`), desktop and desktop browsers keep the 1.0.2 layout (`IxDensity.compact`). Buttons, checkboxes, radios and switches therefore grow ~7px taller on touch platforms only. Pass `density: IxDensity.comfortable` (or wrap the app in `IxDensityScope`, which resolves the density live from the input modality) to opt every platform in; `density: IxDensity.compact` pins the 1.0.2 layout everywhere
- New enum values break exhaustive `switch` statements in consumer code (Dart 3 makes a non-exhaustive `switch` over an enum a compile error): `IxSpinnerVariant.secondary`, `IxToastType.error`, and `IxTypographyVariant.buttonLabel`/`.caption`/`.textDefault`. Add a `default:` arm to any `switch` over these enums
- `IxBlind` changed supertype from `StatelessWidget` to `StatefulWidget` (required by the new uncontrolled mode); subclasses and `find.byType`-style structural assumptions may need updating
- `IxToastOverlay`'s default top offset is 32px (was 16px), matching the upstream toast container; the deprecated `position:` path keeps its 16px offsets
- `IxBreadcrumbTheme.dropdownBorderRadius` defaults to `defaultBorderRadius` (was `smallBorderRadius`), matching the overflow menu now styled by `IxDropdownTheme`
- `ThemeData.focusColor` is transparent; Material widgets without an iX adapter no longer receive an opaque focus fill — wrap custom focusables in `IxFocusRing`
- `IxSpinner`'s default variant is now `IxSpinnerVariant.secondary` (identical styling to the deprecated `standard`)
- `IxApplicationScaffold` menu icons (drawer button, sidebar toggle, category chevron, theme indicator, entries without an `icon`) resolve through `IxIconResolver` instead of hard-coded Material glyphs
- `IxBlind`'s header chevron, `IxBreadcrumb`'s home icon/chevrons/overflow indicator and `IxResponsiveDataView`'s empty-state icons resolve through `IxIconResolver` as well, so an `IxThemeBuilder(icons:)` override now reaches every built-in widget. Two side effects of the fixed `IxIconSize` boxes: the default breadcrumb home icon renders at 16px (was 18px) and the data-view empty-state icons at 32px, the iX base icon size (was 56px, the empty state's large-layout `IconTheme` scale, which `IxIcon` deliberately ignores)
- `IxThemeBuilder(family: IxThemeFamily.custom)` without a `customPalette` now throws an `AssertionError` in debug builds instead of silently falling back to the classic palette (release builds keep the classic fallback)

### Deprecated
- reserved menu entry ids `settings`/`theme-toggle`/`about-legal` (with `showSettings`/`showThemeToggle`/`showAboutLegal`/`onOpenSettings`/`onOpenAboutLegal`, now carrying `@Deprecated` so the analyzer flags them); they still work and now log a one-time debug notice, and become ordinary entries in 2.0 -- use `settings:`, `about:` and `enableToggleTheme` instead
- `IxFonts.robotoMono` as the default UI font (2.0 switches to Work Sans)
- `IxSpinnerVariant.standard`
- `IxButtonVariant.warning*`/`info*`/`success*` (not part of Siemens iX)
- `IxDropdownButtonVariant` and `IxDropdownButton.variant` (use `buttonVariant:` with an `IxButtonVariant`)
- `IxToastType.critical`/`.alarm`/`.neutral` (use `.error`/`.error`/`.info`)
- `IxToastOverlay.position` (`Alignment`); use `placement` (`IxToastPosition`)
- `IxBreadcrumbItemData`/`IxBreadcrumbMenuItem` label-only items (no `breadcrumbKey`); `breadcrumbKey` becomes required in 2.0
- `IxBreadcrumbTheme.dropdownBackground`/`.dropdownBorderRadius` (still honoured for now; overflow menus are styled by `IxDropdownTheme` instead, removed in 2.0)
- `IxThemeFamily.brand` (never a real palette in the OSS build -- it resolves to classic and now logs a debug notice; removed in 2.0)
- `IxThemeBuilder.family`/`.mode`/`.systemBrightness` (use `theme:` + `brightness:`, `IxThemeBuilder.light()`/`.dark()`, or `IxThemeController` for the `system` schema)
- `IxTheme.family`/`.mode` (use `IxTheme.themeName` / `IxTheme.colorSchema`)

### Fixed
- `IxBlind` now honours `IxThemeBuilder(typography:)` instead of always falling back to the default typography
- `neutralHover` (light), `primaryActive`/`secondaryActive`/`secondaryHover` (dark) aligned with iX 5.2.1
- Code typography now loads the bundled JetBrains Mono (package-prefixed font family)
- visible 1px focus ring on checkbox, radio, buttons, blind header, menu tiles and dropdown items (WCAG 2.4.7)
- the `IxBlind` header's semantics node reports `isFocused` while it holds the keyboard focus, so assistive technology can follow the keyboard through a stack of blinds instead of only seeing the ring (WCAG 2.4.7)
- the dropdown item focus ring is drawn inside the row (rounded, negative outline offset) instead of overlapping the neighbouring row and the menu's rounded corner
- the dropdown trigger label is flexible with ellipsis, so it no longer overflows at narrow widths or large text scales (WCAG 1.4.4)
- `IxEmptyState`/`IxToast`/`IxSpinner` render without `IxThemeBuilder`
- `IxBlindTheme.fallback`'s `critical`/`warning`/`success`/`info`/`neutral` variants no longer hard-code Material `Colors.*` swatches; they derive from the ambient `ColorScheme` (`error`/`tertiary`/`secondary`/`primary`/`outline`) instead
- toggling an `IxBlind` (controlled or uncontrolled) no longer throws under `MediaQuery.disableAnimations` (a zero-duration `AnimatedSize` re-entering layout while resizing)
- `IxBlind` drives its expansion with its own `AnimationController` + `SizeTransition` instead of an `AnimatedSize`. Open content that resizes itself under reduced motion no longer throws `A RenderAnimatedSize was mutated in its own performLayout implementation`, and flipping the platform's reduce-motion setting while a blind is open no longer remounts the content subtree (its `State`, scroll positions and controllers survive)
- `IxApplicationScaffold`'s collapsed-rail/drawer fly-out is clamped against the correct edge in RTL, so the panel no longer opens partly outside the viewport
- `IxApplicationScaffold` disposes the `OverlayEntry` it self-hosts when built above the `Navigator`, so leak-tracking suites no longer report it
- `IxResponsiveDataView` headers/rows/mobile cards/search-clear and `IxPaginationBar` no longer hard-code Material `Colors.*`; they derive from `IxTheme` tokens (`color0`/`softBdr`/`weakBdr`/`ghostHover`) with a `ColorScheme` fallback, and no longer overflow at narrow widths or large text scales (WCAG 1.4.4)
- an `IxSpinnerTheme` whose `variants`/`sizes` map does not carry every key no longer throws `Null check operator used on a null value`. A map written before `IxSpinnerVariant.secondary` existed (`{standard, primary}`) now renders the default `IxSpinner()` through the `standard` alias, and both `IxSpinnerTheme.style`/`.size` and `lerp` fall back to the built-in style for any key neither the map nor its alias carries

---

## [1.0.2] - 2026-01-28
Upstream: @siemens/ix@5.2.1 (56dfa751), @siemens/ix-icons v3.5.0 (c46e1b13)

Note: the wiki listed 1.0.3 and 1.0.4 (2026-01-28); these were internal bumps never published to pub.dev. The next published version after 1.0.2 is 1.1.0.

### Changed
- Icon generator moved to separate package `ix_icons_generator` for cleaner dependencies
- Removed generator-related dev_dependencies (http, args, recase, archive, path, yaml, meta)
- Package size reduced by removing unused dependencies
- Shortened package description to comply with pub.dev requirements

### Migration
Replace:
```bash
dart run ix_flutter:generate_icons
```
With:
```yaml
dev_dependencies:
  ix_icons_generator: ^1.0.0
```
```bash
dart run ix_icons_generator:generate_icons
```

---

## [1.0.1] - 2026-01-18

### Changed
- Cleaned LICENSE file to standard MIT format for proper pub.dev recognition
- Included example app in published package for improved pub.dev scoring
- Excluded GitHub-specific files (.github/, WIKI_SETUP.md) from package distribution

### Fixed
- Removed unnecessary library declaration to satisfy static analysis
- Improved pub.dev package scoring compliance

---

## [1.0.0] - 2026-01-18

### Changed
- First stable release graduating from the 0.0.1 preview.
- Documentation updated to reference 1.0.0.
- Publish package excludes repo-only GitHub metadata and wiki setup notes.

### Fixed
- Resolved pub.dev publish warnings related to metadata.

### Known Limitations
- Icons still require manual generation from the official Siemens source.
- Flutter/Dart versions must be 3.10.0 or higher.

---

## [0.0.1] - 2026-01-18

### Added

#### Components
- **IxApplicationScaffold** - Main application container with responsive layout
- **IxBreadcrumb** - Navigation breadcrumb component with overflow handling
- **IxBlind** - Sliding drawer/panel component
- **IxDropdownButton** - Advanced dropdown selection component
- **IxEmptyState** - Empty state placeholder component
- **IxResponsiveDataView** - Responsive data table component
- **IxToast** - Toast notification system
- **IxPaginationBar** - Pagination controls
- Color system with light and dark themes

#### Features
- Complete theme system with Siemens iX styling
- 1400+ Siemens iX icons (via generator tool)
- Icon generator tool (`dart run ix_flutter:generate_icons`)
- Responsive design support
- Light and dark theme support
- Material Design 3 integration

#### Documentation
- Component documentation in `doc/` folder
- Icon integration guide
- Color token reference
- Example application

### Known Limitations
- Icons require manual generation from official Siemens source
- Community-maintained, not official Siemens product
- Flutter/Dart versions must be 3.10.0 or higher

---

## Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes and minor improvements

## Compatibility

### Flutter & Dart Versions

| Version | Flutter | Dart |
| ------- | ------- | ---- |
| 1.0.2   | >=3.10.0 | >=3.10.0 |
| 1.0.1   | >=3.10.0 | >=3.10.0 |
| 1.0.0   | >=3.10.0 | >=3.10.0 |
| 0.0.1   | >=3.10.0 | >=3.10.0 |

### Supported Platforms

- ✅ Web (Flutter Web)
- ✅ Android
- ✅ iOS
- ✅ macOS (desktop)
- ✅ Linux (desktop)
- ✅ Windows (desktop)

## Breaking Changes

### v1.0.2
- Icon generator command changed from `dart run ix_flutter:generate_icons` to `dart run ix_icons_generator:generate_icons`
- Users must now add `ix_icons_generator` as a dev_dependency

### v1.0.1
- No breaking changes, patch release

### v1.0.0
- First stable release, no breaking changes from 0.0.1

### v0.0.1
- Initial preview release, no breaking changes

## Migration Guides

For migration from previous versions, see [ICON_MIGRATION.md](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/ICON_MIGRATION.md).

## Contributors

See individual commit history for contributor information.

## License

MIT License - See [LICENSE](LICENSE)

Icons are subject to Siemens iX Design System licensing - See [ICON_LICENSING.md](ICON_LICENSING.md)

---

**How to Report Issues**: [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
**How to Contribute**: [CONTRIBUTING.md](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/CONTRIBUTING.md)
**Security Issues**: [SECURITY.md](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/SECURITY.md)
