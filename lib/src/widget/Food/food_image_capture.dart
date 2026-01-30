import 'dart:io';
import 'dart:developer' as developer;
import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/Food/food_gallery_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodImageCapture extends StatefulWidget {
  const FoodImageCapture(
      {Key? key, required this.timeframe, required this.timeframeId})
      : super(key: key);

  final String timeframe;
  final String timeframeId;

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

      // Request camera permission first
      final cameraStatus = await Permission.camera.request();
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

      // Auto-open gallery after capture
      final String? recentAssetId = await _getMostRecentImageAssetId();
      await _openGalleryPicker(
        initialFilePath: imageFile.path,
        initialAssetId: recentAssetId,
      );
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
      // Request storage permission for both Android and iOS
      bool hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        print('Gallery permission denied');
        return;
      }

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

      print('Image saved to gallery: $result');

      if (result.isSuccess) {
        print('Image saved successfully to path: ${result.errorMessage}');
        // Show success message briefly
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ảnh đã được lưu vào thư viện'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('Failed to save image: ${result.errorMessage}');
        // Show error message for debugging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi lưu ảnh: ${result.errorMessage}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving to photo album: $e');
      // Show error for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu ảnh: $e'),
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

  void _manualInputSelect() {
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushNamed(context, NavigatorName.add_food,
        arguments: {'type': 'input'});
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
      height: 82,
      margin: EdgeInsets.symmetric(horizontal: 12).copyWith(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_sunny, width: 24, height: 24),
                const SizedBox(height: 4),
                Text(
                  'Ánh sáng tốt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_image_placeholder,
                    width: 24, height: 24),
                const SizedBox(height: 4),
                Text(
                  'Tối đa 5 ảnh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_food_bowl, width: 24, height: 24),
                const SizedBox(height: 4),
                Text(
                  'Mỗi lần 1 món',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
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
                  'Ảnh',
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
                  'Xoay',
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
      // Check gallery permissions first
      bool hasPermission = await _checkGalleryPermission();
      if (!hasPermission) {
        print('Gallery permission not granted');
        return;
      }

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

  Future<bool> _checkGalleryPermission() async {
    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33), check photos permission first
        status = await Permission.photos.status;
        if (!status.isGranted) {
          // Fallback to storage permission for older Android versions
          status = await Permission.storage.status;
        }
      } else if (Platform.isIOS) {
        // For iOS, check photos permission
        status = await Permission.photos.status;
      } else {
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('Error checking gallery permission: $e');
      return false;
    }
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      PermissionStatus status;

      if (Platform.isAndroid) {
        // For Android 13+ (API 33), use photos permission instead of storage
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }

        // Fallback to storage permission for older Android versions
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      } else if (Platform.isIOS) {
        // For iOS, request photos permission which is required for saving to Photos
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }

        // Also check photoLibrary permission as a fallback
        if (!status.isGranted) {
          final photoLibraryStatus = await Permission.photosAddOnly.status;
          if (!photoLibraryStatus.isGranted) {
            status = await Permission.photosAddOnly.request();
          } else {
            status = photoLibraryStatus;
          }
        }
      } else {
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting gallery permission: $e');
      return false;
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

  Future<String?> _getMostRecentImageAssetId() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      if (albums.isEmpty) return null;
      final AssetPathEntity recent = albums.first;
      final List<AssetEntity> assets =
          await recent.getAssetListPaged(page: 0, size: 1);
      if (assets.isEmpty) return null;
      return assets.first.id;
    } catch (e) {
      print('Error fetching most recent image asset id: $e');
      return null;
    }
  }

  Future<void> _openGalleryPicker(
      {String? initialFilePath, String? initialAssetId}) async {
    try {
      // Safely dispose camera with proper error handling
      await _safeDisposeCamera();

      // Open gallery picker
      final List<String>? selectedImages = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => FoodGalleryPicker(
            timeframe: widget.timeframe,
            timeframeId: widget.timeframeId,
            initialSelectedFilePath: initialFilePath,
            initialSelectedAssetId: initialAssetId,
          ),
        ),
      );

      if (selectedImages != null && selectedImages.isNotEmpty) {
        developer.log(
            '[CAPTURE] FoodImageCapture received filePaths count: ' +
                selectedImages.length.toString() +
                ', paths: ' +
                selectedImages.join(', '),
            name: '[CAPTURE]');
        // Process selected images
        await _processSelectedImages(selectedImages);
      } else {
        // Restart camera if no images selected - wait a bit for proper state
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_disposed) {
            _initializeCamera();
          }
        });
      }
    } catch (e) {
      print('Error opening gallery picker: $e');
      // Restart camera on error - wait a bit for proper state
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_disposed) {
          _initializeCamera();
        }
      });
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

      final result = await FoodClient().postFoodImages(imagePaths);
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
        Navigator.pushReplacementNamed(context, NavigatorName.confirm_food,
            arguments: {
              'timeframe': widget.timeframe,
              'timeframeId': widget.timeframeId,
              'foods': updatedResult,
              'files': imagePaths,
            });
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
