import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class FoodImagesSelection extends StatefulWidget {
  final List<dynamic>? initialImages;
  final int maxImages;
  final Function(List<dynamic>)? onImagesChanged;

  const FoodImagesSelection({
    Key? key,
    this.initialImages,
    this.maxImages = 10,
    this.onImagesChanged,
  }) : super(key: key);

  @override
  State<FoodImagesSelection> createState() => _FoodImagesSelectionState();
}

class _FoodImagesSelectionState extends State<FoodImagesSelection> {
  List<dynamic> _selectedImages = [];
  List<String?> _removeIDs = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null) {
      _selectedImages.addAll(widget.initialImages!);
    }
  }

  bool get _canAddMore => _selectedImages.length < widget.maxImages;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: R.color.glucose_bg_color,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _appBarSection(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: R.color.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn ảnh món ăn',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: R.color.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tối đa ${widget.maxImages} ảnh (${_selectedImages.length}/${widget.maxImages})',
                              style: TextStyle(
                                fontSize: 14,
                                color: R.color.primaryGreyColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildImageSelection(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImages.isNotEmpty) _buildSelectedImages(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        'Chọn ảnh món ăn',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.white,
        highlightColor: R.color.white,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildImageSelection() {
    return Column(
      children: [
        // Camera option (first priority)
        _buildImageSelectionOption(
          icon: R.drawable.ic_camera_black,
          title: 'Chụp ảnh từ camera',
          subtitle: 'Chụp ảnh món ăn trực tiếp',
          onTap: _canAddMore ? () => _openCamera() : null,
        ),
        const SizedBox(height: 12),
        Container(height: 1, color: R.color.color0xffE5E5E5),
        const SizedBox(height: 12),
        // Gallery option
        _buildImageSelectionOption(
          icon: R.drawable.ic_photo,
          title: 'Chọn từ thư viện',
          subtitle: 'Chọn ảnh có sẵn trong thiết bị',
          onTap: _canAddMore ? () => _openGallery() : null,
        ),
      ],
    );
  }

  Widget _buildImageSelectionOption({
    required String icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? R.color.white : R.color.color0xfff5f5f5,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? R.color.greenGradientBottom : R.color.color0xffE5E5E5,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEnabled 
                    ? R.color.greenGradientBottom.withOpacity(0.1)
                    : R.color.color0xfff5f5f5,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: 24,
                  height: 24,
                  color: isEnabled 
                      ? R.color.greenGradientBottom
                      : R.color.color0xffBFC6C6,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEnabled ? R.color.textDark : R.color.color0xffBFC6C6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isEnabled ? R.color.primaryGreyColor : R.color.color0xffBFC6C6,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isEnabled ? R.color.greenGradientBottom : R.color.color0xffBFC6C6,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImages() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ảnh đã chọn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: R.color.textDark,
                  ),
                ),
                Text(
                  '${_selectedImages.length}/${widget.maxImages}',
                  style: TextStyle(
                    fontSize: 14,
                    color: R.color.primaryGreyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return _buildImageItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final image = _selectedImages[index];
    return GestureDetector(
      onTap: () {
        _showImagePreview(index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image is PickedFile
                    ? Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      )
                    : NetWorkImageWidget(
                        imageUrl: image.url,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: R.color.greenGradientBottom),
                  ),
                  child: Center(
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _selectedImages.isNotEmpty ? _confirmSelection : null,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedImages.isNotEmpty 
                        ? R.color.greenGradientBottom
                        : R.color.color0xffBFC6C6,
                    borderRadius: BorderRadius.circular(24),
                    gradient: _selectedImages.isNotEmpty 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom,
                            ],
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Xác nhận (${_selectedImages.length})',
                      style: TextStyle(
                        color: R.color.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        maxWidth: 1024,
        maxHeight: 1024,
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
        widget.onImagesChanged?.call(_selectedImages);
      }
    } catch (e) {
      _showPermissionDialog();
    }
  }

  void _openGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        maxWidth: 1024,
        maxHeight: 1024,
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
        widget.onImagesChanged?.call(_selectedImages);
      }
    } catch (e) {
      _showPermissionDialog();
    }
  }

  void _removeImage(int index) {
    setState(() {
      final image = _selectedImages[index];
      if (image is PickedFile) {
        _selectedImages.removeAt(index);
      } else {
        _removeIDs.add(image.id);
        _selectedImages.removeAt(index);
      }
    });
    widget.onImagesChanged?.call(_selectedImages);
  }

  void _showImagePreview(int index) {
    Navigator.pushNamed(
      context,
      '/photo_view',
      arguments: {
        'files': _selectedImages,
        'index': index,
      },
    );
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'images': _selectedImages,
      'removeIDs': _removeIDs,
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thông báo'),
          content: Text('Ứng dụng cần quyền truy cập camera/thư viện để chọn ảnh'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cho phép'),
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
} 