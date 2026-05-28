import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';

class OnboardingSlide extends StatelessWidget {
  final String step;
  final String headline;
  final String body;
  final String imagePath;
  final IconData badgeIcon;

  const OnboardingSlide({
    super.key,
    required this.step,
    required this.headline,
    required this.body,
    required this.imagePath,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final blobWidth = screenWidth * 0.76;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 58,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _LeafDecorationPainter()),
              ),
              Center(
                child: _BlobImage(
                  imagePath: imagePath,
                  badgeIcon: badgeIcon,
                  width: blobWidth,
                  height: blobWidth * 1.12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 42,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  step,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.neutral600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  headline,
                  style: AppTypography.display.copyWith(
                    fontSize: 30,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  body,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.neutral600,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BlobImage extends StatelessWidget {
  final String imagePath;
  final IconData badgeIcon;
  final double width;
  final double height;

  const _BlobImage({
    required this.imagePath,
    required this.badgeIcon,
    required this.width,
    required this.height,
  });

  static const BorderRadius _blobRadius = BorderRadius.only(
    topLeft: Radius.circular(130),
    topRight: Radius.circular(100),
    bottomLeft: Radius.circular(90),
    bottomRight: Radius.circular(130),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: _blobRadius,
            child: Image.asset(
              imagePath,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: _blobRadius,
              border: Border.all(color: AppColors.primary, width: 3.5),
            ),
          ),
          Positioned(
            top: 18,
            right: 6,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(badgeIcon, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    _drawLeaf(canvas, paint, Offset(size.width * 0.06, size.height * 0.28), 20, -35.0);
    _drawLeaf(canvas, paint, Offset(size.width * 0.10, size.height * 0.42), 13, -58.0);
    _drawLeaf(canvas, paint, Offset(size.width * 0.87, size.height * 0.58), 18, 42.0);
    _drawLeaf(canvas, paint, Offset(size.width * 0.83, size.height * 0.72), 12, 26.0);
    _drawLeaf(canvas, paint, Offset(size.width * 0.78, size.height * 0.08), 15, -18.0);
  }

  void _drawLeaf(
    Canvas canvas,
    Paint paint,
    Offset center,
    double leafSize,
    double angleDeg,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleDeg * math.pi / 180);

    final path = Path();
    path.moveTo(0, -leafSize);
    path.quadraticBezierTo(leafSize * 0.76, -leafSize * 0.25, 0, leafSize * 0.35);
    path.quadraticBezierTo(-leafSize * 0.76, -leafSize * 0.25, 0, -leafSize);
    path.close();
    canvas.drawPath(path, paint);

    final stemPaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(0, leafSize * 0.35), stemPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}
