import 'package:flutter/material.dart';

class NavCustomPainter extends CustomPainter {
  late double loc;
  late double s;
  Color color;
  TextDirection textDirection;
  final double iconSize;

  NavCustomPainter(
    double startingLoc,
    int itemsLength,
    this.color,
    this.textDirection, {
    required this.iconSize,
  }) {
    final span = 1.0 / itemsLength;
    s = 0.2;
    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double padding = 4.0;
    final totalActiveIconSpace = (padding * 2 + iconSize).roundToDouble();
    final double hafActiveIconSpace = (totalActiveIconSpace / 2).roundToDouble();

    double middlePoint = (loc + s * 0.5) * size.width;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(middlePoint - hafActiveIconSpace, 0)
      ..arcToPoint(
        Offset(middlePoint, hafActiveIconSpace),
        radius: Radius.circular(hafActiveIconSpace),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(middlePoint + hafActiveIconSpace, 0),
        radius: Radius.circular(hafActiveIconSpace),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
