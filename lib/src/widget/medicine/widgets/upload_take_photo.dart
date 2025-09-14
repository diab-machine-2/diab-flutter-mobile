import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class UploadTakePhotoButtons extends StatefulWidget {
  final VoidCallback onUploadTap;
  final VoidCallback onTakePhotoTap;

  const UploadTakePhotoButtons({
    Key? key,
    required this.onUploadTap,
    required this.onTakePhotoTap,
  }) : super(key: key);

  @override
  State<UploadTakePhotoButtons> createState() => _UploadTakePhotoButtonsState();
}

class _UploadTakePhotoButtonsState extends State<UploadTakePhotoButtons> {
  AssetEntity? _firstPhoto;

  @override
  void initState() {
    super.initState();
    _loadFirstPhoto();
  }

  Future<void> _loadFirstPhoto() async {
    // Xin quyền đọc ảnh (Android 13–15 chuẩn mới)
    final PermissionState ps = await PhotoManager.requestPermissionExtend(); // the method can use optional param `permission`.
    if (ps.isAuth) {
      // Granted
      // You can to get assets here.
    } else if (ps.hasAccess) {
      // Access will continue, but the amount visible depends on the user's selection.
    } else {
      // Limited(iOS) or Rejected, use `==` for more precise judgements.
      // You can call `PhotoManager.openSetting()` to open settings for further steps.
    }

    if (ps.isAuth || ps == PermissionState.limited) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true, // chỉ lấy album "Tất cả ảnh"
      );

      if (albums.isNotEmpty) {
        final List<AssetEntity> media =
        await albums.first.getAssetListPaged(page: 0, size: 1);

        if (media.isNotEmpty) {
          setState(() {
            _firstPhoto = media.first;
          });
        }
      }
    } else {
      // Nếu từ chối quyền thì mở settings cho user
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 10),
        // Nút upload ảnh
        GestureDetector(
          onTap: widget.onUploadTap,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  _firstPhoto == null
                      ? const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.photo, color: Colors.white),
                  )
                      : FutureBuilder<Uint8List?>(
                    future: _firstPhoto!.thumbnailDataWithSize(
                      const ThumbnailSize(200, 200),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          snapshot.hasData) {
                        return CircleAvatar(
                          radius: 25,
                          backgroundImage: MemoryImage(snapshot.data!),
                        );
                      }
                      return const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Tải ảnh lên",
                  style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        // Nút chụp ảnh
        GestureDetector(
          onTap: widget.onTakePhotoTap,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.teal, width: 3),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Chụp ảnh",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 60),
        const SizedBox(width: 5),
      ],
    );
  }
}
