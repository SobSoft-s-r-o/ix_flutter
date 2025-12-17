import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class BlindPage extends StatefulWidget {
  const BlindPage({super.key});

  static const routePath = '/blind';
  static const routeName = 'blind';

  @override
  State<BlindPage> createState() => _BlindPageState();
}

class _BlindPageState extends State<BlindPage> {
  // State for examples
  bool _basicExpanded = false;
  bool _headerActionsExpanded = false;

  // State for variants
  final Map<IxBlindVariant, bool> _variantStates = {
    for (var v in IxBlindVariant.values) v: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blind')),
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
            IxBlind(
              title: 'Basic Blind',
              subtitle: 'This is a basic blind example',
              expanded: _basicExpanded,
              onExpandedChanged: (value) =>
                  setState(() => _basicExpanded = value),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Content of the basic blind.'),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Header Actions Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            IxBlind(
              title: 'Blind with Actions',
              icon: IxIcons.about, // Using an available icon
              headerActions: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {},
                    tooltip: 'Delete',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                    tooltip: 'More',
                  ),
                ],
              ),
              expanded: _headerActionsExpanded,
              onExpandedChanged: (value) =>
                  setState(() => _headerActionsExpanded = value),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Content with header actions.'),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Variants Example',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            IxBlindAccordion(
              children: IxBlindVariant.values.map((variant) {
                return IxBlind(
                  title: '${variant.name} Variant',
                  subtitle: 'Subtitle for ${variant.name}',
                  variant: variant,
                  expanded: _variantStates[variant]!,
                  onExpandedChanged: (value) =>
                      setState(() => _variantStates[variant] = value),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Content for ${variant.name} variant.'),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
