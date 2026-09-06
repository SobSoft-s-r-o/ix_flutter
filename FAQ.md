# Frequently Asked Questions (FAQ)

Common questions about ix_flutter and how to use it.

## Installation & Setup

### Q: How do I install ix_flutter?

**A:** Add it to your `pubspec.yaml`:

```yaml
dependencies:
  ix_flutter: ^1.1.0
```

Then run `flutter pub get`.

See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed setup instructions.

---

### Q: What are the minimum Flutter and Dart versions?

**A:** 
- Flutter: >=3.38.0
- Dart: >=3.10.0

Run `flutter --version` and `dart --version` to check your versions.

The Flutter floor rose from 3.10.0 in 1.0.2 to 3.38.0 for the upcoming 1.1.0,
because the semantics APIs the menu, toast, dropdown and data-view roles are
built on (`SemanticsRole.*`, `SemanticsService.sendAnnouncement`) only exist
from 3.38. The Dart floor is unchanged. An app that cannot move off an older
Flutter stays on 1.0.2 -- `pub` will not resolve 1.1.0 for it.

---

### Q: Do I need any additional setup?

**A:** No. `ix_flutter` widgets render their own icons out of the box (falling back to Material glyphs today; see [doc/ix_icons.md](doc/ix_icons.md#fallback-policy)). Only add the optional `ix_icons_generator` dev dependency if your own code needs the full Siemens iX icon catalogue:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

```bash
dart run ix_icons_generator:generate_icons            # default: @siemens/ix-icons 3.5.0
```

---

## Icons & Icon Generation

### Q: Why aren't icons included in the package?

**A:** The library's own widgets need only a small, fixed set — 28 keys,
enumerated in `IxIconKey`. Once the LEGAL REVIEW gate documented in
[UPSTREAM.md](UPSTREAM.md) is passed, the library will bundle that minimal
internal set; until then its widgets fall back to Material glyphs through
`IxIconResolver.material()` (see
[doc/ix_icons.md](doc/ix_icons.md#fallback-policy)). The full 1 479-icon
catalogue is optional either way and generated into your own app by
`ix_icons_generator`, which downloads it from the official `@siemens/ix-icons`
npm source.

---

### Q: How do I generate icons?

**A:** Run:

```bash
dart run ix_icons_generator:generate_icons
```

This creates an `ix_icons.dart` file in your `lib/` directory.

---

### Q: What if the icon generator fails?

**A:** Check these common issues:

1. **Network connectivity**
   - Check your internet connection and access to `https://registry.npmjs.org`
   - Check proxy/firewall settings if you're behind one

2. **Invalid project structure**
   - Make sure you're in your app directory
   - Check that `lib/` folder exists

See [doc/ix_icons.md](doc/ix_icons.md) for more troubleshooting.

---

### Q: How often do I need to generate icons?

**A:** Once per project, unless:
- You update the package
- You want the latest icons
- Icons fail to generate

The generated files are static assets.

---

### Q: Can I customize the generated icons?

**A:** Yes! After generation, the SVG files are in your `assets/` directory. You can:
- Edit SVG files directly
- Change colors
- Resize icons
- Add custom icons

---

### Q: How do I use icons in my app?

**A:** Import the generated file and pass its constants to `IxIcon`:

```dart
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';

Widget catalogueIcon() => const IxIcon(IxIconsData.home);
```

See [doc/ix_icons.md](doc/ix_icons.md) for complete usage.

---

## Components & Usage

### Q: What components are included?

**A:** Main components:
- IxApplicationScaffold
- IxBreadcrumb
- IxBlind (sliding panel)
- IxDropdownButton
- IxEmptyState
- IxResponsiveDataView
- IxToastService / IxToastOverlay (notifications)
- IxPaginationBar
- IxSpinner
- IxIcon / IxIconButton

See [API_REFERENCE.md](API_REFERENCE.md) for complete list.

---

### Q: How do I use components?

**A:** Import the single barrel and use the widgets directly:

```dart
import 'package:ix_flutter/ix_flutter.dart';
```

See [doc/](doc/) for component-specific documentation, and
[API_REFERENCE.md](API_REFERENCE.md) for the index.

---

### Q: Can I customize component styles?

**A:** Yes, through:
1. **Theme extensions** - every component reads its own `ThemeExtension`
   (`IxButtonTheme`, `IxBreadcrumbTheme`, `IxSpinnerTheme`, ...), which
   `IxThemeBuilder` registers
2. **Widget parameters** - most components accept styling parameters directly
3. **Custom palette** - `IxCustomPalette.partial` overrides individual color
   tokens

See [doc/theming.md](doc/theming.md) for the theme model and [doc/tokens.md](doc/tokens.md) for every color token.

---

## Theming

### Q: How do I apply a theme?

**A:** Build one `ThemeData` per brightness with `IxThemeBuilder`:

```dart
Widget systemThemedApp() => MaterialApp(
  theme: const IxThemeBuilder.light().build(),
  darkTheme: const IxThemeBuilder.dark().build(),
  themeMode: ThemeMode.system, // Uses device setting
  home: const HomePage(),
);
```

To switch themes at runtime, use `IxThemeController` — see
[doc/theming.md](doc/theming.md).

---

### Q: Can I create a custom theme?

**A:** Yes. Override individual color tokens with `IxCustomPalette` and hand
the result to `IxThemeBuilder` or `IxThemeController`:

```dart
IxThemeController controllerWithBrandPrimary() {
  final palette = IxCustomPalette.partial(
    light: {IxThemeColorToken.primary: const Color(0xFF0050F5)},
    dark: {IxThemeColorToken.primary: const Color(0xFF82A0FF)},
  );

  return IxThemeController(customPalette: palette);
}
```

---

### Q: What colors are available?

**A:** [doc/tokens.md](doc/tokens.md) lists every `IxThemeColorToken` with its light and dark value; it is generated from the palettes the package ships.

---

## Development & Contributing

### Q: How do I contribute to ix_flutter?

**A:** See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code style
- Testing requirements
- Pull request process

---

### Q: Can I report bugs?

**A:** Yes! Open an issue on GitHub with:
- Description
- Steps to reproduce
- Expected vs. actual behavior
- Environment details (Flutter version, OS, etc.)

---

### Q: How do I suggest features?

**A:** Open an issue with:
- Feature description
- Use case
- Proposed implementation (optional)

---

## Licensing & Legal

### Q: What license is this package under?

**A:** MIT License for the code. See [LICENSE](packages/ix_flutter/LICENSE).

Icons have separate licensing. See
[ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md).

---

### Q: Can I use this commercially?

**A:** Yes, under MIT License terms. However:
- Review the [LICENSE](packages/ix_flutter/LICENSE) file
- Ensure Siemens iX icon compliance
- See [ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) for icon terms

---

### Q: Is this an official Siemens product?

**A:** No. This is a community-maintained adaptation of the Siemens iX Design System for Flutter. It is not affiliated with, endorsed by, or maintained by Siemens AG.

---

### Q: Can I use Siemens iX icons?

**A:** Yes:
1. `ix_flutter`'s own widgets already use them — no generator needed. They render as Material glyphs today; once the LEGAL REVIEW gate documented in [UPSTREAM.md](UPSTREAM.md) is passed, the library bundles a minimal internal set (28 icons) with an MIT notice.
2. For the full 1 479-icon catalogue in your own code, running the optional `ix_icons_generator` (`dart run ix_icons_generator:generate_icons`) is up to you.
3. `@siemens/ix-icons` is MIT-licensed: redistribution keeps the copyright/permission notice and `READMEOSS.html`. Siemens trademarks and brand guidelines are separate from the MIT license.
4. See [ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) for details.

---

## Troubleshooting

### Q: I'm getting import errors

**A:** 
1. Make sure you've run `flutter pub get`
2. Verify the import is correct:
   ```dart
   import 'package:ix_flutter/ix_flutter.dart';
   ```
3. Check your pubspec.yaml has the dependency

---

### Q: Icons aren't showing up

**A:**
1. Generate icons: `dart run ix_icons_generator:generate_icons`
2. Make sure you import the generated file:
   ```dart
   import 'package:your_app/ix_icons.dart';
   ```
3. Verify icon assets are in `assets/`
4. Rebuild the app: `flutter clean && flutter pub get`

---

### Q: Components look different than expected

**A:**
1. Check if theme is properly applied
2. Verify device is using correct theme (light/dark)
3. Compare with [example/](example/) app
4. Check documentation for component defaults

---

### Q: Build fails with "Cannot find package"

**A:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub cache repair
flutter pub get

# Then try building again
flutter build web  # or android, ios, etc.
```

---

### Q: How do I update to a newer version?

**A:**
```bash
flutter pub upgrade ix_flutter ix_icons_generator
dart run ix_icons_generator:generate_icons  # Regenerate icons if needed
```

---

## Performance & Optimization

### Q: Is ix_flutter performant?

**A:** Yes. It uses:
- Flutter's built-in optimization
- Efficient widget composition
- Responsive design patterns

For large data sets, use pagination (IxPaginationBar).

---

### Q: Does it support web, iOS, and Android?

**A:** Yes! ix_flutter works on:
- Web (Flutter Web)
- Android
- iOS
- macOS (with flutter desktop support)
- Linux (with flutter desktop support)
- Windows (with flutter desktop support)

---

### Q: Can I use it in a library package?

**A:** Yes, but:
1. Generate icons with `--package` flag:
   ```bash
   dart run ix_icons_generator:generate_icons --package my_library_name
   ```
2. Include generated files in your library
3. Document icon usage for library consumers

---

## Examples & Resources

### Q: Where are the examples?

**A:** Check:
- [example/](example/) - Complete example app
- [GETTING_STARTED.md](GETTING_STARTED.md) - Tutorial
- [API_REFERENCE.md](API_REFERENCE.md) - API documentation
- [doc/](doc/) - Component documentation

---

### Q: Is there an example app I can run?

**A:** Yes!

```bash
cd example
flutter pub get
dart run ix_icons_generator:generate_icons
flutter run
```

---

### Q: How do I learn more about Siemens iX?

**A:** Visit official resources:
- https://ix.siemens.io
- https://ix.siemens.io/docs/home/overview
- https://ix.siemens.io/docs/guidelines/overview

---

## Getting Help

### Q: Where can I get help?

**A:**

1. **Documentation**: [doc/](doc/) folder
2. **Getting Started**: [GETTING_STARTED.md](GETTING_STARTED.md)
3. **API Reference**: [API_REFERENCE.md](API_REFERENCE.md)
4. **Issues**: [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
5. **Discussions**: [GitHub Discussions](https://github.com/SobSoft-s-r-o/ix_flutter/discussions)

---

### Q: How do I report a security issue?

**A:** See [SECURITY.md](SECURITY.md) for responsible disclosure procedures.

---

### Q: Can I contact the maintainers?

**A:** Open an issue or discussion on GitHub. For security issues, see [SECURITY.md](SECURITY.md).

---

## Still Have Questions?

- **Read the docs** - Most answers are in [doc/](doc/)
- **Check examples** - See [example/](example/)
- **Search issues** - Your question might be answered
- **Open a discussion** - Ask on GitHub Discussions
- **Report a bug** - If something's broken, create an issue

---

Thank you for using ix_flutter! 🎉
