import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CustomCircleChart extends StatelessWidget {
  const CustomCircleChart({
    Key? key,
    required this.mark1,
    required this.mark2,
  }) : super(key: key);
  final double mark1;
  final double mark2;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircleGraphPainter(mark1: mark1, mark2: mark2 + mark1),
    );
  }
}

class CircleGraphPainter extends CustomPainter {
  CircleGraphPainter({required this.mark1, required this.mark2});

  final double mark1;
  final double mark2;

  final Paint mark1Paint = Paint()
    ..color = R.color.greenGradientBottom
    ..style = PaintingStyle.stroke
    ..strokeWidth = 24;

  final Paint mark2Paint = Paint()
    ..color = R.color.orange_1
    ..style = PaintingStyle.stroke
    ..strokeWidth = 24;

  final Paint backgroundPaint = Paint()
    ..color = R.color.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: center.dx);

    canvas.drawArc(rect, 0, 2 * pi, false, backgroundPaint);

    canvas.drawArc(
      rect,
      -pi / 2,
      mark2 * pi / 50,
      false,
      mark2Paint,
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      mark1 * pi / 50,
      false,
      mark1Paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
