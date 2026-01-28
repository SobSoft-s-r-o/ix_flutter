# Siemens iX Icons

Complete guide for using Siemens iX Design System icons in your Flutter application.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Installation and Setup](#installation-and-setup)
  - [Generate Icons in Your Project](#generate-icons-in-your-project-required)
- [Icon Generator Tool](#icon-generator-tool)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Command Line Options](#command-line-options)
- [Using Icons in Your Code](#using-icons-in-your-code)
  - [Basic Usage](#basic-usage)
  - [Customizing Icon Size and Color](#customizing-icon-size-and-color)
  - [Using IconTheme](#using-icontheme)
- [Available Icons](#available-icons)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## Overview

The Siemens iX Flutter package provides access to 1400+ icons from the Siemens iX Design System.

**⚠️ IMPORTANT: Due to licensing and distribution restrictions, icon SVG files are NOT included in the library package.**

To use Siemens iX icons in your Flutter application, you **MUST** run the icon generator tool. The generator downloads icons directly from the official `@siemens/ix-icons` npm package, ensuring you always have properly licensed icons.

## Quick Start

**Required steps to use Siemens iX icons:**

1. Add library to dev_dependencies
2. Run the generator to download icons from the official Siemens source
3. Import and use the generated icons in your code

## Installation and Setup

### Generate Icons in Your Project (Required)

**Step 1:** Add `ix_flutter` and `ix_icons_generator` to your `pubspec.yaml`:

```yaml
dependencies:
  ix_flutter: ^1.0.4

dev_dependencies:
  ix_icons_generator: ^1.0.0
```

**Step 2:** Run `flutter pub get`:

```bash
flutter pub get
```

**Step 3:** Generate icons by running the generator tool:

```bash
dart run ix_icons_generator:generate_icons
```

This command will:
- ✅ Download all 1407 Siemens iX icons from the official `@siemens/ix-icons` npm package
- ✅ Create `assets/svg/` directory in your project
- ✅ Generate `lib/ix_icons.dart` file with all icon widgets
- ✅ Automatically update your `pubspec.yaml` with asset paths

**Step 4:** Import and use icons in your code:

```dart
import 'package:your_app/ix_icons.dart';  // Use your package name

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IxIcons.home;
  }
}
```

**Why is this required?**
- 📜 **Licensing compliance**: Icons are downloaded from the official Siemens source, ensuring proper licensing
- 🔄 **Latest version**: You always get the latest icons from Siemens iX Design System
- ⚖️ **Distribution restrictions**: Patent and licensing restrictions prevent bundling icons in the library package

## Icon Generator Tool

The icon generator is available as a separate package `ix_icons_generator`.

### Installation

Add the generator to your dev dependencies:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.0.0
```

### Usage

**Basic usage (recommended):**

```bash
dart run ix_icons_generator:generate_icons
```

This uses default settings:
- Output: `lib/ix_icons.dart`
- Assets: `assets/svg/`
- Package: none (icons load from your app)

**Custom output directory:**

```bash
dart run ix_icons_generator:generate_icons \
  --output lib/icons \
  --assets assets/ix_icons
```

**For library packages:**

If you're building a library that will be used by other packages:

```bash
dart run ix_icons_generator:generate_icons \
  --package my_library_name
```

This makes icons reference your library's assets.

### Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--project-root` | `-p` | Root directory of your Flutter project | Current directory |
| `--output` | `-o` | Output directory for generated Dart code (relative to project root) | `lib` |
| `--assets` | `-a` | Assets directory for SVG files (relative to project root) | `assets/svg` |
| `--package` | `-n` | Package name for cross-package usage (leave empty for same package) | Empty (no package) |
| `--help` | `-h` | Show help message | - |

**Examples:**

```bash
# Generate in specific directories
dart run ix_icons_generator:generate_icons \
  --output lib/generated \
  --assets assets/icons/ix

# Generate for a library package
dart run ix_icons_generator:generate_icons \
  --package my_ui_library

# Generate in a specific project
dart run ix_icons_generator:generate_icons \
  --project-root /path/to/my/project

# Show help
dart run ix_icons_generator:generate_icons --help
```

## Using Icons in Your Code

### Basic Usage

After generating icons, they are accessed as static getters on the `IxIcons` class:

```dart
import 'package:your_app/ix_icons.dart';  // Replace with your package name

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IxIcons.menu,
        title: Text('My App'),
        actions: [
          IxIcons.search,
          IxIcons.settings,
        ],
      ),
      body: Column(
        children: [
          IxIcons.home,
          IxIcons.user,
          IxIcons.calendar,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: IxIcons.add,
        onPressed: () {},
      ),
    );
  }
}
```

### Customizing Icon Size and Color

Icons respect Flutter's `IconTheme` for sizing and coloring:

```dart
// Method 1: Using IconTheme
IconTheme(
  data: IconThemeData(
    size: 32,
    color: Colors.blue,
  ),
  child: IxIcons.home,
)

// Method 2: Wrap in a Container with specific size
SizedBox(
  width: 48,
  height: 48,
  child: IconTheme(
    data: IconThemeData(color: Colors.red),
    child: IxIcons.warning,
  ),
)
```

### Using IconTheme

Apply icon styling to multiple icons at once:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        children: [
          IxIcons.home,
          SizedBox(width: 8),
          IxIcons.search,
          SizedBox(width: 8),
          IxIcons.settings,
        ],
      ),
    );
  }
}
```

## Available Icons

The package includes 1407 icons from the Siemens iX Design System. All icons follow a consistent naming pattern:

**Common categories:**

- **Navigation**: `home`, `menu`, `arrowLeft`, `arrowRight`, `chevronDown`, etc.
- **Actions**: `add`, `edit`, `delete`, `save`, `close`, `search`, etc.
- **Communication**: `mail`, `phone`, `notification`, `chat`, etc.
- **Files**: `document`, `folder`, `download`, `upload`, etc.
- **Status**: `success`, `error`, `warning`, `info`, etc.
- **User**: `user`, `userGroup`, `profile`, etc.

**Icon naming conventions:**

- CamelCase: `aboutFilled`, `addCircle`, `alarmBell`
- Descriptive: Icons are named after what they represent
- Variants: Many icons have filled versions (e.g., `home` and `homeFilled`)

**Finding icons:**

Browse all available icons in the generated `ix_icons.dart` file or check the [Siemens iX Design System documentation](https://ix.siemens.io/docs/icon-library/).

## Best Practices

### 1. Use IconTheme for Consistent Styling

```dart
// Good: Define icon styling once
IconTheme(
  data: IconThemeData(size: 24, color: Colors.blue),
  child: Column(
    children: [
      IxIcons.home,
      IxIcons.search,
      IxIcons.settings,
    ],
  ),
)

// Avoid: Wrapping each icon individually
```

### 2. Choose the Right Variant

Many icons come in regular and filled variants:

```dart
// Regular - for outlined appearance
IxIcons.heart

// Filled - for solid appearance  
IxIcons.heartFilled
```

### 3. Consider Accessibility

Wrap icons in `Semantics` widgets for screen readers:

```dart
Semantics(
  label: 'Home',
  child: IconButton(
    icon: IxIcons.home,
    onPressed: () {},
  ),
)
```

### 4. Use Descriptive Icon Names

```dart
// Good: Clear what the icon represents
IxIcons.userSettings
IxIcons.documentDownload

// Available: Search through ix_icons.dart for exact names
```

### 5. Keep Icons Consistent in Size

```dart
// Good: Consistent sizing within a context
AppBar(
  leading: IconTheme(
    data: IconThemeData(size: 24),
    child: IxIcons.menu,
  ),
  actions: [
    IconTheme(
      data: IconThemeData(size: 24),
      child: IxIcons.search,
    ),
  ],
)
```

## Troubleshooting

### Icons Not Showing Up

**Problem:** Icons appear as blank or show an error.

**Solutions:**

1. **Did you run the generator?** Icons are NOT included in the library. You must run:

```bash
dart run ix_icons_generator:generate_icons
```

2. **Check asset configuration** - Make sure `pubspec.yaml` includes assets:

```yaml
flutter:
  assets:
    - assets/svg/
```

3. **Run flutter pub get** after generating icons:

```bash
flutter pub get
```

4. **Clean and rebuild:**

```bash
flutter clean
flutter pub get
flutter run
```

5. **Verify import path:**

```dart
import 'package:your_app/ix_icons.dart';  // Use your package name
```

### Generator Fails to Download Icons

**Problem:** Icon generator fails with network error.

**Solutions:**

1. Check your internet connection
2. Verify you can access npm registry: https://registry.npmjs.org
3. Check for proxy settings if behind corporate firewall
4. Try again - network issues may be temporary

### Icons Are the Wrong Color

**Problem:** Icons don't respect the color I set.

**Solution:** Wrap icons in `IconTheme`:

```dart
IconTheme(
  data: IconThemeData(color: Colors.red),
  child: IxIcons.warning,
)
```

### Generated File Has Errors

**Problem:** After running generator, `ix_icons.dart` has compile errors.

**Solutions:**

1. Delete the file and regenerate:

```bash
rm lib/ix_icons.dart
dart run ix_icons_generator:generate_icons
```

2. Check for manual edits - the file is auto-generated and shouldn't be modified
3. Update the library:

```bash
flutter pub upgrade ix_flutter
```

### Cannot Find Specific Icon

**Problem:** Looking for an icon but can't find it.

**Solutions:**

1. Check the generated `ix_icons.dart` file - all icons are listed there
2. Search by description (e.g., search for "home" finds `home`, `homeFilled`)
3. Visit [Siemens iX icon library](https://ix.siemens.io/docs/icon-library/)
4. Icon names use camelCase, not kebab-case (e.g., `userProfile` not `user-profile`)

## FAQ

### Do I need to run the generator?

**YES, absolutely!** Due to licensing and distribution restrictions, icon SVG files are NOT included in the `ix_flutter` library package. You MUST run the generator to download icons from the official Siemens source before you can use them in your application.

The generator is included with the library, so just run:

```bash
dart run ix_icons_generator:generate_icons
```

### How do I update icons to the latest version?

Run the generator again to download the latest icons from the official Siemens package:

```bash
dart run ix_icons_generator:generate_icons
```

### Can I customize specific icons?

**Yes**, after running the generator:

1. Icons are downloaded to your `assets/svg/` directory
2. You can edit any SVG file in that directory
3. Your modified icons will be used in your app

⚠️ Don't modify the generated `lib/ix_icons.dart` file - it will be overwritten if you regenerate. Only modify the SVG files in the assets folder.

### How large is the icon package?

The generator downloads ~1400 SVG files (~1.5 MB) to your project. However, Flutter's build system only includes icons that your code actually references, so your final app size will be much smaller.

### Can I contribute new icons?

Icons are maintained by the Siemens iX Design System team. To request new icons:

1. Contact the [Siemens iX Design System](https://ix.siemens.io) team
2. Once added to the official `@siemens/ix-icons` npm package, they'll automatically be available
3. Run the generator again to download the latest icons:

```bash
dart run ix_icons_generator:generate_icons
```

### Do icons work on all platforms?

**Yes!** Icons are SVG-based and work on:
- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

### What's the difference between `home` and `homeFilled`?

- **Regular** (e.g., `home`): Outlined/stroke version of the icon
- **Filled** (e.g., `homeFilled`): Solid/filled version of the icon

Choose based on your design needs. Many Material Design apps use filled icons for active states and outlined for inactive states.

### Why can't the library bundle icons?

Due to patent and distribution licensing restrictions, we cannot include Siemens iX icon SVG files directly in the library package. The icon generator ensures you download icons from the official Siemens source (`@siemens/ix-icons` npm package), maintaining proper licensing compliance while giving you access to all icons.

---

## Need Help?

- **Siemens iX Design System:** https://ix.siemens.io
- **Icon Library:** https://ix.siemens.io/docs/icon-library/
- **Flutter SVG Package:** https://pub.dev/packages/flutter_svg
- **Package Issues:** [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)

---

**Last Updated:** January 2026  
**Package Version:** 1.0.0  
**Icons Version:** @siemens/ix-icons 3.2.0
