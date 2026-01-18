import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:example/ix_icons.dart';

import '../edge_to_edge.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  static const routePath = '/cards';
  static const routeName = 'cards';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ixCards = theme.extension<IxCardTheme>();

    if (ixCards == null) {
      return const Center(child: Text('IxCardTheme extension not found.'));
    }

    final baseCards = <_CardDemo>[
      _CardDemo(
        variant: IxCardVariant.filled,
        title: 'Analytics overview',
        subtitle: 'High-level KPIs and quick filters tuned for dashboards.',
        icon: IxIcons.dashboard,
      ),
      _CardDemo(
        variant: IxCardVariant.outline,
        title: 'Experiment rollout',
        subtitle: 'Outline treatment for filters and supporting tools.',
        icon: IxIcons.appMenu,
      ),
      _CardDemo(
        variant: IxCardVariant.primary,
        title: 'Initiate workflow',
        subtitle: 'Highlighted action cards meant for primary flows.',
        icon: IxIcons.rocket,
      ),
    ];

    final statusCards = <_CardDemo>[
      _CardDemo(
        variant: IxCardVariant.alarm,
        title: 'Alarm condition',
        subtitle: 'Notify operators when thresholds exceed safe ranges.',
        icon: IxIcons.alarmBell,
      ),
      _CardDemo(
        variant: IxCardVariant.critical,
        title: 'Critical outage',
        subtitle: 'Escalate incidents that block production entirely.',
        icon: IxIcons.warning,
      ),
      _CardDemo(
        variant: IxCardVariant.warning,
        title: 'Maintenance soon',
        subtitle: 'Warn teams about upcoming maintenance windows.',
        icon: IxIcons.warning,
      ),
      _CardDemo(
        variant: IxCardVariant.success,
        title: 'Inspection cleared',
        subtitle: 'Celebrate a green status after QA handoff.',
        icon: IxIcons.check,
      ),
      _CardDemo(
        variant: IxCardVariant.info,
        title: 'Documentation update',
        subtitle: 'Share product changes or release notes with teams.',
        icon: IxIcons.info,
      ),
      _CardDemo(
        variant: IxCardVariant.neutral,
        title: 'Backlog summary',
        subtitle: 'Neutral information blocks for supporting content.',
        icon: IxIcons.folder,
      ),
    ];

    return ListView(
      padding: EdgeToEdge.scrollPadding(context),
      children: [
        Text('Cards', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Siemens IX cards reuse palette tokens for backgrounds, borders, and focus states. '
          'These demos render static surfaces only — interactions are handled by host widgets.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _CardsSection(
          heading: 'Surface treatments',
          description:
              'Filled, outline, and primary variants cover common content blocks and spotlight tiles.',
          cards: baseCards,
          ixCards: ixCards,
        ),
        const SizedBox(height: 24),
        _CardsSection(
          heading: 'Semantic statuses',
          description:
              'Status cards inherit alarm, warning, and success palettes so alerts stay consistent.',
          cards: statusCards,
          ixCards: ixCards,
        ),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection({
    required this.heading,
    required this.description,
    required this.cards,
    required this.ixCards,
  });

  final String heading;
  final String description;
  final List<_CardDemo> cards;
  final IxCardTheme ixCards;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(description, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((demo) => _CardExample(demo: demo, ixCards: ixCards))
              .toList(),
        ),
      ],
    );
  }
}

class _CardExample extends StatelessWidget {
  const _CardExample({required this.demo, required this.ixCards});

  final _CardDemo demo;
  final IxCardTheme ixCards;

  @override
  Widget build(BuildContext context) {
    final style = ixCards.style(demo.variant);
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(ixCards.borderRadius),
          border: Border.all(
            color: style.borderColor,
            width: ixCards.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _variantLabel(demo.variant).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: style.foreground.withValues(alpha: 0.7),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _CardIcon(style: style, child: demo.icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      demo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: style.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                demo.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: style.foreground.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.style, required this.child});

  final IxCardStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: IconTheme.merge(
          data: IconThemeData(color: style.foreground, size: 22),
          child: child,
        ),
      ),
    );
  }
}

class _CardDemo {
  const _CardDemo({
    required this.variant,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final IxCardVariant variant;
  final String title;
  final String subtitle;
  final Widget icon;
}

String _variantLabel(IxCardVariant variant) {
  switch (variant) {
    case IxCardVariant.filled:
      return 'Filled';
    case IxCardVariant.outline:
      return 'Outline';
    case IxCardVariant.primary:
      return 'Primary';
    case IxCardVariant.alarm:
      return 'Alarm';
    case IxCardVariant.critical:
      return 'Critical';
    case IxCardVariant.warning:
      return 'Warning';
    case IxCardVariant.success:
      return 'Success';
    case IxCardVariant.info:
      return 'Info';
    case IxCardVariant.neutral:
      return 'Neutral';
  }
}
