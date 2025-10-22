import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

const Size chartSize = Size(40, 4);
const radius = Radius.circular(10);

class CustomProgressWidget extends StatelessWidget {
  const CustomProgressWidget({
    required this.total,
    required this.count,
  });
  final int total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final double progress =
        total == 0 ? 0.0 : count.toDouble() / total.toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                R.string.complete_lesson.tr(),
                style: TextStyle(
                  color: R.color.captionColorGray,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                width: 65,
                height: 6,
                child: CustomPaint(
                  painter: MyPainter(
                    progress: progress,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                  text: '$count',
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: '/$total',
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ]),
            ),
          ],
        ),
      ],
    );
  }
}

class MyPainter extends CustomPainter {
  const MyPainter({
    required this.progress,
  });
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint progressPainter = Paint()..color = R.color.green;
    final Paint backgroundPainter = Paint()..color = R.color.grayBorder;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          radius,
        ),
        backgroundPainter);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, progress * size.width, size.height),
          radius,
        ),
        progressPainter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
