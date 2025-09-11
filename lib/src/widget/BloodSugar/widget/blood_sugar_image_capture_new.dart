import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';

class BloodSugarImageCaptureNew extends StatefulWidget {
  const BloodSugarImageCaptureNew({Key? key}) : super(key: key);

  @override
  State<BloodSugarImageCaptureNew> createState() =>
      _BloodSugarImageCaptureNewState();
}

class _BloodSugarImageCaptureNewState extends State<BloodSugarImageCaptureNew>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  File? _lastCapturedImage;

  // Analysis state
  bool _isAnalyzing = false;
  BloodSugarAnalysisResult? _analysisResult;
  bool _showCapturedImage = false;

  // Animation properties
  bool _showFlashEffect = false;
  bool _requestingPermission = false;
  bool _permissionDenied = false;
  bool _permissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (state == AppLifecycleState.inactive) {
      setState(() {
        _isInitialized = false;
      });
      cameraController?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      // Check if permission was granted while in settings
      _checkPermissionAndInitialize();
    }
  }

  Future<void> _checkPermissionAndInitialize() async {
    if (_permissionDenied || _permissionPermanentlyDenied) {
      // Check if permission is now granted
      final status = await Permission.camera.status;
      if (status.isGranted) {
        // Permission is now granted, reset states and initialize
        _permissionDenied = false;
        _permissionPermanentlyDenied = false;
        _initializeCamera();
      }
    } else {
      // No permission issues, initialize normally
      _initializeCamera();
    }
  }

  void _resetAnalyzingState() {
    setState(() {
      _isAnalyzing = false;
      _showCapturedImage = false;
      _lastCapturedImage = null;
      _analysisResult = null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset analyzing state when navigating back to this screen
    if (_isAnalyzing) {
      _resetAnalyzingState();
    }
  }

  Future<void> _initializeCamera() async {
    if (_requestingPermission || _permissionDenied || _permissionPermanentlyDenied) {
      return;
    }
    
    try {
      // Check current permission status
      final permissionStatus = await Permission.camera.status;
      
      // Request permission if not granted
      if (!permissionStatus.isGranted) {
        _requestingPermission = true;
        final newStatus = await Permission.camera.request();
        _requestingPermission = false;
        
        // If permission is permanently denied, show settings dialog
        if (newStatus.isPermanentlyDenied) {
          _permissionPermanentlyDenied = true;
          _showPermissionDeniedDialog();
          return;
        }
        
        // If permission is denied, show permission dialog
        if (!newStatus.isGranted) {
          _permissionDenied = true;
          _showPermissionDialog();
          return;
        }
      }
      
      // Reset permission states if permission is granted
      _permissionDenied = false;
      _permissionPermanentlyDenied = false;
      
      // Get available cameras only if permission is granted
      if (await Permission.camera.isGranted) {
        _cameras = await availableCameras();
        
        if (_cameras.isEmpty) {
          _showNoCameraDialog();
          return;
        }

        // Prefer back camera
        _selectedCameraIndex = 0;
        for (int i = 0; i < _cameras.length; i++) {
          if (_cameras[i].lensDirection == CameraLensDirection.back) {
            _selectedCameraIndex = i;
            break;
          }
        }

        await _setupCamera(_selectedCameraIndex);
      } else {
        _permissionDenied = true;
        _showPermissionDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Không thể khởi tạo camera: $e');
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      setState(() {
        _isInitialized = false;
      });
    }

    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isLoading = true;
    });

    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _selectedCameraIndex = newIndex;
    await _setupCamera(newIndex);

    setState(() {
      _isLoading = false;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _captureImage() async {
    if (_controller?.value == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isStreamingImages) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final XFile file = await _controller!.takePicture();
      final imageFile = File(file.path);

      // Start the zoom animation
      await _startCaptureAnimation(imageFile);

      // Analyze the captured image
      _analyzeImage(imageFile.path);

      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi khi chụp ảnh: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startCaptureAnimation(File imageFile) async {
    // Show flash effect
    setState(() {
      _showFlashEffect = true;
    });

    // Brief flash duration
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _showFlashEffect = false;
      _lastCapturedImage = imageFile;
    });
  }

  Future<void> _selectFromGallery() async {
    try {
      // Check storage permission for gallery access
      if (Platform.isAndroid) {
        final permission = await Permission.photos.status;
        if (!permission.isGranted) {
          final newPermission = await Permission.photos.request();
          if (!newPermission.isGranted) {
            _showGalleryPermissionDialog();
            return;
          }
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        _analyzeImage(pickedFile.path);
      }
    } catch (e) {
      _showGalleryPermissionDialog();
    }
  }

  void _showGalleryPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cần quyền truy cập thư viện'),
          content: const Text(
              'Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh. Vui lòng cấp quyền để tiếp tục.'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Cấp quyền'),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _manualInputSelect() {
    Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
        arguments: {'type': 'input'});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cần quyền truy cập camera'),
          content: const Text(
              'Ứng dụng cần quyền truy cập camera để chụp ảnh đường huyết. Vui lòng cấp quyền để tiếp tục.'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
              },
            ),
            TextButton(
              child: const Text('Cấp quyền'),
              onPressed: () {
                Navigator.pop(context);
                _requestCameraPermission();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quyền truy cập bị từ chối'),
          content: const Text(
              'Quyền truy cập camera đã bị từ chối vĩnh viễn. Vui lòng vào Cài đặt để cấp quyền cho ứng dụng.'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
              },
            ),
            TextButton(
              child: const Text('Mở cài đặt'),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings().then((_) {
                  // Reset permission states when user comes back from settings
                  _permissionDenied = false;
                  _permissionPermanentlyDenied = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoCameraDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Không tìm thấy camera'),
          content: const Text(
              'Thiết bị không có camera hoặc camera không khả dụng. Vui lòng sử dụng chức năng chọn ảnh từ thư viện.'),
          actions: [
            TextButton(
              child: const Text('Chọn ảnh'),
              onPressed: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
            ),
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    try {
      // Reset permission states before requesting
      _permissionDenied = false;
      _permissionPermanentlyDenied = false;
      
      final status = await Permission.camera.request();
      if (status.isGranted) {
        // Permission granted, reinitialize camera
        _initializeCamera();
      } else if (status.isPermanentlyDenied) {
        _permissionPermanentlyDenied = true;
        _showPermissionDeniedDialog();
      } else {
        _permissionDenied = true;
        _showPermissionDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi khi yêu cầu quyền camera: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show analyzing view if analyzing
    if (_isAnalyzing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildAnalyzingView(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _appBarSection(),
          Expanded(
            child: Stack(
              children: [
                // Camera Preview
                _buildCameraPreview(),

                // Bottom controls
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomControls(),
                ),

                // Flash effect
                if (_showFlashEffect) _buildFlashEffect(),

                // Loading indicator
                if (_isLoading) _buildLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        'Đường huyết',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: R.color.white),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () {
          // Trigger observer to refresh glucose data and charts
          Observable.instance.notifyObservers([], notifyName: "glucose_data_refresh");
          Navigator.pop(context);
        },
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _manualInputSelect,
              child: Container(
                width: 145,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFCAFAF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF8FEBE0),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit,
                      color: R.color.greenGradientBottom,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nhập thủ công',
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    // Show loading if requesting permission
    if (_requestingPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Đang yêu cầu quyền camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Show permission denied state
    if (_permissionDenied || _permissionPermanentlyDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Cần quyền truy cập camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng cấp quyền camera để chụp ảnh hoặc sử dụng chức năng chọn ảnh từ thư viện',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _requestCameraPermission,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cấp quyền'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: R.color.greenGradientBottom,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _selectFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Chọn ảnh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Show error state if no cameras available
    if (_cameras.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Camera không khả dụng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng sử dụng chức năng chọn ảnh từ thư viện',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ thư viện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: R.color.greenGradientBottom,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Show loading if camera is not initialized
    if (!_isInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    double paddingBottom = 150 + MediaQuery.of(context).viewInsets.bottom / 2;

    return Positioned.fill(
      bottom: paddingBottom,
      child: OverflowBox(
        maxHeight: MediaQuery.of(context).size.height - paddingBottom,
        alignment: Alignment.topCenter,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize?.height ??
                MediaQuery.of(context).size.width,
            height: _controller!.value.previewSize?.width ??
                MediaQuery.of(context).size.height,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 38),
      color: Colors.white,
      child: SafeArea(
        bottom: true,
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 13),
                _buildControlButton(
                  icon: Icons.photo_library,
                  onTap: _selectFromGallery,
                  size: 56,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ảnh',
                  style: TextStyle(
                    color: Color(0xFF636A6B),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Capture button - only show if camera is available and initialized
            if (_cameras.isNotEmpty && _isInitialized)
              _buildCaptureButton()
            else
              // Show disabled capture button when camera is not available
              _buildDisabledCaptureButton(),

            // Rotate button - only show if multiple cameras available
            if (_cameras.length > 1)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 13),
                  _buildControlButton(
                    icon: Icons.rotate_right,
                    onTap: _isInitialized ? _switchCamera : null,
                    size: 56,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Xoay',
                    style: TextStyle(
                      color: Color(0xFF636A6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              )
            else
              // Show manual input button when no camera switching available
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 13),
                  _buildControlButton(
                    icon: Icons.edit,
                    onTap: _manualInputSelect,
                    size: 56,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nhập',
                    style: TextStyle(
                      color: Color(0xFF636A6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isInitialized ? _captureImage : null,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: R.color.greenGradientBottom,
            width: 4,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: R.color.greenGradientBottom,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledCaptureButton() {
    return GestureDetector(
      onTap: null, // Disabled
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 4,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt,
            color: Colors.grey.shade500,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildFlashEffect() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return Stack(
      children: [
        // Show the captured image in the background
        if (_showCapturedImage && _lastCapturedImage != null)
          Positioned.fill(
            child: Image.file(
              _lastCapturedImage!,
              fit: BoxFit.cover,
            ),
          )
        else if (_controller != null && _controller!.value.isInitialized)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
        // Dark overlay with analyzing text
        Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(R.color.color0xffEDEEEE),
                ),
                SizedBox(height: 24),
                Text(
                  R.string.analyzing_blood_glucose.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.color0xffEDEEEE,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _analyzeImage(String imagePath) async {
    setState(() {
      _showCapturedImage = true;
      _lastCapturedImage = File(imagePath);
      _isAnalyzing = true;
    });

    try {
      final result = await GlucoseClient().postBloodSugarImages([imagePath]);

      if (result != null) {
        setState(() {
          _analysisResult = result;
        });

        // Navigate to add_bloodsugar_new with pre-filled data
        Navigator.pushNamed(
          context,
          NavigatorName.add_blood_sugar_new,
          arguments: {
            'type': 'input',
            'prefilledValue': result.value.toString(),
            'prefilledUnit': result.unit,
            'selectedImages': [imagePath],
          },
        );
      } else {
        BotToast.showText(text: 'Không thể phân tích ảnh. Vui lòng thử lại.');
        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      BotToast.showText(text: 'Lỗi khi phân tích ảnh');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
