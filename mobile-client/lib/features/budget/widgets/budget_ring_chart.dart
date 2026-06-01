import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class BudgetRingChart extends StatelessWidget {
  final double spent;
  final double total;
  final double size;
  final double strokeWidth;

  const BudgetRingChart({
    super.key,
    required this.spent,
    required this.total,
    this.size = 200,
    this.strokeWidth = 18,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(ratio: ratio, strokeWidth: strokeWidth),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Spent this month',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'RM ',
                      style: AppTypography.headline2
                          .copyWith(color: AppColors.primary),
                    ),
                    TextSpan(
                      text: spent.toStringAsFixed(0),
                      style: AppTypography.budgetHero.copyWith(fontSize: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'of RM ${total.toStringAsFixed(0)}',
                style: AppTypography.body2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ratio;
  final double strokeWidth;

  const _RingPainter({required this.ratio, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.neutral200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);

    if (ratio <= 0) return;

    // ui.Gradient.sweep uses the same radian convention as canvas.drawArc
    // (0 rad = 3 o'clock, positive = clockwise), so -π/2 = 12 o'clock.
    // Arc start = green, midpoint = teal, near-full = amber — no hard seams.
    final shader = ui.Gradient.sweep(
      center,
      [AppColors.primary, AppColors.secondary, AppColors.warning],
      [0.0, 0.5, 1.0],
      TileMode.clamp,
      -math.pi / 2,
      -math.pi / 2 + 2 * math.pi,
    );

    final progressPaint = Paint()
      ..shader = shader
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        rect, -math.pi / 2, ratio * 2 * math.pi, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio;
}
