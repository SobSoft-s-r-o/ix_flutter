# ix_icons_generator

Icon generator tool for Siemens iX Design System Flutter icons.

This tool downloads the icons of the official `@siemens/ix-icons` npm package
(1479 icons in the default version 3.5.0) and generates an `IxIconsData`
catalogue for `ix_flutter`'s `IxIcon` widget. Generated code requires
`ix_flutter` 1.1.0 or later.

## Installation

Add to your `pubspec.yaml` as a dev dependency:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

The application or package using the generated catalogue must depend on
`ix_flutter: ^1.1.0` or a later compatible version.

For the generated API replacements available in 1.1.0, see the
[1.1.0 upgrade guide](https://github.com/SobSoft-s-r-o/ix_flutter/blob/main/doc/migration_to_1_1.md).

## Usage

Run the generator in your Flutter project:

```bash
dart run ix_icons_generator:generate_icons
```

This will:
- Download all Siemens iX icons from the official npm package
- Create `assets/svg/` with the SVG files and the upstream `LICENSE.md` and
  `READMEOSS.html`
- Generate `lib/ix_icons.dart` with `IxIconsData` constants
- Update the top-level `flutter.assets` list in `pubspec.yaml`, preserving
  existing entries. Unsupported YAML shapes are reported without writing the
  manifest

Keep both notice files in the generated asset directory when retaining or
redistributing the SVGs. The generator copies their bytes from the selected
`@siemens/ix-icons` version; it refuses a package whose notice files are
missing or empty.

## Command Line Options

```
-p, --project-root    Root directory of the Flutter project (default: current)
-o, --output          Output directory for generated Dart code (default: lib)
-a, --assets          Assets directory for SVG files (default: assets/svg)
-n, --package         Package name for cross-package asset loading
    --icons-version   Version of @siemens/ix-icons to download (default: 3.5.0)
    --[no-]legacy-getters
                      Emit deprecated IxIcons widget getters (default: on)
    --[no-]format     Run `dart format` on the generated file (default: on)
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

# Leave the generated file unformatted (e.g. no `dart` on PATH)
dart run ix_icons_generator:generate_icons --no-format
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

> **Migration note — icon size.** The deprecated getters render an unsized
> `IxIcon`, and `IxIcon` follows the ambient `IconTheme.size` (24 px when
> none is set), so a call site that sized its icon through an enclosing
> `IconTheme`/`IconTheme.merge` — or through a Material slot that does so,
> such as `FilledButton.icon` (18 px) or `InputDecoration.prefixIcon` —
> keeps the size it had. Pass `size:` only where you want to override the
> surrounding slot:
>
> ```dart
> // still 16px, taken from the surrounding IconTheme
> IconTheme.merge(
>   data: const IconThemeData(size: 16),
>   child: const IxIcon(IxIconsData.home),
> )
>
> // 16px regardless of what surrounds it
> const IxIcon(IxIconsData.home, size: IxIconSize.s16)
> ```

The generated file is run through `dart format` by default. Pass `--no-format`
to opt out, for example when no `dart` executable is available on `PATH`.

## Related Packages

- [ix_flutter](https://pub.dev/packages/ix_flutter) - Main UI library with themes and widgets

## License

MIT License - See [LICENSE](LICENSE)

For the generated icons and their required upstream notices, see
[Icon Licensing](ICON_LICENSING.md) and
[Third-Party Notices](THIRD_PARTY_NOTICES.md).

---

Developed by [SobSoft](https://sobsoft.sk) – Industrial HMI & Enterprise Software Engineering
