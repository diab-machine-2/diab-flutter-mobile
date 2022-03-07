import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

const Radius radius = Radius.circular(4);
const double chartHeight = 24;

class CustomProgressChart extends StatefulWidget {
  const CustomProgressChart({
    this.title = '',
    required this.mark1,
    required this.mark2,
    required this.mark3,
    required this.messageStream,
    required this.onTap,
  });

  final String title;
  final int? mark1;
  final int? mark2;
  final int? mark3;
  final Stream messageStream;
  final VoidCallback onTap;

  @override
  State<CustomProgressChart> createState() => CustomProgressChartState();
}

class CustomProgressChartState extends State<CustomProgressChart> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? messegeEntry;
  OverlayEntry? triangleEntry;
  Timer? _timer;

  bool isShowing = false;

  @override
  void initState() {
    super.initState();
    widget.messageStream.listen((_) {
      disposeOverlay();
    });
  }

  @override
  void dispose() {
    disposeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: CompositedTransformTarget(
        link: layerLink,
        child: GestureDetector(
          onTap: () async {
            widget.onTap.call();
            await Future.delayed(const Duration(microseconds: 100));
            _showOverlay();
          },
          child: Row(
            children: [
              if (widget.title.isNotEmpty)
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.title,
                    style: R.style.normalTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (widget.title.isNotEmpty) const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: LayoutBuilder(builder: (context, constraints) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth, chartHeight),
                    painter: MyPainter(
                      mark1: widget.mark1 ?? 0,
                      mark2: widget.mark2 ?? 0,
                      mark3: widget.mark3 ?? 0,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOverlay() {
    final OverlayState? overlay = Overlay.of(context);
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Size? size = renderBox?.size;
    final String _completedPercent = widget.mark2 == 0
        ? '0'
        : '${(((widget.mark1 ?? 0) / (widget.mark2 ?? 1)) * 100).toInt()}';
    if (!isShowing) {
      messegeEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            height: 52,
            child: CompositedTransformFollower(
              link: layerLink,
              offset: const Offset(-20, -58),
              child: Material(
                color: R.color.transparent,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width - 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: R.color.mainColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Bạn đã hoàn thành ${widget.mark1}/${widget.mark2} mục tiêu, đạt $_completedPercent% chặng đường. Tiếp tục tiến lên nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      triangleEntry = OverlayEntry(builder: (context) {
        return Positioned(
          height: 6,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: Offset((size?.width ?? 0) * 0.9 - 3, -6),
            child: ClipPath(
              clipper: CustomTriangleClipper(),
              child: Container(
                width: 6,
                height: 5,
                color: R.color.mainColor,
              ),
            ),
          ),
        );
      });

      if (overlay != null && messegeEntry != null) {
        overlay.insert(messegeEntry!);
        overlay.insert(triangleEntry!);
        isShowing = true;
        _startTimer();
      }
    }
  }

  void disposeOverlay() {
    messegeEntry?.remove();
    messegeEntry = null;
    triangleEntry?.remove();
    triangleEntry = null;
    isShowing = false;
    _stopTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      disposeOverlay();
    });
  }

  void _stopTimer() {
    if (_timer != null && _timer?.isActive == true) {
      _timer?.cancel();
    }
  }
}

class MyPainter extends CustomPainter {
  const MyPainter({
    required this.mark1,
    required this.mark2,
    required this.mark3,
  });
  final int mark1;
  final int mark2;
  final int mark3;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint _paint1 = Paint()..color = R.color.white;
    final Paint _paint2 = Paint()..color = R.color.orange_1;
    final Paint _paint3 = Paint()..color = R.color.greenGradientBottom;

    final String _completedPercent =
        mark2 == 0 ? '' : '${((mark1 / mark2) * 100).toInt()}%';

    final double _mark1Position =
        mark3 == 0 ? 0 : (mark1.toDouble() / mark3.toDouble()) * size.width;
    final double mark2Position =
        mark3 == 0 ? 0 : (mark2.toDouble() / mark3.toDouble()) * size.width;
    final double _mark3Position = size.width;

    final textStyle = TextStyle(
      color: R.color.textDark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );

    final TextPainter _percentTextPainter = TextPainter(
      text: TextSpan(
        text: _completedPercent,
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

    final TextPainter _text1Painter = TextPainter(
      text: TextSpan(
        text: '$mark1',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final TextPainter _text2Painter = TextPainter(
      text: TextSpan(
        text: '$mark2',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final TextPainter _text3Painter = TextPainter(
      text: TextSpan(
        text: '$mark3',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );

    final Offset _percentTextPosition = Offset(
        max((_mark1Position / 2) - (_percentTextPainter.width / 2), 0),
        (size.height - _percentTextPainter.height) / 2);

    Offset _mark1TextPosition = Offset(
        _mark1Position - (_text1Painter.width / 2), -_text1Painter.height - 4);
    Offset _mark2TextPosition = Offset(
        mark2Position - (_text2Painter.width / 2), -_text2Painter.height - 4);
    final Offset mark3TextPosition = Offset(
        _mark3Position - (_text3Painter.width / 2), -_text3Painter.height - 4);

    if (_mark2TextPosition.dx + _text2Painter.width + 8 >
        mark3TextPosition.dx) {
      _mark2TextPosition = Offset(
          mark3TextPosition.dx - 8 - _text2Painter.width,
          _mark2TextPosition.dy);
    }

    if (_mark1TextPosition.dx + _text1Painter.width + 8 >
        _mark2TextPosition.dx) {
      _mark1TextPosition = Offset(
          _mark2TextPosition.dx - 8 - _text1Painter.width,
          _mark1TextPosition.dy);
    }

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, _mark3Position, chartHeight),
          radius,
        ),
        _paint3);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, mark2Position, chartHeight),
          radius,
        ),
        _paint2);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, _mark1Position, chartHeight),
          radius,
        ),
        _paint1);

    // _text1Painter.paint(canvas, _mark1TextPosition);
    // _text2Painter.paint(canvas, _mark2TextPosition);
    // _text3Painter.paint(canvas, mark3TextPosition);
    _percentTextPainter.paint(canvas, _percentTextPosition);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
