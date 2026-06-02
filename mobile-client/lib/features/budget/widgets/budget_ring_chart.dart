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

    final Color arcColor;
    if (ratio >= 1.0) {
      arcColor = AppColors.error;
    } else if (ratio >= 0.75) {
      arcColor = AppColors.warning;
    } else if (ratio >= 0.5) {
      arcColor = AppColors.secondary;
    } else {
      arcColor = AppColors.primary;
    }

    final progressPaint = Paint()
      ..color = arcColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        rect, -math.pi / 2, ratio * 2 * math.pi, false, progressPaint);

    // Thumb dot — white border circle then colored fill, sits at the arc tip
    final endAngle = -math.pi / 2 + ratio * 2 * math.pi;
    final tipCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    final thumbRadius = strokeWidth / 2;

    canvas.drawCircle(
      tipCenter,
      thumbRadius + 2.5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      tipCenter,
      thumbRadius,
      Paint()..color = arcColor,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio;
}
