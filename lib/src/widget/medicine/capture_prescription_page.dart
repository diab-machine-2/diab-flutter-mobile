import 'package:camera/camera.dart';
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
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras!.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (!_cameraController!.value.isInitialized) return;
    final image = await _cameraController!.takePicture();
    setState(() {
      _selectedImage = File(image.path);
    });
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed(NavigatorName.medicine_photo_picker);
    if (result != null) {
      setState(() {
        _selectedImage = result as File?;
      });
      _callApi(context);
    }
  }

  Future<void> _callApi(BuildContext context) async {
    context.read<MedicineBloc>().add(UploadPrescriptionPhotoEvent(_selectedImage!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineBloc(),
      child: BlocListener<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is MedicineError) {
            // Hiện dialog lỗi
            showDialog(
              context: context,
              barrierDismissible: false, // bắt buộc user bấm nút/X
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon cảnh báo
                            SvgPicture.asset(R.icons.ic_error, width: 72, height: 72),
                            const SizedBox(height: 24),

                            // Tiêu đề
                            Text(
                              R.string.can_not_read_prescription.tr(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: R.color.color0xff111515,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),

                            // Nội dung
                            Text(
                              R.string.please_take_another_photo.tr(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: R.color.color0xff5E6566,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Hai nút chia đều
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushNamed(NavigatorName.medicine_search);
                                    },
                                    child: Container(
                                      height: 48,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(200),
                                        border: Border.all(
                                          width: 1,
                                          color: R.color.color0xff008479,
                                        ),
                                        color: Colors.white
                                      ),
                                      child: Center(
                                        child: Text(
                                          R.string.enter_manually.tr(),
                                          style: TextStyle(
                                            color: R.color.color0xff008479,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _captureFromCamera();
                                    },
                                    child: Container(
                                      height: 48,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.centerRight,
                                          colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          R.string.reshoot.tr(),
                                          style: TextStyle(
                                            color: R.color.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      // Icon X ở góc phải trên
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, size: 24, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (state is UploadPrescriptionPhotoSuccess) {
            // Điều hướng sang PrescriptionAddPage
            Navigator.pushNamed(
              context,
              NavigatorName.prescription_add,
              arguments: {'medicineItems': state.createResult},
            );
          }
        },
        child: BlocBuilder<MedicineBloc, MedicineState>(
          builder: (context, state) {
            return Stack(
              children: [
                Scaffold(
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
                  body: buildBody(context),
                ),

                if (state is MedicineLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            R.string.analyzing_prescription.tr(),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _selectedImage != null
                ? Image.file(_selectedImage!)
                : _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
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
              onUploadTap: () => _pickFromGallery(context),
              onTakePhotoTap: _captureFromCamera,
            ))
      ],
    );
  }
}
