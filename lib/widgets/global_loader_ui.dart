import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../services/loading_service.dart';

class GlobalLoaderUI extends StatelessWidget {
  final Widget child;

  const GlobalLoaderUI({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LoadingService().isLoading,
      child: child,
      builder: (context, isLoading, cachedChild) {
        return Stack(
          children: [
            cachedChild!,
            if (isLoading) const Positioned.fill(child: _LoaderScreen()),
          ],
        );
      },
    );
  }
}

class _LoaderScreen extends StatefulWidget {
  const _LoaderScreen();

  @override
  State<_LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<_LoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.deepBlue.withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LOADING...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 250,
                  height: 25,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _StripedProgressPainter(
                          progress: _controller.value,
                          color: AppColors.deepBlue,
                          gradient: AppColors.primaryGradient,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StripedProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Gradient gradient;

  _StripedProgressPainter({
    required this.progress,
    required this.color,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );

    // Draw Border
    canvas.drawRRect(rRect, borderPaint);

    // Draw Stripes
    if (progress > 0) {
      final double fillWidth = (size.width - 4) * progress;

      canvas.save();

      // Clip to the progress area (accounting for border padding)
      final RRect fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, fillWidth, size.height - 4),
        Radius.circular((size.height - 4) / 2),
      );
      canvas.clipRRect(fillRect);

      final Paint stripePaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..style = PaintingStyle.fill;

      // Draw diagonal stripes
      const double stripeWidth = 6.0;
      const double stripeGap = 6.0;
      final double totalWidth =
          size.width + size.height; // Cover diagonal overflow

      for (
        double x = -size.height;
        x < totalWidth;
        x += (stripeWidth + stripeGap)
      ) {
        final Path stripePath = Path()
          ..moveTo(x, size.height)
          ..lineTo(x + stripeWidth, size.height)
          ..lineTo(x + stripeWidth + size.height, 0)
          ..lineTo(x + size.height, 0)
          ..close();

        canvas.drawPath(stripePath, stripePaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StripedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
