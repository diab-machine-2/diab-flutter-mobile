import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/benefit/benefit_lab_test_scan_result_page.dart';
import 'package:medical/src/widget/benefit/benefit_medicine_scan_result_page.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';
import 'package:medical/src/widget/medicine/widgets/upload_take_photo.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitCaptureImagePage extends StatefulWidget {
  final BenefitServiceType serviceType;

  const BenefitCaptureImagePage({Key? key, required this.serviceType})
      : super(key: key);

  @override
  State<BenefitCaptureImagePage> createState() =>
      _BenefitCaptureImagePageState();
}

class _BenefitCaptureImagePageState extends State<BenefitCaptureImagePage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;

  bool get _isMedicine => widget.serviceType == BenefitServiceType.medicine;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    final image = await _cameraController!.takePicture();
    setState(() => _selectedImage = File(image.path));
    _processImage(File(image.path));
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
      _processImage(File(picked.path));
    }
  }

  Future<void> _processImage(File image) async {
    final cubit = context.read<BenefitServiceRequestCubit>();
    setState(() => _isProcessing = true);

    if (_isMedicine) {
      await cubit.scanPrescription(image: image);
    } else {
      await cubit.scanClinicResult(image: image);
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final state = cubit.state;
    if (state is BenefitScanMedicineSuccess) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: BenefitMedicineScanResultPage(
              medicines: state.medicines,
              capturedImage: state.capturedImage,
            ),
          ),
        ),
      );
    } else if (state is BenefitScanLabTestSuccess) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: BenefitLabTestScanResultPage(
              scanData: state.scanData,
              capturedImage: state.capturedImage,
            ),
          ),
        ),
      );
    } else if (state is BenefitServiceRequestError) {
      BotToast.showSimpleNotification(title: state.message);
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
            Navigator.of(context).pop();
          },
        ),
        title: Transform(
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              (_isMedicine
                      ? R.string.benefit_capture_title_medicine
                      : R.string.benefit_capture_title_lab)
                  .tr(),
              style: TextStyle(
                color: R.color.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
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
      body: Stack(
        children: [
          Column(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 40),
                  child: UploadTakePhotoButtons(
                    onUploadTap: _pickFromGallery,
                    onTakePhotoTap: _captureFromCamera,
                  ))
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      _isMedicine
                          ? R.string.analyzing_prescription.tr()
                          : R.string.analyzing_lab_result.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
