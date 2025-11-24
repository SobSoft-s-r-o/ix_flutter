import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import '../edge_to_edge.dart';

class NavigationExamplesPage extends StatefulWidget {
  const NavigationExamplesPage({super.key});

  static const routePath = '/navigation-examples';
  static const routeName = 'navigation-examples';

  @override
  State<NavigationExamplesPage> createState() => _NavigationExamplesPageState();
}

class _NavigationExamplesPageState extends State<NavigationExamplesPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedSpec = _navigationSpecs[_selectedIndex];

    return Scaffold(
      extendBody: true,
      body: ListView(
        padding: EdgeToEdge.scrollPadding(
          context,
          base: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        ),
        children: [
          Text(
            'Bottom app bar navigation',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This page isolates the mobile-style bottom app bar so the other demos remain focused on their components. '
            'Use the pills in the bar to switch between snack bar and dialog walkthroughs.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(selectedSpec.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(selectedSpec.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(selectedSpec.label),
              child: selectedSpec.builder(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomAppBarNavigation(
        selectedIndex: _selectedIndex,
        onSelect: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _BottomAppBarNavigation extends StatelessWidget {
  const _BottomAppBarNavigation({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: BottomAppBar(
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < _navigationSpecs.length; i++)
              _BottomAppBarItem(
                label: _navigationSpecs[i].label,
                icon: _navigationSpecs[i].icon,
                selectedIcon: _navigationSpecs[i].selectedIcon,
                selected: selectedIndex == i,
                colorScheme: colorScheme,
                onSelect: () => onSelect(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomAppBarItem extends StatelessWidget {
  const _BottomAppBarItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.colorScheme,
    required this.onSelect,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? colorScheme.onPrimary : colorScheme.onSurface;
    final background = selected
        ? colorScheme.primary
        : colorScheme.surfaceVariant;

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: foreground, size: 20),
              child: selected ? selectedIcon : icon,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationSpec {
  const _NavigationSpec({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });

  final String label;
  final String title;
  final String description;
  final Widget icon;
  final Widget selectedIcon;
  final Widget Function(BuildContext context) builder;
}

final List<_NavigationSpec> _navigationSpecs = [
  _NavigationSpec(
    label: 'Snack bars',
    title: 'Snack bar guidance',
    description:
        'Use snack bars for transient status or undo affordances. Buttons below trigger different severities.',
    icon: IxIcons.notification,
    selectedIcon: IxIcons.notificationFilled,
    builder: (context) => const _SnackBarExamples(),
  ),
  _NavigationSpec(
    label: 'Dialogs',
    title: 'Dialog walkthrough',
    description:
        'Dialogs pause the flow for confirmations, warnings, or detail review. Explore the alert and form dialogs here.',
    icon: IxIcons.warning,
    selectedIcon: IxIcons.warningFilled,
    builder: (context) => const _DialogExamples(),
  ),
];

class _SnackBarExamples extends StatelessWidget {
  const _SnackBarExamples();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: colorScheme.primary, size: 48),
              child: IxIcons.notification,
            ),
            const SizedBox(height: 16),
            Text(
              'Trigger snack bars to reinforce background operations or offer undo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => _showSnackBar(
                    context,
                    'Asset sync completed',
                    colorScheme.surface,
                    colorScheme.onSurface,
                  ),
                  child: const Text('Show info'),
                ),
                OutlinedButton(
                  onPressed: () => _showSnackBar(
                    context,
                    'Network retry queued',
                    colorScheme.primaryContainer,
                    colorScheme.onPrimaryContainer,
                  ),
                  child: const Text('Show neutral'),
                ),
                TextButton(
                  onPressed: () => _showSnackBar(
                    context,
                    'Alarm suppressed • Undo',
                    colorScheme.errorContainer,
                    colorScheme.onErrorContainer,
                  ),
                  child: const Text('Show warning'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color background,
    Color foreground,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: foreground)),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _DialogExamples extends StatelessWidget {
  const _DialogExamples();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: colorScheme.secondary, size: 48),
              child: IxIcons.warning,
            ),
            const SizedBox(height: 16),
            Text(
              'Dialogs request confirmation or highlight critical alerts. Preview two variants below.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => _showConfirmDialog(context),
                  child: const Text('Alert dialog'),
                ),
                OutlinedButton(
                  onPressed: () => _showFormDialog(context),
                  child: const Text('Form dialog'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'Leaving the inspection will drop any unsaved annotations. You can duplicate the entry for later review.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Discard'),
            ),
          ],
        );
      },
      barrierColor: theme.colorScheme.scrim.withOpacity(0.5),
    );
  }

  Future<void> _showFormDialog(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Schedule downtime'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Capture a quick note describing the maintenance window.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add optional context',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save'),
            ),
          ],
        );
      },
      barrierColor: theme.colorScheme.scrim.withOpacity(0.5),
    );
  }
}
