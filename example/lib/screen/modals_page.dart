import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class ModalsPage extends StatefulWidget {
  const ModalsPage({super.key});

  static const routePath = '/modals';
  static const routeName = 'modals';

  @override
  State<ModalsPage> createState() => _ModalsPageState();
}

class _ModalsPageState extends State<ModalsPage> {
  final List<_ModalShowcase> _showcases = [
    _ModalShowcase(
      title: 'Inline confirmation',
      description: 'Compact confirm modal without header or footer chrome.',
      size: IxModalSize.xs,
      body: [
        'Pause Aleo notifications for the current workspace? You can re-enable alerts at any time from Notification Center preferences.',
      ],
      primaryLabel: 'OK',
      secondaryLabel: 'Cancel',
      showSecondaryAction: true,
      showHeader: false,
      showFooter: false,
      showCloseButton: true,
      inlineActions: true,
      bodySpacing: 8,
    ),
    _ModalShowcase(
      title: 'Shortcut reminder',
      description: 'Extra-small modal to surface a single keyboard hint.',
      size: IxModalSize.xs,
      icon: IxIcons.keyboard,
      iconColorToken: IxThemeColorToken.info,
      body: [
        'Press ⇧⌘K anytime to open Notification Center without leaving your current view.',
      ],
      primaryLabel: 'Got it',
      secondaryLabel: 'Later',
    ),
    _ModalShowcase(
      title: 'Two-factor prompt',
      description: 'Small modal focused on a single verification step.',
      size: IxModalSize.sm,
      icon: IxIcons.shieldCheck,
      iconColorToken: IxThemeColorToken.success,
      body: [
        'Enter the six-digit backup code from your security key to finish pairing with Aleo.',
      ],
      primaryLabel: 'Verify code',
      secondaryLabel: 'Use another method',
    ),
    _ModalShowcase(
      title: 'Standard approval',
      description:
          'Medium modal with supporting bullet list and action buttons.',
      size: IxModalSize.md,
      icon: IxIcons.info,
      iconColorToken: IxThemeColorToken.info,
      body: [
        'New Aleo deployments must be reviewed before routing data into IX dashboards. Use this dialog to confirm scopes and notify downstream owners.',
      ],
      checklist: [
        'Validate connector scopes and API throttles',
        'Notify the objective owners in Notification Center',
        'Log an audit trail entry for compliance teams',
      ],
      primaryLabel: 'Approve deployment',
      secondaryLabel: 'Cancel',
    ),
    _ModalShowcase(
      title: 'Maintenance window',
      description:
          'Large modal with warning iconography and longer supporting copy.',
      size: IxModalSize.lg,
      icon: IxIcons.maintenanceWarning,
      iconColorToken: IxThemeColorToken.warning,
      body: [
        'Aleo services are entering a planned maintenance window. Downstream partners should throttle throughput and capture local buffers until service resumes.',
        'Paused alerts resume once the window closes. Use the outline action to skip the maintenance window if you need immediate access.',
      ],
      checklist: [
        'Throttle throughput to 40% during upgrades',
        'Queue Notification Center alerts while offline',
        'Send recap email when maintenance completes',
      ],
      primaryLabel: 'Acknowledge',
      secondaryLabel: 'Skip window',
    ),
    _ModalShowcase(
      title: 'Background processing',
      description:
          'Small modal referencing the modal-loading component spacing.',
      size: IxModalSize.sm,
      body: [
        'Aleo is validating six uploaded archives. You can keep an eye on the validation progress from this lightweight status dialog.',
      ],
      busyMessage: 'Checking aleo-diagnostics.zip (2.4 MB)…',
      primaryLabel: 'Dismiss',
      showSecondaryAction: false,
    ),
    _ModalShowcase(
      title: 'Full-screen audit trail',
      description:
          'Full-screen takeover removes the radius, border, and box shadow.',
      size: IxModalSize.fullScreen,
      icon: IxIcons.layers,
      iconColorToken: IxThemeColorToken.primary,
      body: [
        'Use the takeover layout when modals need to handle complex flows like multi-step audit reviews or detailed configuration editors. The IxModalTheme exposes width factors and max-height fractions so you can size dialogs consistently.',
        'Full-screen dialogs respect safe areas, drop the default radius, and disable shadows while keeping the same padding and footer spacing tokens.',
      ],
      primaryLabel: 'Close review',
      showSecondaryAction: false,
      alignment: Alignment.topCenter,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ixModal = Theme.of(context).extension<IxModalTheme>();
    final theme = Theme.of(context);

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
          'IxModalTheme exposes Siemens IX modal paddings, outlines, and width presets so dialogs match the Stencil implementation.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _showcases
              .map(
                (showcase) => _ModalDemoCard(
                  showcase: showcase,
                  onTap: () => _openShowcase(showcase),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 32),
        _ModalTokenCard(ixModal: ixModal),
      ],
    );
  }

  Future<void> _openShowcase(_ModalShowcase showcase) async {
    final ixModal = Theme.of(context).extension<IxModalTheme>();
    if (ixModal == null) {
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: showcase.title,
      barrierColor: ixModal.backdropColor.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondary) {
        return _ModalDemoOverlay(ixModal: ixModal, showcase: showcase);
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );
  }
}

class _ModalDemoOverlay extends StatelessWidget {
  const _ModalDemoOverlay({required this.ixModal, required this.showcase});

  final IxModalTheme ixModal;
  final _ModalShowcase showcase;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sizeSpec = ixModal.size(showcase.size);
    final widthFactor = sizeSpec.widthFactor ?? 1.0;
    final maxWidth = sizeSpec.fullScreen
        ? media.size.width
        : sizeSpec.width ?? media.size.width * widthFactor;
    final maxHeight = media.size.height * sizeSpec.maxHeightFraction;

    final padding = sizeSpec.fullScreen
        ? EdgeInsets.zero
        : EdgeInsets.all(ixModal.dialogPadding);

    return SafeArea(
      child: Padding(
        padding: padding,
        child: Align(
          alignment: showcase.alignment,
          child: _ModalSurface(
            ixModal: ixModal,
            showcase: showcase,
            width: maxWidth,
            maxHeight: sizeSpec.fullScreen ? media.size.height : maxHeight,
            fullScreen: sizeSpec.fullScreen,
          ),
        ),
      ),
    );
  }
}

class _ModalSurface extends StatelessWidget {
  const _ModalSurface({
    required this.ixModal,
    required this.showcase,
    required this.width,
    required this.maxHeight,
    required this.fullScreen,
  });

  final IxModalTheme ixModal;
  final _ModalShowcase showcase;
  final double width;
  final double maxHeight;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final borderRadius = fullScreen ? 0.0 : ixModal.borderRadius;
    final hasFloatingClose = !showcase.showHeader && showcase.showCloseButton;
    final columnMainAxisSize = fullScreen ? MainAxisSize.max : MainAxisSize.min;

    final columnChildren = <Widget>[];
    if (showcase.showHeader) {
      columnChildren.add(_ModalHeader(ixModal: ixModal, showcase: showcase));
      columnChildren.add(Divider(color: dividerColor, height: 1));
    }

    final Widget bodyPane = fullScreen
        ? Expanded(
            child: _ModalContent(
              ixModal: ixModal,
              showcase: showcase,
              hasFloatingClose: hasFloatingClose,
            ),
          )
        : Flexible(
            fit: FlexFit.loose,
            child: _ModalContent(
              ixModal: ixModal,
              showcase: showcase,
              hasFloatingClose: hasFloatingClose,
            ),
          );

    columnChildren.add(bodyPane);

    if (showcase.showFooter) {
      columnChildren.add(Divider(color: dividerColor, height: 1));
      columnChildren.add(_ModalFooter(ixModal: ixModal, showcase: showcase));
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            width: width,
            constraints: fullScreen
                ? BoxConstraints.tightFor(width: width, height: maxHeight)
                : BoxConstraints(maxHeight: maxHeight, minWidth: 320),
            decoration: BoxDecoration(
              color: ixModal.backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: ixModal.borderColor,
                width: ixModal.borderWidth,
              ),
              boxShadow: fullScreen ? null : ixModal.shadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: columnMainAxisSize,
              children: columnChildren,
            ),
          ),
          if (hasFloatingClose)
            Positioned(
              top: ixModal.contentPadding.top,
              right: ixModal.contentPadding.right,
              child: IconButton(
                tooltip: 'Close dialog',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: IxIcons.close,
              ),
            ),
        ],
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.ixModal, required this.showcase});

  final IxModalTheme ixModal;
  final _ModalShowcase showcase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ixTheme = theme.extension<IxTheme>();
    final iconColor = showcase.iconColorToken == null
        ? theme.colorScheme.primary
        : ixTheme?.color(showcase.iconColorToken!) ?? theme.colorScheme.primary;

    return Padding(
      padding: ixModal.headerPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showcase.icon != null)
            Padding(
              padding: EdgeInsets.only(right: ixModal.headerGap),
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: 24),
                child: showcase.icon!,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(showcase.title, style: theme.textTheme.titleLarge),
                if (showcase.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      showcase.description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
          if (showcase.showCloseButton)
            IconButton(
              tooltip: 'Close dialog',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: IxIcons.close,
            ),
        ],
      ),
    );
  }
}

class _ModalContent extends StatelessWidget {
  const _ModalContent({
    required this.ixModal,
    required this.showcase,
    required this.hasFloatingClose,
  });

  final IxModalTheme ixModal;
  final _ModalShowcase showcase;
  final bool hasFloatingClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodySpacing = showcase.bodySpacing ?? 12.0;

    final children = <Widget>[];
    final paragraphs = showcase.body;
    if (paragraphs.isNotEmpty) {
      for (var i = 0; i < paragraphs.length; i++) {
        children.add(Text(paragraphs[i], style: theme.textTheme.bodyMedium));
        if (i != paragraphs.length - 1) {
          children.add(SizedBox(height: bodySpacing));
        }
      }
    }

    if (showcase.checklist.isNotEmpty) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: bodySpacing));
      }
      children.add(
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: showcase.checklist
              .map((item) => _ModalChecklistItem(text: item))
              .toList(),
        ),
      );
    }

    if (showcase.busyMessage != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: bodySpacing));
      }
      children.add(
        _ModalLoadingRow(ixModal: ixModal, message: showcase.busyMessage!),
      );
    }

    if (showcase.inlineActions) {
      if (children.isNotEmpty) {
        children.add(SizedBox(height: ixModal.footerGap));
      }
      children.add(
        _ModalInlineActions(showcase: showcase, gap: ixModal.footerGap),
      );
    }

    var contentPadding = ixModal.contentPadding;
    if (hasFloatingClose) {
      contentPadding = EdgeInsets.fromLTRB(
        contentPadding.left,
        contentPadding.top + ixModal.headerPadding.top + 16,
        contentPadding.right + ixModal.headerPadding.left,
        contentPadding.bottom,
      );
    }

    return Padding(
      padding: contentPadding,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _ModalChecklistItem extends StatelessWidget {
  const _ModalChecklistItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTheme(
            data: IconTheme.of(
              context,
            ).copyWith(color: theme.colorScheme.secondary, size: 18),
            child: IxIcons.check,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ModalLoadingRow extends StatelessWidget {
  const _ModalLoadingRow({required this.ixModal, required this.message});

  final IxModalTheme ixModal;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2.4),
        ),
        SizedBox(width: ixModal.footerGap),
        Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

class _ModalFooter extends StatelessWidget {
  const _ModalFooter({required this.ixModal, required this.showcase});

  final IxModalTheme ixModal;
  final _ModalShowcase showcase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ixModal.footerPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showcase.showSecondaryAction) ...[
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(showcase.secondaryLabel),
            ),
            SizedBox(width: ixModal.footerGap),
          ],
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(showcase.primaryLabel),
          ),
        ],
      ),
    );
  }
}

class _ModalInlineActions extends StatelessWidget {
  const _ModalInlineActions({required this.showcase, required this.gap});

  final _ModalShowcase showcase;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showcase.showSecondaryAction) ...[
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(showcase.secondaryLabel),
          ),
          SizedBox(width: gap),
        ],
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(showcase.primaryLabel),
        ),
      ],
    );
  }
}

class _ModalDemoCard extends StatelessWidget {
  const _ModalDemoCard({required this.showcase, required this.onTap});

  final _ModalShowcase showcase;
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
              Text(showcase.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(showcase.description, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Chip(label: Text(_sizeLabel(showcase.size))),
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

class _ModalShowcase {
  const _ModalShowcase({
    required this.title,
    required this.description,
    required this.size,
    this.icon,
    this.iconColorToken,
    this.body = const <String>[],
    this.checklist = const <String>[],
    this.primaryLabel = 'Continue',
    this.secondaryLabel = 'Cancel',
    this.showSecondaryAction = true,
    this.busyMessage,
    this.showHeader = true,
    this.showFooter = true,
    this.showCloseButton = true,
    this.inlineActions = false,
    this.alignment = Alignment.center,
    this.bodySpacing,
  });

  final String title;
  final String description;
  final IxModalSize size;
  final Widget? icon;
  final IxThemeColorToken? iconColorToken;
  final List<String> body;
  final List<String> checklist;
  final String primaryLabel;
  final String secondaryLabel;
  final bool showSecondaryAction;
  final String? busyMessage;
  final bool showHeader;
  final bool showFooter;
  final bool showCloseButton;
  final bool inlineActions;
  final Alignment alignment;
  final double? bodySpacing;
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
