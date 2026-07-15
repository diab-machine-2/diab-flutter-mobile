import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/search_food_controller.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodImageCapture extends StatefulWidget {
  const FoodImageCapture(
      {Key? key, required this.timeframe, required this.timeframeId, this.goalId})
      : super(key: key);

  final String timeframe;
  final String timeframeId;
  final String? goalId;

  @override
  State<FoodImageCapture> createState() => _FoodImageCaptureState();
}

class _FoodImageCaptureState extends State<FoodImageCapture>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final String _refImagePathKey = 'last_captured_food_image';
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  File? _lastCapturedImage;
  bool _disposed = false;

  // Animation properties
  bool _showFlashEffect = false;
  bool _requestingPermission = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestAllPermissions();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _safeDisposeCamera();
    super.dispose();
  }

  /// Safely disposes the camera controller with proper error handling
  Future<void> _safeDisposeCamera() async {
    if (_controller == null) return;

    try {
      // Set initialized to false first to prevent new operations
      // Only call setState if widget is still mounted and not disposed
      if (mounted && !_disposed) {
        try {
          setState(() {
            _isInitialized = false;
          });
        } catch (e) {
          print('Error calling setState during disposal: $e');
          // Continue with disposal even if setState fails
        }
      }

      // Wait a bit to ensure any ongoing operations complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Dispose the controller
      await _controller?.dispose();
    } catch (e) {
      print('Error disposing camera controller: $e');
      // Continue with disposal even if there's an error
    } finally {
      _controller = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _safeDisposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      // Wait a bit before reinitializing to ensure proper state
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_disposed) {
          _initializeCamera();
        }
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    if (_requestingPermission) {
      return;
    }

    try {
      _requestingPermission = true;

      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      developer.log(
          '[PERMISSION] Camera permission status: ${cameraStatus.name}, isGranted: ${cameraStatus.isGranted}',
          name: '[PERMISSION]');
      if (!cameraStatus.isGranted) {
        _requestingPermission = false;
        _showErrorDialog('Camera permission is required to take photos');
        return;
      }

      _requestingPermission = false;

      // Wait a bit before initializing camera to ensure permissions are fully processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize camera after permissions are granted
      await _initializeCamera();
      _loadLastCapturedImage();
    } catch (e) {
      _requestingPermission = false;
      _showErrorDialog('Lỗi khi yêu cầu quyền: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Check camera permission first
      final granted = await Permission.camera.isGranted;
      if (!granted) {
        print('Camera permission not granted');
        return;
      }

      // Dispose existing controller first
      if (_controller != null) {
        await _safeDisposeCamera();
        // Wait a bit for disposal to complete
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorDialog('Không tìm thấy camera nào');
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
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        _showErrorDialog('Không thể khởi tạo camera: $e');
      }
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    try {
      // Ensure we have a valid camera index
      if (cameraIndex >= _cameras.length) {
        print('Invalid camera index: $cameraIndex');
        return;
      }

      // Dispose existing controller first
      if (_controller != null) {
        await _safeDisposeCamera();
        // Wait for disposal to complete
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Create new controller
      _controller = CameraController(
        _cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg, // Use JPEG format
      );

      // Initialize the controller
      await _controller!.initialize();

      if (mounted && !_disposed) {
        try {
          setState(() {
            _isInitialized = true;
          });
          print('Camera initialized successfully');
        } catch (e) {
          print('Error calling setState during camera initialization: $e');
        }
      }
    } catch (e) {
      print('Error setting up camera: $e');
      if (mounted && !_disposed) {
        try {
          setState(() {
            _isInitialized = false;
          });
        } catch (e) {
          print('Error calling setState during camera error: $e');
        }
        // Try to reinitialize after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_disposed) {
            _initializeCamera();
          }
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || !_isInitialized) return;

    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _selectedCameraIndex = newIndex;
    await _setupCamera(newIndex);

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  Future<void> _captureImage() async {
    if (_controller?.value == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isStreamingImages ||
        !_isInitialized) return;

    try {
      final XFile file = await _controller!.takePicture();
      final imageFile = File(file.path);

      // Save image to photo album
      await _saveToPhotoAlbum(imageFile);

      // Save the image path to SharedPreferences for future loading
      await _saveImagePathToPreferences(imageFile.path);

      // Start the zoom animation
      await _startCaptureAnimation(imageFile);

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Convert captured image to 480x480 JPEG for API processing
      final String convertedPath = await _convertToJpeg480x480(imageFile.path);

      // Directly process the captured image
      await _processSelectedImages([convertedPath]);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi khi chụp ảnh: $e');
      }
    }
  }

  Future<void> _startCaptureAnimation(File imageFile) async {
    // Show flash effect
    if (mounted && !_disposed) {
      try {
        setState(() {
          _showFlashEffect = true;
        });
      } catch (e) {
        print('Error calling setState during flash effect: $e');
      }
    }

    // Brief flash duration
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted && !_disposed) {
      try {
        setState(() {
          _showFlashEffect = false;
          _lastCapturedImage = imageFile;
        });
      } catch (e) {
        print('Error calling setState during flash end: $e');
      }
    }
  }

  Future<void> _saveToPhotoAlbum(File imageFile) async {
    try {
      // SaverGallery.saveImage() uses MediaStore insert on API 29+ which
      // does not require READ_MEDIA_IMAGES permission.

      // Read image as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Save to photo album
      String imageName = "DiaB_Food_${DateTime.now().millisecondsSinceEpoch}";

      var result = await SaverGallery.saveImage(
        imageBytes,
        quality: 100,
        name: imageName,
        androidRelativePath: "Pictures/DiaB",
        androidExistNotSave: false,
      );

      developer.log(
          '[SAVE] Image saved to gallery: $result, isSuccess: ${result.isSuccess}, errorMessage: ${result.errorMessage}',
          name: '[SAVE]');

      if (result.isSuccess) {
        developer.log(
            '[SAVE] Image saved successfully',
            name: '[SAVE]');
        // Show success message briefly
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(R.string.image_saved_to_gallery.tr()),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        developer.log(
            '[SAVE] Failed to save image: ${result.errorMessage}',
            name: '[SAVE]');
        // Show error message for debugging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${R.string.image_save_error.tr()}: ${result.errorMessage}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      developer.log(
          '[SAVE] Error saving to photo album: $e',
          name: '[SAVE]');
      // Show error for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${R.string.image_save_error.tr()}: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(R.string.error.tr()),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(R.string.close.tr()),
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

  void _manualInputSelect() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchFoodController(
          foods: [],
          suggestKcal: null,
          popAfterCallback: false,
          callback: (foods) {
            if (foods.isNotEmpty) {
              Navigator.pushNamed(
                context,
                NavigatorName.confirm_food,
                arguments: {
                  'foods': foods,
                  'timeframe': widget.timeframe,
                  'timeframeId': widget.timeframeId,
                  'files': <String>[],
                  'isManualInput': true,
                  'goalId': widget.goalId,
                },
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              _appBarSection(),
              Expanded(
                child: Stack(
                  children: [
                    // Camera Preview
                    _buildCameraPreview(),

                    // Top overlay guide
                    _buildTopOverlay(),

                    // Bottom controls
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildBottomControls(),
                    ),

                    // Flash effect
                    if (_showFlashEffect) _buildFlashEffect(),
                  ],
                ),
              ),
            ],
          ),
          // Full screen analyzing overlay
          if (_isAnalyzing) _buildAnalyzingOverlay(),
        ],
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        widget.timeframe,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: R.color.white),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () => Navigator.pop(context),
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
                    Image.asset(
                      R.drawable.ic_food_edit_raw,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      R.string.nhap_mon_an.tr(),
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
      child: ClipRect(
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
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      margin: EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Good lighting section
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_sunny, width: 24, height: 24),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    R.string.good_lighting.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Maximum 5 photos section
          // Good lighting section
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_image_placeholder,
                    width: 24, height: 24),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    R.string.max_one_photo.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // One dish at a time section
          // Good lighting section
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_food_bowl, width: 24, height: 24),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    R.string.one_dish_per_capture.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            // Gallery button with preview
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 13),
                _buildGalleryPreviewButton(),
                const SizedBox(height: 6),
                Text(
                  R.string.photo.tr(),
                  style: TextStyle(
                    color: Color(0xFF636A6B),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Capture button
            _buildCaptureButton(),

            // Rotate button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 13),
                _buildControlButton(
                  icon: R.drawable.im_food_capture_rotate,
                  onTap: _cameras.length > 1 && _isInitialized
                      ? _switchCamera
                      : null,
                  size: 56,
                ),
                const SizedBox(height: 6),
                Text(
                  R.string.rotate.tr(),
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
    required String icon,
    required VoidCallback? onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        icon,
        width: 51,
        height: 51,
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isInitialized ? _captureImage : null,
      child: Container(
        width: 68,
        height: 68,
        child: Image.asset(
          R.drawable.im_food_capture,
          width: 68,
          height: 68,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildGalleryPreviewButton() {
    if (_lastCapturedImage == null) {
      return _buildControlButton(
        icon: R.drawable.im_food_snack,
        onTap: _openGalleryPicker,
        size: 56,
      );
    } else {
      return GestureDetector(
        onTap: _openGalleryPicker,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    _lastCapturedImage!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFlashEffect() {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  R.string.analyzing_your_meal.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadLastCapturedImage() async {
    try {
      // Load the last captured image path from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final lastImagePath = prefs.getString(_refImagePathKey);

      if (lastImagePath != null && lastImagePath.isNotEmpty) {
        final imageFile = File(lastImagePath);

        // Check if the file still exists
        if (await imageFile.exists()) {
          // Update the preview
          if (mounted && !_disposed) {
            try {
              setState(() {
                _lastCapturedImage = imageFile;
              });
            } catch (e) {
              print('Error calling setState during image load: $e');
            }
          }
        } else {
          // Remove the invalid path from preferences
          await prefs.remove(_refImagePathKey);
        }
      }
    } catch (e) {
      print('Error loading last captured image: $e');
      // Silently fail, not critical for app functionality
    }
  }

  Future<void> _saveImagePathToPreferences(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refImagePathKey, imagePath);
    } catch (e) {
      print('Error saving image path to preferences: $e');
    }
  }

  /// Opens the system photo picker to select an image from the gallery.
  /// Uses ImagePicker which delegates to the OS photo picker and does NOT
  /// require READ_MEDIA_IMAGES permission.
  Future<void> _openGalleryPicker() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        developer.log(
            '[CAPTURE] Image picked from gallery: ${pickedFile.path}',
            name: '[CAPTURE]');

        // Convert to 480x480 JPEG for API processing
        final String convertedPath = await _convertToJpeg480x480(pickedFile.path);

        // Process the selected image
        await _processSelectedImages([convertedPath]);
      } else {
        developer.log(
            '[CAPTURE] No image selected from gallery',
            name: '[CAPTURE]');
      }
    } catch (e) {
      developer.log(
          '[CAPTURE] Error picking image from gallery: $e',
          name: '[CAPTURE]');
      if (mounted) {
        _showErrorDialog('Lỗi khi chọn ảnh: $e');
      }
    }
  }

  /// Convert image to 480x480 JPEG, auto-cropping to center square.
  /// This is especially important on iOS where HEIC / HEIF / Live formats
  /// can cause downstream decoding issues.
  Future<String> _convertToJpeg480x480(String originalPath) async {
    try {
      final File originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        return originalPath;
      }

      // Step 1: Use platform codecs (flutter_image_compress) to ensure
      // HEIC/HEIF/LIVE inputs become JPEG bytes.
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
        originalPath,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null || compressedBytes.isEmpty) {
        return originalPath;
      }

      // Step 2: Decode JPEG bytes with `image` package and center-crop to square,
      // then resize to exactly 480x480.
      final img.Image? decoded = img.decodeImage(compressedBytes);
      if (decoded == null) {
        return originalPath;
      }

      final int cropSize =
          decoded.width < decoded.height ? decoded.width : decoded.height;
      final int offsetX = (decoded.width - cropSize) ~/ 2;
      final int offsetY = (decoded.height - cropSize) ~/ 2;

      final img.Image cropped = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: cropSize,
        height: cropSize,
      );

      final img.Image resized =
          img.copyResize(cropped, width: 480, height: 480);

      final List<int> jpegBytes = img.encodeJpg(resized, quality: 85);

      final Directory tempDir = Directory.systemTemp;
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String baseName = p.basenameWithoutExtension(originalPath);
      final String fileName =
          'DiaB_Food_${timestamp}_${baseName.isEmpty ? "image" : baseName}.jpg';
      final File outFile = File(p.join(tempDir.path, fileName));
      await outFile.writeAsBytes(jpegBytes, flush: true);

      developer.log(
        '[CAPTURE] Converted image to JPEG 480x480: ${outFile.path}',
        name: '[CAPTURE]',
      );

      return outFile.path;
    } catch (e) {
      developer.log(
        '[CAPTURE] Error converting image to JPEG 480x480: $e',
        name: '[CAPTURE]',
      );
      // On any error, fall back to the original path so flow continues.
      return originalPath;
    }
  }

  /// Checks if any of the food items are unidentified meals
  /// Returns true if any item has zero calories and contains "UNIDENTIFIED" in code or "Không xác định" in text
  bool _checkForUnidentifiedMeals(List<dynamic> foods) {
    for (var food in foods) {
      // Check if calories is zero
      double? calorie = food.calorie;
      if (calorie == null || calorie == 0) {
        // Check if code contains "UNIDENTIFIED" or text contains "Không xác định"
        String? code = food.code?.toString() ?? '';
        String? text = food.text?.toString() ?? '';

        const List<String> unidentifiedKeywords = [
          'unidentified',
          'unknown',
          'không xác định'
        ];
        if (unidentifiedKeywords.any((keyword) =>
            code.toLowerCase().contains(keyword) ||
            text.toLowerCase().contains(keyword))) {
          print(
              'Found unidentified meal: code=$code, text=$text, calorie=$calorie');
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _processSelectedImages(List<String> imagePaths) async {
    try {
      // Show analyzing overlay
      if (mounted && !_disposed) {
        try {
          setState(() {
            _isAnalyzing = true;
          });
        } catch (e) {
          print('Error calling setState during analyzing start: $e');
        }
      }

      final mealScoreData = await FoodClient().postMealScore(imagePaths);
      
      List<FoodModel> result = [];
      if (mealScoreData != null && mealScoreData['items'] != null) {
        result = FoodModel.toList(mealScoreData['items']);
      }
      print("API call completed with result: ${result.length} items");

      // Update portion of each item to 1 when uploading with AI
      final updatedResult =
          result.map((food) => food.copyWith(quantity: 1.0)).toList();

      // Hide analyzing overlay
      if (mounted && !_disposed) {
        try {
          setState(() {
            _isAnalyzing = false;
          });
        } catch (e) {
          print('Error calling setState during analyzing end: $e');
        }
      }

      // Check for unidentified meals
      if (updatedResult.isNotEmpty) {
        bool hasUnidentifiedMeal = _checkForUnidentifiedMeals(updatedResult);

        if (hasUnidentifiedMeal) {
          BotToast.closeAllLoading(); // Close all toasts including custom text
          BotToast.showCustomText(
            toastBuilder: (_) => Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: R.color.color0xff111515.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                R.string.unknown_meal_image.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            align: Alignment.center,
            duration: Duration(seconds: 2),
            clickClose: true,
            crossPage: true,
            onlyOne: true,
          );
          // Restart camera - wait a bit for proper state
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _initializeCamera();
            }
          });
          return;
        }
      }

      // Navigate to the food detail page with the new food ID
      if (updatedResult.isNotEmpty) {
        BotToast.closeAllLoading(); // Close all toasts including custom text
        developer.log(
            '[CAPTURE] FoodImageCapture navigating to confirm_food with files count: ' +
                imagePaths.length.toString() +
                ', paths: ' +
                imagePaths.join(', '),
            name: '[CAPTURE]');
        await Navigator.pushNamed(context, NavigatorName.confirm_food,
            arguments: {
              'timeframe': widget.timeframe,
              'timeframeId': widget.timeframeId,
              'foods': updatedResult,
              'files': imagePaths,
              'mealScoreData': mealScoreData,
              'isManualInput': false,
              'goalId': widget.goalId,
            });

        // Re-initialize camera after returning from the confirm_food screen.
        if (mounted && !_disposed) {
          _initializeCamera();
        }
      } else {
        BotToast.closeAllLoading(); // Close all toasts including custom text
        BotToast.showText(text: 'Không tìm thấy thực phẩm nào để đồng bộ');
        // Restart camera - wait a bit for proper state
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_disposed) {
            _initializeCamera();
          }
        });
      }
    } catch (e) {
      print("Error occurred: $e");
      if (mounted && !_disposed) {
        try {
          setState(() {
            _isAnalyzing = false;
          });
        } catch (e) {
          print('Error calling setState during error handling: $e');
        }
      }
      BotToast.showText(text: 'Lỗi khi phân tích bữa ăn');
      // Restart camera - wait a bit for proper state
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_disposed) {
          _initializeCamera();
        }
      });
    }
  }
}
