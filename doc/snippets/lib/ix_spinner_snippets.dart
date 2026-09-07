import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget spinnerBasics() => const Column(
  children: [
    // Default medium spinner
    IxSpinner(),
    // Custom size
    IxSpinner(size: IxSpinnerSize.large),
    // Primary variant
    IxSpinner(variant: IxSpinnerVariant.primary),
    // Without track (just the animated arc)
    IxSpinner(hideTrack: true),
  ],
);

Widget inlineSpinner() => const Row(
  children: [
    Text('Loading'),
    SizedBox(width: 8),
    IxSpinner(size: IxSpinnerSize.xSmall),
  ],
);

Widget fullPageSpinner() =>
    const Center(child: IxSpinner(size: IxSpinnerSize.large));

Widget secondarySpinner() =>
    const IxSpinner(variant: IxSpinnerVariant.secondary);

Widget primarySpinner() => const IxSpinner(variant: IxSpinnerVariant.primary);

Widget submitButton({
  required bool isLoading,
  required VoidCallback onSubmit,
}) => FilledButton(
  onPressed: isLoading ? null : onSubmit,
  child: isLoading
      ? const IxSpinner(size: IxSpinnerSize.small, hideTrack: true)
      : const Text('Submit'),
);

Widget loadingOverlay({required bool isLoading, required Widget content}) =>
    Stack(
      children: [
        content,
        if (isLoading)
          const ColoredBox(
            color: Colors.black54,
            child: Center(
              child: IxSpinner(
                size: IxSpinnerSize.large,
                variant: IxSpinnerVariant.primary,
              ),
            ),
          ),
      ],
    );

Widget loadingListItem() => const ListTile(
  title: Text('Processing...'),
  trailing: IxSpinner(size: IxSpinnerSize.small),
);

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IxSpinner(
              size: IxSpinnerSize.large,
              variant: IxSpinnerVariant.primary,
            ),
            const SizedBox(height: 24),
            Text('Loading...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

ThemeData withSpinnerOverrides(ThemeData base) {
  final spinner = base.extension<IxSpinnerTheme>();
  if (spinner == null) return base; // not an IxThemeBuilder theme
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...base.extensions.values,
      spinner.copyWith(
        rotationDuration: const Duration(seconds: 2),
        maskDuration: const Duration(seconds: 3),
        ringInsetFraction: 0.0833,
      ),
    ],
  );
}

Widget labelledSpinner() => const IxSpinner(semanticLabel: 'Loading content');

Widget spinnerWithVisibleLabel() => const Column(
  children: [IxSpinner(), SizedBox(height: 8), Text('Loading...')],
);
