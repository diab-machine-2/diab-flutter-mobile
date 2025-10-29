import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:photo_manager/photo_manager.dart';

class FoodGalleryPicker extends StatefulWidget {
  const FoodGalleryPicker({
    Key? key,
    required this.timeframe,
    required this.timeframeId,
    this.onImagesSelected,
  }) : super(key: key);

  final String timeframe;
  final String timeframeId;
  final Function(List<String>)? onImagesSelected;

  @override
  State<FoodGalleryPicker> createState() => _FoodGalleryPickerState();
}

class _FoodGalleryPickerState extends State<FoodGalleryPicker> {
  List<AssetEntity> _recentPhotos = [];
  List<String> _selectedImages = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  final int _maxSelection = 5;
  bool _didAutoSelectMostRecent = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    try {
      // Check/ask permission (Android 13+ may return limited)
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      final bool granted = permission == PermissionState.authorized ||
          permission == PermissionState.limited ||
          permission.isAuth;

      if (granted) {
        setState(() {
          _hasPermission = true;
        });
        await _loadRecentPhotos();
      } else {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
        // Don't show permission dialog here since permissions should be granted upfront
        // Just show empty state with message
      }
    } catch (e) {
      print('Error requesting permission: $e');
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentPhotos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get recent photos (last 50)
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isNotEmpty) {
        final AssetPathEntity recentAlbum = albums.first;
        final List<AssetEntity> photos = await recentAlbum.getAssetListPaged(
          page: 0,
          size: 50,
        );

        setState(() {
          _recentPhotos = photos;
          _isLoading = false;
        });

        // Auto-select the most recent captured image once
        if (!_didAutoSelectMostRecent &&
            _selectedImages.isEmpty &&
            photos.isNotEmpty) {
          final File? f = await photos.first.file;
          if (f != null) {
            setState(() {
              _selectedImages.add(f.path);
              _didAutoSelectMostRecent = true;
            });
          }
        }
      } else {
        setState(() {
          _recentPhotos = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading photos: $e');
      setState(() {
        _recentPhotos = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 100,
      );

      if (image != null) {
        // Persist captured image to system gallery and select it
        try {
          final bytes = await File(image.path).readAsBytes();
          final String fileName =
              'DiaB_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final AssetEntity? saved = await PhotoManager.editor.saveImage(
            bytes,
            title: fileName,
            filename: fileName,
          );

          // Reload recent photos to include the new capture
          await _loadRecentPhotos();

          if (saved != null) {
            final File? savedFile = await saved.file;
            if (savedFile != null) {
              setState(() {
                if (!_selectedImages.contains(savedFile.path) &&
                    _selectedImages.length < _maxSelection) {
                  _selectedImages.add(savedFile.path);
                }
                _didAutoSelectMostRecent = true;
              });
            }
          }
        } catch (e) {
          // Fallback: still try to add the temp path so user sees it
          setState(() {
            if (_selectedImages.length < _maxSelection) {
              _selectedImages.add(image.path);
            }
          });
          await _loadRecentPhotos();
        }
      }
    } catch (e) {
      print('Error capturing image: $e');
      _showErrorDialog('Lỗi khi chụp ảnh: $e');
    }
  }

  void _toggleImageSelection(String imagePath) {
    setState(() {
      if (_selectedImages.contains(imagePath)) {
        _selectedImages.remove(imagePath);
      } else if (_selectedImages.length < _maxSelection) {
        _selectedImages.add(imagePath);
      } else {
        _showErrorDialog(
            R.string.max_image_select_dynamic.tr(args: ["${_maxSelection}"]));
      }
    });
  }

  void _confirmSelection() {
    if (_selectedImages.isNotEmpty) {
      widget.onImagesSelected?.call(_selectedImages);
      Navigator.pop(context, _selectedImages);
    } else {
      _showErrorDialog(R.string.please_select_at_least_one_image.tr());
    }
  }

  void _showErrorDialog(String message) {
    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        // width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: R.color.color0xff111515.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _hasPermission
                ? _buildGalleryContent()
                : _buildPermissionDenied(),
          ),
          if (_selectedImages.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        R.string.choose_meal_image.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        // Recent photos grid
        Expanded(
          child:
              _recentPhotos.isEmpty ? _buildEmptyState() : _buildPhotosGrid(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            R.drawable.ic_image_placeholder,
            width: 80,
            height: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có ảnh nào trong thư viện',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _captureImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Chụp ảnh'),
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

  Widget _buildPhotosGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _recentPhotos.length + 1, // +1 for capture button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Capture button as first item
          return _buildCaptureButton();
        } else {
          // Photo items
          final photoIndex = index - 1;
          final photo = _recentPhotos[photoIndex];
          return _buildPhotoItem(photo);
        }
      },
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              'Chụp ảnh',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(AssetEntity photo) {
    return FutureBuilder<File?>(
      future: photo.file,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final file = snapshot.data!;
          final isSelected = _selectedImages.contains(file.path);

          return GestureDetector(
            onTap: () => _toggleImageSelection(file.path),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? R.color.greenGradientBottom
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      file,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: R.color.greenGradientBottom,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có quyền truy cập thư viện ảnh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng cấp quyền truy cập thư viện ảnh\nđể sử dụng tính năng này',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
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

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _confirmSelection,
              child: Container(
                height: 43,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.greenGradientTop,
                        R.color.greenGradientBottom
                      ]),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Center(
                  child: Text(R.string.tiep_tuc.tr(),
                      style: TextStyle(
                          color: R.color.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
