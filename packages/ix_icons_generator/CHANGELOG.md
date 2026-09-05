# Changelog

All notable changes to ix_icons_generator will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-05

### Added
- `--icons-version` option to pick the `@siemens/ix-icons` version to download
- `--no-legacy-getters` flag to omit the deprecated `IxIcons` widget getters
- Generated header records the icons version and the tarball sha1 checksum
- Unit tests covering SVG cleaning, generated code and version selection

### Changed
- Default `@siemens/ix-icons` version is now 3.5.0 (1479 icons)
- Generated code exposes `IxIconsData` constants of `IxIconData` for
  `ix_flutter`'s `IxIcon` widget and no longer imports `flutter_svg`
- SVG cleaning only strips `fill="none"` from `<g>` elements; white
  fill/stroke attributes are left untouched

### Deprecated
- `IxIcons` widget getters — use `IxIcon(IxIconsData.<name>)` instead; they are
  removed in generator 2.0. They now render a fixed 24 px `IxIcon` and no
  longer honour an ambient `IconTheme.size`, so pass `size:` when migrating
  any call site that sized its icon through an enclosing `IconTheme`
  (including Material slots such as `FilledButton.icon`, which style their
  icon at 18 px)

## [1.0.0] - 2026-01-28

### Added
- Initial release as separate package (split from ix_flutter)
- Downloads icons from `@siemens/ix-icons` npm package v3.2.0
- Generates Flutter-compatible `IxIcons` class
- SVG cleaning for proper color theming
- Automatic pubspec.yaml asset path updates
- Command line options for customization
- Support for library package asset loading
