import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';
import 'package:example/ix_icons.dart';

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
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Material banners',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Press a button to show a live banner using IX badge colors for each semantic level.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _showMaterialBanner(
                        context: context,
                        ixBadges: ixBadges,
                        tone: IxBadgeTone.info,
                        title: 'Scheduled maintenance',
                        message:
                            'Systems will be read-only tonight from 01:00–02:00.',
                        primaryLabel: 'Details',
                        secondaryLabel: 'Dismiss',
                      ),
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('Show info banner'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showMaterialBanner(
                        context: context,
                        ixBadges: ixBadges,
                        tone: IxBadgeTone.warning,
                        title: 'Validation required',
                        message:
                            'Manual approval is needed before Aleo deployment continues.',
                        primaryLabel: 'Review change',
                        secondaryLabel: 'Remind later',
                      ),
                      icon: const Icon(Icons.error_outline),
                      label: const Text('Show warning banner'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showMaterialBanner(
                        context: context,
                        ixBadges: ixBadges,
                        tone: IxBadgeTone.critical,
                        title: 'Critical incident IX-423',
                        message:
                            'Immediate action required to restore availability.',
                        primaryLabel: 'Resolve now',
                        secondaryLabel: 'View log',
                      ),
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: const Text('Show critical banner'),
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
                  'Banner semantics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Map tonal semantics to banner messaging to keep alerts consistent.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                _BannerSemanticsExample(
                  badgeLabel: 'Info',
                  heading: 'Info semantics',
                  description:
                      'Use for informational notices like planned downtime or configuration tips.',
                  style: ixBadges.style(IxBadgeTone.info),
                  icon: IxIcons.info,
                ),
                const SizedBox(height: 12),
                _BannerSemanticsExample(
                  badgeLabel: 'Warning',
                  heading: 'Warning semantics',
                  description:
                      'Escalate when partial degradation or manual validation is required.',
                  style: ixBadges.style(IxBadgeTone.warning),
                  icon: IxIcons.maintenanceWarning,
                ),
                const SizedBox(height: 12),
                _BannerSemanticsExample(
                  badgeLabel: 'Critical',
                  heading: 'Critical semantics',
                  description:
                      'Reserve for outage scenarios where immediate user action is mandatory.',
                  style: ixBadges.style(IxBadgeTone.critical),
                  icon: IxIcons.alarmBell,
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

class _BannerSemanticsExample extends StatelessWidget {
  const _BannerSemanticsExample({
    required this.badgeLabel,
    required this.heading,
    required this.description,
    required this.style,
    required this.icon,
  });

  final String badgeLabel;
  final String heading;
  final String description;
  final IxBadgeStyle style;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BadgeTheme(
          data: BadgeThemeData(
            backgroundColor: style.background,
            textColor: style.foreground,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            textStyle: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Badge(label: Text(badgeLabel)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconTheme(
                    data: IconThemeData(size: 20, color: style.foreground),
                    child: icon,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    heading,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(description, style: textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

void _showMaterialBanner({
  required BuildContext context,
  required IxBadgeTheme ixBadges,
  required IxBadgeTone tone,
  required String title,
  required String message,
  required String primaryLabel,
  required String secondaryLabel,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentMaterialBanner();
  messenger.showMaterialBanner(
    _buildMaterialBanner(
      context: context,
      messenger: messenger,
      ixBadges: ixBadges,
      tone: tone,
      title: title,
      message: message,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
    ),
  );
}

MaterialBanner _buildMaterialBanner({
  required BuildContext context,
  required ScaffoldMessengerState messenger,
  required IxBadgeTheme ixBadges,
  required IxBadgeTone tone,
  required String title,
  required String message,
  required String primaryLabel,
  required String secondaryLabel,
}) {
  final badgeStyle = ixBadges.style(tone);
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  return MaterialBanner(
    elevation: 0,
    backgroundColor: colorScheme.surfaceContainerHighest,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    leadingPadding: const EdgeInsets.only(right: 12),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(message, style: textTheme.bodySmall),
      ],
    ),
    leading: BadgeTheme(
      data: BadgeThemeData(
        backgroundColor: badgeStyle.background,
        textColor: badgeStyle.foreground,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        textStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      child: Badge(label: Text(_toneShortLabel(tone))),
    ),
    actions: [
      TextButton(
        onPressed: messenger.hideCurrentMaterialBanner,
        child: Text(secondaryLabel),
      ),
      FilledButton(
        onPressed: messenger.hideCurrentMaterialBanner,
        child: Text(primaryLabel),
      ),
    ],
  );
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
