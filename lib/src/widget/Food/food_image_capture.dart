import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodImageCapture extends StatefulWidget {
  const FoodImageCapture({Key? key, required this.timeframe, required this.timeframeId})
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
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  File? _lastCapturedImage;

  // Animation properties
  bool _showFlashEffect = false;
  bool _requestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _loadLastCapturedImage();
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
      _initializeCamera();
    }
  }

  Future<void> _syncFood() async {
    final paths = await _selectImageToPost();
    if (paths.isEmpty) {
      return;
    }
    try {
      // stop camera
      setState(() {
        _isInitialized = false;
      });
      await _controller?.dispose();
      _controller = null;

      BotToast.showLoading();
      final result = await FoodClient().postFoodImages(paths);

      // Navigate to the food detail page with the new food ID
      if (result.isNotEmpty) {
        Navigator.pushReplacementNamed(context, NavigatorName.confirm_food, arguments: {
          'timeframe': widget.timeframe,
          'timeframeId': widget.timeframeId,
          'foods': result,
          'files': paths,
        });
      } else {
        BotToast.closeAllLoading();
        BotToast.showText(text: 'Không tìm thấy thực phẩm nào để đồng bộ');
      }
    } catch (e) {
      BotToast.showText(text: 'Lỗi khi đồng bộ thực phẩm: $e');
      // restart camera
      _initializeCamera();
    } finally {
      BotToast.closeAllLoading();
    }
  }

  Future<void> _initializeCamera() async {
    if (_requestingPermission) {
      return;
    }
    try {
      // request permission
      if (!(await Permission.camera.isGranted)) {
        _requestingPermission = true;
        await Permission.camera.request();
      }
      final granted = await Permission.camera.isGranted;
      _requestingPermission = false;
      _cameras = !granted ? [] : await availableCameras();
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
      _showErrorDialog('Không thể khởi tạo camera: $e');
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
      // if (mounted) {
      //   _showErrorDialog('Lỗi khi khởi tạo camera: $e');
      // }
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

      // Save image to photo album
      await _saveToPhotoAlbum(imageFile);

      // Save the image path to SharedPreferences for future loading
      await _saveImagePathToPreferences(imageFile.path);

      // Start the zoom animation
      await _startCaptureAnimation(imageFile);

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

  Future<List<String>> _selectImageToPost() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 100,
        limit: 5,
      );

      if (pickedFiles.isNotEmpty) {
        return pickedFiles.map((e) => e.path).toList();
      }
    } catch (e) {
      _showPermissionDialog();
    }
    return [];
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: const Text('Ứng dụng cần quyền truy cập camera/thư viện để chọn ảnh'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Cho phép'),
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
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushNamed(context, NavigatorName.add_food, arguments: {'type': 'input'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Column(
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
        widget.timeframe,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.white),
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
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nhập món ăn',
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
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
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
                Image.asset(R.drawable.ic_image_placeholder, width: 24, height: 24),
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
                    color: Color(0xF636A6B),
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
                  onTap: _cameras.length > 1 && _isInitialized ? _switchCamera : null,
                  size: 56,
                ),
                const SizedBox(height: 6),
                Text(
                  'Xoay',
                  style: TextStyle(
                    color: Color(0xF636A6B),
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
        onTap: _syncFood,
        size: 56,
      );
    } else {
      return GestureDetector(
        onTap: _syncFood,
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
          if (mounted) {
            setState(() {
              _lastCapturedImage = imageFile;
            });
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
        // For Android, check storage permission
        status = await Permission.storage.status;
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
}
