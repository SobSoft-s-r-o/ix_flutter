# ix_icons_generator

Icon generator tool for Siemens iX Design System Flutter icons.

This tool downloads 1400+ icons from the official `@siemens/ix-icons` npm package and generates Flutter-compatible icon widgets.

## Installation

Add to your `pubspec.yaml` as a dev dependency:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.0.0
```

## Usage

Run the generator in your Flutter project:

```bash
dart run ix_icons_generator:generate_icons
```

This will:
- Download all Siemens iX icons from the official npm package
- Create `assets/svg/` directory with SVG files
- Generate `lib/ix_icons.dart` with icon widgets
- Update your `pubspec.yaml` with asset paths

## Command Line Options

```
-p, --project-root    Root directory of the Flutter project (default: current)
-o, --output          Output directory for generated Dart code (default: lib)
-a, --assets          Assets directory for SVG files (default: assets/svg)
-n, --package         Package name for cross-package asset loading
-h, --help            Show help message
```

## Example

```bash
# Generate icons with default settings
dart run ix_icons_generator:generate_icons

# Specify custom output directories
dart run ix_icons_generator:generate_icons -o lib/generated -a assets/icons

# Generate for a library package
dart run ix_icons_generator:generate_icons -n my_package
```

## Using Generated Icons

After generation, import and use the icons:

```dart
import 'package:your_app/ix_icons.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IxIcons.home;
  }
}
```

Icons respect `IconTheme` for size and color:

```dart
IconTheme(
  data: IconThemeData(size: 32, color: Colors.blue),
  child: IxIcons.settings,
)
```

## Related Packages

- [ix_flutter](https://pub.dev/packages/ix_flutter) - Main UI library with themes and widgets

## License

MIT License - See [LICENSE](LICENSE)

Icons are subject to Siemens iX Design System licensing.

---

Developed by [SobSoft](https://sobsoft.sk) – Industrial HMI & Enterprise Software Engineering
