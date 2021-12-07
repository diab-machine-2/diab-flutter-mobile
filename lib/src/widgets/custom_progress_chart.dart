import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

const Radius radius = Radius.circular(4);
const double chartAndTextHeight = 52;
const double chartHeight = 24;

class CustomProgressChart extends StatelessWidget {
  const CustomProgressChart({
    required this.title,
    required this.mark_1,
    required this.mark_2,
    required this.mark_3,
  });

  final String title;
  final int mark_1;
  final int mark_2;
  final int mark_3;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      height: chartAndTextHeight,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: R.style.normalTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: LayoutBuilder(builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, chartHeight),
                painter: MyPainter(
                  mark_1: mark_1,
                  mark_2: mark_2,
                  mark_3: mark_3,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  const MyPainter({
    required this.mark_1,
    required this.mark_2,
    required this.mark_3,
  });
  final int mark_1;
  final int mark_2;
  final int mark_3;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()..color = R.color.greenGradientBottom;
    final Paint paint2 = Paint()..color = R.color.orange_1;
    final Paint paint3 = Paint()..color = R.color.white;

    final String completedPercent =
        mark_2 == 0 ? '' : '${((mark_1 / mark_2) * 100).toInt()}%';

    final double mark1Position =
        mark_3 == 0 ? 0 : (mark_1.toDouble() / mark_3.toDouble()) * size.width;
    final double mark2Position =
        mark_3 == 0 ? 0 : (mark_2.toDouble() / mark_3.toDouble()) * size.width;
    final double mark3Position = size.width;

    final textStyle = TextStyle(
      color: R.color.textDark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final TextPainter percentTextPainter = TextPainter(
      text: TextSpan(
        text: completedPercent,
        style: textStyle.copyWith(
          color: R.color.white,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final TextPainter text1Painter = TextPainter(
      text: TextSpan(
        text: '$mark_1',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final TextPainter text2Painter = TextPainter(
      text: TextSpan(
        text: '$mark_2',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final TextPainter text3Painter = TextPainter(
      text: TextSpan(
        text: '$mark_3',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final Offset percentTextPosition = Offset(
        (mark1Position / 2) - (percentTextPainter.width / 2),
        (size.height - percentTextPainter.height) / 2);

    Offset mark1TextPosition = Offset(
        mark1Position - (text1Painter.width / 2), -text1Painter.height - 4);
    Offset mark2TextPosition = Offset(
        mark2Position - (text2Painter.width / 2), -text2Painter.height - 4);
    final Offset mark3TextPosition = Offset(
        mark3Position - (text3Painter.width / 2), -text3Painter.height - 4);

    if (mark2TextPosition.dx + text2Painter.width + 8 > mark3TextPosition.dx) {
      mark2TextPosition = Offset(
          mark3TextPosition.dx - 8 - text2Painter.width, mark2TextPosition.dy);
    }

    if (mark1TextPosition.dx + text1Painter.width + 8 > mark2TextPosition.dx) {
      mark1TextPosition = Offset(
          mark2TextPosition.dx - 8 - text1Painter.width, mark1TextPosition.dy);
    }

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, mark3Position, chartHeight),
          radius,
        ),
        paint3);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, mark2Position, chartHeight),
          radius,
        ),
        paint2);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, mark1Position, chartHeight),
          radius,
        ),
        paint1);

    text1Painter.paint(canvas, mark1TextPosition);
    text2Painter.paint(canvas, mark2TextPosition);
    text3Painter.paint(canvas, mark3TextPosition);
    percentTextPainter.paint(canvas, percentTextPosition);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
