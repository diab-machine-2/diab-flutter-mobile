import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../res/R.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../utils/navigator_name.dart';
import 'widgets/upload_take_photo.dart';

class CapturePrescriptionPage extends StatefulWidget {
  @override
  _CapturePrescriptionPageState createState() => _CapturePrescriptionPageState();
}

class _CapturePrescriptionPageState extends State<CapturePrescriptionPage> {
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final result = await Navigator.of(context).pushNamed(NavigatorName.medicine_photo_picker);
    if (result != null) {
      setState(() {
        _selectedImage = result as File?;
      });
      _callApi();
    }
  }

  Future<void> _captureFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _callApi() async {
    setState(() {
      _isLoading = true;
    });

    context.read<MedicineBloc>().add(UploadPrescriptionPhotoEvent(_selectedImage!));

    setState(() {
      _isLoading = false;
    });

    // TODO: navigate sang màn hình hiển thị kết quả đơn thuốc
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Phân tích đơn thuốc xong!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.white,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.chup_anh.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: [
              InkWell(
                onTap: () {
                  // Navigator.of(context).pushNamed(NavigatorName.medicine_tutorial)
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFC4FFF9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 1.5,
                      color: Color(0xFFC4FFF9),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(R.icons.ic_edit, width: 16),
                      SizedBox(width: 10),
                      Text(
                        R.string.input_medicine.tr(),
                        style: TextStyle(color: R.color.color0xff008479, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            backgroundColor: R.color.transparent,
            //No more green
            elevation: 0.0,
            //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [R.color.greenGradientMid, R.color.greenGradientBottom])),
            ),
          ),
          body: buildBody(),
        ),

        // Overlay loading
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Đang phân tích đơn thuốc của bạn",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildBody() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _selectedImage != null ? Image.file(_selectedImage!) : SizedBox(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(15),
          color: Colors.black,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: R.color.color0xff008479,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    R.string.should_capture_advice.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ),
        Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 40),
            child: UploadTakePhotoButtons(
              onUploadTap: _pickFromGallery,
              onTakePhotoTap: _captureFromCamera,
            ))
      ],
    );
  }
}
