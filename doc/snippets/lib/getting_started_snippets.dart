import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

// Stands in for `package:your_app/ix_icons.dart`, the file the generator
// writes into your app.
import 'generated_icons_stub.dart';

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

class MyIconWidget extends StatelessWidget {
  const MyIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const IxIcon(IxIconsData.home, size: IxIconSize.s24);
  }
}

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

(ThemeData light, ThemeData dark) buildThemes() =>
    (const IxThemeBuilder.light().build(), const IxThemeBuilder.dark().build());

Widget systemThemedApp() => MaterialApp(
  theme: const IxThemeBuilder.light().build(),
  darkTheme: const IxThemeBuilder.dark().build(),
  themeMode: ThemeMode.system, // Uses device setting
  home: const HomePage(),
);

Color primaryToken(BuildContext context) {
  final ixTheme = IxTheme.of(context);
  return ixTheme.palette[IxThemeColorToken.primary]!;
}

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
