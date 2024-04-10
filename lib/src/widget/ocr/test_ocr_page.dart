import 'package:flutter/material.dart';
import 'package:medical/src/utils/navigator_name.dart';

class TestOcrPage extends StatelessWidget {
  const TestOcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test OCR'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // button camera
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, NavigatorName.test_ocr_camera);
              },
              child: Text('Camera'),
            ),
            const SizedBox(height: 20.0),
            // button gallery
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, NavigatorName.test_ocr_gallery);
              },
              child: Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}