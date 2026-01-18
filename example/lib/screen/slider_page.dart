import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

import '../edge_to_edge.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  static const routePath = '/sliders';
  static const routeName = 'sliders';

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _standardValue = 48;
  double _steppedValue = 4;
  double _indicatorValue = 72;
  final double _disabledValue = 24;
  RangeValues _rangeValues = const RangeValues(25, 75);
  double _infoValue = 36;
  double _warningValue = 60;
  final double _invalidValue = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeToEdge.scrollPadding(context),
      children: [
        Text('Slider controls', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Sliders inherit IxSliderTheme so their thumb, trace, and track colors stay aligned with Siemens IX tokens across states.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _SliderSection(
          title: 'Continuous controls',
          description:
              'Standard sliders cover continuous and discrete adjustments plus disabled visuals.',
          children: [
            _SliderTile(
              title: 'Live value',
              subtitle: 'Drag to preview the default dynamic accent track.',
              slider: Slider(
                value: _standardValue,
                min: 0,
                max: 100,
                label: '${_standardValue.round()}%',
                onChanged: (value) => setState(() => _standardValue = value),
              ),
            ),
            _SliderTile(
              title: 'Stepped thresholds',
              subtitle: 'Divisions add anchors for discrete ranges.',
              slider: Slider(
                value: _steppedValue,
                min: 0,
                max: 8,
                divisions: 8,
                label: '${_steppedValue.round()}',
                onChanged: (value) => setState(() => _steppedValue = value),
              ),
            ),
            _SliderTile(
              title: 'Disabled example',
              subtitle: 'Shows component surfaces without interactions.',
              slider: Slider(
                value: _disabledValue,
                min: 0,
                max: 100,
                onChanged: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SliderSection(
          title: 'Variants',
          description:
              'Range sliders and persistent value indicators reuse the Ix slider primitives.',
          children: [
            _SliderTile(
              title: 'Range selection',
              subtitle: 'Pick both lower and upper limits in one gesture.',
              slider: RangeSlider(
                values: _rangeValues,
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  '${_rangeValues.start.round()}%',
                  '${_rangeValues.end.round()}%',
                ),
                onChanged: (value) => setState(() => _rangeValues = value),
              ),
            ),
            _SliderTile(
              title: 'Always-on indicator',
              subtitle:
                  'Useful for exact tuning while preserving Siemens type.',
              slider: SliderTheme(
                data: theme.sliderTheme.copyWith(
                  showValueIndicator: ShowValueIndicator.onDrag,
                ),
                child: Slider(
                  value: _indicatorValue,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_indicatorValue.round()}%',
                  onChanged: (value) => setState(() => _indicatorValue = value),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SliderSection(
          title: 'Semantic styling',
          description:
              'Info, warning, and invalid treatments pull their palette straight from IxSliderTheme.',
          children: [
            _semanticTile(
              context,
              title: 'Info bandwidth cap',
              subtitle: 'Highlights informational ranges for operators.',
              status: IxSliderStatus.info,
              value: _infoValue,
              onChanged: (value) => setState(() => _infoValue = value),
            ),
            _semanticTile(
              context,
              title: 'Warning capacity',
              subtitle: 'Use warning tokens when throughput nears limits.',
              status: IxSliderStatus.warning,
              value: _warningValue,
              onChanged: (value) => setState(() => _warningValue = value),
            ),
            _semanticTile(
              context,
              title: 'Invalid lockout',
              subtitle: 'Alarm styling makes blocking ranges stand out.',
              status: IxSliderStatus.invalid,
              value: _invalidValue,
              onChanged: null,
            ),
          ],
        ),
      ],
    );
  }

  static Widget _semanticTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IxSliderStatus status,
    required double value,
    required ValueChanged<double>? onChanged,
  }) {
    final sliderTheme = _semanticTheme(context, status);

    return _SliderTile(
      title: title,
      subtitle: subtitle,
      slider: SliderTheme(
        data: sliderTheme,
        child: Slider(
          value: value,
          min: 0,
          max: 100,
          label: '${value.round()}%',
          divisions: 20,
          onChanged: onChanged,
        ),
      ),
    );
  }

  static SliderThemeData _semanticTheme(
    BuildContext context,
    IxSliderStatus status,
  ) {
    final ixSliderTheme = Theme.of(context).extension<IxSliderTheme>();
    final colors = ixSliderTheme?.style(status);
    final base = Theme.of(context).sliderTheme;
    if (colors == null) {
      return base;
    }

    return base.copyWith(
      activeTrackColor: colors.trace,
      inactiveTrackColor: colors.track,
      disabledActiveTrackColor: colors.traceDisabled,
      disabledInactiveTrackColor: colors.trackDisabled,
      thumbColor: colors.thumb,
      disabledThumbColor: colors.thumbDisabled,
      overlayColor: colors.thumbHover.withValues(alpha: 0.3),
      activeTickMarkColor: colors.marker,
      inactiveTickMarkColor: colors.marker,
      disabledActiveTickMarkColor: colors.markerDisabled,
      disabledInactiveTickMarkColor: colors.markerDisabled,
      valueIndicatorColor: colors.thumb,
      valueIndicatorTextStyle: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: Colors.white),
      showValueIndicator: ShowValueIndicator.onDrag,
    );
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection({
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
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({required this.title, required this.slider, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        slider,
      ],
    );
  }
}
