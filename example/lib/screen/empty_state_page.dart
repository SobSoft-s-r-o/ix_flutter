import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class EmptyStatePage extends StatelessWidget {
  const EmptyStatePage({super.key});

  static const routePath = '/empty-state';
  static const routeName = 'empty-state';

  @override
  Widget build(BuildContext context) {
    final ixButtons = Theme.of(context).extension<IxButtonTheme>();

    return Scaffold(
      appBar: AppBar(title: const Text('Empty State')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            IxEmptyState(
              icon: IxIcons.add,
              title: 'No elements available',
              subtitle: 'Create an element first',
              primaryAction: FilledButton(
                style: ixButtons?.style(IxButtonVariant.primary),
                onPressed: () {},
                child: const Text('Create element'),
              ),
            ),

            const Divider(height: 48),

            const Text(
              'No Results Example (Compact)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            IxEmptyState(
              layout: IxEmptyStateLayout.compact,
              icon: IxIcons.search,
              title: 'No results found',
              subtitle: 'Try adjusting your search terms',
              primaryAction: FilledButton(
                style: ixButtons?.style(IxButtonVariant.secondary),
                onPressed: () {},
                child: const Text('Clear search'),
              ),
            ),

            const Divider(height: 48),

            const Text(
              'Error Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            IxEmptyState(
              type: IxEmptyStateType.error,
              icon: IxIcons.error,
              title: 'Something went wrong',
              subtitle: 'Please try again later',
              primaryAction: FilledButton(
                style: ixButtons?.style(IxButtonVariant.primary),
                onPressed: () {},
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
