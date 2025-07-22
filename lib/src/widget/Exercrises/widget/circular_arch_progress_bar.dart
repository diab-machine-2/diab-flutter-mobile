import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularArchProgressBarPainter extends CustomPainter {
  final double strokeWidth;
  final double value;
  final Color color;

  CircularArchProgressBarPainter({
    required this.strokeWidth,
    required this.value,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final double startAngle =
        math.pi - (math.pi / 18); // Dịch chuyển góc bắt đầu
    final double sweepAngle =
        (200 / 180) * math.pi * (value / 100); // Quét 200 độ

    canvas.drawArc(
      Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircularArchProgressBar extends StatefulWidget {
  final double value;
  final double strokeWidth;
  final Color fillColor;
  final Color backgroundColor;
  final double width;

  CircularArchProgressBar({
    required this.value,
    this.strokeWidth = 10.0,
    this.fillColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.width = 100.0,
  });

  @override
  _CircularArchProgressBarState createState() =>
      _CircularArchProgressBarState();
}

class _CircularArchProgressBarState extends State<CircularArchProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation =
        Tween<double>(begin: 0.0, end: widget.value).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double adjustedSize =
        widget.width - widget.strokeWidth; // Giảm kích thước
    final double adjustedContainerHeight =
        200 * (adjustedSize / 2) / 180; // Tính toán chiều cao của container
    return Stack(
      alignment: Alignment.center,
      children: [
        // Vòng cung nền
        SizedBox(
          width: adjustedSize,
          height: adjustedContainerHeight,
          child: CustomPaint(
            painter: CircularArchProgressBarPainter(
              strokeWidth: widget.strokeWidth,
              color: widget.backgroundColor,
              value: 100, // Nền luôn quét đủ 200 độ
            ),
          ),
        ),
        // Vòng cung động
        SizedBox(
          width: adjustedSize,
          height: adjustedContainerHeight,
          child: CustomPaint(
            painter: CircularArchProgressBarPainter(
              strokeWidth: widget.strokeWidth,
              color: widget.fillColor,
              value: widget.value, // Giá trị động
            ),
          ),
        ),
      ],
    );
  }
}
