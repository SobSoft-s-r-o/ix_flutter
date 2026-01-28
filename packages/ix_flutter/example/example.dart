import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

/// Simple example demonstrating ix_flutter usage.
///
/// For a complete example app, see the repository:
/// https://github.com/SobSoft-s-r-o/ix_flutter/tree/main/example
void main() {
  // Build Siemens iX themes
  final lightTheme = const IxThemeBuilder(mode: ThemeMode.light).build();
  final darkTheme = const IxThemeBuilder(mode: ThemeMode.dark).build();

  runApp(MyApp(lightTheme: lightTheme, darkTheme: darkTheme));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
  });

  final ThemeData lightTheme;
  final ThemeData darkTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ix_flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
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
      appBar: AppBar(
        title: const Text('ix_flutter Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown button example
            IxDropdownButton<String>(
              label: 'Select Option',
              items: const [
                IxDropdownMenuItem(label: 'Option 1', value: 'opt1'),
                IxDropdownMenuItem(label: 'Option 2', value: 'opt2'),
                IxDropdownMenuItem(label: 'Option 3', value: 'opt3'),
              ],
              onItemSelected: (value) {
                // Handle selection
              },
            ),
            const SizedBox(height: 24),

            // Empty state example
            const Expanded(
              child: IxEmptyState(
                icon: Icon(Icons.inbox_outlined, size: 64),
                title: 'No items yet',
                subtitle: 'Add some items to get started',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
