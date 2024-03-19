import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';

import 'test_ocr_final_image_page.dart';
import 'widgets/a4_port_camera_preview.dart';

class TestOcrCamera extends StatefulWidget {
  const TestOcrCamera({super.key});

  @override
  State<TestOcrCamera> createState() => _TestOcrCameraState();
}

class _TestOcrCameraState extends State<TestOcrCamera> {
  CameraController? _controller;

  final double ratio = 210.0 / 297.0;
  final double sidePaddingPercent = 0.05;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  void _initStateAsync() async {
    List<CameraDescription> cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.max);

    try {
      await _controller!.initialize();
      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: A4PortCameraView(
              _controller!,
              sidePaddingPercent: sidePaddingPercent,
              ratio: ratio,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      _takePicture(context);
                    },
                    child: const Text('Take Picture'),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _takePicture(BuildContext context) async {
    try {
      final XFile file = await _controller!.takePicture();

      // use package image to drop image to a4 ratio
      final image = decodeImage(File(file.path).readAsBytesSync());
      if (image != null) {
        int horizontalPadding = (image.width * sidePaddingPercent).round();
        int expectedWidth = (image.width * (1 - sidePaddingPercent * 2)).round();
        int expectedHeight = (expectedWidth * ratio).round();
        int verticalPadding = ((image.height - expectedHeight) / 2).round();
        final a4Image = copyCrop(image,
            x: horizontalPadding, y: verticalPadding, width: expectedWidth, height: expectedHeight);
        final bytes = encodeJpg(a4Image);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestOcrFinalImage(bytes: bytes),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
