import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodImageCapture extends StatefulWidget {
  const FoodImageCapture({Key? key}) : super(key: key);

  @override
  State<FoodImageCapture> createState() => _FoodImageCaptureState();
}

class _FoodImageCaptureState extends State<FoodImageCapture> with WidgetsBindingObserver {
  final String _refImagePathKey = 'last_captured_food_image';
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  File? _lastCapturedImage;

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
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
      _showErrorDialog('Không thể khởi tạo camera: $e');
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_controller != null) {
      await _controller!.dispose();
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
      _showErrorDialog('Lỗi khi khởi tạo camera: $e');
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
    if (_controller?.value == null || !_controller!.value.isInitialized) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final XFile file = await _controller!.takePicture();
      final imageFile = File(file.path);

      // Save image to photo album
      await _saveToPhotoAlbum(imageFile);

      // Update preview with last captured image
      setState(() {
        _lastCapturedImage = imageFile;
      });

      // Save the image path to SharedPreferences for future loading
      await _saveImagePathToPreferences(imageFile.path);

      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      _showErrorDialog('Lỗi khi chụp ảnh: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      final result = await SaverGallery.saveImage(
        imageBytes,
        quality: 100,
        name: imageName,
        androidRelativePath: "Pictures/DiaB",
      );
      print('Image saved to gallery: $result');

      if (result.isSuccess) {
        print('Image saved successfully: ${result.errorMessage}');
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
        print('Failed to save image: $result');
      }
    } catch (e) {
      print('Error saving to photo album: $e');
      // Don't show error dialog as this is a secondary feature
    }
  }

  Future<void> _openGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 100,
      );

      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          // Process picked files if needed
          print('Picked file: ${file.path}');
        }

        // Navigator.pop(context, pickedFiles);
        // TODO: handle picked files
      }
    } catch (e) {
      _showPermissionDialog();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _buildCameraPreview(),

          // Top overlay guide
          _buildTopOverlay(),

          // Bottom controls
          _buildBottomControls(),

          // Loading indicator
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller?.value == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Positioned.fill(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Column(
        children: [
          // App bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Chụp ảnh món ăn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40), // Balance the close button
              ],
            ),
          ),

          // Guide overlay
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Đặt món ăn vào giữa khung hình',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Đảm bảo ánh sáng đủ và hình ảnh rõ nét',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Chụp toàn bộ món ăn trong đĩa/bát',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button with preview
              _buildGalleryPreviewButton(),

              // Capture button
              _buildCaptureButton(),

              // Switch camera button
              _buildControlButton(
                icon: R.drawable.ic_refresh,
                onTap: _cameras.length > 1 ? _switchCamera : null,
                size: 56,
              ),
            ],
          ),
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
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: 24,
            height: 24,
            color: onTap != null ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                R.color.greenGradientTop,
                R.color.greenGradientBottom,
              ],
            ),
          ),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryPreviewButton() {
    if (_lastCapturedImage == null) {
      return _buildControlButton(
        icon: R.drawable.ic_photo,
        onTap: _openGallery,
        size: 56,
      );
    } else {
      return GestureDetector(
        onTap: _openGallery,
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
        // For Android, check and request storage permission
        status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        } 
        // For Android, check and request photos permission
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }

      } else if (Platform.isIOS) {
        // For iOS, check and request photos permission
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
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
