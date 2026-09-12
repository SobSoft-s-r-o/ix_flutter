import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget largeEmptyState(VoidCallback onCreate) => IxEmptyState(
  icon: const IxIcon.key(IxIconKey.document),
  title: 'No elements available',
  subtitle: 'Create an element first',
  primaryAction: FilledButton(
    onPressed: onCreate,
    child: const Text('Create element'),
  ),
);

Widget compactEmptyState(VoidCallback onClearSearch) => IxEmptyState(
  layout: IxEmptyStateLayout.compact,
  icon: const IxIcon.key(IxIconKey.search),
  title: 'No results found',
  subtitle: 'Try adjusting your search terms',
  primaryAction: FilledButton(
    onPressed: onClearSearch,
    child: const Text('Clear search'),
  ),
);

Widget errorEmptyState(VoidCallback onRetry) => IxEmptyState(
  icon: const IxIcon.key(IxIconKey.error),
  title: 'Something went wrong',
  subtitle: 'Please try again later',
  primaryAction: FilledButton(onPressed: onRetry, child: const Text('Retry')),
);
