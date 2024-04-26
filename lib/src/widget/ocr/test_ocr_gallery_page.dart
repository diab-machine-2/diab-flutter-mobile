import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'test_ocr_final_image_page.dart';

class TestOcrGallery extends StatefulWidget {
  const TestOcrGallery({super.key});

  @override
  State<TestOcrGallery> createState() => _TestOcrGalleryState();
}

class _TestOcrGalleryState extends State<TestOcrGallery> {
  final _controller = CropController();
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    Widget? body;
    if (_imageData == null) {
      body = Center(
        child: ElevatedButton(
          onPressed: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              final imageData = await image.readAsBytes();
              setState(() {
                _imageData = imageData;
              });
            }
          },
          child: Text('Pick Image'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: body ??
          Column(
            children: [
              Expanded(
                child: Crop(
                  image: _imageData!,
                  controller: _controller,
                  onCropped: (image) {
                    // save to file
                    // final dir = Directory.systemTemp;
                    // final file =
                    //     File('${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
                    // file.writeAsBytesSync(image);

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestOcrFinalImage(
                            bytes: image, fullImage: _imageData),
                      ),
                    );
                  },
                  aspectRatio: 297.0 / 210.0,
                  initialSize: 1.0,
                  // initialRectBuilder: (_, rect) {
                  //   return Rect.fromLTRB(
                  //       rect.left + 24, rect.top + 32, rect.right - 24, rect.bottom - 32);
                  // },
                  baseColor: Colors.blue.shade900,
                  maskColor: Colors.black.withOpacity(0.7),
                  progressIndicator: const CircularProgressIndicator(),
                  radius: 0,
                  onMoved: (newRect) {
                    // do something with current crop rect.
                  },
                  onStatusChanged: (status) {
                    // do something with current CropStatus
                  },
                  willUpdateScale: (newScale) {
                    // if returning false, scaling will be canceled
                    return newScale < 3;
                  },
                  cornerDotBuilder: (size, edgeAlignment) =>
                      const DotControl(color: Colors.blue),
                  clipBehavior: Clip.none,
                  interactive: true,
                  fixCropRect: false,
                  // formatDetector: (image) {},
                  // imageCropper: myCustomImageCropper,
                  // imageParser: (image, {format}) {},
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _controller.crop();
                },
                child: Text('Crop Image'),
              ),
              SafeArea(child: SizedBox(height: 20.0)),
            ],
          ),
    );
  }
}
