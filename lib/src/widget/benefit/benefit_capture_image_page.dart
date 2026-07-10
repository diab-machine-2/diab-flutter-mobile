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
    _processImage(File(image.path));
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) _processImage(File(picked.path));
  }

  Future<void> _processImage(File image) async {
    final cubit = context.read<BenefitServiceRequestCubit>();
    BotToast.showLoading(allowClick: false);

    if (_isMedicine) {
      await cubit.scanPrescription(image: image);
    } else {
      await cubit.scanClinicResult(image: image);
    }

    if (!mounted) return;
    BotToast.closeAllLoading();

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
      body: Stack(
        children: [
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            Positioned.fill(child: Container(color: Colors.black87)),
          // AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        (_isMedicine
                                ? R.string.benefit_capture_title_medicine
                                : R.string.benefit_capture_title_lab)
                            .tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center hint
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                R.string.benefit_capture_hint.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 20),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      icon: Icons.photo_library_outlined,
                      label: R.string.benefit_capture_btn_gallery.tr(),
                      onTap: _pickFromGallery,
                    ),
                    GestureDetector(
                      onTap: _captureFromCamera,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 30, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          GapH(4),
          Text(label,
              style:
                  const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
