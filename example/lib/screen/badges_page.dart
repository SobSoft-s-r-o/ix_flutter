import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import '../edge_to_edge.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  static const routePath = '/badges';
  static const routeName = 'badges';

  @override
  Widget build(BuildContext context) {
    final ixBadges = Theme.of(context).extension<IxBadgeTheme>();

    if (ixBadges == null) {
      return const Center(child: Text('IxBadgeTheme extension not found.'));
    }

    final tones = IxBadgeTone.values;
    return ListView(
      padding: EdgeToEdge.scrollPadding(context),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status badges',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Solid tokens',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final tone in tones)
                      _BadgePill(
                        label: _toneLabel(tone),
                        style: ixBadges.style(tone),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Subtle tokens',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final tone in tones)
                      _BadgePill(
                        label: _toneLabel(tone),
                        style: ixBadges.style(tone, subtle: true),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Badge overlays',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Using Flutter\'s Badge widget with IX colors.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    for (final tone in tones)
                      _BadgeOverlay(tone: tone, style: ixBadges.style(tone)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.label, required this.style});

  final String label;
  final IxBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: style.foreground,
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.borderColor),
      ),
      child: Text(label, style: textStyle),
    );
  }
}

class _BadgeOverlay extends StatelessWidget {
  const _BadgeOverlay({required this.tone, required this.style});

  final IxBadgeTone tone;
  final IxBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    final label = _toneShortLabel(tone);
    return BadgeTheme(
      data: BadgeThemeData(
        backgroundColor: style.background,
        textColor: style.foreground,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      child: Badge(label: Text(label), child: const Icon(Icons.notifications)),
    );
  }
}

String _toneLabel(IxBadgeTone tone) {
  switch (tone) {
    case IxBadgeTone.neutral:
      return 'Neutral';
    case IxBadgeTone.info:
      return 'Info';
    case IxBadgeTone.success:
      return 'Success';
    case IxBadgeTone.warning:
      return 'Warning';
    case IxBadgeTone.critical:
      return 'Critical';
    case IxBadgeTone.alarm:
      return 'Alarm';
  }
}

String _toneShortLabel(IxBadgeTone tone) {
  switch (tone) {
    case IxBadgeTone.neutral:
      return 'N';
    case IxBadgeTone.info:
      return 'I';
    case IxBadgeTone.success:
      return 'S';
    case IxBadgeTone.warning:
      return '!';
    case IxBadgeTone.critical:
      return 'C';
    case IxBadgeTone.alarm:
      return 'A';
  }
}
