# Upgrading to ix_flutter 1.1.0

This guide covers upgrading from ix_flutter 1.0.2 to 1.1.0, including SDK
requirements, observable behavior changes and replacements available in
1.1.0 for deprecated APIs. Deprecated APIs remain available in this release;
the warnings give applications time to migrate before their removal in a
future major release.

Update the application's dependency to `ix_flutter: ^1.1.0`. If the project
generates the icon catalogue, also update its development dependency to
`ix_icons_generator: ^1.1.0`, resolve dependencies and regenerate the icons.
Run the analyzer and the application's tests after upgrading.

## SDK and 1.x compatibility

ix_flutter 1.1.0 requires Dart `>=3.10.0 <4.0.0` and Flutter `>=3.38.0`.
The explicit Flutter floor aligns the package constraints with the
`SemanticsRole.*` and `SemanticsService.sendAnnouncement` APIs used by the
menu, toast, dropdown and data-view accessibility implementation. Resolution
depends on both the Dart and Flutter constraints; verify the application
toolchain before upgrading.

The following status labels are used in this guide:

- **Analyzer**: 1.1.0 carries `@Deprecated`; the row describes its current
  replacement or any compatibility limitation.
- **Runtime**: 1.1.0 prints a one-time debug notice and has an available
  migration.

## Deprecations and replacements in 1.1.0

| Deprecated API or behavior | Status in 1.1.0 | Action when upgrading to 1.1.0 |
|---|---|---|
| `IxThemeFamily`; `IxThemeBuilder.family`, `.mode`, `.systemBrightness` | Analyzer | Replace `family: IxThemeFamily.classic` with `theme: IxThemeName.classic`. For a custom identity, replace `family: IxThemeFamily.custom` with `theme: const IxThemeName('my-theme')` alongside an explicit `customPalette:`. Use `theme: IxThemeName.classic` with `customPalette:` only when classic identity with color overrides is intentional. Use `brightness:`, `IxThemeBuilder.light()` / `.dark()`, or `IxThemeController` for the system schema. |
| `IxThemeFamily.brand` | Analyzer + Runtime | It is a classic compatibility alias in the open-source build. `IxThemeBuilder` resolves it to the classic palette and prints one debug-only notice per process. Use `theme: IxThemeName.classic` for the same built-in palette. For a consumer-owned brand identity and palette, use `theme: const IxThemeName('brand')` alongside an explicit `customPalette:`. |
| `IxTheme.family`, `.mode` | Analyzer | Read `themeName`, `colorSchema`, and resolved `brightness`. |
| `IxFonts.robotoMono` and `robotoMonoFallback` as UI defaults | Analyzer | Work Sans is available through `IxTypography(fontFamily: IxFonts.workSans, package: IxFonts.packageName)`, or supply an independently licensed family. Roboto Mono remains the default and is still bundled in 1.1.0; opting in is a deliberate typography change. |
| Direct import of the library's legacy `IxIcons` stub | Analyzer | Use `IxIcon.key(IxIconKey.*)` for semantic library icons, or generate the catalogue and use `IxIcon(IxIconsData.*)`. The stub is not exported from the package barrel. |
| Generated `IxIcons.*` widget getters | Analyzer in generated output | Regenerate with `ix_icons_generator` 1.1 and replace each getter with `IxIcon(IxIconsData.*)`. `--no-legacy-getters` lets a project verify the completed migration. |
| `IxDropdownButtonVariant` and `IxDropdownButton.variant` | Analyzer | Pass an `IxButtonVariant` through `buttonVariant:`. |
| `IxSpinnerVariant.standard` | Analyzer | Use `secondary`. In 1.1 it is the same enum value, so `secondary.name` is still `standard` and exhaustive switches retain the published two-value shape. |
| `IxToastType.critical`, `.alarm`, `.neutral` | Analyzer | Use `error`, `error`, and `info`, respectively. In 1.1 `error` aliases `critical`, so `error.name` is still `critical`; exhaustive switches retain the six published enum values and indices. |
| `IxToastOverlay.position` | Analyzer | For a top-right or bottom-right stack, use `placement: IxToastPosition.topRight` or `.bottomRight` and remove `position:`. Check the vertical spacing: placement uses 32 px, while the non-default legacy path uses 16 px. Retain `position:` in 1.1.0 if another alignment or that legacy spacing is required; `IxToastPosition` only supports the two right corners. A non-default `position:` continues to override `placement:`. |
| `IxEmptyStateType` and `IxEmptyState.type` | Analyzer | Omit them. They remain accepted but have no visual or semantic effect in 1.1.0. |
| `IxButtonVariant.warning*`, `info*`, `success*` | Analyzer | Choose the closest supported `primary`, `secondary`, `tertiary`, `subtle*`, or `danger*` variant for the action's meaning. |
| `IxToastService.show()` returning `IxToastData` | Analyzer | Use `showToast()`, which returns an `IxToastHandle` with close, pause, resume, and completion APIs. |
| `IxApplicationScaffold.showSettings`, `showThemeToggle`, `showAboutLegal`, `onOpenSettings`, `onOpenAboutLegal` | Analyzer | Use `settings:`, `about:`, and `enableToggleTheme:`. |
| Menu entry IDs `settings`, `theme-toggle`, `about-legal` | Runtime | Move built-in behavior to `settings:`, `about:`, and `enableToggleTheme:`. The reserved IDs still work in 1.1.0 and print one debug notice per process. |
| Breadcrumb items without `breadcrumbKey` | Runtime | Give every item and menu item a stable unique key now and consume `IxBreadcrumbClick.breadcrumbKey`. The 1.1 fallback to `label` is ambiguous when labels repeat. |
| `IxBreadcrumbTheme.dropdownBackground`, `.dropdownBorderRadius` | Analyzer | Retain these values if the breadcrumb overflow needs a custom background or radius in 1.1.0: it still reads the deprecated fields directly. `IxDropdownTheme` already controls the rest of the popup, but its `background` and `borderRadius` do not replace these two breadcrumb fields in this release. |
| `IxResponsiveDataView.searchHintText` | Analyzer | Remove it and set `InputDecoration.hintText` on the consumer-owned search input. `IxResponsiveDataView` does not render a search field, so this argument has no effect in 1.1. |

## Behavior to check after upgrading

- Touch platforms use 48×48 tap targets by default, so controls can grow
  compared with 1.0.2. Pass `density: IxDensity.compact` to
  `IxThemeBuilder` for the previous tap-target layout, or use `IxDensityScope`
  to resolve touch and pointer input dynamically.
- `IxApplicationScaffold` dismisses the keyboard on an outside tap or scroll
  drag by default. Pass `dismissKeyboardOnInteraction: false` to retain the
  previous behavior.
- An `IxIcon` without an explicit `size:` follows its surrounding
  `IconTheme.size`; pass `size:` when the application needs a fixed size.
- `ThemeData.focusColor` is transparent. Use `IxFocusRing` for custom
  focusable widgets that previously relied on Material's opaque focus fill.
- The toast overlay's default top offset is 32 px, previously 16 px. The
  deprecated `position:` path retains its 16 px offsets.
- Collapsing an `IxBlind` or scaffold menu category retains its content until
  the animation finishes, while excluding it from semantics and keyboard
  traversal. Widget tests that expect removal should wait for the transition;
  reduced motion completes it in one frame.

The published spinner, toast and typography enum values, indices and
exhaustive switches are preserved. Roboto Mono remains the default UI font,
the toast placement remains top right, and `dismissOnAction` remains `true`.
See the [1.1.0 changelog](../packages/ix_flutter/CHANGELOG.md) for the full
list of changes and fixes.

## IxBlind subclasses

`IxBlind` remains a `StatelessWidget` with a non-null public `bool expanded`
getter. An exact `IxBlind` instance is automatically uncontrolled when the
constructor argument is omitted or `null`; it starts from
`initiallyExpanded`. Every subclass remains controlled by its virtual
`expanded` getter, including a subclass that omitted the old constructor
argument and calls `super.build(context)`. A subclass that wants automatic
state should compose a plain `IxBlind` rather than inherit from it.

## Icon assets and fonts

The 1.1 library bundles Work Sans, JetBrains Mono, and the 1.x Roboto Mono
font assets. It does not bundle an internal Siemens SVG set;
library widgets currently resolve semantic keys through the Material default.
The optional generator writes the full catalogue into the consumer project,
copies the upstream `LICENSE.md` and `READMEOSS.html`, and updates the
top-level `flutter.assets` list while preserving existing entries. An
unsupported YAML shape is reported without modifying the manifest.
