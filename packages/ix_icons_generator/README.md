# ix_icons_generator

Icon generator tool for Siemens iX Design System Flutter icons.

This tool downloads the icons of the official `@siemens/ix-icons` npm package (1479 icons in the default version 3.5.0) and generates an `IxIconsData` catalogue for `ix_flutter`'s `IxIcon` widget.

## Installation

Add to your `pubspec.yaml` as a dev dependency:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

## Usage

Run the generator in your Flutter project:

```bash
dart run ix_icons_generator:generate_icons
```

This will:
- Download all Siemens iX icons from the official npm package
- Create `assets/svg/` directory with SVG files
- Generate `lib/ix_icons.dart` with `IxIconsData` constants
- Update your `pubspec.yaml` with asset paths

## Command Line Options

```
-p, --project-root    Root directory of the Flutter project (default: current)
-o, --output          Output directory for generated Dart code (default: lib)
-a, --assets          Assets directory for SVG files (default: assets/svg)
-n, --package         Package name for cross-package asset loading
    --icons-version   Version of @siemens/ix-icons to download (default: 3.5.0)
    --[no-]legacy-getters
                      Emit deprecated IxIcons widget getters (default: on)
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

# Pin a specific icon set version and skip the deprecated widget getters
dart run ix_icons_generator:generate_icons --icons-version 3.5.0 --no-legacy-getters
```

## Using Generated Icons

After generation, import and use the icons:

```dart
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const IxIcon(IxIconsData.home);
  }
}
```

Size and color are set on the widget itself:

```dart
IxIcon(
  IxIconsData.settings,
  size: IxIconSize.s32,
  color: Colors.blue,
)
```

The generated file also contains an `IxIcons` class with deprecated widget
getters (`IxIcons.home`) so existing code keeps compiling. They are removed in
generator 2.0 — migrate to `IxIcon(IxIconsData.home)`, or generate without them
using `--no-legacy-getters`.

The generated file is not run through `dart format`; if your project checks
formatting, run `dart format lib/ix_icons.dart` after generating.

## Related Packages

- [ix_flutter](https://pub.dev/packages/ix_flutter) - Main UI library with themes and widgets

## License

MIT License - See [LICENSE](LICENSE)

Icons are subject to Siemens iX Design System licensing.

---

Developed by [SobSoft](https://sobsoft.sk) – Industrial HMI & Enterprise Software Engineering
