# Siemens iX Icons - Important Change Notice

## ⚠️ BREAKING CHANGE

**Icon SVG files are NO LONGER included in the `ix_flutter` library package.**

Due to licensing and distribution restrictions, you **MUST** now run the icon generator tool to download icons from the official Siemens source before using them in your application.

## Why This Change?

### Legal and Licensing Compliance

- **📜 Patent Protection**: Distribution restrictions prevent bundling icon files in the library
- **⚖️ Licensing Compliance**: Ensures proper licensing by downloading from official Siemens sources
- **🔒 Legal Safety**: Protects both library maintainers and users from potential violations

### Technical Benefits

- **🔄 Latest Icons**: Always get the most up-to-date icons from `@siemens/ix-icons` npm package
- **💾 Smaller Library**: Library package size reduced significantly
- **🎨 Customization**: Icons in your project can be modified if needed

## Before (Old Approach - No Longer Available)

Previously, icons were bundled with the library:

```dart
// ❌ This NO LONGER WORKS
import 'package:ix_flutter/src/ix_icons/ix_icons.dart';

Widget build(BuildContext context) {
  return IxIcons.home;  // Icons no longer bundled in library
}
```

## After (New Approach - Required)

You must generate icons in your project using the icon generator tool.

### Step 1: Add Dependencies

Update your `pubspec.yaml` - just add the library (generator is included):

```yaml
dev_dependencies:
  ix_flutter: ^0.0.1
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Generate Icons

Run the icon generator to download icons from the official Siemens source:

```bash
dart run ix_flutter:generate_icons
```

This command will:
- ✅ Download all 1407 icons from the official `@siemens/ix-icons` npm package
- ✅ Create `assets/svg/` directory in your project
- ✅ Generate `lib/ix_icons.dart` file with icon widgets
- ✅ Automatically update your `pubspec.yaml` with asset paths

### Step 4: Update Import Statements

Change your imports from the old library import to your project import:

```dart
// ✅ New (Required)
import 'package:your_app/ix_icons.dart';  // Replace 'your_app' with your package name

Widget build(BuildContext context) {
  return IxIcons.home;  // Works with locally generated icons
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

- [ ] **Add icon generator to `pubspec.yaml`** under `dev_dependencies`
- [ ] **Run `flutter pub get`** to install the generator
- [ ] **Run `dart run ix_flutter:generate_icons`** to download icons
- [ ] **Find all imports of `package:ix_flutter/src/ix_icons/ix_icons.dart`**
- [ ] **Replace with `package:your_app/ix_icons.dart`** (your package name)
- [ ] **Run `flutter clean && flutter pub get`**
- [ ] **Test all screens that use icons**
- [ ] **Commit the generated files** to version control (optional but recommended)

## Generator Command Reference

### Basic Usage (Recommended)

```bash
dart run ix_flutter:generate_icons
```

Uses defaults:
- Output: `lib/ix_icons.dart`
- Assets: `assets/svg/`
- No package reference (icons load from your app)

### Custom Paths

```bash
dart run ix_flutter:generate_icons \
  --output lib/generated \
  --assets assets/icons/ix
```

### For Library Packages

If you're building a library that uses these icons:

```bash
dart run ix_flutter:generate_icons \
  --package my_library_name
```

### All Options

| Option | Description | Default |
|--------|-------------|---------|
| `--project-root` | Project root directory | Current directory |
| `--output` | Output directory for Dart code | `lib` |
| `--assets` | Assets directory for SVG files | `assets/svg` |
| `--package` | Package name for cross-package usage | None |

## Benefits of New Approach

### Legal Compliance
- ✅ Icons downloaded from official Siemens `@siemens/ix-icons` npm package
- ✅ Ensures proper licensing and distribution compliance
- ✅ Protects against patent and copyright violations
- ✅ Maintains legal safety for all users

### Technical Advantages
- ✅ Latest icons from Siemens iX Design System
- ✅ Smaller library package size
- ✅ Icons can be version controlled in your project
- ✅ Ability to customize SVG files if needed
- ✅ Control over asset paths and structure

### Development Workflow
- ✅ Easy to update - just rerun generator
- ✅ One-time setup process
- ✅ Clear separation between library and assets
- ✅ Transparent icon sourcing

## Troubleshooting

### Icons Not Showing Up

**Symptom**: Icons appear blank or missing after migration.

**Solution**:

1. Verify you ran the generator:
   ```bash
   dart run ix_flutter:generate_icons
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
   dart run ix_flutter:generate_icons
   ```

2. Don't manually edit `ix_icons.dart` - it's auto-generated

3. Update library:
   ```bash
   flutter pub upgrade ix_flutter
   ```

## Frequently Asked Questions

### Q: Why can't the library include icon files?

**A:** Due to patent and distribution licensing restrictions on the Siemens iX Design System icons, we cannot legally bundle the SVG files in the library package. The generator ensures icons are downloaded from the official Siemens source, maintaining proper licensing compliance.

### Q: Is this permanent?

**A:** Yes. This is the required approach for legal compliance. All users must generate icons from the official source.

### Q: Do I need to regenerate icons for each project?

**A:** Yes, each Flutter project that uses Siemens iX icons needs to run the generator once during setup. After that, the icons are part of your project.

### Q: Can I commit generated icons to Git?

**A:** Yes, it's recommended. Commit both the generated `ix_icons.dart` file and the `assets/svg/` directory. This ensures team members and CI/CD systems have the icons without needing to run the generator.

### Q: How do I update to newer icons?

**A:** Run the generator again:
```bash
dart run ix_flutter:generate_icons
```
It will download the latest version from the `@siemens/ix-icons` npm package.

### Q: Will this slow down my development?

**A:** No. After the initial one-time setup (running the generator), icons work normally. You only need to regenerate if you want updated icons from Siemens.

### Q: What if I don't want all 1407 icons?

**A:** Currently, the generator downloads all icons. However, Flutter's build system only includes icons your code actually references, so unused icons won't increase your app size significantly.

### Q: Can I use different icon versions in different projects?

**A:** Yes. Each project downloads its own icons independently, so different projects can have different versions.

## Additional Resources

- **Complete Documentation**: [doc/ix_icons.md](doc/ix_icons.md)
- **Generator Tool Docs**: [tool/README.md](tool/README.md)
- **Example Project**: [example/](example/)
- **Siemens iX Design System**: https://ix.siemens.io
- **Icon Library**: https://ix.siemens.io/docs/icon-library/

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

**Important**: This change ensures legal compliance and protects all users of the library. While it adds one setup step, it provides proper licensing and access to the latest official Siemens icons.

**Last Updated**: January 2026  
**Effective Immediately**: All new projects must use the generator approach.
