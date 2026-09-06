# Changelog

All notable changes to the ix_flutter project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
Upstream: @siemens/ix@5.2.1 (56dfa751), @siemens/ix-icons v3.5.0 (c46e1b13)

Prepared as **1.1.0**, and not published. `pubspec.yaml` still carries 1.0.2:
the version bump and this section's release date are made later by the
**Version Bump (Manual)** workflow, which turns `[Unreleased]` into the new
release section in place -- see [CONTRIBUTING.md](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/CONTRIBUTING.md#release-process).
Until that runs, the newest published version is
[1.0.2](https://pub.dev/packages/ix_flutter/versions/1.0.2).

### Added
- Public exports for `IxPaginationBar` and `IxBottomSheetTheme` from the package barrel
- `IxTheme.of`/`IxTheme.maybeOf` static accessors for reading the Siemens IX theme extension from a `BuildContext`
- `IxFocusRing`, the shared 1px focus indicator used by the iX controls and available for wrapping custom focusables
- `IxUpstream` exported from the package barrel (the `@Upstream` traceability annotation)
- `IxKeyboardDismissScope`, a scope that releases a focused text input -- taking the soft keyboard down with it -- when the user taps outside the field or drags a scroll view. Flutter does neither on a touch screen: its tap-outside action (`_EditableTextTapOutsideAction`) only drops the focus on desktop, and dismissal on scroll is per scroll view through `ScrollView.keyboardDismissBehavior`, whose app-wide default is `ScrollViewKeyboardDismissBehavior.manual`. The scope overrides `EditableTextTapOutsideIntent`/`EditableTextTapUpOutsideIntent` for its subtree, so it reads Flutter's own `TextFieldTapRegion` grouping instead of hit-testing on its own, and watches `ScrollUpdateNotification`s carrying drag details, so one scope covers every list, grid, `SingleChildScrollView` and nested scrollable under it. A tap inside the field or on one of its satellites keeps focus, a programmatic `jumpTo`/`animateTo`, a ballistic settle, a mouse wheel and a field's own text scrolling never dismiss, a non-text focus is never cleared, and neither taps nor scroll notifications are consumed. `onTapOutside` and `onDrag` toggle the two triggers independently, `enabled: false` restores Flutter's defaults for both, and `dismissKeyboard: false` leaves the IME to the framework
- `IxApplicationScaffold.dismissKeyboardOnInteraction` (default `true`), which wraps the whole scaffold frame -- app bar, menu, fly-out, drawer and `body` -- in `IxKeyboardDismissScope`, so an app built on the scaffold gets both triggers with no extra code. Pass `false` for the 1.x/Flutter default
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
- `IxResponsiveDataView.paginationStrings` and `IxResponsiveDataViewStrings.pageSelectionLabel`
- `IxApplicationStrings`, `IxApplicationScaffold` `settings`/`about`/`enableToggleTheme` API, menu keyboard navigation (Arrow/Home/End), `menuBar` landmark with a single semantics node per tile, and a category fly-out in the collapsed rail
- `IxThemeName` and `IxColorSchema` (the upstream `data-ix-theme`/`data-ix-color-schema` model), `IxThemeController` (resolves the `system` schema at runtime, `themeChanged` stream, `updatePlatformBrightness`, and forwards `icons:`/`density:` to both built themes), `IxThemeBuilder.light()`/`IxThemeBuilder.dark()` plus `IxThemeBuilder(theme:/brightness:)`, `IxTheme.themeName`/`IxTheme.colorSchema`, `IxCustomPalette.partial()`/`IxCustomPalette.copyWith()` -- see `doc/theming.md`

### Changed
- **The minimum Flutter SDK is now 3.38.0** (`environment: flutter: ">=3.38.0"`, was `>=3.10.0`). The Dart SDK floor is unchanged at `>=3.10.0`. `SemanticsRole.*` and `SemanticsService.sendAnnouncement` -- which the menu, toast, dropdown and data-view semantics in this release are built on -- are only available from Flutter 3.38. `pub` will not resolve this version for an app on an older Flutter; such an app stays on 1.0.2. CI builds and tests on Flutter 3.44.6 stable
- `IxThemeBuilder.build()` now bakes the static tap-target density from the platform the way Material derives `materialTapTargetSize` itself: touch platforms (Android/iOS/Fuchsia) get 48x48 hit areas (`IxDensity.comfortable`), desktop and desktop browsers keep the 1.0.2 layout (`IxDensity.compact`). Buttons, checkboxes, radios and switches therefore grow ~7px taller on touch platforms only. Pass `density: IxDensity.comfortable` (or wrap the app in `IxDensityScope`, which resolves the density live from the input modality) to opt every platform in; `density: IxDensity.compact` pins the 1.0.2 layout everywhere
- New enum values break exhaustive `switch` statements in consumer code (Dart 3 makes a non-exhaustive `switch` over an enum a compile error): `IxSpinnerVariant.secondary`, `IxToastType.error`, and `IxTypographyVariant.buttonLabel`/`.caption`/`.textDefault`. Add a `default:` arm to any `switch` over these enums
- `IxBlind` changed supertype from `StatelessWidget` to `StatefulWidget` (required by the new uncontrolled mode); subclasses and `find.byType`-style structural assumptions may need updating
- `IxToastOverlay`'s default top offset is 32px (was 16px), matching the upstream toast container; the deprecated `position:` path keeps its 16px offsets
- `ThemeData.focusColor` is transparent; Material widgets without an iX adapter no longer receive an opaque focus fill — wrap custom focusables in `IxFocusRing`
- `IxSpinner`'s default variant is now `IxSpinnerVariant.secondary` (identical styling to the deprecated `standard`)
- `IxIcon.size` is now nullable and defaults to `null`: the icon's square box is the explicit `IxIconSize` if given, else the ambient `IconTheme.size` used exactly (not snapped to an `IxIconSize`), else 24px. `MaterialApp`'s own `IconTheme` is 24px, so nothing changes outside a slot that styles its icon -- inside one (`IxIconButton`, `TextButton.icon`, `InputDecoration.prefixIcon`, ...) an unsized `IxIcon` now matches the slot instead of always rendering at 24px. An explicit `size:` still wins. This also reaches the slots the iX widgets style themselves, so an unsized `IxIcon` you hand to one of them changes size: `IxEmptyState.icon` (32px, or 56px in the large layout), `IxResponsiveDataView` row-action popup entries (20px) and action chips (18px), `IxBreadcrumb` item icons (16px) and the home icon slot (18px). Pass `size:` to pin any of them
- collapsing an `IxBlind`, or an `IxApplicationScaffold` menu category, keeps its content in the tree until the collapse animation ends (it is what the transition shrinks) instead of removing it on the first frame. The content is excluded from semantics and from keyboard traversal for the whole collapse, so it is inert while it is still visible. A test asserting `findsNothing` one frame after the tap needs `pumpAndSettle` under normal motion; under reduced motion one `pump()` is still the whole transition
- `IxApplicationScaffold` menu icons (drawer button, sidebar toggle, category chevron, theme indicator, entries without an `icon`) resolve through `IxIconResolver` instead of hard-coded Material glyphs
- `IxBlind`'s header chevron, `IxBreadcrumb`'s home icon/chevrons/overflow indicator and `IxResponsiveDataView`'s empty-state icons resolve through `IxIconResolver` as well, so an `IxThemeBuilder(icons:)` override now reaches every built-in widget. They keep the sizes they had: the icons handed to a slot that styles its own `IconTheme` (the empty state's 56px/32px box, the breadcrumb's 18px home slot) are passed without a `size:` of their own, so the slot still decides

### Deprecated
- reserved menu entry ids `settings`/`theme-toggle`/`about-legal` (with `showSettings`/`showThemeToggle`/`showAboutLegal`/`onOpenSettings`/`onOpenAboutLegal`, now carrying `@Deprecated` so the analyzer flags them); they still work and now log a one-time debug notice, and become ordinary entries in 2.0 -- use `settings:`, `about:` and `enableToggleTheme` instead
- `IxFonts.robotoMono` as the default UI font (2.0 switches to Work Sans)
- `IxSpinnerVariant.standard`
- `IxButtonVariant.warning*`/`info*`/`success*` (not part of Siemens iX)
- `IxDropdownButtonVariant` and `IxDropdownButton.variant` (use `buttonVariant:` with an `IxButtonVariant`)
- `IxToastType.critical`/`.alarm`/`.neutral` (use `.error`/`.error`/`.info`)
- `IxToastOverlay.position` (`Alignment`); use `placement` (`IxToastPosition`)
- `IxBreadcrumbItemData`/`IxBreadcrumbMenuItem` label-only items (no `breadcrumbKey`); `breadcrumbKey` becomes required in 2.0
- `IxBreadcrumbTheme.dropdownBackground`/`.dropdownBorderRadius` (the overflow menu still reads these two directly; `IxDropdownTheme` already styles the rest of the popup -- item height, padding, etc. -- and takes over these two as well, removed in 2.0)
- `IxThemeFamily.brand` (never a real palette in the OSS build -- it resolves to classic and now logs a debug notice; removed in 2.0)
- `IxThemeBuilder.family`/`.mode`/`.systemBrightness` (use `theme:` + `brightness:`, `IxThemeBuilder.light()`/`.dark()`, or `IxThemeController` for the `system` schema)
- `IxTheme.family`/`.mode` (use `IxTheme.themeName` / `IxTheme.colorSchema`)
- `IxResponsiveDataView.searchHintText` -- confirmed dead already in 1.0.2 (`origin/main`): the widget has never rendered a search field to apply a hint to, only a read-only search status bar. Pass the hint to your own search input's `InputDecoration.hintText` instead -- see "Search / Filtering" in `doc/ix_responsive_data_view.md`. Removed in 2.0

### Fixed
- `IxBlind` now honours `IxThemeBuilder(typography:)` instead of always falling back to the default typography
- `neutralHover` (light), `primaryActive`/`secondaryActive`/`secondaryHover` (dark) aligned with iX 5.2.1
- Code typography now loads the bundled JetBrains Mono (package-prefixed font family)
- visible 1px focus ring on checkbox, radio, buttons, blind header, menu tiles and dropdown items (WCAG 2.4.7)
- the `IxBlind` header's semantics node reports `isFocused` while it holds the keyboard focus, so assistive technology can follow the keyboard through a stack of blinds instead of only seeing the ring (WCAG 2.4.7)
- a disabled `IxApplicationScaffold` menu entry (`IxMenuEntry(enabled: false)`) no longer reports `isFocusable`; it was published as focusable despite being out of the traversal order and having no tap action
- `IxIconResolver.resolve` falls back to `IxIconResolver.material()` for a key the resolver's own map does not declare, instead of asserting in debug and throwing a null-check error in release. A hand-built partial resolver (`IxIconResolver(icons: {IxIconKey.close: ...})`) is now usable as the constructor's dartdoc always said it was: registering one through `IxThemeBuilder(icons:)` no longer makes every built-in widget that asks for another key -- an `IxBlind`'s header chevron, say -- throw
- the dropdown item focus ring is drawn inside the row (rounded, negative outline offset) instead of overlapping the neighbouring row and the menu's rounded corner
- the dropdown trigger label is flexible with ellipsis, so it no longer overflows at narrow widths or large text scales (WCAG 1.4.4)
- a failing `IxIcon` SVG load no longer surfaces as an uncaught asynchronous error in the app's zone. `flutter_svg`'s cache and `vector_graphics`' picture cache both chain error-handler-less callbacks onto the load future, so a missing or corrupt asset reached `runZonedGuarded`/`PlatformDispatcher.onError` (and any crash reporter behind them) on top of the intended fallback. `IxIcon` now loads through a guarded loader that contains the failure, remembers the failed asset for the life of the process, and renders the Material fallback for every later icon of that asset without loading again
- `IxIcon`'s SVG failure reporting is now debug-only (`assert`), matching what its dartdoc always promised; release builds fall back silently
- moving the keyboard focus inside an `IxDropdownButton` menu now scrolls the focused row into view (arrows, `Home`/`End`, and the row the menu opens on), so a focused row in a menu taller than its height budget is no longer left off screen (WCAG 2.4.7)
- `Escape` closes an open `IxDropdownButton` menu whose rows are all disabled, or that has no rows at all. Focus stays on the trigger in that case, so the menu's own focus scope never saw the key and the menu could not be dismissed from the keyboard (WCAG 2.1.2)
- `IxEmptyState`/`IxToast`/`IxSpinner` render without `IxThemeBuilder`
- `IxBlindTheme.fallback`'s `critical`/`warning`/`success`/`info`/`neutral` variants no longer hard-code Material `Colors.*` swatches; they derive from the ambient `ColorScheme` (`error`/`tertiary`/`secondary`/`primary`/`surfaceContainerHighest`) instead
- toggling an `IxBlind` (controlled or uncontrolled) no longer throws under `MediaQuery.disableAnimations` (a zero-duration `AnimatedSize` re-entering layout while resizing)
- `IxBlind` and the `IxApplicationScaffold` menu category drive their expansion with their own `AnimationController` + `SizeTransition` instead of an `AnimatedSize`. Open content that resizes itself under reduced motion no longer throws `A RenderAnimatedSize was mutated in its own performLayout implementation`, and flipping the platform's reduce-motion setting while one is open no longer remounts the content subtree (its `State`, scroll positions and controllers survive). Collapsing a blind, or a menu category, whose content holds the keyboard focus moves it to the blind's header (respectively the category's tile) instead of dropping it into the enclosing scope
- `IxApplicationScaffold`'s collapsed-rail/drawer fly-out is clamped against the correct edge in RTL, so the panel no longer opens partly outside the viewport
- `IxApplicationScaffold` disposes the `OverlayEntry` it self-hosts when built above the `Navigator`, so leak-tracking suites no longer report it
- `IxResponsiveDataView` headers/rows/mobile cards/search-clear and `IxPaginationBar` no longer hard-code Material `Colors.*`; they derive from `IxTheme` tokens (`color0`/`softBdr`/`weakBdr`/`ghostHover`) with a `ColorScheme` fallback, and no longer overflow at narrow widths or large text scales (WCAG 1.4.4)
- an `IxSpinnerTheme` whose `variants`/`sizes` map does not carry every key no longer throws `Null check operator used on a null value`. A map written before `IxSpinnerVariant.secondary` existed (`{standard, primary}`) now renders the default `IxSpinner()` through the `standard` alias, and both `IxSpinnerTheme.style`/`.size` and `lerp` fall back to the built-in style for any key neither the map nor its alias carries
- `IxDropdownButton` builds again where no `Overlay` can be resolved -- a persistent shell above the `Navigator`, built through `MaterialApp.builder`. The menu's portal is only mounted where an overlay exists (1.0.2 reached for one on open, not on build), so the trigger no longer takes the whole shell down with `No Overlay widget found`. Opening it there logs a one-time debug notice naming the remedy: wrap the shell in `Overlay.wrap(child: ...)`, which tooltips in that placement need as well
- an `IxDropdownButton` menu exposes its rows to assistive technology from the first frame of its fade-in. The transparent opening frame dropped their semantics, which also left the `menu` role node child-less and tripped the framework's "a menu cannot be empty" assertion on every open in a debug build with semantics enabled
- the dropdown menu is laid out inside the safe area: the status bar, a notch and the home indicator no longer count as room, so a menu near the bottom of the screen flips above the trigger instead of hiding under the home indicator
- `bottomStart`/`bottomEnd`/`topStart`/`topEnd` align the dropdown menu to the *reading* start/end, so in RTL the menu's right edge lines up with the trigger's right edge instead of its physical left
- `IxResponsiveDataView`'s sortable headers, desktop rows and mobile cards paint the Siemens IX focus ring while they hold the keyboard focus. They have been focusable since this release, but `ThemeData.focusColor` is transparent app-wide (`IxFocusRing` owns the affordance), so they showed nothing at all (WCAG 2.4.7)
- hover and press feedback is visible again on those headers, rows and cards. Their `InkWell` had no `Material` of its own, so the ink painted on the enclosing page's Material -- underneath the opaque background each of them draws. The background now lives on a `Material` inside each one
- a non-sortable `IxResponsiveDataView` column heading is no longer published as a *disabled* control (`button: false` + `enabled: false`); it is a plain label, and screen readers stop announcing it as unavailable
- the `IxApplicationScaffold` menu's arrow keys, `Home` and `End` step over a disabled entry instead of stopping at it. A disabled tile is rendered, so it was in the traversal order, but its `InkWell` refuses the focus -- so the arrow keys could not move past one (WCAG 2.1.1)
- a nested menu category no longer traps the arrow keys. A category inside a category renders its own children only in the fly-out, never inline, but the traversal order was built as if they were there, so it contained focus nodes with no widget behind them
- tapping a menu entry in the drawer layout closes the drawer through the scaffold's own `ScaffoldState` instead of `Navigator.maybePop()`, which threw `Navigator operation requested with a context that does not include a Navigator` for a scaffold placed above the `Navigator` (`MaterialApp.builder`)
- a settings/about fly-out is closed when its anchor goes away (`settings:` set back to null, the category removed) and when a menu entry navigates, instead of leaving the portal showing an empty panel that re-opened by itself later
- a control that opens an overlay of its own inside an `IxApplicationScaffold` fly-out panel -- an `IxDropdownButton` in `settings:` -- works there. It threw `The paint transform cannot be reliably computed because of RenderFollowerLayer(s)` when opened, because the panel positioned itself with a `CompositedTransformFollower`; the panel is positioned directly now. Its overlay also registers in the panel's tap-region group, so choosing an item no longer dismisses the panel mid-selection
- the scaffold fly-out stays inside the viewport on a phone. Anchored beside a 304px drawer it was clamped to the 48px left over at 360px (8px at 320px), where its own header row overflowed; with less than 200px beside the menu the panel is placed over it, flush to the far edge
- closing an `IxDropdownButton` menu returns the focus to the trigger only when the focus was still inside the menu -- a keyboard close (`Escape`, `Tab`, activating a row). It used to do so unconditionally, so clicking outside the menu left a focus ring on the trigger on desktop, and an `onItemSelected` handler that moved the focus somewhere of its own was overruled. `onItemSelected` also runs after the menu has closed, so its focus request is the last one made
- a controlled `IxDropdownButton` whose owner *declines* an open request no longer leaves a focus claim armed on the row that request named: the next accepted open focuses the row its own key asked for. The focused row is read from the row focus nodes instead of a mirrored field that went stale across an external open or close
- handing a controlled `IxDropdownButton` back to itself (`isOpen` set to null) keeps the state the owner last declared instead of snapping the menu shut without an `onOpenChanged`
- `IxToastOverlay` no longer throws `BoxConstraints has a negative minimum width` on a viewport narrower than its own 32px of margins, or under a `MediaQueryData()` that reports no size at all (which now means "no constraint" rather than zero)
- `IxToastService.dismiss` (and `IxToastHandle.close`) is a no-op for a toast that is no longer live and for a service that has been disposed, instead of throwing the `ChangeNotifier` used-after-dispose assertion from a handle that fired late, or notifying listeners for a close that changed nothing. `dismissAll` also completes the `onClose` of a handle that outlived its toast
- `IxToastHandle.pause()` freezes the toast's progress bar, not only its timer -- the bar used to keep draining through a programmatic pause, showing a countdown that was not running. Hovering an owner-paused toast and leaving again no longer resumes it, and `resume()` does not restart the countdown while the pointer is still on the card
- the scaffold's drawer button and the fly-out panel's close button are localized again: `IxApplicationStrings.openMenu` and `.closePanel` are now `String?` and default to `null`, which takes `MaterialLocalizations.openAppDrawerTooltip` / `.closeButtonTooltip` -- the strings Flutter already translates for every locale the app declares. A string passed explicitly still wins
- a reserved `settings`/`about-legal` menu entry opens the matching `settings:`/`about:` panel (and still calls the deprecated `onOpenSettings`/`onOpenAboutLegal`). Keeping the 1.x entry while adopting the new parameters used to leave a row that did nothing, because the entry suppressed the built-in row and the callback it invoked was already null. A reserved id in the *top* entry list now suppresses the built-in row as well, instead of producing two identical rows
- `IxResponsiveDataView` can localize the pagination bar's page-size trigger: `IxResponsiveDataViewStrings.pageSelectionLabel` (bridged into `IxPaginationStrings.pageSelection`), or a whole `IxPaginationStrings` through the new `paginationStrings` parameter
- an enabled `IxBlind` header and `IxApplicationScaffold` menu tile publish a `focus` action, so assistive technology can move the focus to a control they already report as focusable. `excludeSemantics: true` had dropped the `InkWell`'s own action along with the rest of its node (WCAG 2.4.7)
- an SVG-backed `IxIcon` no longer adds an `image: true` semantics annotation of its own. `IxIcon` owns the icon's semantics, and `SvgPicture`'s annotation merged into the enclosing node -- so an `IxIconButton` with an asset icon announced itself as an image, which the Material branch never did
- an SVG-backed `IxIcon` honours `IconThemeData.opacity`, so an icon in a slot that dims its contents -- a disabled `ListTile`'s leading icon, say -- is dimmed too, as Material's own `Icon` already was. The Material-glyph branch of `IxIcon` still renders about the *square* of the requested opacity (alpha 0.251 rather than 0.502 at `opacity: 0.5`): `IxIcon` dims the colour itself and hands the result to Flutter's `Icon`, which re-applies the same ambient `IconTheme.opacity` to any colour it is given. Only a slot that sets a non-default `opacity` is affected, and only for Material glyphs; it is not fixed in this release
- `IxDensity.resolve()`'s adaptive density no longer starts `comfortable` on a desktop platform and jumps to `compact` the first time the cursor enters the window (and back on the way out). `mouseIsConnected` is only true once a pointer has actually been seen, so "no mouse tracked yet" is not the same thing as "this is a touch device": the platform's own static default (the same one `IxThemeBuilder.build()` bakes in) is now consulted before the mouse, and only a touch platform still needs one connected to go `compact`
- `IxTypography.copyWith(fontFamily: ...)` drops a `package` that named the package shipping the *old* family instead of carrying it over onto the new one, where it would point at the wrong asset bundle -- the same sentinel `monospacePackage` already used to tell "not passed" from an explicit `package: null`
- `IxThemeBuilder(family: IxThemeFamily.custom)` without a `customPalette` falls back to the classic palette, as 1.0.2 did, instead of asserting in debug builds; it logs a one-time debug notice naming the remedy (`customPalette:` is not deprecated, only the `family:` spelling of it)
- `IxTheme.family`/`.mode` report the resolved family/mode when the theme was built with the new API (`theme:`/`brightness:`, including `IxThemeBuilder.light()`/`.dark()`), instead of parroting back the deprecated fields' unrelated defaults -- `IxThemeBuilder.dark()` used to report `mode == ThemeMode.system`. A theme built with only the deprecated `family:`/`mode:` pair still reports exactly what was passed
- `IxIconButton` keeps its fixed visual size under `ThemeData(useMaterial3: false)`. Its size/shape/tap-target were only forwarded through `IconButton.style`, which Material's legacy (M2) render path does not read; `constraints`/`padding` are now also forwarded through the plain constructor parameters that path does use (harmless under M3, which already had it from `style`)
- `IxPaginationStrings.rowsPerPage`'s own default ("Items per page", no colon) no longer disagrees with `IxResponsiveDataViewStrings.rowsPerPageLabel`'s ("Items per page:", with one) -- constructing `IxPaginationStrings` directly and bridging from `IxResponsiveDataViewStrings.defaultsEn()` now produce the identical label, both from the one constant (`IxPaginationStrings.defaultRowsPerPage`) that owns it
- an `IxDropdownButton` menu opens on its checked row -- focused, and scrolled into view -- instead of always on the first one, so a menu that picks a value opens showing where the user already is (`IxPaginationBar`'s page-size selector included). A menu with nothing checked still opens on its first enabled row, a checked row that is also disabled falls back the same way, and the explicit positional keys are unchanged: `Home` opens on the first row, `ArrowUp`/`End` on the last. The example app's pagination-mode menu now marks its current mode `checked`
- example app: the Responsive Data View page's search box filters as it is typed in. Its `TextField` only had `onSubmitted`, so a query did nothing until Enter was pressed or the (untooltipped) magnifier was clicked, which read as "search does not work at all". `IxResponsiveDataView` renders no search input of its own -- it only consumes `searchQuery`/`onClearSearch` -- so the library contract was never involved. The page's simulated load now restarts its delay on each keystroke rather than abandoning a suspended `Completer`, and the row filter and the pagination counters share one predicate
- example app: the Modals page's persistent bottom sheet closes again. `showBottomSheet` rebuilds the `Scaffold`, not the page, so the page never learned it had a sheet up: its toggle kept offering "Show bottom sheet", a second click opened a second sheet, and the first sheet's `closed` future then cleared the controller field belonging to the second one -- leaving a sheet whose close button called `close()` on `null`. The library itself is unaffected (a regression test confirms the toast layer, hosted `Overlay` included, does not intercept pointer events)
- `IxToastOverlay` hosts its own `Overlay` when it finds none, the way `IxApplicationScaffold` already did. In the documented placement -- a `Stack` inside `MaterialApp.builder`, i.e. above the `Navigator` that owns the app's `Overlay` -- a toast's close button was replaced by a red `No Overlay widget found` error box as soon as the pointer hovered it, because its tooltip resolves an `Overlay` when it shows; the same went for any overlay-based content inside a toast. The hosted overlay fills the surrounding `Stack` but stays click-through, and an `Overlay` already in scope is still used unchanged
- an expanded `IxBlind`'s content divider (the top border drawn above `child`) spans the full width of the blind again, instead of shrinking to a short `child`'s own intrinsic width. `IxCollapsible`'s `SizeTransition` is built from an `Align`, which always loosens the width constraint it hands to its child, unlike the `AnimatedSize` it replaced (1.0.2), which forwarded the ambient constraint through unchanged; both `IxBlind`'s content and the `IxApplicationScaffold` menu category's children now get an explicit full-width box inside `IxCollapsible` so neither depends on that ambient constraint being tight
- `IxBlindTheme.fromPalette` is wired into `IxThemeBuilder.build()`'s `extensions:` list. It always existed but was never registered, so every `IxBlind` in an `IxThemeBuilder`-themed app silently used `IxBlindTheme.fallback`'s generic Material-role approximation instead -- most visibly, dark `warning` and `success` both rendering as the same unreadable cyan, because that fallback's `ColorScheme.tertiary`/`.secondary` roles both derive from the iX "dynamic"/"dynamic-alt" accent tokens, which upstream itself defines as the same color. Every variant now resolves the exact upstream background + `--contrast` foreground token pair (`blind.scss`), verified for WCAG AA contrast (>= 4.5:1) in both palettes
- example app: the Navigation Examples page's bottom app bar no longer overflows ("RIGHT OVERFLOWED BY n PIXELS") at phone widths. Its three pill-style switches ("Snack bars"/"Dialogs"/"Breadcrumbs") sat in a fixed-width `Row`, which does not shrink its children to fit; the strip now scrolls horizontally instead. Entirely example chrome (a plain Material `BottomAppBar`/`Row`) -- no `ix_flutter` widget was involved
- `IxResponsiveDataView.onSearchChangedRequestResetPagination` now fires for every `searchQuery` change, including one that crosses the empty/non-empty items boundary. That boundary is exactly where the widget swaps its desktop/mobile content subtree for its empty-state subtree (and back); the swap used to unmount whichever subtree was tracking the query change and mount the other one fresh, so neither subtree's `didUpdateWidget` ever ran and the callback was silently dropped for the one transition it exists to catch. Detection now lives in a wrapper above both the empty-state and content subtrees, which persists across the swap

---

## [1.0.2] - 2026-01-28

Note: the wiki listed 1.0.3 and 1.0.4 (2026-01-28); these were internal bumps never published to pub.dev. The next published version after 1.0.2 will be 1.1.0.

No `Upstream:` line is recorded for this release. The pinned `@siemens/ix` 5.2.1 / `@siemens/ix-icons` 3.5.0 baseline in [UPSTREAM.md](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/UPSTREAM.md) was first established for the upcoming release above, months after 1.0.2 shipped, and there is no record of what 1.0.2 was verified against.

### Changed
- Icon generator moved to separate package `ix_icons_generator` for cleaner dependencies
- Removed generator-related dev_dependencies (http, args, recase, archive, path, yaml, meta)
- Package size reduced by removing unused dependencies
- Shortened package description to comply with pub.dev requirements
- Migrating: see [ICON_MIGRATION.md](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/ICON_MIGRATION.md) for the exact before/after (`ix_icons_generator` becomes a dev dependency; the generate command's package prefix changes)

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

## 0.0.1 - 2026-01-18

The preview that 1.0.0 graduated from. It was never published to pub.dev, so
it has no link reference definition below and its header carries no `[...]`.

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

[Unreleased]: https://github.com/SobSoft-s-r-o/ix_flutter/commits/main
[1.0.2]: https://pub.dev/packages/ix_flutter/versions/1.0.2
[1.0.1]: https://pub.dev/packages/ix_flutter/versions/1.0.1
[1.0.0]: https://pub.dev/packages/ix_flutter/versions/1.0.0
