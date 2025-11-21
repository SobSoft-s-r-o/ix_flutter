import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class ButtonsPage extends StatelessWidget {
  const ButtonsPage({super.key});

  static const routePath = '/buttons';
  static const routeName = 'buttons';

  @override
  Widget build(BuildContext context) {
    final ixButtons = Theme.of(context).extension<IxButtonTheme>();
    final ixTheme = Theme.of(context).extension<IxTheme>();

    if (ixButtons == null) {
      return const Center(
        child: Text('IxButtonTheme extension is not available.'),
      );
    }

    final variants = IxButtonVariant.values;

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) {
        final variant = variants[index];
        final style = ixButtons.style(variant);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _variantLabel(variant),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      style: style,
                      onPressed: () {},
                      child: const Text('Enabled'),
                    ),
                    FilledButton.icon(
                      style: style,
                      onPressed: () {},
                      icon: IxIcons.add,
                      label: const Text('With icon'),
                    ),
                    FilledButton(
                      style: style,
                      onPressed: null,
                      child: const Text('Disabled'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _variantDescription(variant, ixTheme),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemCount: variants.length,
    );
  }
}

String _variantLabel(IxButtonVariant variant) {
  switch (variant) {
    case IxButtonVariant.primary:
      return 'Primary';
    case IxButtonVariant.secondary:
      return 'Secondary';
    case IxButtonVariant.tertiary:
      return 'Tertiary';
    case IxButtonVariant.subtlePrimary:
      return 'Subtle / Primary';
    case IxButtonVariant.subtleSecondary:
      return 'Subtle / Secondary';
    case IxButtonVariant.subtleTertiary:
      return 'Subtle / Tertiary';
    case IxButtonVariant.dangerPrimary:
      return 'Danger / Primary';
    case IxButtonVariant.dangerSecondary:
      return 'Danger / Secondary';
    case IxButtonVariant.dangerTertiary:
      return 'Danger / Tertiary';
  }
}

String _variantDescription(IxButtonVariant variant, IxTheme? ixTheme) {
  String token(IxThemeColorToken token) {
    if (ixTheme == null) {
      return token.name;
    }
    final argb = ixTheme.color(token).toARGB32().toRadixString(16);
    return '${token.name} (0x$argb)';
  }

  switch (variant) {
    case IxButtonVariant.primary:
      return 'Emphasized action using ${token(IxThemeColorToken.primary)} backgrounds and primary-contrast text.';
    case IxButtonVariant.secondary:
      return 'Outlined control showing ${token(IxThemeColorToken.primary)} borders with ghost fills.';
    case IxButtonVariant.tertiary:
      return 'Text-only treatment relying on ${token(IxThemeColorToken.primary)} ink for interactions.';
    case IxButtonVariant.subtlePrimary:
      return 'Low-emphasis surface that leans on component tokens for dashboards.';
    case IxButtonVariant.subtleSecondary:
      return 'Neutral outline for supporting actions or filters.';
    case IxButtonVariant.subtleTertiary:
      return 'Ghost-like treatment that only shows hover/active overlays.';
    case IxButtonVariant.dangerPrimary:
      return 'Alarm foreground/background pairing for irreversible actions.';
    case IxButtonVariant.dangerSecondary:
      return 'Outlined danger action accenting ${token(IxThemeColorToken.alarmText)} borders.';
    case IxButtonVariant.dangerTertiary:
      return 'Text treatment for alarm flows with hover/error overlays.';
  }
}
