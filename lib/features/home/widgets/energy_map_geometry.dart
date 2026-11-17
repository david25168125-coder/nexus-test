import 'package:flutter/material.dart';

/// Painter and touch targets share coordinates, including desktop scaling.
class EnergyMapGeometry {
  final Size size;
  final bool landscape;
  final double nodeScale;
  const EnergyMapGeometry(
      {required this.size, required this.landscape, this.nodeScale = 1});
  Offset get center => Offset(size.width / 2, size.height / 2);
  double get verticalOffset =>
      size.height * (nodeScale > 1 ? 0.28 : (landscape ? 0.22 : 0.28));
  double get horizontalOffset => size.width * (landscape ? 0.32 : 0.28);
  Offset get solar => center.translate(0, -verticalOffset);
  Offset get battery => center.translate(0, verticalOffset);
  Offset get grid => center.translate(-horizontalOffset, 0);
  Offset get ev => center.translate(horizontalOffset, 0);
  double get smallRadius => (landscape ? 32 : 40) * nodeScale;
  double get homeRadius => (landscape ? 48 : 60) * nodeScale;
}
