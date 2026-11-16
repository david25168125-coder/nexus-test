import 'dart:math';
import 'package:flutter/material.dart';

class SOCRing extends StatelessWidget {
  final double percentage;
  final double size;

  const SOCRing({
    super.key,
    required this.percentage,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SOCRingPainter(percentage),
        child: Center(
          child: Text(
            "${percentage.toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SOCRingPainter extends CustomPainter {
  final double percentage;

  _SOCRingPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final radius = (size.width / 2) - strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00FF9A),
          Color(0xFF4DA3FF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
