import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

class MyDropdownExample extends StatelessWidget {
  const MyDropdownExample({super.key});

  @override
  Widget build(BuildContext context) {
    return IxDropdownButton<String>(
      label: 'Open Menu',
      items: const [
        IxDropdownMenuItem(label: 'Action 1', value: '1'),
        IxDropdownMenuItem(label: 'Action 2', value: '2'),
      ],
      onItemSelected: (value) {
        debugPrint('Selected: $value');
      },
    );
  }
}

Widget dropdownWithIconAndVariant(ValueChanged<String> onItemSelected) =>
    IxDropdownButton<String>(
      label: 'Settings',
      icon: const IxIcon.key(IxIconKey.cogwheel, size: IxIconSize.s16),
      buttonVariant: IxButtonVariant.secondary,
      items: const [
        IxDropdownMenuItem(
          label: 'Profile',
          value: 'profile',
          icon: Icon(Icons.person, size: 16),
        ),
        IxDropdownMenuItem(
          label: 'Logout',
          value: 'logout',
          icon: Icon(Icons.logout, size: 16),
        ),
      ],
      onItemSelected: onItemSelected,
    );

Widget dropdownWithCheckedItem() => const IxDropdownButton<String>(
  label: 'Sort by',
  items: [
    IxDropdownMenuItem(label: 'Name', value: 'name', checked: true),
    IxDropdownMenuItem(label: 'Date', value: 'date'),
  ],
);

Widget controlledDropdown({
  required bool isOpen,
  required ValueChanged<bool> onOpenChanged,
}) => IxDropdownButton<String>(
  label: 'Actions',
  isOpen: isOpen,
  onOpenChanged: onOpenChanged,
  items: const [IxDropdownMenuItem(label: 'Edit', value: 'edit')],
);

Widget dropdownWithOpenVeto({
  required bool formIsValid,
  required List<IxDropdownMenuItem<String>> items,
}) => IxDropdownButton<String>(
  label: 'Actions',
  onWillOpen: () => formIsValid,
  items: items,
);

Widget dropdownWithPlacement(List<IxDropdownMenuItem<String>> items) =>
    IxDropdownButton<String>(
      label: 'Top Start',
      placement: IxDropdownPlacement.topStart,
      items: items,
    );
