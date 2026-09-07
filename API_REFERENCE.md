# API Reference

The full, always-current API reference is generated from the source:

- **Online**: <https://pub.dev/documentation/ix_flutter/latest/> (published with
  each release)
- **Locally**:

  ```bash
  cd packages/ix_flutter
  dart doc
  # open doc/api/index.html
  ```

This page is only an index: every widget's parameters, defaults and behaviour
are documented in the pages below and in the Dart doc comments, so there is no
hand-written signature here to fall out of date.

## Components

| Component | Guide |
|---|---|
| `IxApplicationScaffold`, `IxMenuEntry`, `IxApplicationStrings` | [doc/ix_application_scaffold.md](doc/ix_application_scaffold.md) |
| `IxKeyboardDismissScope` (tap outside a text input, or scroll, to dismiss the keyboard) | [doc/ix_application_scaffold.md](doc/ix_application_scaffold.md#keyboard-dismissal) |
| `IxBlind`, `IxBlindAccordion` | [doc/ix_blind.md](doc/ix_blind.md) |
| `IxBreadcrumb`, `IxBreadcrumbItemData`, `IxBreadcrumbStrings` | [doc/ix_breadcrumb.md](doc/ix_breadcrumb.md) |
| `IxDropdownButton`, `IxDropdownMenuItem` | [doc/ix_dropdown_button.md](doc/ix_dropdown_button.md) |
| `IxEmptyState` | [doc/ix_empty_state.md](doc/ix_empty_state.md) |
| `IxIcon`, `IxIconData`, `IxIconKey`, `IxIconSize`, `IxIconResolver` | [doc/ix_icons.md](doc/ix_icons.md) |
| `IxIconButton` and the density policy (`IxDensity`, `IxDensityScope`) | [doc/density.md](doc/density.md) |
| `IxResponsiveDataView`, `IxResponsiveDataViewStrings`, `IxPaginationBar`, `IxPaginationStrings` | [doc/ix_responsive_data_view.md](doc/ix_responsive_data_view.md) |
| `IxSpinner` | [doc/ix_spinner.md](doc/ix_spinner.md) |
| `IxToastService`, `IxToastHandle`, `IxToastOverlay`, `IxToastType`, `IxToastPosition`, `IxToastStrings` | [doc/ix_toast.md](doc/ix_toast.md) |

## Theme and tokens

| Topic | Guide |
|---|---|
| `IxThemeBuilder`, `IxThemeName`, `IxColorSchema`, `IxCustomPalette` | [doc/theming.md](doc/theming.md) |
| `IxThemeController` (runtime theme switching) | [doc/theming.md](doc/theming.md#switching-themes-at-runtime) |
| Per-component theme extensions (`IxButtonTheme`, `IxBreadcrumbTheme`, `IxDropdownTheme`, `IxSpinnerTheme`, ...), registered by `IxThemeBuilder` | [doc/theming.md](doc/theming.md) |
| `IxThemeColorToken` values with their light/dark colors | [doc/tokens.md](doc/tokens.md) |
| `IxTypography`, `IxFonts` | [doc/typography.md](doc/typography.md) |

## Guides

- [GETTING_STARTED.md](GETTING_STARTED.md) - install, theme and first screens
- [FAQ.md](FAQ.md) - common questions
- [ICON_MIGRATION.md](ICON_MIGRATION.md) - moving off the deprecated
  `IxIcons.<name>` getters
- [CONTRIBUTING.md](CONTRIBUTING.md) - development setup and release checklist

## API stability

`ix_flutter` follows semantic versioning. 1.x releases stay source-compatible:
APIs that will change in 2.0 are deprecated first, keep working, and are listed
in [packages/ix_flutter/CHANGELOG.md](packages/ix_flutter/CHANGELOG.md) together
with their replacement.
