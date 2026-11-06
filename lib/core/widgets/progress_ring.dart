import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:moreki/core/theme/app_colors.dart';

/// Keeps a progress value inside 0..1 (and treats NaN as 0).
double clampProgress(double value) {
  if (value.isNaN) return 0;
  return value.clamp(0.0, 1.0).toDouble();
}

/// A thick gradient arc with rounded ends. [value] is 0..1.
/// With [showTicks] a halo of small ticks is drawn around the ring; ticks
/// up to the current progress are lit, the rest stay dim.
/// The ring is a picture; always give [semanticsLabel] so screen readers
/// get the real numbers in words.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.semanticsLabel,
    this.center,
    this.size = 120,
    this.strokeWidth = 12,
    this.colors = const [AppColors.blue, AppColors.cyan, AppColors.green],
    this.showTicks = false,
  });

  final double value;
  final String semanticsLabel;
  final Widget? center;
  final double size;
  final double strokeWidth;
  final List<Color> colors;
  final bool showTicks;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clampProgress(value)),
            duration:
                reduceMotion ? Duration.zero : const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animated, child) => CustomPaint(
              painter: _RingPainter(
                progress: animated,
                colors: colors,
                stroke: strokeWidth,
                showTicks: showTicks,
              ),
              child: child,
            ),
            child: Center(child: center),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.colors,
    required this.stroke,
    required this.showTicks,
  });

  final double progress;
  final List<Color> colors;
  final double stroke;
  final bool showTicks;

  static const int _tickCount = 48;
  static const double _tickLength = 6;
  static const double _tickGap = 6;

  Color _colorAt(double t) {
    if (colors.length == 1) return colors.first;
    final scaled = t.clamp(0.0, 1.0) * (colors.length - 1);
    final i = scaled.floor().clamp(0, colors.length - 2);
    return Color.lerp(colors[i], colors[i + 1], scaled - i)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;

    if (showTicks) {
      final tickPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < _tickCount; i++) {
        final f = i / _tickCount;
        final angle = -math.pi / 2 + 2 * math.pi * f;
        final dir = Offset(math.cos(angle), math.sin(angle));
        final lit = progress > 0 && f < progress;
        tickPaint.color = lit
            ? _colorAt(progress == 0 ? 0 : f / progress)
            : Colors.white.withValues(alpha: 0.14);
        canvas.drawLine(
          center + dir * (outer - _tickLength),
          center + dir * outer,
          tickPaint,
        );
      }
    }

    final inset = showTicks ? _tickLength + _tickGap : 0.0;
    final radius = (size.shortestSide / 2) - inset - stroke / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.max(sweep, 0.01),
        colors: colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect);
    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.colors != colors ||
      old.showTicks != showTicks;
}
