import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import '../edge_to_edge.dart';

class DropdownButtonPage extends StatelessWidget {
  const DropdownButtonPage({super.key});

  static const routePath = '/dropdown-button';
  static const routeName = 'dropdown-button';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown Button')),
      body: ListView(
        padding: EdgeToEdge.scrollPadding(context),
        children: [
          _buildSection(
            context,
            'Basic Example',
            const IxDropdownButtonExampleBasic(),
          ),
          _buildSection(
            context,
            'Icon Example',
            const IxDropdownButtonExampleIcon(),
          ),
          _buildSection(
            context,
            'Placements',
            const IxDropdownButtonExamplePlacements(),
          ),
          _buildSection(
            context,
            'Variants',
            const IxDropdownButtonExampleVariants(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}

class IxDropdownButtonExampleBasic extends StatelessWidget {
  const IxDropdownButtonExampleBasic({super.key});

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<String>(
      label: 'Open Dropdown',
      items: const [
        IxDropdownMenuItem(label: 'Item 1', value: '1'),
        IxDropdownMenuItem(label: 'Item 2', value: '2'),
        IxDropdownMenuItem(label: 'Item 3', value: '3'),
      ],
      onItemSelected: (value) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Selected: $value')));
      },
    );
  }
}

class IxDropdownButtonExampleIcon extends StatelessWidget {
  const IxDropdownButtonExampleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<String>(
      label: 'Dropdown with Icon',
      icon: IxIcons.star,
      items: const [
        IxDropdownMenuItem(
          label: 'Action 1',
          value: '1',
          icon: Icon(Icons.cut, size: 16),
        ),
        IxDropdownMenuItem(
          label: 'Action 2',
          value: '2',
          icon: Icon(Icons.copy, size: 16),
        ),
        IxDropdownMenuItem(
          label: 'Action 3',
          value: '3',
          icon: Icon(Icons.paste, size: 16),
        ),
      ],
      onItemSelected: (value) {
        print('Selected: $value');
      },
    );
  }
}

class IxDropdownButtonExamplePlacements extends StatelessWidget {
  const IxDropdownButtonExamplePlacements({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        IxDropdownButton<String>(
          label: 'Bottom Start',
          placement: IxDropdownPlacement.bottomStart,
          items: const [IxDropdownMenuItem(label: 'Item', value: '1')],
        ),
        IxDropdownButton<String>(
          label: 'Bottom End',
          placement: IxDropdownPlacement.bottomEnd,
          items: const [IxDropdownMenuItem(label: 'Item', value: '1')],
        ),
        IxDropdownButton<String>(
          label: 'Top Start',
          placement: IxDropdownPlacement.topStart,
          items: const [IxDropdownMenuItem(label: 'Item', value: '1')],
        ),
        IxDropdownButton<String>(
          label: 'Top End',
          placement: IxDropdownPlacement.topEnd,
          items: const [IxDropdownMenuItem(label: 'Item', value: '1')],
        ),
      ],
    );
  }
}

class IxDropdownButtonExampleVariants extends StatelessWidget {
  const IxDropdownButtonExampleVariants({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: IxDropdownButtonVariant.values.map((variant) {
        return IxDropdownButton<String>(
          label: variant.name,
          variant: variant,
          items: const [IxDropdownMenuItem(label: 'Item', value: '1')],
        );
      }).toList(),
    );
  }
}
