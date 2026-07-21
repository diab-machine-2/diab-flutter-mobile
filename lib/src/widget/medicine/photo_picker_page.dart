import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../res/R.dart';
import '../../utils/navigator_name.dart';

class PhotoPickerPage extends StatefulWidget {
  const PhotoPickerPage({Key? key}) : super(key: key);

  @override
  State<PhotoPickerPage> createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _selectedImage = file;
      });
      if (mounted) {
        Navigator.pop(context, file);
      }
    }
  }

  Future<void> _captureFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      final file = File(image.path);
      setState(() {
        _selectedImage = file;
      });
      if (mounted) {
        Navigator.pop(context, file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              NavigatorName.tabbar,
                  (route) => false,
            );
          },
        ),
        title: Transform(
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              R.string.chup_anh.tr(),
              style: TextStyle(
                color: R.color.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(NavigatorName.medicine_search),
            child: Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFC4FFF9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 1.5,
                  color: const Color(0xFFC4FFF9),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(R.icons.ic_edit, width: 16),
                  const SizedBox(width: 10),
                  Text(
                    R.string.input_medicine.tr(),
                    style: TextStyle(
                      color: R.color.color0xff008479,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: R.color.transparent,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [R.color.greenGradientMid, R.color.greenGradientBottom],
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _captureFromCamera,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.teal, width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.camera_alt, size: 40, color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              R.string.chup_anh.tr(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _pickFromGallery,
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: Icon(Icons.photo, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'T\u1EA3i \u1EA3nh l\u00EAn',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}