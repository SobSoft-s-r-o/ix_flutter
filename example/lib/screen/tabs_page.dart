import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import '../edge_to_edge.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  static const routePath = '/tabs';
  static const routeName = 'tabs';

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {
  int _selectedCircleTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ixTabs = theme.extension<IxTabsTheme>();

    if (ixTabs == null) {
      return const Center(child: Text('IxTabsTheme extension not found.'));
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tabs', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'The Siemens IX tabs theme exposes spacing, indicator height, and stateful colors for both text and icon treatments. '
                  'Use the categories below to toggle between the text navigation preview and circle icon tabs.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              tabs: const [
                Tab(text: 'Text tabs'),
                Tab(text: 'Circle tabs'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: EdgeToEdge.scrollPadding(
                    context,
                    base: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  ),
                  children: [_TextTabsDemo(ixTabs: ixTabs)],
                ),
                ListView(
                  padding: EdgeToEdge.scrollPadding(
                    context,
                    base: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  ),
                  children: [
                    _CircleTabsDemo(
                      ixTabs: ixTabs,
                      selectedIndex: _selectedCircleTab,
                      onSelect: (index) =>
                          setState(() => _selectedCircleTab = index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextTabsDemo extends StatelessWidget {
  const _TextTabsDemo({required this.ixTabs});

  final IxTabsTheme ixTabs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: _textTabs.length,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Navigation tabs', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Default TabBar adopts IxTabsTheme spacing, typography, and indicator tokens. '
                'Badges reuse the pill border tokens for unread counters.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TabBar(
                isScrollable: true,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  for (var i = 0; i < _textTabs.length; i++)
                    Tab(
                      child: _TabLabel(
                        index: i,
                        label: _textTabs[i].label,
                        count: _textTabs[i].count,
                        ixTabs: ixTabs,
                        leading: _textTabs[i].leading,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: TabBarView(
                  children: _textTabs
                      .map(
                        (tab) => _TabPanel(
                          title: tab.panelTitle,
                          body: tab.panelBody,
                          icon: tab.icon,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleTabsDemo extends StatelessWidget {
  const _CircleTabsDemo({
    required this.ixTabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final IxTabsTheme ixTabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Icon circle tabs', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Circle tabs expose dedicated tokens for border width, indicator dots, and icon states. '
              'Tap the controls to see the selected treatments applied.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (var i = 0; i < _circleTabs.length; i++)
                  _CircleTab(
                    ixTabs: ixTabs,
                    spec: _circleTabs[i],
                    selected: i == selectedIndex,
                    onTap: _circleTabs[i].disabled ? null : () => onSelect(i),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const double _badgeSize = 20;

class _TabLabel extends StatefulWidget {
  const _TabLabel({
    required this.index,
    required this.label,
    required this.ixTabs,
    this.count,
    this.leading,
  });

  final int index;
  final String label;
  final IxTabsTheme ixTabs;
  final int? count;
  final Widget? leading;

  @override
  State<_TabLabel> createState() => _TabLabelState();
}

class _TabLabelState extends State<_TabLabel> {
  bool _hovering = false;
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (_controller == controller) {
      return;
    }
    _controller?.removeListener(_handleTabChange);
    _controller = controller;
    _controller?.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _selected => _controller?.index == widget.index;

  Color _backgroundColor() {
    final bg = widget.ixTabs.tab.background;
    if (_hovering && !_selected) {
      return bg.hover;
    }
    if (_selected) {
      return bg.selected;
    }
    return bg.base;
  }

  TextStyle? _labelStyle(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.labelLarge;
    final color = _selected
        ? widget.ixTabs.tab.foreground.selected
        : widget.ixTabs.tab.foreground.base;
    return themeStyle?.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leading != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconTheme.merge(
              data: IconThemeData(
                color: _selected
                    ? widget.ixTabs.tab.foreground.selected
                    : widget.ixTabs.tab.foreground.base,
                size: 16,
              ),
              child: widget.leading!,
            ),
          ),
        Text(widget.label, style: _labelStyle(context)),
      ],
    );

    if (widget.count != null) {
      label = Padding(
        padding: EdgeInsets.only(right: _badgeSize / 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            label,
            Positioned(
              top: -_badgeSize / 1.2,
              right: -_badgeSize / 0.8,
              child: _TabBadge(ixTabs: widget.ixTabs, count: widget.count!),
            ),
          ],
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.ixTabs.tabPadding,
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(999),
        ),
        child: label,
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.ixTabs, required this.count});

  final IxTabsTheme ixTabs;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: ixTabs.tab.foreground.selected,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: _badgeSize,
      height: _badgeSize,
      decoration: BoxDecoration(
        color: ixTabs.tab.background.selected,
        shape: BoxShape.circle,
        border: Border.all(color: ixTabs.pill.border.selected, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(count.toString(), style: textStyle),
    );
  }
}

class _TabPanel extends StatelessWidget {
  const _TabPanel({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconTheme.merge(
              data: IconThemeData(color: theme.colorScheme.primary, size: 28),
              child: icon,
            ),
            const SizedBox(width: 12),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        Text(body, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _CircleTab extends StatelessWidget {
  const _CircleTab({
    required this.ixTabs,
    required this.spec,
    required this.selected,
    this.onTap,
  });

  final IxTabsTheme ixTabs;
  final _CircleTabSpec spec;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = _resolveColor(ixTabs.circle.background);
    final border = _resolveColor(ixTabs.circle.border);
    final iconColor = _resolveColor(ixTabs.circle.icon);
    final indicatorColor = _indicatorColor(ixTabs.circle.indicator);
    final indicatorWidth = _indicatorWidth(ixTabs.circleDiameter);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: spec.disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: spec.disabled ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: ixTabs.circleDiameter,
              height: ixTabs.circleDiameter,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: border,
                  width: ixTabs.circleBorderWidth,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconTheme.merge(
                  data: IconThemeData(color: iconColor, size: 16),
                  child: spec.icon,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: indicatorWidth,
          height: ixTabs.indicatorHeight,
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(ixTabs.indicatorHeight),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          spec.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: spec.disabled
                ? theme.textTheme.labelMedium?.color?.withValues(alpha: 0.5)
                : theme.textTheme.labelMedium?.color,
          ),
        ),
      ],
    );
  }

  Color _resolveColor(IxTabStateColors colors) {
    if (spec.disabled) {
      return colors.disabled;
    }
    if (selected) {
      return colors.selected;
    }
    return colors.base;
  }

  Color _indicatorColor(IxTabStateColors colors) {
    if (spec.disabled) {
      return colors.disabled;
    }
    if (selected) {
      return colors.selected;
    }
    return Colors.transparent;
  }

  double _indicatorWidth(double diameter) {
    if (spec.disabled) {
      return 0;
    }
    return selected ? diameter : 0;
  }
}

class _TextTabSpec {
  const _TextTabSpec({
    required this.label,
    required this.panelTitle,
    required this.panelBody,
    required this.icon,
    this.count,
    this.leading,
  });

  final String label;
  final String panelTitle;
  final String panelBody;
  final Widget icon;
  final int? count;
  final Widget? leading;
}

class _CircleTabSpec {
  const _CircleTabSpec({
    required this.label,
    required this.icon,
    this.disabled = false,
  });

  final String label;
  final Widget icon;
  final bool disabled;
}

final List<_TextTabSpec> _textTabs = [
  _TextTabSpec(
    label: 'Monitor',
    panelTitle: 'Asset monitoring',
    panelBody:
        'Track live KPIs for turbines and connected lines. '
        'Tab copy inherits IxTypography.label with bold weight.',
    icon: IxIcons.dashboard,
    count: 4,
  ),
  _TextTabSpec(
    label: 'Incidents',
    panelTitle: 'Incident triage',
    panelBody:
        'Use a badge to highlight open alerts. '
        'Indicator height stays at 0.125rem per Siemens IX tokens.',
    icon: IxIcons.warning,
    count: 8,
    leading: IxIcons.warning,
  ),
  _TextTabSpec(
    label: 'Insights',
    panelTitle: 'Data insights',
    panelBody:
        'Tabs align to the ghost surface tokens, keeping text legible on dashboards.',
    icon: IxIcons.ai,
  ),
];

final List<_CircleTabSpec> _circleTabs = [
  _CircleTabSpec(label: 'Devices', icon: IxIcons.layers),
  _CircleTabSpec(label: 'Logbook', icon: IxIcons.appMenu),
  _CircleTabSpec(label: 'Analytics', icon: IxIcons.analysis),
  _CircleTabSpec(label: 'Disabled', icon: IxIcons.close, disabled: true),
];
