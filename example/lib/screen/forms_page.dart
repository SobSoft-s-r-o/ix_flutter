import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import '../edge_to_edge.dart';

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
  final TextEditingController _notesController = TextEditingController(
    text:
        'Summaries from Aleo dispatchers sync here so investigators can triage.',
  );

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
  bool _aleoNotifications = true;
  bool _aleoGlobalBroadcast = false;
  bool _aleoMaintenanceThrottle = true;
  bool _aleoAlarmMute = false;
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
    _notesController.dispose();
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
    final ixToggles = theme.extension<IxToggleTheme>();
    final ixUpload = theme.extension<IxUploadTheme>();

    return ListView(
      padding: EdgeToEdge.scrollPadding(context),
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
            const _FieldLabel('Project name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                helperText: 'Autofills retain the same component background.',
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Search assets'),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
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
            const _FieldLabel('Tolerance window'),
            const SizedBox(height: 8),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                prefixText: '±',
                suffixText: 'ms',
                helperText:
                    'Suffix and prefix text share the Siemens body style.',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Disabled input', state: IxLabelState.disabled),
            const SizedBox(height: 8),
            const TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Component surfaces drop to color-0.',
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Email address'),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                helperText: 'Validation errors pick up alarm borders.',
                errorText: 'Please enter a valid email',
                suffixIcon: _FormIcon(
                  child: IxIcons.alarm,
                  color: ixFields?.error.icon,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Incident summary'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                helperText:
                    'Multi-line text areas reuse IxFormFieldTheme states.',
                hintText: 'Describe the Aleo site context and mitigation plan.',
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
            const _FieldLabel('Workflow status'),
            const SizedBox(height: 8),
            DropdownMenu<String>(
              controller: _dropdownController,
              initialSelection: _selectedStatus,
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
            const _FieldLabel(
              'Disabled dropdown',
              state: IxLabelState.disabled,
            ),
            const SizedBox(height: 8),
            DropdownMenu<String>(
              enabled: false,
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 'disabled', label: 'Unavailable'),
              ],
              trailingIcon: IxIcons.chevronDownSmall,
              selectedTrailingIcon: IxIcons.chevronUpSmall,
            ),
            const SizedBox(height: 16),
            const _FieldLabel('Due date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
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
          title: 'Aleo toggles',
          description:
              'SwitchListTile controls showcase IxToggleTheme track, thumb, and semantic accents.',
          children: [
            SwitchListTile(
              value: _aleoNotifications,
              onChanged: (value) => setState(() => _aleoNotifications = value),
              title: const Text('Notifications enabled'),
              subtitle: const Text(
                'Standard toggle styling covers hover, press, and disabled states.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SwitchTheme(
              data:
                  ixToggles?.themeData(IxToggleStatus.info) ??
                  const SwitchThemeData(),
              child: SwitchListTile(
                value: _aleoGlobalBroadcast,
                onChanged: (value) =>
                    setState(() => _aleoGlobalBroadcast = value),
                title: const Text('Global broadcast'),
                subtitle: const Text(
                  'Info semantics align with guidance for mission-critical cues.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            SwitchTheme(
              data:
                  ixToggles?.themeData(IxToggleStatus.warning) ??
                  const SwitchThemeData(),
              child: SwitchListTile(
                value: _aleoMaintenanceThrottle,
                onChanged: (value) =>
                    setState(() => _aleoMaintenanceThrottle = value),
                title: const Text('Maintenance throttle'),
                subtitle: const Text(
                  'Warning styling communicates partial capacity windows.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            SwitchTheme(
              data:
                  ixToggles?.themeData(IxToggleStatus.invalid) ??
                  const SwitchThemeData(),
              child: SwitchListTile(
                value: _aleoAlarmMute,
                onChanged: (value) => setState(() => _aleoAlarmMute = value),
                title: const Text('Mute alarm relays'),
                subtitle: const Text(
                  'Invalid semantics highlight destructive or error-prone choices.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            SwitchListTile(
              value: false,
              onChanged: null,
              title: const Text('Disabled toggle'),
              subtitle: const Text(
                'Disabled sample inherits IxToggleTheme weaker thumb and track.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
        if (ixUpload != null) ...[
          const SizedBox(height: 24),
          _FormSection(
            title: 'File uploads',
            description:
                'IxUploadTheme exposes dropzone padding, dashed outlines, and semantic colors for drag states.',
            children: [_UploadDropzoneGallery(theme: ixUpload)],
          ),
        ],
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.state = IxLabelState.standard});

  final String text;
  final IxLabelState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ixLabelTheme = theme.extension<IxLabelTheme>();
    final fallback = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final style = ixLabelTheme?.style(state) ?? fallback;
    return Text(text, style: style);
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

class _UploadDropzoneGallery extends StatelessWidget {
  const _UploadDropzoneGallery({required this.theme});

  final IxUploadTheme theme;

  @override
  Widget build(BuildContext context) {
    final states = IxUploadSurfaceState.values;
    return Column(
      children: [
        for (var index = 0; index < states.length; index++) ...[
          _UploadDropzoneTile(theme: theme, state: states[index]),
          if (index != states.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _UploadDropzoneTile extends StatelessWidget {
  const _UploadDropzoneTile({required this.theme, required this.state});

  final IxUploadTheme theme;
  final IxUploadSurfaceState state;

  bool get _isDisabled => state == IxUploadSurfaceState.disabled;
  bool get _isBusy => state == IxUploadSurfaceState.checking;

  @override
  Widget build(BuildContext context) {
    final surface = theme.style(state);
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleSmall?.copyWith(
      color: surface.textColor,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = textTheme.bodyMedium?.copyWith(color: surface.textColor);
    final borderRadius = BorderRadius.circular(theme.borderRadius);
    final leading = _buildLeading(context, surface.textColor);
    final messageRowChildren = <Widget>[
      if (leading != null) ...[leading, const SizedBox(width: 8)],
      Expanded(child: Text(_uploadMessage(state), style: bodyStyle)),
    ];
    final buttonEnabled = !(_isDisabled || _isBusy);

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      constraints: BoxConstraints(minHeight: theme.minHeight),
      padding: theme.padding,
      decoration: BoxDecoration(
        color: surface.background,
        borderRadius: borderRadius,
        border: surface.borderStyle == IxUploadBorderStyle.dashed
            ? null
            : Border.all(color: surface.borderColor, width: theme.borderWidth),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_uploadTitle(state), style: titleStyle),
                const SizedBox(height: 6),
                Row(children: messageRowChildren),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: buttonEnabled ? () {} : null,
            child: const Text('Upload file…'),
          ),
        ],
      ),
    );

    if (surface.borderStyle == IxUploadBorderStyle.dashed) {
      container = _DashedBorder(
        color: surface.borderColor,
        strokeWidth: theme.borderWidth,
        borderRadius: borderRadius,
        child: container,
      );
    }

    return container;
  }

  Widget? _buildLeading(BuildContext context, Color textColor) {
    switch (state) {
      case IxUploadSurfaceState.checking:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        );
      case IxUploadSurfaceState.dragOver:
        return IconTheme(
          data: IconTheme.of(context).copyWith(color: textColor, size: 20),
          child: IxIcons.cloudUpload,
        );
      case IxUploadSurfaceState.disabled:
        return Icon(Icons.block, size: 20, color: textColor);
      case IxUploadSurfaceState.idle:
        return IconTheme(
          data: IconTheme.of(context).copyWith(color: textColor, size: 20),
          child: IxIcons.upload,
        );
    }
  }
}

class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  final Widget child;
  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
        dashLength: 8,
        gapLength: 4,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final BorderRadius borderRadius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Offset.zero & size;
    final safeWidth = rect.width - strokeWidth;
    final safeHeight = rect.height - strokeWidth;
    final deflated = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      safeWidth > 0 ? safeWidth : 0,
      safeHeight > 0 ? safeHeight : 0,
    );
    final rrect = borderRadius.toRRect(deflated);
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashLength) < metric.length
            ? distance + dashLength
            : metric.length;
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}

String _uploadTitle(IxUploadSurfaceState state) {
  switch (state) {
    case IxUploadSurfaceState.idle:
      return 'Select files';
    case IxUploadSurfaceState.dragOver:
      return 'Drop to upload';
    case IxUploadSurfaceState.checking:
      return 'Validating files';
    case IxUploadSurfaceState.disabled:
      return 'Upload unavailable';
  }
}

String _uploadMessage(IxUploadSurfaceState state) {
  switch (state) {
    case IxUploadSurfaceState.idle:
      return '+ Drag files here or browse your system.';
    case IxUploadSurfaceState.dragOver:
      return 'Release to upload aleo-diagnostic.zip';
    case IxUploadSurfaceState.checking:
      return 'Checking files…';
    case IxUploadSurfaceState.disabled:
      return 'File upload currently not possible.';
  }
}
