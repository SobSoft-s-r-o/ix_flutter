import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';
import '../toast_provider.dart';

class ToastPage extends StatelessWidget {
  const ToastPage({super.key});

  static const routePath = '/toast';
  static const routeName = 'toast';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<IxTheme>();
    final typography = theme?.typography;

    if (theme == null || typography == null) {
      return const Center(child: Text('IxTheme not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic', style: typography.h2),
          const SizedBox(height: 16),
          const IxToastExampleBasic(),
          const SizedBox(height: 32),
          Text('With Title', style: typography.h2),
          const SizedBox(height: 16),
          const IxToastExampleTitle(),
          const SizedBox(height: 32),
          Text('Types', style: typography.h2),
          const SizedBox(height: 16),
          const IxToastExampleTypes(),
          const SizedBox(height: 32),
          Text('Action', style: typography.h2),
          const SizedBox(height: 16),
          const IxToastExampleAction(),
        ],
      ),
    );
  }
}

class IxToastExampleBasic extends StatelessWidget {
  const IxToastExampleBasic({super.key});

  @override
  Widget build(BuildContext context) {
    final ixButtons = Theme.of(context).extension<IxButtonTheme>();
    return FilledButton(
      style: ixButtons?.style(IxButtonVariant.primary),
      onPressed: () {
        ToastProvider.of(context).show(message: 'My toast message!');
      },
      child: const Text('Trigger toast'),
    );
  }
}

class IxToastExampleTypes extends StatelessWidget {
  const IxToastExampleTypes({super.key});

  @override
  Widget build(BuildContext context) {
    final ixButtons = Theme.of(context).extension<IxButtonTheme>();
    final style = ixButtons?.style(IxButtonVariant.secondary);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(
          style: style,
          onPressed: () {
            ToastProvider.of(
              context,
            ).show(type: IxToastType.info, message: 'Info toast');
          },
          child: const Text('Info'),
        ),
        FilledButton(
          style: style,
          onPressed: () {
            ToastProvider.of(
              context,
            ).show(type: IxToastType.success, message: 'Success toast');
          },
          child: const Text('Success'),
        ),
        FilledButton(
          style: style,
          onPressed: () {
            ToastProvider.of(
              context,
            ).show(type: IxToastType.warning, message: 'Warning toast');
          },
          child: const Text('Warning'),
        ),
        FilledButton(
          style: style,
          onPressed: () {
            ToastProvider.of(
              context,
            ).show(type: IxToastType.critical, message: 'Critical toast');
          },
          child: const Text('Critical'),
        ),
        FilledButton(
          style: style,
          onPressed: () {
            ToastProvider.of(
              context,
            ).show(type: IxToastType.alarm, message: 'Alarm toast');
          },
          child: const Text('Alarm'),
        ),
      ],
    );
  }
}

class IxToastExampleAction extends StatelessWidget {
  const IxToastExampleAction({super.key});

  @override
  Widget build(BuildContext context) {
    final ixButtons = Theme.of(context).extension<IxButtonTheme>();
    return FilledButton(
      style: ixButtons?.style(IxButtonVariant.primary),
      onPressed: () {
        ToastProvider.of(context).show(
          message: 'Toast with action',
          actionLabel: 'Undo',
          onAction: () {
            print('Action clicked');
          },
        );
      },
      child: const Text('Trigger toast with action'),
    );
  }
}

class IxToastExampleTitle extends StatelessWidget {
  const IxToastExampleTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final ixButtons = Theme.of(context).extension<IxButtonTheme>();
    return FilledButton(
      style: ixButtons?.style(IxButtonVariant.primary),
      onPressed: () {
        ToastProvider.of(
          context,
        ).show(title: 'Toast Title', message: 'Toast message with a title');
      },
      child: const Text('Trigger toast with title'),
    );
  }
}
