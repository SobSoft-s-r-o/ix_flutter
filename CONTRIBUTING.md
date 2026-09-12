# Contributing to ix_flutter

Thank you for your interest in contributing to ix_flutter! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions. We are committed to providing a welcoming and inspiring community.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one.

When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps which reproduce the problem** in as many details as possible
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots and animated GIFs if possible**
- **Include your environment details**: Flutter version, Dart version, OS, device/emulator

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior** and **the expected behavior**
- **Explain why this enhancement would be useful**

### Pull Requests

- Fill in the required template
- Follow the Dart/Flutter style guides (dartfmt, analyzer)
- Include appropriate test cases
- Update relevant documentation
- End all files with a newline

## Development Setup

### Prerequisites

- Flutter SDK: >=3.38.0 (CI pins 3.44.6 stable)
- Dart SDK: >=3.10.0
- Git
- A code editor (VS Code, Android Studio, etc.)

### Getting Started

1. **Fork the repository**
   ```bash
   # Go to https://github.com/SobSoft-s-r-o/ix_flutter and click "Fork"
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ix_flutter.git
   cd ix_flutter
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/SobSoft-s-r-o/ix_flutter.git
   ```

4. **Install dependencies**

   The repository root has no `pubspec.yaml`; every command runs inside a
   package.

   ```bash
   cd packages/ix_flutter && flutter pub get && cd ../..
   cd packages/ix_icons_generator && dart pub get && cd ../..
   cd example && flutter pub get && cd ..
   ```

5. **Create a new branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```

### Building and Testing

#### Run Tests

```bash
# The library suite
cd packages/ix_flutter
flutter test
flutter test --coverage                          # with coverage
flutter test test/ix_theme_color_tokens_test.dart # one file

# The generator suite
cd ../ix_icons_generator && dart test

# The example suite
cd ../../example && flutter test
```

#### Static Analysis

```bash
cd packages/ix_flutter && flutter analyze          # the library
cd ../ix_icons_generator && dart analyze           # the generator
cd ../../example && flutter analyze                # the example
cd ../doc/snippets && flutter analyze              # the doc snippets
```

#### Format Code

Same directories CI checks (see `.github/workflows/ci.yml`, job `format`):

```bash
cd packages/ix_flutter && dart format lib test tool example
cd ../ix_icons_generator && dart format lib bin test
cd ../../example && dart format lib test

# Check formatting without modifying (what CI runs)
dart format --output=none --set-exit-if-changed lib test
```

#### Build Examples

```bash
# Build web example
cd example
flutter build web

# Run example app
flutter run -d chrome
```

#### Icon Generation

```bash
# Generate icons for development/testing
dart run ix_icons_generator:generate_icons

# Generate with custom output path
dart run ix_icons_generator:generate_icons --output lib/generated --assets assets/icons
```

## Style Guidelines

### Language

Everything committed to this repository -- source code comments and
dartdoc, tests, documentation, commit messages, pull request descriptions,
CI workflow comments, and tool scripts -- is written in English (see
[CLAUDE.md](CLAUDE.md#language)). The only exception is translation/
localization files (for example `*.arb`, `*.po`, or a `l10n/`/`translations/`
directory), which carry the target language of the translation.
`tool/check_docs.sh` runs in CI and fails the build if it finds a letter
unique to the Slovak alphabet (see that script's `check_no_slovak` function
for the exact set) in a `*.dart`, `*.md`, `*.sh`, `*.yml`/`*.yaml` or `*.txt`
file, guarding against a regression of the Slovak comments that had crept
into tests and tooling before this rule existed. The check is deliberately
narrow to that one alphabet rather than every non-English language, so a
deliberate, narrow use of another language elsewhere (for example a
localization-override example, or a string exercising text rendering) is
still subject to the general rule above and should be justified in review.

### Dart/Flutter Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dartfmt` for automatic formatting
- Run `flutter analyze` before committing
- Use meaningful variable and function names
- Add comments for complex logic
- Write doc comments for public APIs

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Example:
```
Add support for custom icon colors

- Implement IxIcon color parameter
- Update icon documentation
- Add unit tests

Fixes #123
```

### Documentation

- Update relevant documentation in the [doc/](doc/) folder
- Update README.md if adding new features
- Include code examples for new features
- Update CHANGELOG.md with your changes

## Documentation Updates

When you make changes, update the relevant documentation:

1. **Component Documentation**: Update files in [doc/](doc/) folder
2. **Main README**: Update [README.md](README.md) if adding features
3. **Changelog**: Add entry to [packages/ix_flutter/CHANGELOG.md](packages/ix_flutter/CHANGELOG.md)
4. **Inline Comments**: Add/update code comments and doc strings

### Documentation Structure

- **doc/**: Component-specific documentation
- **doc/snippets/**: the compiled sources of every Dart snippet in the
  documentation (see below)
- **doc/tokens.md**: generated color-token table -- never edit it by hand
- **README.md**: repository overview
- **packages/ix_flutter/README.md**: the README published to pub.dev
- **packages/ix_flutter/CHANGELOG.md**: version history
- **packages/ix_flutter/LICENSE**: license terms
- **packages/ix_flutter/ICON_LICENSING.md**: icon licensing specifics

### Code snippets in documentation

Every ```dart block in the component pages (`doc/*.md`) and the hub documents
(`README.md`, `packages/ix_flutter/README.md`, `GETTING_STARTED.md`, `FAQ.md`)
is a verbatim copy of a declaration in [doc/snippets](doc/snippets), so a
snippet can never drift away from the API it documents. Exempt are the test
skeleton in this file and the before/after fragments in `ICON_MIGRATION.md`,
whose "before" half deliberately shows code that no longer compiles.

When you change a snippet:

1. Edit the declaration in `doc/snippets/lib/<page>_snippets.dart`
2. Run `cd doc/snippets && flutter pub get && flutter analyze`
3. Copy the declaration into the matching block in the documentation page

### Regenerating the token table

`doc/tokens.md` is generated from the classic palettes:

```bash
cd packages/ix_flutter
dart run tool/gen_token_table.dart
```

CI regenerates it and fails if the committed file differs.

## Testing Requirements

### Test Coverage

- Add unit tests for new features
- Maintain or improve overall test coverage
- Test edge cases and error conditions
- Include integration tests where appropriate

### Repository test conventions

- `pumpIx()` (`packages/ix_flutter/test/helpers/pump_ix.dart`) is the standard
  wrapper: IxTheme, viewport, text scale, `disableAnimations: true`.
- A test that mirrors a specific upstream `.ct.ts` test or scss/tsx source
  cites it with `@Upstream('...')` (`test/helpers/upstream.dart`). Where no
  direct counterpart exists (for example the width/text-scale and RTL
  matrices), the file instead carries a doc comment above `void main()` naming
  the finding ID and the task that resolves it.
- A matrix case in `test/a11y`, `test/responsive` or `test/rtl` that documents
  an unfixed finding is marked `skip: true` with a trailing
  `// IXF-xxx - <plan/task>` comment naming it (`skip` is `bool?` in
  `flutter_test`, not `String`), and the task that fixes the finding un-skips
  it. No test is skipped today -- the whole suite runs.
- Goldens: see `packages/ix_flutter/test/golden/README.md`.

### Test Guidelines

```dart
// Example test structure
void main() {
  group('IxSomething', () {
    testWidgets('should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IxSomething(),
          ),
        ),
      );

      expect(find.byType(IxSomething), findsOneWidget);
    });

    test('should calculate correctly', () {
      final result = someFunction();
      expect(result, expectedValue);
    });
  });
}
```

## Licensing and Copyright

- All contributions are licensed under the MIT License
- You agree that your contributions will be licensed under the MIT License
- Include copyright headers in new files if required
- Update AUTHORS/contributors list if applicable

## Icons and Design System

When working with icons or design patterns:

1. Icons are from the [Siemens iX Design System](https://ix.siemens.io)
2. Regenerate icons using the provided tool if needed
3. Ensure icon licensing compliance
4. Test icon generation on your system
5. Document any new icon integration patterns

## Submitting Changes

### Before Submitting

- [ ] Run `flutter analyze` and fix any issues
- [ ] Run `dart format` to format your code
- [ ] Run `flutter test` and ensure all tests pass
- [ ] Update documentation
- [ ] Update CHANGELOG.md

### Creating a Pull Request

1. Push your branch to your fork:
   ```bash
   git push origin feature/AmazingFeature
   ```

2. Go to the original repository and create a Pull Request

3. Fill in the PR template with:
   - **Description**: What does this PR do?
   - **Type of Change**: Bug fix, feature, documentation, etc.
   - **Related Issues**: Closes #123
   - **Testing**: How have you tested this?
   - **Screenshots**: If applicable

### PR Review Process

- Maintainers will review your PR
- Address any requested changes
- Discussion may occur before merging
- Be patient and respectful during review

## Versioning and compatibility

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes and minor improvements

Each release's own `packages/ix_flutter/CHANGELOG.md` entry calls out its
breaking changes inline, in that release's `Changed`/`Removed`/`Deprecated`
bullets. Historically:

- **1.1.0**: raises the minimum Flutter SDK to 3.38.0; preserves the
  published enum values and exhaustive switches by implementing
  `IxSpinnerVariant.secondary` and `IxToastType.error` as aliases, and keeps
  `IxBlind` as a `StatelessWidget` with its published getter contract; makes
  `ThemeData.focusColor` transparent; bakes a platform-derived tap-target
  density, so controls grow about 7px on touch platforms; makes `IxIcon.size`
  nullable so an unsized icon follows the slot around it; and moves
  `IxToastOverlay`'s default top offset from 16px to 32px. Several APIs are
  deprecated but still work. The changelog's `Changed` and `Deprecated`
  sections carry the per-API detail and the opt-outs
- **1.0.2**: the icon generator's command moved from the `ix_flutter`
  package prefix to its own `ix_icons_generator` package, which must be
  added as a dev dependency -- see [ICON_MIGRATION.md](ICON_MIGRATION.md)
  for the exact old and new commands
- **1.0.1**, **1.0.0**, **0.0.1**: no breaking changes

### Flutter & Dart compatibility

1.1.0 raises the Flutter floor for the first time; the Dart floor is
unchanged from 1.0.2:

| Version           | Flutter  | Dart     |
| ----------------- | -------- | -------- |
| 1.1.0             | >=3.38.0 | >=3.10.0 |
| 1.0.2             | >=3.10.0 | >=3.10.0 |
| 1.0.1             | >=3.10.0 | >=3.10.0 |
| 1.0.0             | >=3.10.0 | >=3.10.0 |
| 0.0.1             | >=3.10.0 | >=3.10.0 |

`SemanticsRole.*` and `SemanticsService.sendAnnouncement`, which 1.1.0's menu,
toast, dropdown and data-view semantics use, are only available from Flutter
3.38 -- hence the explicit floor. Package resolution considers both Dart and
Flutter constraints; verify both parts of the application toolchain before
upgrading.

See [README.md#requirements](README.md#requirements) for the current
requirement and [README.md#platform-support](README.md#platform-support) for
the current supported-platform list (unchanged since 0.0.1).

### Migration guides

See [ICON_MIGRATION.md](ICON_MIGRATION.md) for the icon-generator package split
and [doc/migration_to_1_1.md](doc/migration_to_1_1.md) for upgrading to 1.1.0 and addressing its deprecation warnings.

## Release Process

Maintainers handle releases. Package publication is always an authenticated
local `dart pub publish`; no workflow publishes to pub.dev.

For a release whose notes are still under `[Unreleased]`, the **Version Bump
(Manual)** workflow ([.github/workflows/version-bump.yml](.github/workflows/version-bump.yml))
can prepare a release pull request on demand (`workflow_dispatch`):

1. Land everything the release contains, with its entries under `[Unreleased]`
   in `packages/<package>/CHANGELOG.md`
2. Work through the [release checklist](#release-checklist) below; in
   particular `dart pub publish --dry-run` must report 0 warnings
3. Start **Version Bump (Manual)** from the Actions tab and choose the package
   (`ix_flutter`, `ix_icons_generator` or `both`) and the semver bump. Choose
   `none` when `pubspec.yaml` already carries the intended version; this runs
   `cider release` without running `cider bump`. A prerelease identifier is
   valid only with `patch`, `minor`, or `major`. The run uses Flutter 3.44.6
   and cider 0.2.10, installs dependencies, analyzes and tests every selected
   package, finalizes the changelog, and opens a labelled release pull request
4. Review that pull request: confirm the `Upstream:` line that sat under
   `[Unreleased]` is still the first line under the *new* release header (see
   [UPSTREAM.md](UPSTREAM.md#release-header-format) -- `cider release` renames
   the header in place and carries the line with it, but the round trip is not
   guaranteed lossless, so check rather than assume), update the CHANGELOG's
   link reference definitions (`cider release` deletes the `[Unreleased]` one
   and adds nothing for the new version), diff the rest of `CHANGELOG.md` for
   anything `cider` dropped or reflowed, wait for CI, then merge it
5. Merge the reviewed release pull request, then publish from the package
   directory with `dart pub publish`
6. Add the new version's link reference definition
   (`https://pub.dev/packages/<package>/versions/<version>`) once the version
   is live on pub.dev, and point `[Unreleased]` back at `commits/main`

The workflow needs `contents: write` and `pull-requests: write`, plus the
repository setting that allows GitHub Actions to create pull requests. A pull
request created through `GITHUB_TOKEN` can require a maintainer's explicit
approval before its workflows run; review the pending checks rather than
assuming the event was skipped. See GitHub's
[workflow trigger documentation](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).

### Direct maintainer-authored release pull request

When the intended versions and dated changelog sections were prepared and
reviewed locally, open a normal maintainer-authored pull request with those
files. Do not run `cider bump` or `cider release` again. This is the path for
the prepared 1.1.0 release: both pubspecs already carry 1.1.0 and both
changelogs already carry the 2026-09-12 release section. Wait for that pull
request's CI, merge it, then run the two authenticated local publish commands:

```bash
cd packages/ix_icons_generator && dart pub publish
cd ../ix_flutter && dart pub publish
```

#### Which packages need which step

The packages remain independently versioned even when they happen to share a
release number. Neither 1.1.0 package is published yet. This repository has no
git tags or GitHub releases, so no changelog link may point at `releases/tag/…`
or `compare/…`; every such URL currently 404s (see
[UPSTREAM.md](UPSTREAM.md#what-these-definitions-may-point-at)). Add a pub.dev
version link only after that package is live.

### Release checklist

Run through this before publishing `ix_flutter` or `ix_icons_generator` to
pub.dev:

- [ ] `packages/ix_flutter`: `flutter analyze`, `flutter test`,
      `dart format --output=none --set-exit-if-changed lib test example`
- [ ] `example`: `flutter analyze`, `flutter test`
- [ ] `tool/check_docs.sh` passes (no stale API names, versions or claims)
- [ ] `doc/snippets`: `flutter pub get && flutter analyze` -- every snippet in
      the documentation still compiles
- [ ] `packages/ix_flutter`: `dart run tool/gen_token_table.dart` leaves
      `doc/tokens.md` unchanged
- [ ] `packages/ix_flutter`: `dart run tool/upstream_check.dart` -- `UPSTREAM.md`
      and the CHANGELOG release header agree with `IxUpstream`
- [ ] CHANGELOG.md: the section being prepared -- `[Unreleased]` before the
      bump, the new release section after it -- is followed by its `Upstream:`
      line, and no *older* section was edited to carry one (see
      [UPSTREAM.md](UPSTREAM.md#release-header-format))
- [ ] CHANGELOG.md ends with a keep-a-changelog link reference definition for
      `[Unreleased]` and for every **bracketed** version header -- required for
      `cider release` to parse the file without mangling it. A version with
      nothing truthful to link to (never published) carries no definition and
      drops its brackets instead. Every definition must resolve: pub.dev
      version pages for published versions, `commits/main` for `[Unreleased]`,
      and no tag or release URLs while the repository has neither (see
      [UPSTREAM.md](UPSTREAM.md#what-these-definitions-may-point-at))
- [ ] CHANGELOG.md stays strictly keep-a-changelog after automated or manual
      finalization: the `# Changelog` intro, the current release section,
      the per-release sections and the
      closing link reference definitions, and nothing else. `cider release`
      silently drops or misfiles a heading or paragraph outside that shape
      (a `## Versioning`-style section, a stray paragraph inside a category,
      a non-standard `#### `-level heading) instead of erroring, which is
      why the versioning policy, the per-release compatibility/breaking-change
      history and the migration guide pointer live in this file's
      [Versioning and compatibility](#versioning-and-compatibility) section
      instead of the changelog -- the Version Bump run never touches this
      file
- [ ] Diff the whole `CHANGELOG.md` finalization change
      (see [Release Process](#release-process) step 4): `cider release`
      escapes a stray underscore and drops blank lines/`---` separators even
      inside a section it keeps. That much is cosmetic (renders the same),
      but the diff is the only way to confirm nothing else moved
- [ ] The version the release will carry is referenced consistently in the
      package pubspec and documentation (`ix_flutter: ^<version>`)
- [ ] Screenshots in `packages/ix_flutter/screenshots/` still match the current
      UI, and `pubspec.yaml`'s `screenshots:` entry points at a file that exists
- [ ] `dart pub publish --dry-run` in `packages/ix_flutter` **and**
      `packages/ix_icons_generator`: 0 warnings, and the published file list
      contains `LICENSE`, `README.md`, `CHANGELOG.md`, `ICON_LICENSING.md` and
      `THIRD_PARTY_NOTICES.md` but no `tool/`
- [ ] The automated or direct maintainer-authored release pull request is
      CI-green before it is merged

## Recognition

Contributors are recognized in:

- Pull request comments
- Release notes in CHANGELOG.md
- AUTHORS file (if applicable)
- Individual commit history, for full contributor attribution

## Questions?

- **Documentation**: Check existing docs in [doc/](doc/)
- **Issues**: Search for similar issues
- **Discussions**: Open a GitHub Discussion
- **Email**: Contact maintainers

## Important Reminders

- ⚠️ This is NOT an official Siemens product
- 📋 Ensure compliance with Siemens iX Design System licensing
- 🔒 Respect intellectual property rights
- ✅ Follow the code of conduct
- 🤝 Be respectful and collaborative

Thank you for contributing to ix_flutter! 🎉

---

**License**: MIT
