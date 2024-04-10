import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class A4PortCameraView extends StatefulWidget {
  final CameraController controller;
  final double sidePaddingPercent;
  final double ratio;
  const A4PortCameraView(
    this.controller, {
    super.key,
    required this.sidePaddingPercent,
    required this.ratio,
  });

  @override
  State<A4PortCameraView> createState() => _A4PortCameraViewState();
}

class _A4PortCameraViewState extends State<A4PortCameraView> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double horizontalPadding = (size.width * widget.sidePaddingPercent).roundToDouble();
    double width = size.width - (horizontalPadding * 2);
    double height = width * widget.ratio;

    final color = Colors.black.withOpacity(0.7);
    return Stack(
      children: [
        Center(child: CameraPreview(widget.controller)),
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  color: color,
                ),
              ),
              Container(
                height: height,
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: color,
                      ),
                    ),
                    Container(
                      width: width,
                      color: Colors.transparent,
                    ),
                    Expanded(
                      child: Container(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
