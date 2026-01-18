import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../theme_controller.dart';

class ApplicationPage extends StatefulWidget {
  const ApplicationPage({super.key});

  static const routePath = '/application-menu';
  static const routeName = 'application-menu';

  @override
  State<ApplicationPage> createState() => _ApplicationPageState();
}

class _ApplicationPageState extends State<ApplicationPage> {
  String _activeEntryId = 'dashboard';
  ThemeMode? _themeMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeMode ??= ThemeControllerScope.of(context).mode;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final themeMode = _themeMode ?? ThemeControllerScope.of(context).mode;

    return IxApplicationScaffold(
      appTitle: 'Operations hub',
      appBar: AppBar(title: const Text('Application menu demo')),
      entries: entries,
      onNavigate: _handleNavigate,
      body: _DemoPageContent(activeEntryId: _activeEntryId),
      themeMode: themeMode,
      onThemeModeChanged: _handleThemeModeChanged,
      onOpenSettings: _showSettingsOverlay,
      onOpenAboutLegal: _showAboutDialog,
    );
  }

  List<IxMenuEntry> _buildEntries() {
    final selectedId = _activeEntryId;

    IxMenuEntry child(String id, String label, {int? badge}) {
      return IxMenuEntry(
        id: id,
        type: IxMenuEntryType.item,
        label: label,
        notificationCount: badge,
        selected: selectedId == id,
      );
    }

    return [
      IxMenuEntry(
        id: 'dashboard',
        type: IxMenuEntryType.item,
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        selected: selectedId == 'dashboard',
        tooltip: 'Summary insights',
      ),
      IxMenuEntry(
        id: 'orders',
        type: IxMenuEntryType.category,
        icon: Icons.shopping_cart_outlined,
        label: 'Orders',
        tooltip: 'Order insights',
        children: [
          child('orders-open', 'Open orders', badge: 3),
          child('orders-history', 'Order history'),
          child('orders-returns', 'Returns & refunds'),
        ],
      ),
      IxMenuEntry(
        id: 'analytics',
        type: IxMenuEntryType.item,
        icon: Icons.pie_chart_outline,
        label: 'Analytics',
        selected: selectedId == 'analytics',
      ),
      IxMenuEntry(
        id: 'alerts',
        type: IxMenuEntryType.item,
        icon: Icons.warning_amber_outlined,
        label: 'Alerts',
        notificationCount: 12,
        selected: selectedId == 'alerts',
      ),
      IxMenuEntry(
        id: 'settings',
        type: IxMenuEntryType.item,
        icon: Icons.settings_outlined,
        label: 'Settings',
        isBottom: true,
      ),
      IxMenuEntry(
        id: 'theme-toggle',
        type: IxMenuEntryType.custom,
        icon: Icons.brightness_6_outlined,
        label: 'Theme',
        tooltip: 'Switch between light, dark, and system',
        isBottom: true,
      ),
      IxMenuEntry(
        id: 'about-legal',
        type: IxMenuEntryType.item,
        icon: Icons.info_outline,
        label: 'About & legal',
        isBottom: true,
      ),
    ];
  }

  void _handleNavigate(String id) {
    setState(() => _activeEntryId = id);
  }

  void _handleThemeModeChanged(ThemeMode mode) {
    ThemeControllerScope.of(context).setMode(mode);
    setState(() => _themeMode = mode);
  }

  void _showSettingsOverlay() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text(
                'This is where settings or overlays would appear. You can place forms or quick toggles here while the current page remains visible.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Operations hub',
      applicationVersion: '1.0.0',
      children: const [Text('Siemens IX design language demo for Flutter.')],
    );
  }
}

class _DemoPageContent extends StatelessWidget {
  const _DemoPageContent({required this.activeEntryId});

  final String activeEntryId;

  @override
  Widget build(BuildContext context) {
    final page = _demoPages[activeEntryId] ?? _demoPages['dashboard']!;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(page.id),
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(page.icon, size: 56),
              const SizedBox(height: 16),
              Text(
                page.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoPageMeta {
  const _DemoPageMeta({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

final Map<String, _DemoPageMeta> _demoPages = {
  'dashboard': _DemoPageMeta(
    id: 'dashboard',
    title: 'Fleet overview',
    description:
        'Live KPIs, recently triggered alerts, and upcoming maintenance windows land here.',
    icon: Icons.dashboard_customize_outlined,
  ),
  'orders-open': _DemoPageMeta(
    id: 'orders-open',
    title: 'Open orders',
    description: 'Track work-in-progress orders grouped by assignee.',
    icon: Icons.list_alt,
  ),
  'orders-history': _DemoPageMeta(
    id: 'orders-history',
    title: 'Order history',
    description:
        'Historical search with filters for region, business unit, and escalation level.',
    icon: Icons.history,
  ),
  'orders-returns': _DemoPageMeta(
    id: 'orders-returns',
    title: 'Returns & refunds',
    description: 'Analyze returns trends and capture refund KPIs in context.',
    icon: Icons.reply_all,
  ),
  'analytics': _DemoPageMeta(
    id: 'analytics',
    title: 'Analytics',
    description:
        'Dashboards for throughput, capacity planning, and predictive modeling summaries.',
    icon: Icons.stacked_line_chart,
  ),
  'alerts': _DemoPageMeta(
    id: 'alerts',
    title: 'Alerts',
    description:
        'Triage outstanding alerts, suppress noisy signals, and provide operator notes.',
    icon: Icons.warning_amber,
  ),
};
