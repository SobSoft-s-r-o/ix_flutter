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
      title: 'Siemens iX Demo',
      theme: const IxThemeBuilder.light().build(),
      darkTheme: const IxThemeBuilder.dark().build(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

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

Widget catalogueIcon() => const IxIcon(IxIconsData.home);
