import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../edge_to_edge.dart';
import '../theme_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routePath = '/';
  static const routeName = 'home';

  @override
  Widget build(BuildContext context) {
    final controller = ThemeControllerScope.of(context);
    final theme = Theme.of(context);
    final ixTheme = theme.extension<IxTheme>();
    final appMenuTheme = theme.extension<IxAppMenuTheme>();
    final sidebarTheme = theme.extension<IxSidebarTheme>();

    return ListView(
      padding: EdgeToEdge.scrollPadding(context),
      children: [
        Text('IX Flutter Theme Overview', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Toggle between theme families and brightness modes to see the IX tokens update in real time.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _ThemeInfoCard(controller: controller, ixTheme: ixTheme),
        const SizedBox(height: 24),
        _ThemeSwitcherCard(controller: controller),
        const SizedBox(height: 24),
        _ComponentThemeCard(
          title: 'Application Menu',
          description:
              'Menu surfaces reuse color-2 backgrounds, subtle outlines, and Siemens Sans labels.',
          chips: [
            _InfoChip('Background', appMenuTheme?.backgroundColor),
            _InfoChip('Divider', appMenuTheme?.dividerColor),
            _InfoChip('Badge', appMenuTheme?.badgeBackgroundColor),
          ],
        ),
        const SizedBox(height: 16),
        _ComponentThemeCard(
          title: 'Sidebar Navigation',
          description:
              'Navigation rails inherit IxSidebarTheme so destinations match IX hover, focus, and selection cues.',
          chips: [
            _InfoChip('Background', sidebarTheme?.backgroundColor),
            _InfoChip('Divider', sidebarTheme?.dividerColor),
            _InfoChip('Focus', sidebarTheme?.focusOutlineColor),
          ],
        ),
        const SizedBox(height: 24),
        Text('Core palette', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _paletteTokens
              .map(
                (token) => _ColorSwatch(
                  label: token,
                  color: _resolveColor(context, token),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ThemeInfoCard extends StatelessWidget {
  const _ThemeInfoCard({required this.controller, required this.ixTheme});

  final ThemeController controller;
  final IxTheme? ixTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightnessLabel = theme.brightness.name;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current configuration', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _InfoRow('Family', _familyLabel(controller.family)),
                _InfoRow('Theme mode', _modeLabel(controller.mode)),
                _InfoRow('Brightness', brightnessLabel),
                _InfoRow(
                  'Palette tokens',
                  ixTheme == null
                      ? 'Unavailable'
                      : ixTheme!.palette.length.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitcherCard extends StatelessWidget {
  const _ThemeSwitcherCard({required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme family', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SegmentedButton<IxThemeFamily>(
              segments: IxThemeFamily.values
                  // Brand family is not available in the OSS build.
                  .where((family) => family != IxThemeFamily.brand)
                  .map(
                    (family) => ButtonSegment(
                      value: family,
                      label: Text(_familyLabel(family)),
                    ),
                  )
                  .toList(),
              selected: {controller.family},
              onSelectionChanged: (value) => controller.setFamily(value.first),
            ),
            const SizedBox(height: 20),
            Text('Theme mode', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            SegmentedButton<ThemeMode>(
              segments: ThemeMode.values
                  .map(
                    (mode) => ButtonSegment(
                      value: mode,
                      label: Text(_modeLabel(mode)),
                    ),
                  )
                  .toList(),
              selected: {controller.mode},
              onSelectionChanged: (value) => controller.setMode(value.first),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentThemeCard extends StatelessWidget {
  const _ComponentThemeCard({
    required this.title,
    required this.description,
    required this.chips,
  });

  final String title;
  final String description;
  final List<_InfoChip> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((chip) => chip).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.7),
        ),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, this.color);

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      backgroundColor: color ?? theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(color: theme.dividerColor),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.label, required this.color});

  final IxThemeColorToken label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          label.name,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

List<IxThemeColorToken> get _paletteTokens => const [
  IxThemeColorToken.primary,
  IxThemeColorToken.dynamic,
  IxThemeColorToken.secondary,
  IxThemeColorToken.color1,
  IxThemeColorToken.color2,
  IxThemeColorToken.color3,
  IxThemeColorToken.ghost,
  IxThemeColorToken.ghostHover,
];

Color _resolveColor(BuildContext context, IxThemeColorToken token) {
  final ixTheme = Theme.of(context).extension<IxTheme>();
  return ixTheme?.color(token) ?? Theme.of(context).colorScheme.primary;
}

String _familyLabel(IxThemeFamily family) {
  switch (family) {
    case IxThemeFamily.custom:
      return 'Custom';
    case IxThemeFamily.classic:
      return 'Classic';
    case IxThemeFamily.brand:
      return 'Brand';
  }
}

String _modeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
  }
}
