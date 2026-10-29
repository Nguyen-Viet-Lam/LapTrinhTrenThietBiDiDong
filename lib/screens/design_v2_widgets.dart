import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hiệu ứng số nhảy mượt mà (Smooth Easing Animated Counter)
/// Tự động nội suy giá trị từ cũ sang mới khi điểm XP, Streak, hoặc Level thay đổi.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
  });

  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, current, child) {
        final displayValue = current.round();
        return Text(
          '$prefix$displayValue$suffix',
          style: style,
        );
      },
    );
  }
}

/// Vòng tròn tiến độ phong cách Neon Glass 3D (ProgressRing)
/// Hiển thị phần trăm hoàn thành hoặc cấp độ với hiệu ứng đổ bóng phát sáng và gradient kép.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 72,
    this.strokeWidth = 7,
    this.centerWidget,
    this.startColor = const Color(0xFF38BDF8),
    this.endColor = const Color(0xFF0284C7),
    this.backgroundColor,
    this.showPercentage = true,
    this.percentageStyle,
    this.glow = true,
  });

  final double progress; // Giá trị từ 0.0 -> 1.0
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;
  final Color startColor;
  final Color endColor;
  final Color? backgroundColor;
  final bool showPercentage;
  final TextStyle? percentageStyle;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final bg = backgroundColor ?? Colors.white.withValues(alpha: 0.15);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng tròn vẽ tùy chỉnh với Gradient Arc & Glow
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: clamped),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: animatedProgress,
                  strokeWidth: strokeWidth,
                  startColor: startColor,
                  endColor: endColor,
                  backgroundColor: bg,
                  glow: glow,
                ),
              );
            },
          ),
          // Phần nội dung trung tâm
          if (centerWidget != null)
            centerWidget!
          else if (showPercentage)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: clamped * 100),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) {
                return Text(
                  '${val.round()}%',
                  style: percentageStyle ??
                      TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: size * 0.22,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.startColor,
    required this.endColor,
    required this.backgroundColor,
    required this.glow,
  });

  final double progress;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;
  final Color backgroundColor;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Vẽ vòng nền mờ
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0.0) return;

    final sweepAngle = 2 * math.pi * progress;
    final startAngle = -math.pi / 2; // Bắt đầu từ 12h

    // 2. Vẽ viền phát sáng (Glow Shadow)
    if (glow) {
      final glowPaint = Paint()
        ..color = startColor.withValues(alpha: 0.35)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }

    // 3. Vẽ vòng cung tiến độ với Gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: [startColor, endColor, startColor],
      transform: const GradientRotation(-math.pi / 2),
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}

