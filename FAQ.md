# Frequently Asked Questions (FAQ)

Common questions about ix_flutter and how to use it.

## Installation & Setup

### Q: How do I install ix_flutter?

**A:** Add it to your `pubspec.yaml`:

```yaml
dependencies:
   ix_flutter: ^1.0.0
```

Then run `flutter pub get`.

See [GETTING_STARTED.md](GETTING_STARTED.md) for detailed setup instructions.

---

### Q: What are the minimum Flutter and Dart versions?

**A:** 
- Flutter: >=3.10.0
- Dart: >=3.10.0

Run `flutter --version` and `dart --version` to check your versions.

---

### Q: Do I need any additional setup?

**A:** Yes, you must generate icons before using them:

```bash
dart run ix_flutter:generate_icons
```

This downloads icons from the official Siemens source.

---

## Icons & Icon Generation

### Q: Why aren't icons included in the package?

**A:** Due to licensing and distribution restrictions on Siemens iX Design System icons, SVG files cannot be bundled. The generator ensures legal compliance by downloading icons from the official source.

---

### Q: How do I generate icons?

**A:** Run:

```bash
dart run ix_flutter:generate_icons
```

This creates an `ix_icons.dart` file in your `lib/` directory.

---

### Q: What if the icon generator fails?

**A:** Check these common issues:

1. **Node.js/npm not installed**
   ```bash
   node --version
   npm --version
   ```

2. **Network connectivity**
   - Check your internet connection
   - The generator downloads from npm

3. **Permissions issue**
   ```bash
   sudo dart run ix_flutter:generate_icons  # macOS/Linux
   ```

4. **Invalid project structure**
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

**A:** Import the generated file and use the icons:

```dart
import 'package:your_app/ix_icons.dart';

Icon(IxIcons.home)
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
- IxToast (notifications)
- IxPaginationBar
- And more...

See [API_REFERENCE.md](API_REFERENCE.md) for complete list.

---

### Q: How do I use components?

**A:** Import from the main package:

```dart
import 'package:ix_flutter/ix_flutter.dart';

// Use components
IxToast.success(context, message: 'Done!')
```

See [doc/](doc/) for component-specific documentation.

---

### Q: Can I customize component styles?

**A:** Yes, through:
1. **Theme system** - Use `IxTheme`
2. **Widget parameters** - Most components accept styling params
3. **Override theme** - Create custom theme based on `IxTheme`

See [doc/copilot_colors.md](doc/copilot_colors.md) for color tokens.

---

## Theming

### Q: How do I apply a theme?

**A:**

```dart
MaterialApp(
  theme: IxTheme.lightTheme,
  darkTheme: IxTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

---

### Q: Can I create a custom theme?

**A:** Yes, extend `IxTheme`:

```dart
final customTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
  ),
  // ... customize
);

MaterialApp(
  theme: customTheme,
)
```

---

### Q: What colors are available?

**A:** See [doc/copilot_colors.md](doc/copilot_colors.md) for the complete color system.

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

**A:** MIT License for the code. See [LICENSE](LICENSE).

Icons have separate licensing. See [ICON_LICENSING.md](ICON_LICENSING.md).

---

### Q: Can I use this commercially?

**A:** Yes, under MIT License terms. However:
- Review the [LICENSE](LICENSE) file
- Ensure Siemens iX icon compliance
- See [ICON_LICENSING.md](ICON_LICENSING.md) for icon terms

---

### Q: Is this an official Siemens product?

**A:** No. This is a community-maintained adaptation of the Siemens iX Design System for Flutter. It is not affiliated with, endorsed by, or maintained by Siemens AG.

---

### Q: Can I use Siemens iX icons?

**A:** Yes, but you must:
1. Generate them using our tool
2. Comply with Siemens iX licensing
3. Provide proper attribution
4. See [ICON_LICENSING.md](ICON_LICENSING.md)

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
1. Generate icons: `dart run ix_flutter:generate_icons`
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
flutter pub upgrade ix_flutter
dart run ix_flutter:generate_icons  # Regenerate icons if needed
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
   dart run ix_flutter:generate_icons --package my_library_name
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
dart run ix_flutter:generate_icons
flutter run
```

---

### Q: How do I learn more about Siemens iX?

**A:** Visit official resources:
- https://ix.siemens.io
- https://ix.siemens.io/docs/
- https://ix.siemens.io/docs/guidelines/

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

**Last Updated**: January 2026
**Package Version**: 1.0.0

Thank you for using ix_flutter! 🎉
