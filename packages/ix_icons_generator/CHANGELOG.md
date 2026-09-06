# Changelog

All notable changes to ix_icons_generator will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `--no-format` flag; the generated `ix_icons.dart` is now run through
  `dart format` by default (best effort — a missing `dart` executable is only
  reported), so it satisfies a project's own formatting check as generated

### Fixed
- SVG cleaning also strips `fill="none"` from the root `<svg>` element and from
  shapes that carry no stroke. 891 of the 1479 `@siemens/ix-icons` 3.5.0 icons
  declare `fill="none"` on the root `<svg>` and fill their `<path>`s by
  inheritance; taken literally by Flutter (which has no `icon.css` to override
  it, as the web build has) they compiled to zero draw commands and rendered
  blank. A shape that pairs `fill="none"` with a real `stroke` is a deliberate
  outline and keeps the attribute
- A tar entry rejected mid-extraction no longer orphans the temporary
  extraction directory
- Icon names that do not spell a Dart identifier are sanitised instead of
  producing a file that does not compile: a leading digit is prefixed
  (`3d-view` → `icon3dView`) and a reserved word suffixed (`class` → `class_`).
  Two icons that collapse to the same identifier now abort generation with a
  message naming both files

## [1.1.0] - 2026-09-05

### Added
- `--icons-version` option to pick the `@siemens/ix-icons` version to download
- `--no-legacy-getters` flag to omit the deprecated `IxIcons` widget getters
- Generated header records the icons version and the tarball sha1 checksum
- Unit tests covering SVG cleaning, generated code and version selection

### Security
- The downloaded tarball is verified against the registry's `dist.shasum`
  (sha1) before anything is written to disk; a mismatch aborts generation.
  A version whose registry entry publishes no `shasum` still generates and
  is marked `tarball sha1 unknown` in the generated header, as before
- Tar entries that would resolve outside the temporary extraction directory
  ("zip slip", e.g. `../../file`) are rejected, and symbolic-link entries
  are skipped instead of being materialised

### Changed
- Default `@siemens/ix-icons` version is now 3.5.0 (1479 icons)
- Generated code exposes `IxIconsData` constants of `IxIconData` for
  `ix_flutter`'s `IxIcon` widget and no longer imports `flutter_svg`
- SVG cleaning only strips `fill="none"` (see the Unreleased section for the
  elements it covers); white fill/stroke attributes are left untouched

### Deprecated
- `IxIcons` widget getters — use `IxIcon(IxIconsData.<name>)` instead; they are
  removed in generator 2.0. They render an unsized `IxIcon`, which follows the
  ambient `IconTheme.size` (24 px when none is set), so a call site that sized
  its icon through an enclosing `IconTheme` — including Material slots such as
  `FilledButton.icon`, which style their icon at 18 px — keeps the size it had.
  Pass `size:` only where the icon should override the surrounding slot

## [1.0.0] - 2026-01-28

### Added
- Initial release as separate package (split from ix_flutter)
- Downloads icons from `@siemens/ix-icons` npm package v3.2.0
- Generates Flutter-compatible `IxIcons` class
- SVG cleaning for proper color theming
- Automatic pubspec.yaml asset path updates
- Command line options for customization
- Support for library package asset loading
