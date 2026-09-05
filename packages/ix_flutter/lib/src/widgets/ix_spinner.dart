import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_colors/theme/ix_classic_light_colors.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_spinner_theme.dart';

/// Animated Siemens IX spinner that pulls its colors and sizing from
/// [IxSpinnerTheme].
///
/// Exposes a [SemanticsRole.status] node labelled [semanticLabel] (defaults
/// to `'Loading'`) so assistive technologies announce the loading state, and
/// stops its repeating animation -- rather than merely slowing it down --
/// when the platform's reduced-motion preference
/// (`MediaQuery.disableAnimationsOf`) is set. When no [IxThemeBuilder] theme
/// is present, it still renders its own custom-painted arc (sized and
/// colored from the classic light palette) instead of a Material
/// [CircularProgressIndicator].
class IxSpinner extends StatefulWidget {
  const IxSpinner({
    super.key,
    this.size = IxSpinnerSize.medium,
    this.variant = IxSpinnerVariant.secondary,
    this.hideTrack = false,
    this.semanticLabel,
  });

  final IxSpinnerSize size;
  final IxSpinnerVariant variant;
  final bool hideTrack;

  /// The label announced by assistive technologies for the spinner's
  /// [SemanticsRole.status] node.
  ///
  /// Defaults to `'Loading'` when unset.
  final String? semanticLabel;

  @override
  State<IxSpinner> createState() => _IxSpinnerState();
}

class _IxSpinnerState extends State<IxSpinner> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this);
    _sweepController = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final spinnerTheme = Theme.of(context).extension<IxSpinnerTheme>();
    final rotationDuration =
        spinnerTheme?.rotationDuration ?? const Duration(seconds: 2);
    final maskDuration =
        spinnerTheme?.maskDuration ?? const Duration(seconds: 3);

    if (MediaQuery.disableAnimationsOf(context)) {
      // Reduced motion: stop rather than merely speed up the animation, and
      // park both controllers at a fixed, sensible frame instead of leaving
      // a repeating ticker alive.
      _rotationController.stop();
      _sweepController.stop();
      _rotationController.value = 0;
      _sweepController.value = 0.25;
    } else {
      _rotationController
        ..duration = rotationDuration
        ..repeat();
      _sweepController
        ..duration = maskDuration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spinnerTheme =
        Theme.of(context).extension<IxSpinnerTheme>() ??
        IxSpinnerTheme.fromPalette(palette: IxClassicLightColors.palette);

    final spec = spinnerTheme.size(widget.size);
    final style = spinnerTheme.style(widget.variant);

    return Semantics(
      role: SemanticsRole.status,
      liveRegion: false,
      label: widget.semanticLabel ?? 'Loading',
      child: SizedBox(
        width: spec.diameter,
        height: spec.diameter,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _sweepController]),
          builder: (context, _) {
            final startAngle = _rotationController.value * 2 * math.pi;
            final sweepAngle = _calculateSweepAngle(_sweepController.value);

            return CustomPaint(
              painter: _SpinnerPainter(
                startAngle: startAngle,
                sweepAngle: sweepAngle,
                strokeWidth: spec.trackWidth,
                indicatorColor: style.indicatorColor,
                trackColor: widget.hideTrack
                    ? Colors.transparent
                    : style.trackColor,
                insetFraction: spinnerTheme.ringInsetFraction,
              ),
            );
          },
        ),
      ),
    );
  }

  double _calculateSweepAngle(double controllerValue) {
    const double minSweep = math.pi / 3; // 60 degrees.
    const double maxSweep = math.pi * 1.8; // 324 degrees.
    final normalized =
        (math.sin((controllerValue * 2 * math.pi) - math.pi / 2) + 1) / 2;
    return lerpDouble(minSweep, maxSweep, normalized);
  }

  double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.strokeWidth,
    required this.indicatorColor,
    required this.trackColor,
    required this.insetFraction,
  });

  final double startAngle;
  final double sweepAngle;
  final double strokeWidth;
  final Color indicatorColor;
  final Color trackColor;
  final double insetFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = math.min(size.width, size.height);
    final inset = shortestSide * insetFraction;
    final rect =
        Offset(inset, inset) &
        Size(shortestSide - inset * 2, shortestSide - inset * 2);
    final paintStroke = strokeWidth.clamp(1, rect.width).toDouble();

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = paintStroke
      ..strokeCap = StrokeCap.butt;

    if (trackColor.a > 0) {
      canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);
    }

    final indicatorPaint = trackPaint..color = indicatorColor;
    canvas.drawArc(rect, startAngle, sweepAngle, false, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return startAngle != oldDelegate.startAngle ||
        sweepAngle != oldDelegate.sweepAngle ||
        strokeWidth != oldDelegate.strokeWidth ||
        indicatorColor != oldDelegate.indicatorColor ||
        trackColor != oldDelegate.trackColor ||
        insetFraction != oldDelegate.insetFraction;
  }
}
