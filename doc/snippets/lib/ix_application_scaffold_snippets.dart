import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentRoute = 'home';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return IxApplicationScaffold(
      appTitle: 'My App',
      themeMode: _themeMode,
      onThemeModeChanged: (mode) {
        setState(() {
          _themeMode = mode;
        });
      },
      entries: [
        const IxMenuEntry(
          id: 'home',
          label: 'Home',
          icon: Icons.home,
          type: IxMenuEntryType.item,
        ),
        const IxMenuEntry(
          id: 'projects',
          label: 'Projects',
          icon: Icons.folder,
          type: IxMenuEntryType.category,
          children: [
            IxMenuEntry(
              id: 'project-a',
              label: 'Project A',
              type: IxMenuEntryType.item,
            ),
            IxMenuEntry(
              id: 'project-b',
              label: 'Project B',
              type: IxMenuEntryType.item,
            ),
          ],
        ),
      ],
      onNavigate: (id) {
        setState(() {
          _currentRoute = id;
        });
      },
      body: Center(child: Text('Current Route: $_currentRoute')),
    );
  }
}

Widget localizedScaffold({
  required List<IxMenuEntry> entries,
  required ValueChanged<String> onNavigate,
  required Widget body,
}) => IxApplicationScaffold(
  appTitle: 'My App',
  strings: const IxApplicationStrings(
    settings: 'Einstellungen',
    toggleTheme: 'Design wechseln',
  ),
  entries: entries,
  onNavigate: onNavigate,
  body: body,
);

Widget scaffoldWithBottomEntries({
  required List<IxMenuEntry> entries,
  required ValueChanged<String> onNavigate,
  required Widget body,
  required ThemeMode themeMode,
  required ValueChanged<ThemeMode> onThemeModeChanged,
}) => IxApplicationScaffold(
  appTitle: 'My App',
  entries: entries,
  onNavigate: onNavigate,
  body: body,
  themeMode: themeMode,
  onThemeModeChanged: onThemeModeChanged,
  settings: const SettingsPanel(), // upstream <ix-menu-settings>
  about: const AboutLegalPanel(), // upstream <ix-menu-about>
  enableToggleTheme: true, // default
);

/// Your own panel content; anything can go in here.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

/// Your own panel content; anything can go in here.
class AboutLegalPanel extends StatelessWidget {
  const AboutLegalPanel({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

Widget scaffoldWithoutKeyboardDismissal({
  required List<IxMenuEntry> entries,
  required ValueChanged<String> onNavigate,
  required Widget body,
}) => IxApplicationScaffold(
  appTitle: 'My App',
  entries: entries,
  onNavigate: onNavigate,
  body: body,
  // Back to Flutter's own behaviour: on a touch screen a focused field
  // survives both a tap outside it and a scroll.
  dismissKeyboardOnInteraction: false,
);

Widget formPage() => IxKeyboardDismissScope(
  child: const Padding(
    padding: EdgeInsets.all(16),
    child: TextField(decoration: InputDecoration(labelText: 'Name')),
  ),
);
