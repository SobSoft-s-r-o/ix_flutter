import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:siemens_ix_flutter/src/ix_theme/components/ix_spinner_theme.dart';

/// Animated Siemens IX spinner that pulls its colors and sizing from
/// [IxSpinnerTheme].
class IxSpinner extends StatefulWidget {
  const IxSpinner({
    super.key,
    this.size = IxSpinnerSize.medium,
    this.variant = IxSpinnerVariant.standard,
    this.hideTrack = false,
  });

  final IxSpinnerSize size;
  final IxSpinnerVariant variant;
  final bool hideTrack;

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

    _rotationController
      ..duration = rotationDuration
      ..repeat();
    _sweepController
      ..duration = maskDuration
      ..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spinnerTheme = Theme.of(context).extension<IxSpinnerTheme>();
    if (spinnerTheme == null) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }

    final spec = spinnerTheme.size(widget.size);
    final style = spinnerTheme.style(widget.variant);

    return SizedBox(
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
