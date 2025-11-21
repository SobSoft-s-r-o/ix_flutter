import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  static const routePath = '/forms';
  static const routeName = 'forms';

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Siemens Energy Gateway',
  );
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dropdownController = TextEditingController();

  final List<DropdownMenuEntry<String>> _statusEntries = const [
    DropdownMenuEntry(value: 'backlog', label: 'Backlog'),
    DropdownMenuEntry(value: 'in-progress', label: 'In progress'),
    DropdownMenuEntry(value: 'validation', label: 'Validation'),
    DropdownMenuEntry(value: 'done', label: 'Done'),
  ];

  DateTime? _selectedDate;
  String? _selectedStatus = 'in-progress';
  bool _aleoMonitoring = true;
  bool _aleoAlarmRouting = false;
  bool _aleoBetaFeatures = true;
  String _aleoDeployment = 'regional';

  @override
  void initState() {
    super.initState();
    _unitController.text = '42';
    _dropdownController.text = 'In progress';
    _selectedDate = DateTime.now();
    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _unitController.dispose();
    _dateController.dispose();
    _dropdownController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ixFields = theme.extension<IxFormFieldTheme>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Form inputs', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Text fields, dropdowns, and pickers below render with IxFormFieldTheme so hover, focus, and semantic states match the design system.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _FormSection(
          title: 'Text fields',
          description:
              'InputDecorationTheme drives spacing, typography, and token-based borders.',
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project name',
                helperText: 'Autofills retain the same component background.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search assets',
                prefixIcon: _FormIcon(child: IxIcons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear query',
                        onPressed: () {
                          setState(_searchController.clear);
                        },
                        icon: const Icon(Icons.close),
                      ),
                helperText: 'Prefix icons inherit iconColor from the theme.',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Tolerance window',
                prefixText: '±',
                suffixText: 'ms',
                helperText:
                    'Suffix and prefix text share the Siemens body style.',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Disabled input',
                hintText: 'Component surfaces drop to color-0.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email address',
                helperText: 'Validation errors pick up alarm borders.',
                errorText: 'Please enter a valid email',
                suffixIcon: _FormIcon(
                  child: IxIcons.alarm,
                  color: ixFields?.error.icon,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FormSection(
          title: 'Dropdowns & pickers',
          description:
              'DropdownMenu and date pickers reuse the same rounded corners and outlines.',
          children: [
            DropdownMenu<String>(
              controller: _dropdownController,
              initialSelection: _selectedStatus,
              label: const Text('Workflow status'),
              onSelected: (value) {
                setState(() => _selectedStatus = value);
              },
              dropdownMenuEntries: _statusEntries,
              leadingIcon: _FormIcon(child: IxIcons.layers),
              trailingIcon: IxIcons.chevronDownSmall,
              selectedTrailingIcon: IxIcons.chevronUpSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Menu overlays inherit ghost surfaces and soft borders.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              enabled: false,
              label: Text('Disabled dropdown'),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 'disabled', label: 'Unavailable'),
              ],
              trailingIcon: IxIcons.chevronDownSmall,
              selectedTrailingIcon: IxIcons.chevronUpSmall,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Due date',
                    helperText:
                        'Tap to open showDatePicker themed by IX tokens.',
                    suffixIcon: _FormIcon(child: IxIcons.calendar),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FormSection(
          title: 'Aleo checkboxes',
          description:
              'Demonstrates Aleo feature toggles wired to standard CheckboxListTile components.',
          children: [
            CheckboxListTile(
              value: _aleoMonitoring,
              onChanged: (value) =>
                  setState(() => _aleoMonitoring = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Enable Aleo monitoring'),
              subtitle: const Text(
                'Streams live KPIs from Aleo sites into the IX dashboard.',
              ),
            ),
            CheckboxListTile(
              value: _aleoAlarmRouting,
              onChanged: (value) =>
                  setState(() => _aleoAlarmRouting = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Route Aleo alarms'),
              subtitle: const Text(
                'Escalate Aleo events to Notification Center recipients.',
              ),
            ),
            CheckboxListTile(
              value: _aleoBetaFeatures,
              onChanged: (value) =>
                  setState(() => _aleoBetaFeatures = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Join Aleo beta channel'),
              subtitle: const Text(
                'Unlock experimental UI controls for upcoming Aleo releases.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FormSection(
          title: 'Aleo deployment radios',
          description:
              'RadioListTile controls use IxRadioTheme for hover, press, and semantic colors.',
          children: [
            RadioListTile<String>(
              value: 'regional',
              groupValue: _aleoDeployment,
              onChanged: (value) =>
                  setState(() => _aleoDeployment = value ?? _aleoDeployment),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Regional redundancy'),
              subtitle: const Text(
                'Standard styling keeps the control subtle while still accessible.',
              ),
            ),
            RadioListTile<String>(
              value: 'global',
              groupValue: _aleoDeployment,
              onChanged: (value) =>
                  setState(() => _aleoDeployment = value ?? _aleoDeployment),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Global active-active'),
              subtitle: const Text(
                'Info semantics highlight mission critical setups.',
              ),
            ),
            RadioListTile<String>(
              value: 'maintenance',
              groupValue: _aleoDeployment,
              onChanged: (value) =>
                  setState(() => _aleoDeployment = value ?? _aleoDeployment),
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Maintenance freeze'),
              subtitle: const Text(
                'Warning styling communicates limited capacity windows.',
              ),
            ),
            RadioListTile<String>(
              value: 'offline',
              groupValue: _aleoDeployment,
              onChanged: null,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Offline (disabled)'),
              subtitle: const Text(
                'Disabled sample inherits IxRadioTheme label colors.',
              ),
            ),
          ],
        ),
        if (ixFields != null) ...[
          const SizedBox(height: 24),
          _FormSection(
            title: 'Semantic banners',
            description:
                'Info, warning, and error states expose IxFormFieldTheme semantic colors for inline callouts.',
            children: [
              _SemanticBanner(
                label: 'Info state',
                message:
                    'Surface subtle hints or descriptions near related inputs.',
                colors: ixFields.info,
                icon: IxIcons.infoFeed,
              ),
              const SizedBox(height: 12),
              _SemanticBanner(
                label: 'Warning state',
                message: 'Use when downstream inputs have limited validity.',
                colors: ixFields.warning,
                icon: IxIcons.maintenanceWarning,
              ),
              const SizedBox(height: 12),
              _SemanticBanner(
                label: 'Error state',
                message: 'Reserve for blocking issues that prevent submission.',
                colors: ixFields.error,
                icon: IxIcons.alarmBell,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _FormIcon extends StatelessWidget {
  const _FormIcon({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? _resolveDecorationIconColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconTheme.merge(
        data: IconTheme.of(context).copyWith(color: resolved, size: 20),
        child: child,
      ),
    );
  }
}

Color _resolveDecorationIconColor(BuildContext context) {
  final decorationTheme = Theme.of(context).inputDecorationTheme;
  final color = decorationTheme.iconColor;
  if (color is WidgetStateColor) {
    return color.resolve(const <WidgetState>{});
  }
  if (color != null) {
    return color;
  }
  final theme = Theme.of(context);
  return theme.iconTheme.color ?? theme.colorScheme.onSurfaceVariant;
}

class _SemanticBanner extends StatelessWidget {
  const _SemanticBanner({
    required this.label,
    required this.message,
    required this.colors,
    required this.icon,
  });

  final String label;
  final String message;
  final IxFormFieldSemanticColors colors;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTheme(
            data: IconTheme.of(context).copyWith(color: colors.icon, size: 24),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
