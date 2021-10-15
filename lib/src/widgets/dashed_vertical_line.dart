import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class DashedVerticalLine extends StatelessWidget {
  const DashedVerticalLine({
    this.dashHeight = 5,
    this.dashSpace = 5,
  });

  final double dashHeight;
  final double dashSpace;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: DashedLinePainter(
      dashHeight: dashHeight,
      dashSpace: dashSpace,
    ));
  }
}

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({required this.dashHeight, required this.dashSpace});
  final double dashHeight;
  final double dashSpace;
  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final paint = Paint()
      ..color = R.color.color0xffB1DDDB
      ..strokeWidth = 1;
    while (startY < size.height - dashHeight) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
