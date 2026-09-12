# Siemens iX Icons - Important Change Notice

## ⚠️ BREAKING CHANGE

**The full Siemens iX icon catalogue is not bundled in the `ix_flutter` library package.**

`ix_flutter` addresses its own widget icons through a small set of semantic
keys, resolved to Material glyphs by default today; the planned internal
Siemens SVG set is not bundled (see `doc/ix_icons.md`). To use the full Siemens
iX catalogue in your own code, run the optional `ix_icons_generator` tool to
download icons from the official Siemens source.

## Why This Change?

### Technical Benefits

- **📦 Smaller Library**: Library package size is reduced significantly by not shipping 1 479 SVG files
- **🎨 Customization**: Icons downloaded into your project can be modified if needed
- **📌 Pinned, Reproducible Versions**: Every project pins an exact `@siemens/ix-icons` release (default `3.5.0`), selectable with `--icons-version`

## Before (Old Approach - No Longer Available)

Previously, icons were bundled with the library:

```dart
// ❌ This NO LONGER WORKS
import 'package:ix_flutter/src/ix_icons/ix_icons.dart';

Widget build(BuildContext context) {
  return IxIcons.home;  // Icons no longer bundled in library
}
```

## After (New Approach - Required for the Full Catalogue)

Generate icons in your project using the icon generator tool.

### Step 1: Add the Generator

Add `ix_icons_generator` as a dev dependency:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Generate Icons

Run the icon generator to download icons from the official Siemens source:

```bash
dart run ix_icons_generator:generate_icons            # default: @siemens/ix-icons 3.5.0
```

This command will:
- ✅ Download the pinned `@siemens/ix-icons` release (1 479 icons in 3.5.0) from the official npm package
- ✅ Create an assets directory (default `assets/svg/`) in your project
- ✅ Generate `lib/ix_icons.dart` with `IxIconsData` constants for `IxIcon`
- ✅ Automatically update your `pubspec.yaml` with asset paths

### Step 4: Update Import Statements

Change your imports from the old library import to your project import, and render icons through `IxIcon`:

```dart
// ✅ New (Required)
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';  // Replace 'your_app' with your package name

Widget build(BuildContext context) {
  return const IxIcon(IxIconsData.home);  // Works with locally generated icons
}
```

### Step 5: Test

Clean and run your application:

```bash
flutter clean
flutter pub get
flutter run
```

## Migration Checklist for Existing Projects

If you were previously using library icons, follow this checklist:

- [ ] **Add `ix_icons_generator` to `pubspec.yaml`** under `dev_dependencies`
- [ ] **Run `flutter pub get`** to install the generator
- [ ] **Run `dart run ix_icons_generator:generate_icons`** to download icons
- [ ] **Find all imports of `package:ix_flutter/src/ix_icons/ix_icons.dart`**
- [ ] **Replace with `package:your_app/ix_icons.dart`** (your package name)
- [ ] **Replace `IxIcons.<name>` usages with `IxIcon(IxIconsData.<name>)`** — an unsized `IxIcon` follows the ambient `IconTheme.size` (24px when none is set), so a call site that sized its icon through an enclosing `IconTheme` keeps the size it had; pass `size:` only where the icon should override the surrounding slot (see `packages/ix_icons_generator/CHANGELOG.md`)
- [ ] **Run `flutter clean && flutter pub get`**
- [ ] **Test all screens that use icons**
- [ ] **Commit the generated files** to version control (optional but recommended)

## Generator Command Reference

### Basic Usage (Recommended)

```bash
dart run ix_icons_generator:generate_icons
```

Uses defaults:
- Output: `lib/ix_icons.dart`
- Assets: `assets/svg/`
- Icons version: `3.5.0` — a pinned version, selectable with `--icons-version`
- No package reference (icons load from your app)

### Custom Paths and Pinned Version

```bash
dart run ix_icons_generator:generate_icons --icons-version 3.5.0 -a assets/ix_icons
```

### For Library Packages

If you're building a library that uses these icons:

```bash
dart run ix_icons_generator:generate_icons --package my_library_name
```

### All Options

| Option | Description | Default |
|--------|-------------|---------|
| `--project-root` | Project root directory | Current directory |
| `--output` | Output directory for Dart code | `lib` |
| `--assets` | Assets directory for SVG files | `assets/svg` |
| `--package` | Package name for cross-package usage | None |
| `--icons-version` | `@siemens/ix-icons` version to download | `3.5.0` |
| `--[no-]legacy-getters` | Emit deprecated `IxIcons` widget getters | on |

## Benefits of New Approach

### Technical Advantages
- ✅ A pinned, reproducible `@siemens/ix-icons` version, selectable with `--icons-version`
- ✅ Smaller library package size
- ✅ Icons can be version controlled in your project
- ✅ Ability to customize SVG files if needed
- ✅ Control over asset paths and structure

### Development Workflow
- ✅ Easy to update - just rerun generator with `--icons-version`
- ✅ One-time setup process
- ✅ Clear separation between library and assets
- ✅ Transparent icon sourcing

## Troubleshooting

### Icons Not Showing Up

**Symptom**: Icons appear blank or missing after migration.

**Solution**:

1. Verify you ran the generator:
   ```bash
   dart run ix_icons_generator:generate_icons
   ```

2. Check `pubspec.yaml` includes assets:
   ```yaml
   flutter:
     assets:
       - assets/svg/
   ```

3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. Verify import uses your package name:
   ```dart
   import 'package:your_app/ix_icons.dart';  // Not ix_flutter
   ```

### Generator Fails to Download Icons

**Symptom**: Generator fails with network error.

**Solution**:

1. Check internet connection
2. Verify access to npm registry: https://registry.npmjs.org
3. Check proxy/firewall settings
4. Try again - network issues may be temporary

### Import Errors After Migration

**Symptom**: Import not found or compilation errors.

**Solution**:

1. Ensure you changed import from:
   ```dart
   import 'package:ix_flutter/src/ix_icons/ix_icons.dart';  // Old
   ```
   To:
   ```dart
   import 'package:your_app/ix_icons.dart';  // New
   ```

2. Run `flutter pub get`

3. Restart your IDE/editor

### Generated File Has Errors

**Symptom**: `ix_icons.dart` shows compilation errors.

**Solution**:

1. Delete and regenerate:
   ```bash
   rm lib/ix_icons.dart
   dart run ix_icons_generator:generate_icons
   ```

2. Don't manually edit `ix_icons.dart` - it's auto-generated

3. Update the generator and the library:
   ```bash
   flutter pub upgrade ix_flutter ix_icons_generator
   ```

## Frequently Asked Questions

### Q: Why doesn't the library bundle the full icon catalogue?

**A:** The library's own widgets need only 28 icons, addressed by `IxIconKey`. Once the LEGAL REVIEW gate documented in `UPSTREAM.md` is passed, the library will bundle that minimal internal set; until then those widgets fall back to Material glyphs through `IxIconResolver.material()` — see `doc/ix_icons.md`. The full 1 479-icon catalogue stays optional and generated either way, so the library package itself stays small; the generator downloads it from the official Siemens source on demand.

### Q: Is this permanent?

**A:** For the full catalogue, yes — it is generated into each project rather than bundled in the library.

### Q: Do I need to regenerate icons for each project?

**A:** Yes, each Flutter project that uses the full Siemens iX catalogue needs to run the generator once during setup. After that, the icons are part of your project.

### Q: Can I commit generated icons to Git?

**A:** Yes, it's recommended. Commit both the generated `ix_icons.dart` file and your assets directory. This ensures team members and CI/CD systems have the icons without needing to run the generator.

### Q: How do I update to newer icons?

**A:** Run the generator again, optionally pinning a version:
```bash
dart run ix_icons_generator:generate_icons --icons-version 3.5.0
```

### Q: Will this slow down my development?

**A:** No. After the initial one-time setup (running the generator), icons work normally. You only need to regenerate if you want a different `@siemens/ix-icons` version.

### Q: What if I don't want all 1 479 icons?

**A:** Currently, the generator downloads the full pinned release. However, Flutter's build system only includes icons your code actually references, so unused icons won't increase your app size significantly.

### Q: Can I use different icon versions in different projects?

**A:** Yes. Each project downloads its own icons independently via `--icons-version`, so different projects can pin different releases.

## Additional Resources

- **Complete Documentation**: [doc/ix_icons.md](doc/ix_icons.md)
- **Generator Tool Docs**: [packages/ix_icons_generator/README.md](packages/ix_icons_generator/README.md)
- **Example Project**: [example/](example/)
- **Siemens iX Design System**: https://ix.siemens.io
- **Icon Library**: https://ix.siemens.io/docs/icons/icon-library

## Need Help?

If you encounter issues during migration:

1. Check this migration guide
2. Review [doc/ix_icons.md](doc/ix_icons.md) for detailed documentation
3. Check the troubleshooting section above
4. Open an issue on GitHub with:
   - Your Flutter/Dart version
   - Generator command you ran
   - Error messages
   - Steps to reproduce

---

**Important**: This document tracks how icons are set up in `ix_flutter`
today: semantic internal keys use the Material default because the planned
internal Siemens SVG set is not bundled (see `doc/ix_icons.md`), and the full
catalogue is generated on demand from the official Siemens source.
