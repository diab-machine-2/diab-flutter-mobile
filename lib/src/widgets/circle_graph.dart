import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CircleGraphWidget extends StatelessWidget {
  const CircleGraphWidget({
    Key? key,
    required this.percent,
    required this.icon,
  }) : super(key: key);
  final double percent;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: R.color.white,
            ),
            child: Image.asset(
              icon,
              width: 40,
              height: 40,
            ),
          ),
          CustomPaint(
            painter: CircleGraphPainter(percent),
            size: const Size(60, 60),
          ),
        ],
      ),
    );
  }
}

class CircleGraphPainter extends CustomPainter {
  CircleGraphPainter(this.percent);

  final double percent;

  final Paint activePainter = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  final Paint inActivePainter = Paint()
    ..color = R.color.grayBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: center.dx);
    activePainter.shader = RadialGradient(
      colors: [
        R.color.greenGradientTop,
        const Color(0xFF01857A),
        R.color.greenGradientBottom,
      ],
    ).createShader(
      Rect.fromCircle(
        center: center,
        radius: center.dx,
      ),
    );
    canvas.drawArc(rect, 0, 2 * pi, false, inActivePainter);
    canvas.drawArc(
      rect,
      -pi / 2,
      percent * pi / 50,
      false,
      activePainter,
    );
    canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
