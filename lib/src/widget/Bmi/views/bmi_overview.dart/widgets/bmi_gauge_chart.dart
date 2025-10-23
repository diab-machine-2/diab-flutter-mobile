import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_input_bloc.dart';

class BmiGaugeChart extends StatelessWidget {
  final List<double> thresholds;
  final int currentIndex; // chỉ số của khoảng cần highlight (0-based)
  final double strokeWidth;

  const BmiGaugeChart({
    super.key,
    required this.thresholds,
    required this.currentIndex,
    this.strokeWidth = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    BmiInputBloc _bmiInputBloc = context.read();
    Color thresholdColor = Utils.parseStringToColor(_bmiInputBloc.calculatedBmi?.colorCode);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomPaint(
          size: Size(width, 200),
          painter: _BmiGaugePainter(
            thresholds: thresholds,
            currentIndex: currentIndex,
            strokeWidth: strokeWidth,
            highlighColor: thresholdColor,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _bmiInputBloc.calculatedBmi?.note ?? "--",
              style: R.style.smallDisplayStyle.copyWith(color: thresholdColor),
            ),
            SizedBox(height: 16),
            Text.rich(TextSpan(
                text: "${_bmiInputBloc.weight} ",
                style: R.style.boldXLargeStyle,
                children: [
                  TextSpan(
                    text: "kg",
                    style: R.style.normalTextStyle.neutral3,
                  )
                ]))
          ],
        ),
      ],
    );
  }
}

class _BmiGaugePainter extends CustomPainter {
  final List<double> thresholds;
  final int currentIndex;
  final double strokeWidth;
  final Color highlighColor;

  _BmiGaugePainter({
    required this.thresholds,
    required this.currentIndex,
    required this.strokeWidth,
    required this.highlighColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final segmentCount = thresholds.length + 1;
    final segmentSweep = math.pi / segmentCount;

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = math.pi + i * segmentSweep;

      paint.color =
          i == currentIndex ? highlighColor : Colors.grey.withOpacity(0.2);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentSweep,
        false,
        paint,
      );
    }

    // Vẽ label (chỉ vẽ các mốc, không vẽ min/max)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < thresholds.length; i++) {
      final angle = math.pi + (i + 1) * segmentSweep;
      final labelX = center.dx + (radius + 12) * math.cos(angle);
      final labelY = center.dy + (radius + 12) * math.sin(angle);
      textPainter.text = TextSpan(
        text: thresholds[i].toStringAsFixed(1),
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height * 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
