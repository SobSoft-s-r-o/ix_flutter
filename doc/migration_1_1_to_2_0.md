# Preparing for ix_flutter 2.0 from 1.1

ix_flutter 1.1.0 is the compatibility release before 2.0. It preserves the
published 1.0.2 source contracts while adding replacements and diagnostics
where those replacements already exist. The 2.0 APIs described as
**planned** below are not available in 1.1.0; do not change application code
to use them until a 2.0 package is available.

## SDK and 1.x compatibility

ix_flutter 1.1.0 requires Dart `>=3.10.0 <4.0.0` and Flutter `>=3.38.0`.
The explicit Flutter floor aligns the package constraints with the
`SemanticsRole.*` and `SemanticsService.sendAnnouncement` APIs used by the
menu, toast, dropdown and data-view accessibility implementation. Resolution
depends on both the Dart and Flutter constraints; verify the application
toolchain before upgrading.

The following status labels are used in this guide:

- **Analyzer**: 1.1.0 carries `@Deprecated` and an available migration.
- **Runtime**: 1.1.0 prints a one-time debug notice and has an available
  migration.
- **Planned**: the compatibility API remains unchanged in 1.1.0 and its 2.0
  replacement is not available yet.

## API migration table

| 1.1 API or behavior | Status in 1.1.0 | Migration for 2.0 |
|---|---|---|
| `IxThemeFamily`; `IxThemeBuilder.family`, `.mode`, `.systemBrightness` | Analyzer | Replace `family: IxThemeFamily.classic` with `theme: IxThemeName.classic`. For a custom identity, replace `family: IxThemeFamily.custom` with `theme: const IxThemeName('my-theme')` alongside an explicit `customPalette:`. Use `theme: IxThemeName.classic` with `customPalette:` only when classic identity with color overrides is intentional. Use `brightness:`, `IxThemeBuilder.light()` / `.dark()`, or `IxThemeController` for the system schema. |
| `IxThemeFamily.brand` | Analyzer + Runtime | It is a classic compatibility alias in the open-source build. `IxThemeBuilder` resolves it to the classic palette and prints one debug-only notice per process. Use `theme: IxThemeName.classic` for the same built-in palette. For a consumer-owned brand identity and palette, use `theme: const IxThemeName('brand')` alongside an explicit `customPalette:`. |
| `IxTheme.family`, `.mode` | Analyzer | Read `themeName`, `colorSchema`, and resolved `brightness`. |
| `IxFonts.robotoMono` and `robotoMonoFallback` as UI defaults | Analyzer | Opt in now with `IxTypography(fontFamily: IxFonts.workSans, package: IxFonts.packageName)`, or supply an independently licensed family. The bundled Roboto Mono UI assets are removed in 2.0; JetBrains Mono remains for code styles. The undeclared, unused Play font files are removed at the same time. |
| Direct import of the library's legacy `IxIcons` stub | Analyzer | Use `IxIcon.key(IxIconKey.*)` for semantic library icons, or generate the catalogue and use `IxIcon(IxIconsData.*)`. The stub is not exported from the package barrel. |
| Generated `IxIcons.*` widget getters | Analyzer in generated output | Regenerate with `ix_icons_generator` 1.1 and replace each getter with `IxIcon(IxIconsData.*)`. `--no-legacy-getters` lets a project verify the completed migration. |
| `IxDropdownButtonVariant` and `IxDropdownButton.variant` | Analyzer | Pass an `IxButtonVariant` through `buttonVariant:`. |
| `IxSpinnerVariant.standard` | Analyzer | Use `secondary`. In 1.1 it is the same enum value, so `secondary.name` is still `standard` and exhaustive switches retain the published two-value shape. |
| `IxToastType.critical`, `.alarm`, `.neutral` | Analyzer | Use `error`, `error`, and `info`, respectively. In 1.1 `error` aliases `critical`, so `error.name` is still `critical`; exhaustive switches retain the six published enum values and indices. |
| `IxToastOverlay.position` | Analyzer | Replace it with `placement: IxToastPosition.topRight` or `.bottomRight`. In 1.1 a non-default `position:` still takes precedence over `placement:`; remove that old argument once the placement migration is complete. |
| `IxEmptyStateType` and `IxEmptyState.type` | Analyzer | Omit them. They have no visual or semantic effect in 1.1 and are removed without replacement. |
| `IxButtonVariant.warning*`, `info*`, `success*` | Analyzer | Choose the closest supported `primary`, `secondary`, `tertiary`, `subtle*`, or `danger*` variant for the action's meaning. |
| `IxToastService.show()` returning `IxToastData` | Analyzer | Use `showToast()`, which returns an `IxToastHandle` with close, pause, resume, and completion APIs. |
| `IxApplicationScaffold.showSettings`, `showThemeToggle`, `showAboutLegal`, `onOpenSettings`, `onOpenAboutLegal` | Analyzer | Use `settings:`, `about:`, and `enableToggleTheme:`. |
| Menu entry IDs `settings`, `theme-toggle`, `about-legal` | Runtime | Move built-in behavior to `settings:`, `about:`, and `enableToggleTheme:`. In 2.0 those IDs become ordinary application IDs. |
| Breadcrumb items without `breadcrumbKey` | Runtime | Give every item and menu item a stable unique key now and consume `IxBreadcrumbClick.breadcrumbKey`. The 1.1 fallback to `label` is ambiguous when labels repeat. |
| `IxBreadcrumbTheme.dropdownBackground`, `.dropdownBorderRadius` | Analyzer | Move the menu-surface values to `IxDropdownTheme.background` and `.borderRadius`. The 1.1 breadcrumb overflow still reads its two deprecated fields directly, so retain matching values there only while supporting 1.1; `IxDropdownTheme` takes over the surface in 2.0 and already controls the rest of the popup in 1.1. |
| `IxBreadcrumbButtonAppearance` / `buttonAppearance`; `showNavigationMenu`, `homeMenuLabel`, `showHomeLabel`, `homeIcon` | Planned | 2.0 replaces appearance with `subtle:` and represents Home as an ordinary keyed item. Its overflow uses an ellipsis action. Keep the 1.1 API until those replacements ship. |
| `IxApplicationScaffold.appTitle`, `appBar`, `initiallyExpanded`, the 1024 px breakpoint, and 320/72 px widths | Planned | The 1.1 API remains unchanged. In 2.0, map `appTitle:` to `header: IxApplicationHeader(name: ...)`; the planned header also provides `nameSuffix`, `logo`, and `actions` slots. `appBar:` remains an escape hatch and is not removed. The scaffold also schedules controlled `expanded` / `onExpandChanged`, `startExpanded: false`, `sm` 768 and `md` 1280 breakpoints, and 256/52 px menu widths. None of these replacements are available in 1.1. |
| `IxPaginationBar` and the current `IxPaginationConfig` constructor | Planned | 2.0 schedules a sealed standard/infinite configuration and a standalone `IxPagination` with 0-based `selectedPage` and `[10, 15, 20, 40, 100]` item-count choices. `IxResponsiveDataView` keeps its existing 1-based page contract. |
| `IxResponsiveDataView.searchHintText` | Analyzer | Remove it and set `InputDecoration.hintText` on the consumer-owned search input. `IxResponsiveDataView` does not render a search field, so this argument has no effect in 1.1. |
| `IxResponsiveDataView.onRowTapDesktop`, `initialSortKey`, `initialSortAscending` | Planned | 2.0 schedules `onRowTap` and controlled `sort: IxSortSpec?` / `onSortChanged`. Continue using the 1.1 arguments until those APIs ship. |
| `IxEmptyState.title`, `subtitle`, `primaryAction`, `secondaryAction` | Planned | 2.0 schedules `header`, `subHeader`, `action`, and `onActionClick`. Continue using the 1.1 widget arguments until then. |
| `IxBorders` | Under review | 2.0 will either connect it to the theme or remove it if it remains unused. No removal decision or replacement is available in 1.1. |

## Default and layout changes scheduled for 2.0

1.1.0 deliberately keeps these product defaults so an upgrade within 1.x
does not silently adopt the 2.0 layout:

| Setting | 1.1.0 | Planned 2.0 |
|---|---|---|
| UI font | Roboto Mono | Work Sans |
| Exact `IxBlind` initial state | collapsed (`initiallyExpanded: false`) | expanded |
| Toast placement | top right | bottom right |
| `IxToastService.showToast()` `dismissOnAction` | `true` | `false` |
| Medium spinner diameter | 48 px | 32 px |
| Standard control visual height / button minimum width | 40 px / 64 px | 32 px / 80 px |
| Responsive data-view card breakpoint | 600 px | 768 px |
| Application scaffold | drawer below 1024 px; 320/72 px; initially expanded | `sm` 768 / `md` 1280; 256/52 px; `startExpanded: false` |

The toast width is already 280 px in 1.1.0. Adaptive 48×48 touch hit areas
are also already present: this is accessibility geometry around the visual
control, not the planned 32 px visual-height change. Pin
`density: IxDensity.compact` for the 1.0.2 tap-target layout, or use
`IxDensityScope` to resolve touch and pointer input dynamically.

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
font assets. It does not bundle the planned internal Siemens SVG set;
library widgets currently resolve semantic keys through the Material default.
The optional generator writes the full catalogue into the consumer project,
copies the upstream `LICENSE.md` and `READMEOSS.html`, and updates the
top-level `flutter.assets` list while preserving existing entries. An
unsupported YAML shape is reported without modifying the manifest.
