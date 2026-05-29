import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';

// Shared leaf path — used by all painters
void _drawOrganicLeaf(
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
  path.cubicTo(
    leafSize * 0.65, -leafSize * 0.45,
    leafSize * 0.65, leafSize * 0.20,
    0, leafSize * 0.42,
  );
  path.cubicTo(
    -leafSize * 0.65, leafSize * 0.20,
    -leafSize * 0.65, -leafSize * 0.45,
    0, -leafSize,
  );
  path.close();
  canvas.drawPath(path, paint);
  canvas.restore();
}

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
    final screenSize = MediaQuery.of(context).size;

    // Cap blob so it never exceeds 42% of screen height on large devices
    final maxFromWidth = screenSize.width * 0.76;
    final maxFromHeight = (screenSize.height * 0.42) / 1.12;
    final blobWidth = math.min(maxFromWidth, maxFromHeight);
    final blobHeight = blobWidth * 1.12;

    // Border leaf canvas size — leaf centered in a 2S×2S box
    final bls = blobWidth * 0.10;

    return Stack(
      children: [
        // Background leaves span the full slide, framing the blob from outside
        Positioned.fill(
          child: CustomPaint(painter: _LeafDecorationPainter()),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wrapper Stack: border leaves below, blob on top.
              // Blob image covers leaf portions inside its bounds;
              // Clip.none lets the outside portions remain visible.
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Left border leaf ──────────────────────────────────────
                    // Canvas 2bls×2bls centered at blob's left edge, 60% down.
                    Positioned(
                      left: -bls,
                      top: blobHeight * 0.60 - bls,
                      child: CustomPaint(
                        size: Size(bls * 2, bls * 2),
                        painter: const _SingleLeafPainter(angleDeg: -120),
                      ),
                    ),
                    // ── Bottom border leaf ────────────────────────────────────
                    // Canvas centered at 70% across blob, on the bottom edge.
                    Positioned(
                      left: blobWidth * 0.70 - bls,
                      top: blobHeight - bls,
                      child: CustomPaint(
                        size: Size(bls * 1.8, bls * 1.8),
                        painter: const _SingleLeafPainter(angleDeg: 172),
                      ),
                    ),
                    // ── Blob image on top — covers leaf interior ──────────────
                    _BlobImage(
                      imagePath: imagePath,
                      badgeIcon: badgeIcon,
                      width: blobWidth,
                      height: blobHeight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            ],
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

  BorderRadius get _blobRadius => BorderRadius.only(
        topLeft: Radius.circular(width * 0.44),
        topRight: Radius.circular(width * 0.34),
        bottomLeft: Radius.circular(width * 0.30),
        bottomRight: Radius.circular(width * 0.44),
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

// Draws a single leaf centered in its canvas — used for border-overlap leaves.
class _SingleLeafPainter extends CustomPainter {
  final double angleDeg;
  const _SingleLeafPainter({required this.angleDeg});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    _drawOrganicLeaf(
      canvas,
      paint,
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      angleDeg,
    );
  }

  @override
  bool shouldRepaint(covariant _SingleLeafPainter old) => old.angleDeg != angleDeg;
}

// Background leaves that frame the blob from the outside on the full slide canvas
class _LeafDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final solid = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final faded = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Left side — just outside the blob's left edge (~12% of width)
    _drawOrganicLeaf(canvas, solid, Offset(size.width * 0.05, size.height * 0.22), 22, -30.0);
    _drawOrganicLeaf(canvas, faded, Offset(size.width * 0.07, size.height * 0.40), 14, -52.0);

    // Right side — just outside the blob's right edge (~88% of width)
    _drawOrganicLeaf(canvas, solid, Offset(size.width * 0.93, size.height * 0.18), 18, 35.0);
    _drawOrganicLeaf(canvas, faded, Offset(size.width * 0.92, size.height * 0.46), 16, 50.0);

    // Small accent above the blob
    _drawOrganicLeaf(canvas, solid, Offset(size.width * 0.76, size.height * 0.06), 13, -20.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) => false;
}
