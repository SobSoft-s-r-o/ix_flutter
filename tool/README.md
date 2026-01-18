# Siemens iX Icons Generator

This tool generates Flutter icon constants from the Siemens iX Design System icon set.

## Features

- Downloads the latest Siemens iX icons from npm
- Generates Flutter-friendly icon widgets
- Supports both library packages (with package references) and local projects (without package references)
- Automatically cleans SVG files for proper coloring support
- Updates pubspec.yaml with asset paths

## Installation

### As a dev dependency (recommended)

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  ix_flutter:
    path: path/to/tool  # Or use git URL
```

Then run:

```bash
flutter pub get
```

## Usage

### Generate icons for your project

```bash
dart run siemens_ix_icons_generator:generate_icons
```

This will:
1. Create an `assets/svg/` directory in your project
2. Download all Siemens iX icons into that directory
3. Generate `lib/ix_icons.dart` with icon constants
4. Update your `pubspec.yaml` to include the assets

### Advanced options

```bash
dart run ix_flutter:generate_icons \
  --project-root . \
  --output lib \
  --assets assets/ix_icons \
  --package my_package_name
```

Options:
- `--project-root` or `-p`: Root directory of your Flutter project (default: current directory)
- `--output` or `-o`: Output directory for generated Dart code, relative to project root (default: `lib`)
- `--assets` or `-a`: Assets directory for SVG files, relative to project root (default: `assets/svg`)
- `--package` or `-n`: Package name for cross-package icon usage (leave empty for same-package usage)
- `--help` or `-h`: Show help message

### Using generated icons

In your Dart code:

```dart
import 'package:your_package/ix_icons.dart';

// Use an icon
Widget build(BuildContext context) {
  return IconTheme(
    data: IconThemeData(
      size: 32,
      color: Colors.blue,
    ),
    child: IxIcons.home,
  );
}
```

## How it works

### For library packages

When you specify a `--package` name, the generator creates icons that reference assets from that package:

```dart
class IxIcons {
  static const _assetPackage = 'your_package_name';
  // Icons will load from package assets
}
```

### For application projects

When you don't specify a package name (or leave it empty), icons load from local assets:

```dart
class IxIcons {
  static const String? _assetPackage = null;
  // Icons will load from app's own assets
}
```

## Example

See the `example/` directory for a working demonstration of using the icon generator in an application project.

To set up the example:

```bash
cd example
flutter pub get
dart run siemens_ix_icons_generator:generate_icons
flutter run
```

## Requirements

- Dart SDK ^3.10.0
- Internet connection (to download icons from npm)

## License

This tool is part of the ix_flutter package.
