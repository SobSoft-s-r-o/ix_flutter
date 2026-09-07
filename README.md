# ix_flutter

[![CI](https://github.com/SobSoft-s-r-o/ix_flutter/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/SobSoft-s-r-o/ix_flutter/actions/workflows/ci.yml)
[![Version Bump](https://github.com/SobSoft-s-r-o/ix_flutter/actions/workflows/version-bump.yml/badge.svg?branch=main)](https://github.com/SobSoft-s-r-o/ix_flutter/actions/workflows/version-bump.yml)
[![Pub Version](https://img.shields.io/pub/v/ix_flutter.svg)](https://pub.dev/packages/ix_flutter)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](packages/ix_flutter/LICENSE)

A Flutter component library that implements the Siemens iX Design System.

## Packages

This repository contains two packages:

| Package | pub.dev | Description |
|---------|---------|-------------|
| [ix_flutter](packages/ix_flutter/) | [![Pub](https://img.shields.io/pub/v/ix_flutter.svg)](https://pub.dev/packages/ix_flutter) | Main UI component library |
| [ix_icons_generator](packages/ix_icons_generator/) | [![Pub](https://img.shields.io/pub/v/ix_icons_generator.svg)](https://pub.dev/packages/ix_icons_generator) | Icon generator CLI tool |

> ⚠️ **Important Disclaimer**: This is an **independent, community-maintained** adaptation of the Siemens iX Design System for Flutter. It is **NOT** developed, maintained, or endorsed by Siemens AG. See [LICENSE](packages/ix_flutter/LICENSE), [ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md), and [THIRD_PARTY_NOTICES.md](packages/ix_flutter/THIRD_PARTY_NOTICES.md) for complete legal information.

## Screenshots

![Theme configuration and token overview, classic dark](packages/ix_flutter/screenshots/overview_dark.png)

*Theme configuration and token overview (classic dark, bundled Work Sans typography)*

![Buttons: variants and states, classic light](packages/ix_flutter/screenshots/components_light.png)

*Buttons, variants and states (classic light)*

## Overview

`ix_flutter` provides Flutter widgets and components that implement the Siemens iX Design System, enabling developers to build consistent, professional applications that follow Siemens design guidelines.

This package brings the design patterns, components, and visual language from [Siemens iX](https://ix.siemens.io) to Flutter applications.

## Features

- 🎨 **Siemens iX theme system** - `IxThemeBuilder` and `IxThemeController` for light, dark and system color schemas
- 🧩 **UI components** - application shell, breadcrumb, blind, dropdown, data view, toasts, spinner, empty state
- 🎯 **1 479 icons** - full Siemens iX icon catalogue via the optional `ix_icons_generator`
- 📱 **Responsive design** - components adapt to different screen sizes
- ♿ **Accessibility** - semantics, keyboard navigation and WCAG-sized hit areas ([doc/density.md](doc/density.md))

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  ix_flutter: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Using Siemens iX icons

`ix_flutter` widgets render their own icons out of the box (falling back to Material glyphs today; see [doc/ix_icons.md](doc/ix_icons.md#fallback-policy)) — no generator required. The optional `ix_icons_generator` tool adds the full 1 479-icon Siemens iX catalogue to your own app.

1. Add the generator to your `pubspec.yaml`:

```yaml
dev_dependencies:
  ix_icons_generator: ^1.1.0
```

2. Generate the icons:

```bash
dart run ix_icons_generator:generate_icons            # default: @siemens/ix-icons 3.5.0
```

3. Use them in your code:

```dart
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';

Widget catalogueIcon() => const IxIcon(IxIconsData.home);
```

**See [doc/ix_icons.md](doc/ix_icons.md) for the complete icon guide** (internal icons, fallback policy, licensing).

## Getting started

### 1. Build your theme

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siemens iX Demo',
      theme: const IxThemeBuilder.light().build(),
      darkTheme: const IxThemeBuilder.dark().build(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
```

To switch themes at runtime, use `IxThemeController` — see [doc/theming.md](doc/theming.md).

### 2. Use iX components

Material buttons pick up the iX styling from the theme; `IxButtonTheme.style(...)` selects a Siemens iX button variant.

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:your_app/ix_icons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = Theme.of(context).extension<IxButtonTheme>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        leading: const IxIcon(IxIconsData.menu),
      ),
      body: Column(
        children: [
          FilledButton(
            style: buttons?.style(IxButtonVariant.primary),
            onPressed: () {},
            child: const Text('Primary Action'),
          ),
          FilledButton(
            style: buttons?.style(IxButtonVariant.secondary),
            onPressed: () {},
            child: const Text('Secondary Action'),
          ),
        ],
      ),
    );
  }
}
```

Every Dart snippet in this repository's documentation is compiled in
[doc/snippets](doc/snippets), so it always matches the current API.

## Documentation

| Topic | Page |
|---|---|
| Step-by-step setup | [GETTING_STARTED.md](GETTING_STARTED.md) |
| API index and `dart doc` | [API_REFERENCE.md](API_REFERENCE.md) |
| Documentation map | [DOCUMENTATION.md](DOCUMENTATION.md) |
| Themes, color schemas, custom palettes | [doc/theming.md](doc/theming.md) |
| Color tokens (generated table) | [doc/tokens.md](doc/tokens.md) |
| Typography | [doc/typography.md](doc/typography.md) |
| Density and `IxIconButton` | [doc/density.md](doc/density.md) |
| Icons | [doc/ix_icons.md](doc/ix_icons.md) |
| Application scaffold | [doc/ix_application_scaffold.md](doc/ix_application_scaffold.md) |
| Blind (collapsible panel) | [doc/ix_blind.md](doc/ix_blind.md) |
| Breadcrumb | [doc/ix_breadcrumb.md](doc/ix_breadcrumb.md) |
| Dropdown button | [doc/ix_dropdown_button.md](doc/ix_dropdown_button.md) |
| Empty state | [doc/ix_empty_state.md](doc/ix_empty_state.md) |
| Responsive data view and pagination | [doc/ix_responsive_data_view.md](doc/ix_responsive_data_view.md) |
| Spinner | [doc/ix_spinner.md](doc/ix_spinner.md) |
| Toasts | [doc/ix_toast.md](doc/ix_toast.md) |
| Upstream baseline (`@siemens/ix` versions) | [UPSTREAM.md](UPSTREAM.md) |

## Example

Check out the [example](example/) directory for a complete working application demonstrating all components.

To run the example:

```bash
cd example
flutter pub get

# The example ships with pre-generated icons (example/lib/ix_icons.dart
# and its assets), so this step is optional -- run it only to
# regenerate them, e.g. against a different @siemens/ix-icons version.
# dart run ix_icons_generator:generate_icons

flutter run
```

## Icon generator tool

`ix_icons_generator` is an optional dev dependency that downloads the full Siemens iX icon catalogue (1 479 icons in the pinned `3.5.0` release) from the official `@siemens/ix-icons` npm package and generates `IxIconsData` constants for `ix_flutter`'s `IxIcon` widget.

```bash
# Basic usage
dart run ix_icons_generator:generate_icons            # default: @siemens/ix-icons 3.5.0

# Custom paths, pinned version
dart run ix_icons_generator:generate_icons --icons-version 3.5.0 -a assets/ix_icons

# For library packages
dart run ix_icons_generator:generate_icons --package my_library_name

# Show help
dart run ix_icons_generator:generate_icons --help
```

See [ix_icons_generator](packages/ix_icons_generator/) for complete generator documentation.

## Platform support

| Platform | Supported |
|----------|-----------|
| Android  | ✅         |
| iOS      | ✅         |
| Web      | ✅         |
| macOS    | ✅         |
| Windows  | ✅         |
| Linux    | ✅         |

## Requirements

- Flutter SDK: >=3.38.0
- Dart SDK: >=3.10.0

CI builds and tests against the pinned Flutter 3.44.6 (stable).

## Important legal notice

### Trademark and attribution

- **Siemens iX Design System** is owned and maintained by Siemens AG
- This package is an **independent community adaptation**, not an official Siemens product
- Not developed, maintained, or endorsed by Siemens
- Siemens® and Siemens iX™ are trademarks of Siemens AG

For official Siemens iX resources, visit: https://ix.siemens.io

### Icon licensing

`@siemens/ix-icons` is MIT-licensed (Copyright (c) 2022 Siemens AG); see [UPSTREAM.md](UPSTREAM.md) for the exact version, tag, commit and tarball checksum:

1. Once the LEGAL REVIEW gate documented in `UPSTREAM.md` is passed, the library will bundle a minimal internal set (28 icons) required by its own widgets; until then library widgets fall back to Material glyphs through `IxIconResolver.material()`.
2. The full catalogue is optional and generated into your app from the official `@siemens/ix-icons` npm package with the `ix_icons_generator` tool.
3. Redistribution keeps the MIT copyright/permission notice and `READMEOSS.html`; Siemens trademarks and brand guidelines are separate from the MIT copyright license.

See [ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) and [THIRD_PARTY_NOTICES.md](packages/ix_flutter/THIRD_PARTY_NOTICES.md) for the complete licensing information.

## License

This package is licensed under the MIT License. See [LICENSE](packages/ix_flutter/LICENSE) for details.

**Important**: Icons and design patterns are subject to separate licensing terms. See [ICON_LICENSING.md](packages/ix_flutter/ICON_LICENSING.md) for details.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for the development setup, coding style, test conventions and the release checklist.

```bash
# Clone repository
git clone https://github.com/SobSoft-s-r-o/ix_flutter.git
cd ix_flutter

# Install dependencies and run the library's tests
cd packages/ix_flutter
flutter pub get
flutter test

# Run the example app
cd ../../example
flutter pub get
dart run ix_icons_generator:generate_icons
flutter run
```

## Resources

### Official Siemens iX Design System
- **Website**: https://ix.siemens.io
- **Documentation**: https://ix.siemens.io/docs/home/overview
- **Icon Library**: https://ix.siemens.io/docs/icons/icon-library
- **Design Guidelines**: https://ix.siemens.io/docs/guidelines/overview

### This package
- **Changelog**: [packages/ix_flutter/CHANGELOG.md](packages/ix_flutter/CHANGELOG.md)
- **Security policy**: [SECURITY.md](SECURITY.md)
- **Issues**: [Report a bug](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
- **Discussions**: [Ask a question](https://github.com/SobSoft-s-r-o/ix_flutter/discussions)
- **Maintainer**: SobSoft (https://sobsoft.sk)

### Sponsorship

Support the development of this package! ❤️

[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?style=for-the-badge&logo=github)](https://github.com/sponsors/SobSoft-s-r-o)

Your sponsorship helps maintain and improve ix_flutter. [Become a sponsor](https://github.com/sponsors/SobSoft-s-r-o) or use the **Sponsor** button at the top of the repository.

### Commercial support

For paid support, consulting, or custom development services, contact SobSoft:

📧 **[Contact Form](https://sobsoft.sk/en/contact)**

We offer professional services including:
- Custom component development
- Migration assistance
- Integration support
- Training and consulting

---

**Community Project Notice**: This package is maintained by the community and is not affiliated with Siemens. For official Siemens iX resources, visit https://ix.siemens.io

**Disclaimer**: This is not an official Siemens product. This library is developed independently and provides Flutter implementations of Siemens iX Design System patterns. Always ensure compliance with Siemens licensing terms when using iX design assets.

---

Developed by [SobSoft](https://sobsoft.sk) – Industrial HMI & Enterprise Software Engineering
