import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class ModalsPage extends StatelessWidget {
  const ModalsPage({super.key});

  static const routePath = '/modals';
  static const routeName = 'modals';

  static const List<_ModalExample> _examples = <_ModalExample>[
    _ModalExample(
      cardTitle: 'Standard modal',
      cardDescription:
          'Relies on DialogTheme so padding, radius, and shadows match IX.',
      dialogHeading: 'Workflow confirmation',
      body: [
        'This modal uses the DialogTheme created from IxModalTheme tokens, so the spacing and colors stay aligned with the Siemens IX Stencil implementation.',
        'Use the stock AlertDialog APIs whenever possible to inherit the same rules in your product code.',
      ],
      primaryActionLabel: 'Approve',
      secondaryActionLabel: 'Cancel',
    ),
    _ModalExample(
      cardTitle: 'Inline status',
      cardDescription:
          'Demonstrates a lightweight message with progress feedback.',
      dialogHeading: 'Background processing',
      body: [
        'The dialog body remains scrollable and respects the theme content padding automatically.',
      ],
      busyMessage: 'Validating aleo-diagnostics.zip (2.4 MB)…',
      primaryActionLabel: 'Dismiss',
    ),
    _ModalExample(
      cardTitle: 'Informational copy',
      cardDescription:
          'Multiple paragraphs share the same vertical rhythm from the theme.',
      dialogHeading: 'Security notice',
      body: [
        'Downstream services will switch to read-only mode while maintenance completes. Alerts remain queued until acknowledgements resume.',
        'Preview dialogs like this to verify how far copy stretches before you reach the themed max-width constraint.',
      ],
      primaryActionLabel: 'Got it',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ixModal = theme.extension<IxModalTheme>();

    if (ixModal == null) {
      return const Center(
        child: Text('IxModalTheme was not found on the current Theme.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Modal dialogs', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'These previews intentionally use stock AlertDialog widgets so every dimension comes directly from the DialogTheme wired to IxModalTheme.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _examples
              .map(
                (example) => _ModalExampleCard(
                  example: example,
                  onTap: () => _openExample(context, example),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 32),
        _ModalTokenCard(ixModal: ixModal),
      ],
    );
  }

  Future<void> _openExample(BuildContext context, _ModalExample example) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: example.cardTitle,
      builder: (context) {
        final theme = Theme.of(context);
        final children = <Widget>[
          Text(example.dialogHeading, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
        ];

        for (var i = 0; i < example.body.length; i++) {
          children.add(
            Text(example.body[i], style: theme.textTheme.bodyMedium),
          );
          if (i != example.body.length - 1) {
            children.add(const SizedBox(height: 12));
          }
        }

        if (example.busyMessage != null) {
          if (children.isNotEmpty) {
            children.add(const SizedBox(height: 16));
          }
          children.add(
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    example.busyMessage!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }

        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
          actions: [
            if (example.secondaryActionLabel != null)
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(example.secondaryActionLabel!),
              ),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(example.primaryActionLabel),
            ),
          ],
        );
      },
    );
  }
}

class _ModalExampleCard extends StatelessWidget {
  const _ModalExampleCard({required this.example, required this.onTap});

  final _ModalExample example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 320,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(example.cardTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(example.cardDescription, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onTap,
                child: const Text('Preview modal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalTokenCard extends StatelessWidget {
  const _ModalTokenCard({required this.ixModal});

  final IxModalTheme ixModal;

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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ColorChip('Background', ixModal.backgroundColor),
                _ColorChip('Border', ixModal.borderColor),
                _ColorChip('Backdrop', ixModal.backdropColor),
              ],
            ),
            const SizedBox(height: 16),
            Text('Size presets', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: IxModalSize.values
                  .map(
                    (size) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _sizeLabel(size),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _sizeValueLabel(ixModal.size(size)),
                            style: theme.textTheme.bodySmall,
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

class _ColorChip extends StatelessWidget {
  const _ColorChip(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }
}

String _sizeLabel(IxModalSize size) {
  switch (size) {
    case IxModalSize.xs:
      return '360px';
    case IxModalSize.sm:
      return '480px';
    case IxModalSize.md:
      return '600px';
    case IxModalSize.lg:
      return '720px';
    case IxModalSize.xl:
      return '840px';
    case IxModalSize.fullWidth:
      return 'Full width';
    case IxModalSize.fullScreen:
      return 'Full screen';
  }
}

class _ModalExample {
  const _ModalExample({
    required this.cardTitle,
    required this.cardDescription,
    required this.dialogHeading,
    required this.body,
    this.primaryActionLabel = 'Close',
    this.secondaryActionLabel,
    this.busyMessage,
  });

  final String cardTitle;
  final String cardDescription;
  final String dialogHeading;
  final List<String> body;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final String? busyMessage;
}

String _sizeValueLabel(IxModalSizeSpec spec) {
  if (spec.fullScreen) {
    return '100% viewport (safe areas)';
  }
  if (spec.width != null) {
    return '${spec.width!.toStringAsFixed(0)} px';
  }
  if (spec.widthFactor != null) {
    return '${(spec.widthFactor! * 100).toStringAsFixed(0)}% of width';
  }
  return 'Auto';
}
