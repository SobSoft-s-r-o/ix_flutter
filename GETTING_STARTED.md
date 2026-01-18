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

### Step 1: Add Dependency

Add `ix_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ix_flutter: ^1.0.0  # Latest version
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

Create your app with ix_flutter theming:

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My ix_flutter App',
      theme: IxTheme.lightTheme,
      darkTheme: IxTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: const Center(
        child: Text('Hello from ix_flutter!'),
      ),
    );
  }
}
```

---

## Icon Setup

### Important: Icon Generation Required

**⚠️ Icons are NOT bundled with this package.** You must generate them separately.

### Step 1: Generate Icons

```bash
dart run ix_flutter:generate_icons
```

This command:
- Downloads icons from the official Siemens source
- Converts them to Flutter-compatible format
- Generates an `ix_icons.dart` file in your app

### Step 2: Verify Generation

Check that `lib/ix_icons.dart` was created:

```bash
ls lib/ix_icons.dart  # Should exist
```

### Step 3: Use Icons in Your App

```dart
import 'package:your_app/ix_icons.dart';  // Generated file
import 'package:flutter/material.dart';

class MyIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      IxIcons.home,
      size: 24.0,
    );
  }
}
```

### Troubleshooting Icon Generation

**Problem**: Command not found
```bash
# Make sure you're in the app directory
cd my_app
dart run ix_flutter:generate_icons
```

**Problem**: Permission denied
```bash
# On Linux/Mac, you may need sudo
sudo dart run ix_flutter:generate_icons
```

**Problem**: Icons not found
```bash
# Check if Node.js and npm are installed
node --version
npm --version

# Verify npm package is available
npm view @siemens/ix-icons
```

See [doc/ix_icons.md](doc/ix_icons.md) for more troubleshooting.

---

## Using Components

### Example 1: Simple Dropdown

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class DropdownExample extends StatefulWidget {
  @override
  State<DropdownExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<DropdownExample> {
  String? selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<String>(
      value: selectedOption,
      items: [
        DropdownMenuItem(
          value: 'Option 1',
          child: Text('Option 1'),
        ),
        DropdownMenuItem(
          value: 'Option 2',
          child: Text('Option 2'),
        ),
        DropdownMenuItem(
          value: 'Option 3',
          child: Text('Option 3'),
        ),
      ],
      onChanged: (value) {
        setState(() => selectedOption = value);
      },
    );
  }
}
```

### Example 2: Toast Notifications

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class ToastExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            IxToast.success(
              context,
              message: 'Action completed successfully!',
            );
          },
          child: Text('Show Success'),
        ),
        ElevatedButton(
          onPressed: () {
            IxToast.error(
              context,
              message: 'An error occurred!',
            );
          },
          child: Text('Show Error'),
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
  @override
  Widget build(BuildContext context) {
    return IxEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: 'Your cart is empty',
      message: 'Add some items to get started',
      action: ElevatedButton(
        onPressed: () {
          // Navigate to shop
        },
        child: Text('Continue Shopping'),
      ),
    );
  }
}
```

### Example 4: Responsive Data View

```dart
import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class DataTableExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IxResponsiveDataView(
      columns: [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Status')),
      ],
      rows: [
        DataRow(cells: [
          DataCell(Text('John Doe')),
          DataCell(Text('john@example.com')),
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Active', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ],
    );
  }
}
```

---

## Theming

### Light Theme

```dart
MaterialApp(
  theme: IxTheme.lightTheme,
)
```

### Dark Theme

```dart
MaterialApp(
  darkTheme: IxTheme.darkTheme,
)
```

### System Theme (Auto Light/Dark)

```dart
MaterialApp(
  theme: IxTheme.lightTheme,
  darkTheme: IxTheme.darkTheme,
  themeMode: ThemeMode.system,  // Uses device setting
)
```

### Access Theme Colors

```dart
final themeData = Theme.of(context);
final primaryColor = themeData.primaryColor;
final textColor = themeData.textTheme.bodyMedium?.color;
```

---

## Common Tasks

### Task 1: Add Application Scaffold

```dart
import 'package:ix_flutter/ix_flutter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IxApplicationScaffold(
      title: 'My App',
      child: Scaffold(
        body: Center(
          child: Text('Content here'),
        ),
      ),
    );
  }
}
```

### Task 2: Handle Navigation

```dart
// Using breadcrumb navigation
IxBreadcrumb(
  items: [
    BreadcrumbItem(label: 'Home', onTap: () => Navigator.pop(context)),
    BreadcrumbItem(label: 'Settings', onTap: () {}),
  ],
)
```

### Task 3: Create a Form

```dart
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            IxDropdownButton<String>(
              value: selectedValue,
              items: [
                DropdownMenuItem(value: 'opt1', child: Text('Option 1')),
                DropdownMenuItem(value: 'opt2', child: Text('Option 2')),
              ],
              onChanged: (value) {
                setState(() => selectedValue = value);
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                IxToast.success(context, message: 'Form submitted!');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Task 4: Display Loading State

```dart
class LoadingExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 2)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Text('Data loaded!');
      },
    );
  }
}
```

---

## Next Steps

### Learn More

1. **Check the Examples**: Browse [example/](example/) folder for complete working app
2. **Read Component Docs**: See [doc/](doc/) for detailed component documentation
3. **API Reference**: Review [API_REFERENCE.md](API_REFERENCE.md)
4. **Icon Guide**: Learn about icons in [doc/ix_icons.md](doc/ix_icons.md)

### Best Practices

- ✅ Always generate icons before using them
- ✅ Use appropriate theme colors from `IxTheme`
- ✅ Follow Siemens iX design guidelines
- ✅ Test on multiple screen sizes
- ✅ Use responsive components for mobile

### Resources

- **Siemens iX**: https://ix.siemens.io
- **Icon Library**: https://ix.siemens.io/docs/icon-library/
- **Design Guidelines**: https://ix.siemens.io/docs/guidelines/
- **Example App**: [example/](example/)

### Get Help

- 📖 **Documentation**: Check [doc/](doc/) folder
- 🐛 **Report Issues**: [GitHub Issues](https://github.com/SobSoft-s-r-o/ix_flutter/issues)
- 💬 **Ask Questions**: [GitHub Discussions](https://github.com/SobSoft-s-r-o/ix_flutter/discussions)
- 📝 **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)

---

**Happy coding with ix_flutter!** 🚀

**Last Updated**: January 2026
**Version**: 1.0.0
