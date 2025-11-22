import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class SpinnerPage extends StatelessWidget {
  const SpinnerPage({super.key});

  static const routePath = '/spinners';
  static const routeName = 'spinners';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spinnerTheme = theme.extension<IxSpinnerTheme>();

    if (spinnerTheme == null) {
      return const Center(
        child: Text('IxSpinnerTheme was not found on the current Theme.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Spinners', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'These examples solely rely on the IxSpinnerTheme extension, so every spinner automatically inherits Siemens IX sizes and colors.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text('Size presets', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: IxSpinnerSize.values
              .map(
                (size) => _SpinnerSizeCard(
                  size: size,
                  description: _sizeDescription(size),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 32),
        Text('Variants', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _SpinnerVariantCard(variant: IxSpinnerVariant.standard),
            _SpinnerVariantCard(variant: IxSpinnerVariant.primary),
          ],
        ),
        const SizedBox(height: 32),
        _SpinnerTokenCard(spinnerTheme: spinnerTheme),
      ],
    );
  }
}

class _SpinnerSizeCard extends StatelessWidget {
  const _SpinnerSizeCard({required this.size, required this.description});

  final IxSpinnerSize size;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_sizeLabel(size), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              const SizedBox(height: 4),
              Center(child: IxSpinner(size: size)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinnerVariantCard extends StatelessWidget {
  const _SpinnerVariantCard({required this.variant});

  final IxSpinnerVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_variantLabel(variant), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Uses the ${variant == IxSpinnerVariant.primary ? 'dynamic/ghost hover' : 'soft text/component-3'} palette pairing.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Center(
                child: IxSpinner(size: IxSpinnerSize.medium, variant: variant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinnerTokenCard extends StatelessWidget {
  const _SpinnerTokenCard({required this.spinnerTheme});

  final IxSpinnerTheme spinnerTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Token summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Sizes', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: IxSpinnerSize.values
                  .map(
                    (size) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(_sizeLabel(size)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(_sizeValueLabel(spinnerTheme.size(size))),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Variants', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: IxSpinnerVariant.values
                  .map(
                    (variant) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(_variantLabel(variant)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _variantValueLabel(spinnerTheme.style(variant)),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

String _sizeLabel(IxSpinnerSize size) {
  switch (size) {
    case IxSpinnerSize.xxSmall:
      return 'XX-small';
    case IxSpinnerSize.xSmall:
      return 'X-small';
    case IxSpinnerSize.small:
      return 'Small';
    case IxSpinnerSize.medium:
      return 'Medium';
    case IxSpinnerSize.large:
      return 'Large';
  }
}

String _sizeDescription(IxSpinnerSize size) {
  switch (size) {
    case IxSpinnerSize.xxSmall:
      return 'Compact spinner for inline control adornments.';
    case IxSpinnerSize.xSmall:
      return 'Use inside dense cards or data tables.';
    case IxSpinnerSize.small:
      return 'Default size for inline busy states.';
    case IxSpinnerSize.medium:
      return 'Ideal for dialogs and section-level loading.';
    case IxSpinnerSize.large:
      return 'Hero spinner for page-level busy states.';
  }
}

String _sizeValueLabel(IxSpinnerSizeSpec spec) {
  final diameter = spec.diameter.toStringAsFixed(0);
  final stroke = spec.trackWidth.toStringAsFixed(0);
  return '$diameter px diameter • $stroke px stroke';
}

String _variantLabel(IxSpinnerVariant variant) {
  switch (variant) {
    case IxSpinnerVariant.standard:
      return 'Standard';
    case IxSpinnerVariant.primary:
      return 'Primary';
  }
}

String _variantValueLabel(IxSpinnerVariantStyle style) {
  String toHex(Color color) =>
      color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
  return 'Indicator: ${toHex(style.indicatorColor)} • Track: ${toHex(style.trackColor)}';
}
