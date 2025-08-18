import 'package:flutter/material.dart';

class DashLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashLinePainter({
    this.color = Colors.grey,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DashLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashLine({
    Key? key,
    this.height = 1.0,
    this.color = Colors.grey,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: DashLinePainter(
        color: color,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        strokeWidth: height,
      ),
    );
  }
}
