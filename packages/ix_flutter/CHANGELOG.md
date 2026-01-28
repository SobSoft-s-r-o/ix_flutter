# Changelog

All notable changes to the ix_flutter project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [1.0.2] - 2026-01-28

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

For migration from previous versions, see [ICON_MIGRATION.md](ICON_MIGRATION.md).

## Contributors

See individual commit history for contributor information.

## License

MIT License - See [LICENSE](LICENSE)

Icons are subject to Siemens iX Design System licensing - See [ICON_LICENSING.md](ICON_LICENSING.md)

---

**How to Report Issues**: [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
**How to Contribute**: [CONTRIBUTING.md](CONTRIBUTING.md)
**Security Issues**: [SECURITY.md](SECURITY.md)
