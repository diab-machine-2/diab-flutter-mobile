import 'dart:typed_data';
import 'package:flutter/material.dart';

class TestOcrFinalImage extends StatelessWidget {
  final Uint8List bytes;
  const TestOcrFinalImage({super.key, required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cropped image')),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(bytes),
        ),
      ),
    );
  }
}