import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../../res/R.dart';
import '../../utils/navigator_name.dart';

class PhotoPickerPage extends StatefulWidget {
  const PhotoPickerPage({Key? key}) : super(key: key);

  @override
  State<PhotoPickerPage> createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  List<AssetEntity> _photos = [];
  AssetEntity? _selected; // chỉ giữ 1 ảnh được chọn
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      PhotoManager.openSetting();
      return;
    }

    await PhotoManager.clearFileCache();
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isNotEmpty) {
      final recent = albums.first;
      final photos = await recent.getAssetListPaged(page: 0, size: 100);
      setState(() {
        _photos = photos;
      });
    }
  }

  void _toggleSelect(AssetEntity asset) {
    setState(() {
      if (_selected == asset) {
        _selected = null; // bỏ chọn nếu nhấn lại
      } else {
        _selected = asset; // thay thế bằng ảnh mới
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = 3;

    return Scaffold(
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
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: _photos.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Ô chụp ảnh
                  return GestureDetector(
                    onTap: () {
                      _captureFromCamera();
                    },
                    child: Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.camera_alt, size: 40, color: Colors.black54),
                      ),
                    ),
                  );
                }

                final asset = _photos[index - 1];
                return FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(color: Colors.grey[200]);
                    }

                    final isSelected = _selected == asset;

                    return GestureDetector(
                      onTap: () => _toggleSelect(asset),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(snapshot.data!, fit: BoxFit.cover),
                          // Icon check ở góc trên bên phải
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.teal : Colors.white,
                              size: 28,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              color: Colors.black26,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          if (_selected != null) {
            final file = await _selected!.file;
            if (file != null) {
              Navigator.pop(context, file); // trả về file cho màn hình trước
            }
          }
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: R.color.mainColor,
            borderRadius: BorderRadius.circular(200),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: _selected != null
                ? [R.color.greenGradientTop, R.color.greenGradientBottom]
                : [R.color.grey, R.color.gray_1],
            ),
          ),
          child: Center(
            child: Text(
              R.string.tiep_tuc.tr(),
              style: TextStyle(
                color: R.color.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    await _picker.pickImage(source: ImageSource.camera);
    _loadPhotos();
  }
}