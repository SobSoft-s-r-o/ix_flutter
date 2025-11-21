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
    final ixChips = Theme.of(context).extension<IxChipTheme>();

    if (ixButtons == null || ixChips == null) {
      return const Center(child: Text('IxTheme extensions were not found.'));
    }

    final variants = IxButtonVariant.values;
    final baseChipVariants = IxChipVariant.values;
    const statusVariants = IxChipStatus.values;

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemBuilder: (context, index) {
        if (index < variants.length) {
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
        }

        return _ChipExamples(
          ixChips: ixChips,
          baseVariants: baseChipVariants,
          statusVariants: statusVariants,
        );
      },
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemCount: variants.length + 1,
    );
  }
}

class _ChipExamples extends StatelessWidget {
  const _ChipExamples({
    required this.ixChips,
    required this.baseVariants,
    required this.statusVariants,
  });

  final IxChipTheme ixChips;
  final List<IxChipVariant> baseVariants;
  final List<IxChipStatus> statusVariants;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chips', style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Base treatments', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final variant in baseVariants)
                  _buildChip(
                    context,
                    label: _chipVariantLabel(variant),
                    style: ixChips.variant(variant),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Semantic statuses', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final status in statusVariants)
                  _buildChip(
                    context,
                    label: _chipStatusLabel(status),
                    style: ixChips.statusStyle(status),
                    closable: true,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Semantic outlines', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final status in statusVariants)
                  _buildChip(
                    context,
                    label: _chipStatusLabel(status),
                    style: ixChips.statusStyle(status, outline: true),
                    outlined: true,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IxChipStyle style,
    bool closable = false,
    bool outlined = false,
  }) {
    return Chip(
      label: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: style.foreground),
      ),
      backgroundColor: style.background,
      side: outlined ? BorderSide(color: style.borderColor) : null,
      deleteIcon: closable ? const Icon(Icons.close, size: 16) : null,
      onDeleted: closable ? () {} : null,
      deleteIconColor: style.closeForeground,
    );
  }
}

String _chipVariantLabel(IxChipVariant variant) {
  switch (variant) {
    case IxChipVariant.standard:
      return 'Standard';
    case IxChipVariant.outline:
      return 'Outline';
    case IxChipVariant.primary:
      return 'Primary';
    case IxChipVariant.primaryOutline:
      return 'Primary / Outline';
  }
}

String _chipStatusLabel(IxChipStatus status) {
  switch (status) {
    case IxChipStatus.alarm:
      return 'Alarm';
    case IxChipStatus.critical:
      return 'Critical';
    case IxChipStatus.warning:
      return 'Warning';
    case IxChipStatus.info:
      return 'Info';
    case IxChipStatus.neutral:
      return 'Neutral';
    case IxChipStatus.success:
      return 'Success';
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
    case IxButtonVariant.warningPrimary:
      return 'Warning / Primary';
    case IxButtonVariant.warningSecondary:
      return 'Warning / Secondary';
    case IxButtonVariant.warningTertiary:
      return 'Warning / Tertiary';
    case IxButtonVariant.infoPrimary:
      return 'Info / Primary';
    case IxButtonVariant.infoSecondary:
      return 'Info / Secondary';
    case IxButtonVariant.infoTertiary:
      return 'Info / Tertiary';
    case IxButtonVariant.successPrimary:
      return 'Success / Primary';
    case IxButtonVariant.successSecondary:
      return 'Success / Secondary';
    case IxButtonVariant.successTertiary:
      return 'Success / Tertiary';
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
    case IxButtonVariant.warningPrimary:
      return 'Prominent caution state using ${token(IxThemeColorToken.warning)} fills with ${token(IxThemeColorToken.warningContrast)} text.';
    case IxButtonVariant.warningSecondary:
      return 'Warning outline featuring ${token(IxThemeColorToken.warningText)} ink and ${token(IxThemeColorToken.warningBdr)} borders.';
    case IxButtonVariant.warningTertiary:
      return 'Ghost warning action that keeps ${token(IxThemeColorToken.warningText)} copy on ${token(IxThemeColorToken.ghost)} surfaces.';
    case IxButtonVariant.infoPrimary:
      return 'Informational highlight using ${token(IxThemeColorToken.info)} backgrounds and ${token(IxThemeColorToken.infoContrast)} text.';
    case IxButtonVariant.infoSecondary:
      return 'Info outline pairing neutral fills with ${token(IxThemeColorToken.info)} strokes.';
    case IxButtonVariant.infoTertiary:
      return 'Ghost info button reserved for inline help cues with ${token(IxThemeColorToken.info)} ink.';
    case IxButtonVariant.successPrimary:
      return 'Affirmative confirmation state driven by ${token(IxThemeColorToken.success)} fills and ${token(IxThemeColorToken.successContrast)} text.';
    case IxButtonVariant.successSecondary:
      return 'Success outline balancing ${token(IxThemeColorToken.success)} borders over ${token(IxThemeColorToken.color0)} surfaces.';
    case IxButtonVariant.successTertiary:
      return 'Ghost success control for passive confirmations relying on ${token(IxThemeColorToken.success)} text.';
  }
}
