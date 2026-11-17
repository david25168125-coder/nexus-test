import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'water_status.dart';

class WaterUsageChart extends StatelessWidget {
  final List<WaterUsagePoint> history;
  const WaterUsageChart({super.key, required this.history});
  @override
  Widget build(BuildContext context) {
    final points =
        history.length > 7 ? history.sublist(history.length - 7) : history;
    final description = points.isEmpty
        ? 'No water usage history available'
        : points
            .map((p) =>
                '${p.date.day}/${p.date.month}: ${p.litres.toStringAsFixed(1)} litres')
            .join(', ');
    return Semantics(
        label: description,
        child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Stack(alignment: Alignment.center, children: [
              Positioned.fill(child: CustomPaint(painter: _WaterBars(points))),
              if (points.isEmpty)
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 36, color: Color(0xFF88ACDC)),
                      SizedBox(height: 12),
                      Text('Your usage history will appear here',
                          textAlign: TextAlign.center),
                      SizedBox(height: 6),
                      Text('Connect meter history to see daily consumption.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 12, color: Colors.white38)),
                    ])),
            ])));
  }
}

class _WaterBars extends CustomPainter {
  final List<WaterUsagePoint> points;
  _WaterBars(this.points);
  void label(Canvas canvas, String text, Offset position,
      {Color color = Colors.white54}) {
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: color)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(canvas, position - Offset(painter.width / 2, 0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bottom = size.height - 28;
    final plot = Rect.fromLTRB(8, 24, size.width - 8, bottom);
    final grid = Paint()
      ..color = const Color(0xFF273340)
      ..strokeWidth = 1;
    for (var line = 0; line < 4; line++) {
      final y = plot.top + plot.height * line / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
    }
    if (points.isEmpty) return;
    final maximum = math.max(1.0, points.map((p) => p.litres).reduce(math.max));
    final slot = plot.width / points.length;
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = plot.left + slot * (i + 0.5);
      final height = point.litres / maximum * (plot.height - 22);
      final bar = Rect.fromLTRB(x - slot * 0.25, bottom - math.max(2, height),
          x + slot * 0.25, bottom);
      canvas.drawRRect(
          RRect.fromRectAndRadius(bar, const Radius.circular(6)),
          Paint()
            ..shader = const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF88ACDC), Color(0xFF366C90)])
                .createShader(bar));
      label(canvas, '${point.litres.toStringAsFixed(0)} L',
          Offset(x, bar.top - 18));
      label(canvas, '${point.date.day}/${point.date.month}',
          Offset(x, bottom + 10));
    }
  }

  @override
  bool shouldRepaint(covariant _WaterBars oldDelegate) =>
      oldDelegate.points != points;
}
