import 'dart:math';
import 'package:flutter/material.dart';
import 'tesla_icons.dart';

class TeslaEnergyMap extends StatefulWidget {
  final double solarKw;
  final double batteryKw;

  final double liveGridKw;
  final double liveHomeKw;
  final double liveEvKw;

  final double solarDayKwh;
  final double batteryDayKwh;
  final double evDayKwh;
  final double gridDayKwh;
  final double homeDayKwh;

  final double importTariffP;
  final double exportTariffP;

  final bool solarComms;
  final bool batteryComms;
  final bool evComms;
  final bool gridComms;

  final bool solarFault;
  final bool batteryFault;
  final bool evFault;
  final bool gridFault;

  final int homeCostBand;

  const TeslaEnergyMap({
    super.key,
    required this.solarKw,
    required this.batteryKw,
    required this.liveGridKw,
    required this.liveHomeKw,
    required this.liveEvKw,
    required this.solarDayKwh,
    required this.batteryDayKwh,
    required this.evDayKwh,
    required this.gridDayKwh,
    required this.homeDayKwh,
    required this.importTariffP,
    required this.exportTariffP,
    required this.solarComms,
    required this.batteryComms,
    required this.evComms,
    required this.gridComms,
    required this.solarFault,
    required this.batteryFault,
    required this.evFault,
    required this.gridFault,
    required this.homeCostBand,
  });

  @override
  State<TeslaEnergyMap> createState() => _TeslaEnergyMapState();
}

class _TeslaEnergyMapState extends State<TeslaEnergyMap>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  int cycleMode = 0;

  bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _cycle() {
    setState(() {
      cycleMode = (cycleMode + 1) % 4;
    });
  }

  Color _homeRingColor() {
    final grid = widget.liveGridKw.abs();
    final solar = widget.solarKw > 0 ? widget.solarKw : 0;
    final battery = widget.batteryKw < 0 ? widget.batteryKw.abs() : 0;
    final tariff = widget.importTariffP;

    double stress = (grid * tariff)
        - (solar * (widget.exportTariffP * 0.5))
        - (battery * 10);

    if (stress < 0) stress = 0;

    if (stress < 20) return Colors.green;
    if (stress < 60) return Colors.yellow;
    return Colors.red;
  }

  Color _ringColor({
    required bool comms,
    required bool fault,
    required bool active,
    required Color activeColor,
  }) {
    if (fault) return Colors.red;
    if (!comms) return Colors.blue;
    if (active) return activeColor;
    return Colors.grey;
  }

  double _valueForNode({
    required double liveKw,
    required double dailyKwh,
    required bool isSolar,
    required bool isBattery,
    required bool isGrid,
  }) {
    switch (cycleMode) {
      case 0:
        return liveKw;
      case 1:
        if (isSolar) return liveKw * (widget.exportTariffP / 100);
        if (isBattery && liveKw < 0) return 0;
        return liveKw * (widget.importTariffP / 100);
      case 2:
        return dailyKwh;
      case 3:
        if (isSolar) return dailyKwh * (widget.exportTariffP / 100);
        if (isBattery) return 0;
        return dailyKwh * (widget.importTariffP / 100);
      default:
        return liveKw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final landscape = isLandscape(context);

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
              child: CustomPaint(
                painter: _TeslaFlowPainter(
                  context: context,
                  animation: controller,
                  landscape: landscape,

                  solarKw: widget.solarKw,
                  batteryKw: widget.batteryKw,
                  evKw: widget.liveEvKw,
                  gridKw: widget.liveGridKw,
                  homeKw: widget.liveHomeKw,

                  solarDisplay: _valueForNode(
                    liveKw: widget.solarKw,
                    dailyKwh: widget.solarDayKwh,
                    isSolar: true,
                    isBattery: false,
                    isGrid: false,
                  ),
                  batteryDisplay: _valueForNode(
                    liveKw: widget.batteryKw,
                    dailyKwh: widget.batteryDayKwh,
                    isSolar: false,
                    isBattery: true,
                    isGrid: false,
                  ),
                  evDisplay: _valueForNode(
                    liveKw: widget.liveEvKw,
                    dailyKwh: widget.evDayKwh,
                    isSolar: false,
                    isBattery: false,
                    isGrid: false,
                  ),
                  gridDisplay: _valueForNode(
                    liveKw: widget.liveGridKw,
                    dailyKwh: widget.gridDayKwh,
                    isSolar: false,
                    isBattery: false,
                    isGrid: true,
                  ),
                  homeDisplay: _valueForNode(
                    liveKw: widget.liveHomeKw,
                    dailyKwh: widget.homeDayKwh,
                    isSolar: false,
                    isBattery: false,
                    isGrid: false,
                  ),

                  solarColor: Colors.grey,
                  batteryColor: Colors.grey,

                  evColor: widget.evFault
                      ? Colors.red
                      : !widget.evComms
                          ? Colors.blue
                          : widget.liveEvKw.abs() > 0.05
                              ? Colors.green
                              : Colors.grey,

                  gridColor: _ringColor(
                    comms: widget.gridComms,
                    fault: widget.gridFault,
                    active: widget.liveGridKw.abs() > 0.05,
                    activeColor: Colors.green,
                  ),

                  homeColor: _homeRingColor(),

                  solarLabel: "Solar ${widget.exportTariffP.toStringAsFixed(1)}p",
                  gridLabel: "Grid ${widget.importTariffP.toStringAsFixed(1)}p",
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),

        ],
      );
    }
  }

class _TeslaFlowPainter extends CustomPainter {
  final BuildContext context;
  final Animation<double> animation;
  final bool landscape;

  final double solarKw;
  final double batteryKw;
  final double evKw;
  final double gridKw;
  final double homeKw;

  final double solarDisplay;
  final double batteryDisplay;
  final double evDisplay;
  final double gridDisplay;
  final double homeDisplay;

  final Color solarColor;
  final Color batteryColor;
  final Color evColor;
  final Color gridColor;
  final Color homeColor;

  final String solarLabel;
  final String gridLabel;

  _TeslaFlowPainter({
    required this.context,
    required this.animation,
    required this.landscape,
    required this.solarKw,
    required this.batteryKw,
    required this.evKw,
    required this.gridKw,
    required this.homeKw,
    required this.solarDisplay,
    required this.batteryDisplay,
    required this.evDisplay,
    required this.gridDisplay,
    required this.homeDisplay,
    required this.solarColor,
    required this.batteryColor,
    required this.evColor,
    required this.gridColor,
    required this.homeColor,
    required this.solarLabel,
    required this.gridLabel,
  }) : super(repaint: animation);

  double get smallRadius => landscape ? 32 : 40;
  double get homeRadius  => landscape ? 48 : 60;
  double get labelSize   => landscape ? 13 : 16;

  Offset _edgePoint(Offset from, Offset to, double radius) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final dist = sqrt(dx * dx + dy * dy);
    if (dist == 0) return from;
    final ux = dx / dist;
    final uy = dy / dist;
    return Offset(from.dx + ux * radius, from.dy + uy * radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    double verticalOffset   = size.height * (landscape ? 0.22 : 0.28);
    double horizontalOffset = size.width  * (landscape ? 0.32 : 0.28);

    final solarPos   = Offset(center.dx, center.dy - verticalOffset);
    final batteryPos = Offset(center.dx, center.dy + verticalOffset);
    final gridPos    = Offset(center.dx - horizontalOffset, center.dy);
    final evPos      = Offset(center.dx + horizontalOffset, center.dy);

    if (solarKw.abs() > 0.05) {
      _drawBaseLine(canvas, solarPos, center, smallRadius, homeRadius);
    }
    if (gridKw.abs() > 0.05) {
      _drawBaseLine(canvas, gridPos, center, smallRadius, homeRadius);
    }
    if (evKw.abs() > 0.05) {
      _drawBaseLine(canvas, evPos, center, smallRadius, homeRadius);
    }
    if (batteryKw.abs() > 0.05) {
      _drawBaseLine(canvas, batteryPos, center, smallRadius, homeRadius);
    }

    _drawNode(canvas, solarPos, smallRadius, solarColor, TeslaIcons.solar,
        solarDisplay, label: solarLabel, labelAbove: true);

    _drawNode(canvas, gridPos, smallRadius, gridColor, TeslaIcons.grid,
        gridDisplay, label: gridLabel, labelAbove: true);

    _drawNode(canvas, evPos, smallRadius, evColor, TeslaIcons.ev, evDisplay,
        label: "EV", labelAbove: true);

    _drawNode(canvas, batteryPos, smallRadius, batteryColor, TeslaIcons.battery,
        batteryDisplay, label: "Battery", labelAbove: false);

    _drawNode(canvas, center, homeRadius, homeColor, TeslaIcons.home,
        homeDisplay, label: "", labelAbove: false);

    if (gridKw.abs() > 0.05) {
      _drawFlow(canvas, gridPos, center, gridKw, gridColor, smallRadius, homeRadius);
    }
    if (evKw.abs() > 0.05) {
      _drawFlow(canvas, evPos, center, evKw, evColor, smallRadius, homeRadius);
    }
    if (homeKw.abs() > 0.05) {
      _drawFlow(canvas, center, center, homeKw, homeColor, homeRadius, homeRadius);
    }
  }

  void _drawBaseLine(Canvas canvas, Offset from, Offset to, double r1, double r2) {
    final start = _edgePoint(from, to, r1);
    final end   = _edgePoint(to, from, r2);

    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1;

    canvas.drawLine(start, end, paint);
  }

  void _drawNode(
    Canvas canvas,
    Offset pos,
    double radius,
    Color ringColor,
    IconData icon,
    double value, {
    required String label,
    required bool labelAbove,
  }) {
    if (label.isNotEmpty) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: Colors.white, fontSize: labelSize),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      final offset = labelAbove
          ? Offset(pos.dx - labelPainter.width / 2, pos.dy - radius - 35)
          : Offset(pos.dx - labelPainter.width / 2, pos.dy + radius + 15);

      labelPainter.paint(canvas, offset);
    }

    final pulse = 1 + sin(animation.value * 2 * pi) * 0.06;

    final outerGlow = Paint()
      ..color = ringColor.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);

    canvas.drawCircle(pos, (radius + 26) * pulse, outerGlow);

    final innerGlow = Paint()
      ..color = ringColor.withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(pos, (radius + 10) * pulse, innerGlow);

    final fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius - 2.4, fillPaint);

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(pos, radius, ringPaint);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: landscape ? 26 : 34,
          color: Colors.white.withOpacity(0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();

    final valuePainter = TextPainter(
      text: TextSpan(
        text: value.abs() < 0.01 ? "0.0" : value.abs().toStringAsFixed(2),
        style: TextStyle(color: Colors.white, fontSize: landscape ? 12 : 14),
      ),
      textDirection: TextDirection.ltr,
    );
    valuePainter.layout();

    final totalHeight = iconPainter.height + valuePainter.height + 4;
    final startY = pos.dy - totalHeight / 2;

    iconPainter.paint(
      canvas,
      Offset(pos.dx - iconPainter.width / 2, startY),
    );

    valuePainter.paint(
      canvas,
      Offset(pos.dx - valuePainter.width / 2, startY + iconPainter.height + 4),
    );
  }

  void _drawFlow(Canvas canvas, Offset from, Offset to, double kw, Color color,
      double r1, double r2) {
    if (from == to) return;

    Offset start = _edgePoint(from, to, r1);
    Offset end   = _edgePoint(to, from, r2);

    if (kw < 0) {
      final temp = start;
      start = end;
      end = temp;
    }

    final width = 2.0 + (kw.abs().clamp(0.0, 7.0) / 7.0) * 8.0;

    final linePaint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, linePaint);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(start, width * 0.8, glowPaint);

    final t = animation.value;
    final pulseCount = kw.abs() < 1.0 ? 1 : kw.abs() < 3.0 ? 3 : 5;

    for (int i = 0; i < pulseCount; i++) {
      final phase = (t + i / pulseCount) % 1.0;

      final dx = start.dx + (end.dx - start.dx) * phase;
      final dy = start.dy + (end.dy - start.dy) * phase;

      final pulsePaint = Paint()..color = color.withOpacity(0.9);
      canvas.drawCircle(Offset(dx, dy), width * 0.5, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
