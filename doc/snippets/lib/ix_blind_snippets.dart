import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget uncontrolledBlind() => const IxBlind(
  title: 'Details',
  initiallyExpanded: true, // optional; defaults to false in 1.x
  child: Text('Content...'),
);

Widget controlledBlind({
  required bool expanded,
  required ValueChanged<bool> onExpandedChanged,
}) => IxBlind(
  title: 'Details',
  expanded: expanded,
  onExpandedChanged: onExpandedChanged,
  child: const Text('Content...'),
);

class MyBlindExample extends StatefulWidget {
  const MyBlindExample({super.key});

  @override
  State<MyBlindExample> createState() => _MyBlindExampleState();
}

class _MyBlindExampleState extends State<MyBlindExample> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return IxBlind(
      title: 'Basic Blind',
      subtitle: 'Optional subtitle',
      icon: const IxIcon.key(IxIconKey.info), // Optional leading icon
      expanded: _expanded,
      onExpandedChanged: (value) {
        setState(() {
          _expanded = value;
        });
      },
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('This is the content of the blind.'),
      ),
    );
  }
}

Widget blindWithHeaderActions({
  required bool expanded,
  required ValueChanged<bool> onExpandedChanged,
  required VoidCallback onDelete,
}) => IxBlind(
  title: 'Blind with Actions',
  expanded: expanded,
  onExpandedChanged: onExpandedChanged,
  headerActions: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    ],
  ),
  child: const Text('Content...'),
);

Widget blindAccordion({
  required bool firstExpanded,
  required ValueChanged<bool> onFirstExpandedChanged,
  required bool secondExpanded,
  required ValueChanged<bool> onSecondExpandedChanged,
}) => IxBlindAccordion(
  children: [
    IxBlind(
      title: 'First Blind',
      expanded: firstExpanded,
      onExpandedChanged: onFirstExpandedChanged,
      child: const Text('Content 1'),
    ),
    IxBlind(
      title: 'Second Blind',
      expanded: secondExpanded,
      onExpandedChanged: onSecondExpandedChanged,
      child: const Text('Content 2'),
    ),
  ],
);
