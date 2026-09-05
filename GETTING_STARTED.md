# Getting Started with ix_flutter

Complete guide to get started with the ix_flutter component library.

## Table of Contents

1. [Installation](#installation)
2. [Basic Setup](#basic-setup)
3. [Icon Setup](#icon-setup)
4. [Using Components](#using-components)
5. [Theming](#theming)
6. [Common Tasks](#common-tasks)
7. [Next Steps](#next-steps)

## Installation

### Prerequisites

Flutter SDK 3.44.6 (stable) or later — the version this package is developed and tested against.

### Step 1: Add Dependency

Add `ix_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ix_flutter: ^1.1.0
```

Or add it with the Flutter CLI instead of editing `pubspec.yaml` by hand:

```bash
flutter pub add ix_flutter
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Verify Installation

```bash
flutter pub get
flutter analyze
```

---

## Basic Setup

### Minimal App Setup

Create your app with ix_flutter theming. `IxThemeBuilder.light()`/`.dark()` each
build one `ThemeData`; `MaterialApp` picks between them:

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My ix_flutter App',
      theme: const IxThemeBuilder.light().build(),
      darkTheme: const IxThemeBuilder.dark().build(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: const Center(child: Text('Hello from ix_flutter!')),
    );
  }
}
```

---

## Icon Setup

### Icons Work Out of the Box

`ix_flutter` widgets render their own icons without any setup (falling back to Material glyphs today — see [doc/ix_icons.md](doc/ix_icons.md#fallback-policy)). The steps below are only needed if your own code wants icons from the full 1 479-icon Siemens iX catalogue.

### Step 1: Add the Generator

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

Or:

```bash
dart pub add --dev ix_icons_generator
```

### Step 2: Generate Icons

```bash
dart run ix_icons_generator:generate_icons            # default: @siemens/ix-icons 3.5.0
```

This command:
- Downloads the pinned `@siemens/ix-icons` release from the official npm package
- Writes SVG assets into your assets directory (default `assets/svg/`)
- Generates an `ix_icons.dart` file with `IxIconsData` constants in your app

### Step 3: Verify Generation

Check that `lib/ix_icons.dart` was created:

```bash
ls lib/ix_icons.dart  # Should exist
```

### Step 4: Use Icons in Your App

```dart
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';

class MyIconWidget extends StatelessWidget {
  const MyIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const IxIcon(IxIconsData.home, size: IxIconSize.s24);
  }
}
```

`IxIcon` never reads an ambient `IconTheme.size`, so always pass `size:`
explicitly.

### Troubleshooting Icon Generation

**Problem**: Command not found
```bash
# Make sure you're in the app directory
cd my_app
dart run ix_icons_generator:generate_icons
```

**Problem**: Generator fails to download icons
```bash
# Check your internet connection and access to the npm registry
curl -I https://registry.npmjs.org
```

See [doc/ix_icons.md](doc/ix_icons.md) for more troubleshooting.

---

## Using Components

### Example 1: Dropdown Button

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class DropdownExample extends StatefulWidget {
  const DropdownExample({super.key});

  @override
  State<DropdownExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<String>(
      label: selectedOption,
      items: const [
        IxDropdownMenuItem(label: 'Option 1', value: 'Option 1'),
        IxDropdownMenuItem(label: 'Option 2', value: 'Option 2'),
        IxDropdownMenuItem(label: 'Option 3', value: 'Option 3'),
      ],
      onItemSelected: (value) {
        setState(() => selectedOption = value);
      },
    );
  }
}
```

See [doc/ix_dropdown_button.md](doc/ix_dropdown_button.md) for placements,
checked items and the keyboard model.

### Example 2: Toast Notifications

Toasts are shown through an `IxToastService` and rendered by an
`IxToastOverlay` in your `MaterialApp.builder` — see
[doc/ix_toast.md](doc/ix_toast.md) for the full setup.

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class ToastExample extends StatelessWidget {
  const ToastExample({super.key, required this.toasts});

  final IxToastService toasts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: () {
            toasts.show(
              type: IxToastType.success,
              message: 'Action completed successfully!',
            );
          },
          child: const Text('Show Success'),
        ),
        FilledButton(
          onPressed: () {
            toasts.show(type: IxToastType.error, message: 'An error occurred!');
          },
          child: const Text('Show Error'),
        ),
      ],
    );
  }
}
```

### Example 3: Empty State

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class EmptyListView extends StatelessWidget {
  const EmptyListView({super.key, required this.onContinueShopping});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return IxEmptyState(
      icon: const Icon(Icons.shopping_cart_outlined, size: 32),
      title: 'Your cart is empty',
      subtitle: 'Add some items to get started',
      primaryAction: FilledButton(
        onPressed: onContinueShopping,
        child: const Text('Continue Shopping'),
      ),
    );
  }
}
```

### Example 4: Responsive Data View

`IxResponsiveDataView` renders a table on wide screens and cards on narrow
ones, from one set of definitions:

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// One row of the data view example below.
class Person {
  const Person({required this.name, required this.email, required this.active});

  final String name;
  final String email;
  final bool active;
}

class DataViewExample extends StatelessWidget {
  const DataViewExample({super.key, required this.people});

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    return IxResponsiveDataView<Person>(
      items: people,
      desktopColumns: [
        IxColumnDef(
          label: 'Name',
          cellBuilder: (context, person) => Text(person.name),
        ),
        IxColumnDef(
          label: 'Email',
          cellBuilder: (context, person) => Text(person.email),
        ),
        IxColumnDef(
          label: 'Status',
          cellBuilder: (context, person) =>
              Text(person.active ? 'Active' : 'Inactive'),
        ),
      ],
      mobileFields: [
        IxMobileFieldDef(
          label: 'Name',
          valueBuilder: (context, person) => Text(person.name),
        ),
        IxMobileFieldDef(
          label: 'Email',
          valueBuilder: (context, person) => Text(person.email),
        ),
      ],
      rowActions: const [],
    );
  }
}
```

See [doc/ix_responsive_data_view.md](doc/ix_responsive_data_view.md) for
sorting, pagination, search and localization.

---

## Theming

### Light and Dark Themes

```dart
(ThemeData light, ThemeData dark) buildThemes() =>
    (const IxThemeBuilder.light().build(), const IxThemeBuilder.dark().build());
```

### System Theme (Auto Light/Dark)

```dart
Widget systemThemedApp() => MaterialApp(
  theme: const IxThemeBuilder.light().build(),
  darkTheme: const IxThemeBuilder.dark().build(),
  themeMode: ThemeMode.system, // Uses device setting
  home: const HomePage(),
);
```

To change the theme at runtime (including `IxColorSchema.system`), use
`IxThemeController` — see [doc/theming.md](doc/theming.md).

### Access Theme Colors

Every built theme carries an `IxTheme` extension with the resolved palette:

```dart
Color primaryToken(BuildContext context) {
  final ixTheme = IxTheme.of(context);
  return ixTheme.palette[IxThemeColorToken.primary]!;
}
```

The complete token list is in [doc/tokens.md](doc/tokens.md).

---

## Common Tasks

### Task 1: Add the Application Scaffold

```dart
class MyAppShell extends StatelessWidget {
  const MyAppShell({super.key, required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return IxApplicationScaffold(
      appTitle: 'My App',
      entries: const [
        IxMenuEntry(
          id: 'home',
          label: 'Home',
          icon: Icons.home,
          type: IxMenuEntryType.item,
        ),
      ],
      onNavigate: onNavigate,
      body: const Center(child: Text('Content here')),
    );
  }
}
```

See [doc/ix_application_scaffold.md](doc/ix_application_scaffold.md) for
categories, built-in settings/about panels and the theme toggle.

### Task 2: Handle Navigation

```dart
Widget breadcrumbNavigation(ValueChanged<String> go) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: '/',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Settings', breadcrumbKey: '/settings'),
  ],
  onItemClick: (click) => go(click.breadcrumbKey),
);
```

### Task 3: Display a Loading State

```dart
class LoadingExample extends StatelessWidget {
  const LoadingExample({super.key, required this.load});

  final Future<void> Function() load;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: IxSpinner());
        }
        return const Text('Data loaded!');
      },
    );
  }
}
```

---

## Next Steps

### Learn More

1. **Check the Examples**: Browse [example/](example/) for a complete working app
2. **Read Component Docs**: See [doc/](doc/) for detailed component documentation
3. **API Reference**: Review [API_REFERENCE.md](API_REFERENCE.md)
4. **Icon Guide**: Learn about icons in [doc/ix_icons.md](doc/ix_icons.md)

### Best Practices

- ✅ Only run the icon generator if you need the full iX icon catalogue
- ✅ Build themes with `IxThemeBuilder`, and switch them with `IxThemeController`
- ✅ Read colors from `IxTheme.of(context).palette` instead of hard-coding them
- ✅ Follow Siemens iX design guidelines
- ✅ Test on multiple screen sizes and with a large text scale
- ✅ Wrap the app in `IxDensityScope` so hit areas follow the input modality

### Resources

- **Siemens iX**: https://ix.siemens.io
- **Icon Library**: https://ix.siemens.io/docs/icons/icon-library
- **Design Guidelines**: https://ix.siemens.io/docs/guidelines/overview
- **Example App**: [example/](example/)

### Get Help

- 📖 **Documentation**: Check the [doc/](doc/) folder
- 🐛 **Report Issues**: [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
- 💬 **Ask Questions**: [GitHub Discussions](https://github.com/SobSoft-s-r-o/ix_flutter/discussions)
- 📝 **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Happy coding with ix_flutter!** 🚀

Version history is in
[packages/ix_flutter/CHANGELOG.md](packages/ix_flutter/CHANGELOG.md).
