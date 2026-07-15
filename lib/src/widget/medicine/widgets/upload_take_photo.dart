import 'package:flutter/material.dart';

class UploadTakePhotoButtons extends StatefulWidget {
  final VoidCallback onUploadTap;
  final VoidCallback onTakePhotoTap;

  const UploadTakePhotoButtons({
    Key? key,
    required this.onUploadTap,
    required this.onTakePhotoTap,
  }) : super(key: key);

  @override
  State<UploadTakePhotoButtons> createState() => _UploadTakePhotoButtonsState();
}

class _UploadTakePhotoButtonsState extends State<UploadTakePhotoButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 10),
        // Nút upload ảnh
        GestureDetector(
          onTap: widget.onUploadTap,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: Icon(Icons.photo, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text("Tải ảnh lên",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        // Nút chụp ảnh
        GestureDetector(
          onTap: widget.onTakePhotoTap,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.teal, width: 3),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Chụp ảnh",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 60),
        const SizedBox(width: 5),
      ],
    );
  }
}
