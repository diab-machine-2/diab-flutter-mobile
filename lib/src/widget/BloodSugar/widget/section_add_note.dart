import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

// Wrapper class to track image source
class ImageWithSource {
  final dynamic file;
  final bool isFromCamera;

  ImageWithSource(this.file, this.isFromCamera);
}

class SectionAddNote extends StatefulWidget {
  const SectionAddNote({
    super.key,
    this.focusNode,
    this.controllerNote,
    this.maxMedia = 5,
    this.initialFiles,
    this.maxLength = 250,
    this.noteTitle,
    this.horizontalPadding = 16,
    this.subText,
    this.showCameraIcons = true, // Default to true for backward compatibility
    this.initialFilesFromCamera = false,
  });

  final FocusNode? focusNode;
  final TextEditingController? controllerNote;
  final int maxMedia;
  final int maxLength;
  final List<dynamic>? initialFiles;
  final String? subText;
  final bool showCameraIcons;
  final bool initialFilesFromCamera;

  // decorator
  final String? noteTitle;
  final double horizontalPadding;

  @override
  State<SectionAddNote> createState() => SectionAddNoteState();
}

class SectionAddNoteState extends State<SectionAddNote> {
  List<ImageWithSource> _files = [];
  List<String?> _removeIDs = [];

  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    // Convert initial files to ImageWithSource.
    // Mark as from camera if caller indicates so, otherwise mark as not from camera.
    _files.addAll((widget.initialFiles ?? [])
        .map((file) => ImageWithSource(file, widget.initialFilesFromCamera)));
    if (widget.controllerNote != null) {
      _currentLength = widget.controllerNote?.text.length ?? 0;
    }
  }

  void updateFilesAndNote(List<dynamic> files, String note) {
    _files.clear();
    // Convert files to ImageWithSource, keep the same initial source setting flag
    _files.addAll(files
        .map((file) => ImageWithSource(file, widget.initialFilesFromCamera)));
    widget.controllerNote?.text = note;
    _currentLength = note.length;
    setState(() {});
  }

  bool get _isAddable => _files.length < widget.maxMedia;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.noteTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                widget.noteTitle!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: R.font.sfpro,
                  color: R.color.textDark,
                  height: 21 / 15,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          TextField(
            focusNode: widget.focusNode,
            controller: widget.controllerNote,
            style: TextStyle(
                color: R.color.black,
                fontSize: 16,
                fontWeight: FontWeight.w400),
            keyboardType: TextInputType.multiline,
            maxLength: widget.maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            decoration: InputDecoration(
              hintText: R.string.nhap_ghi_chu_cua_ban.tr(),
              counterText: '',
              contentPadding: EdgeInsets.only(bottom: 8),
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
              ),
              suffixIcon: GestureDetector(
                onTap: _isAddable
                    ? () {
                        _showActionSheet(context);
                      }
                    : null,
                child: Image.asset(
                  R.drawable.ic_pick_photo,
                  width: 24,
                  height: 24,
                  color: _isAddable
                      ? R.color.greenGradientBottom
                      : R.color.color0xffBFC6C6,
                ),
              ),
              suffixIconConstraints: BoxConstraints(
                maxHeight: 24,
                maxWidth: 24,
              ),
            ),
            maxLines: 10,
            minLines: 1,
            onChanged: (value) {
              _currentLength = value.length;
              setState(() {});
            },
          ),
          Container(height: 1, color: R.color.color0xffE5E5E5),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '$_currentLength/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: R.font.sfpro,
                  color: R.color.primaryGreyColor,
                ),
              ),
            ),
          ),
          if (_files.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _files.map((imageWithSource) {
                final index = _files.indexOf(imageWithSource);
                final file = imageWithSource.file;
                final isFromCamera = imageWithSource.isFromCamera;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Pass actual file objects to PhotoView
                        List<dynamic> photoViewFiles =
                            _files.map((img) => img.file).toList();
                        Navigator.pushNamed(context, '/photo_view', arguments: {
                          'files': photoViewFiles,
                          'index': index
                        });
                      },
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            Positioned.fill(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                width: 56,
                                height: 56,
                                clipBehavior: Clip.hardEdge,
                                child: file is XFile
                                    ? Image.file(
                                        File(file.path),
                                        fit: BoxFit.cover,
                                      )
                                    : file is File
                                        ? Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                          )
                                        : NetWorkImageWidget(
                                            imageUrl: file.url,
                                            fit: BoxFit.cover),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Only allow removing if NOT from camera
                                if (isFromCamera) return;
                                setState(() {
                                  if (file is XFile || file is File) {
                                    _files.removeAt(index);
                                  } else {
                                    _removeIDs.add(file.id);
                                    _files.removeAt(index);
                                  }
                                });
                              },
                              child: isFromCamera
                                  ? Image.asset(R.drawable.ic_camera_white,
                                      width: 24, height: 24)
                                  : Image.asset(R.drawable.ic_close_circle_red,
                                      width: 24, height: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          // Show subText at section level when there is at least one camera image
          if (widget.subText != null && _files.any((e) => e.isFromCamera))
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                widget.subText!,
                style: TextStyle(
                  fontSize: 10,
                  color: R.color.color0xff666666,
                ),
                textAlign: TextAlign.start,
              ),
            ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_isAddable) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
                  SizedBox(width: 16),
                  Text(R.string.chon_trong_thu_vien.tr(),
                      style: TextStyle(
                          color: R.color.color0xff333333, fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openGallery(context);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text(R.string.chup_anh.tr(),
                      style: TextStyle(
                          color: R.color.color0xff333333, fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openCamera(context);
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(R.string.cancel.tr(),
              style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      //Message.showToastMessage(context, R.string.max_image_select.tr());
    }
  }

  void _openCamera(BuildContext context) async {
    try {
      // Check camera permission first
      final permissionStatus = await Permission.camera.status;

      if (!permissionStatus.isGranted) {
        final newStatus = await Permission.camera.request();
        if (!newStatus.isGranted) {
          if (newStatus.isPermanentlyDenied) {
            _showPermissionDeniedDialog(context);
          } else {
            _showAlertDialog(context);
          }
          return;
        }
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        // Convert image to JPEG format (handles HEIC/HEIF from iOS)
        final convertedPath = await Utils.convertImageToJpeg(pickedFile.path);
        final convertedFile = XFile(convertedPath);
        _files.add(ImageWithSource(convertedFile, true)); // Mark as from camera
        setState(() {});
      }
    } catch (e) {
      // Handle specific camera errors
      if (e.toString().contains('camera') ||
          e.toString().contains('permission')) {
        _showAlertDialog(context);
      } else {
        // For other errors, show a generic error
        _showGenericErrorDialog(
            context, 'Không thể mở camera. Vui lòng thử lại.');
      }
    }
  }

  void _openGallery(BuildContext context) async {
    try {
      // Check storage permission for gallery access on Android
      if (Platform.isAndroid) {
      // For Android 13+ use photos, for <=12 use storage
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      Permission permissionToRequest;
      if (sdkInt >= 33) {
        permissionToRequest = Permission.photos;      // READ_MEDIA_IMAGES
      } else {
        permissionToRequest = Permission.storage;     // READ_EXTERNAL_STORAGE
      }

      final status = await permissionToRequest.status;
      if (!status.isGranted) {
        final newStatus = await permissionToRequest.request();
        if (!newStatus.isGranted) {
          _showGalleryPermissionDialog(context);
          return;
        }
      }
    }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        // Convert image to JPEG format (handles HEIC/HEIF from iOS)
        final convertedPath = await Utils.convertImageToJpeg(pickedFile.path);
        final convertedFile = XFile(convertedPath);
        _files.add(ImageWithSource(convertedFile, false)); // Mark as from gallery
        setState(() {});
      }
    } catch (e) {
      if (e.toString().contains('permission') ||
          e.toString().contains('storage')) {
        _showGalleryPermissionDialog(context);
      } else {
        _showGenericErrorDialog(
            context, 'Không thể mở thư viện ảnh. Vui lòng thử lại.');
      }
    }
  }

  void _showGalleryPermissionDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text('Mở cài đặt'),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Cần quyền truy cập thư viện'),
      content: Text(
          'Ứng dụng cần quyền truy cập thư viện ảnh để chọn ảnh. Vui lòng cấp quyền để tiếp tục.'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(R.string.allowed.tr()),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(R.string.notification.tr()),
      content: Text(R.string.ask_for_permission.tr()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text('Mở cài đặt'),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Quyền truy cập bị từ chối'),
      content: Text(
          'Quyền truy cập camera đã bị từ chối vĩnh viễn. Vui lòng vào Cài đặt để cấp quyền cho ứng dụng.'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showGenericErrorDialog(BuildContext context, String message) {
    Widget okButton = TextButton(
      child: Text('OK'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Lỗi'),
      content: Text(message),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  SectionAddNoteData getNote() {
    return SectionAddNoteData(
      note: widget.controllerNote?.text ?? '',
      files: _files.map((imageWithSource) => imageWithSource.file).toList(),
      removeIDs: _removeIDs,
    );
  }
}

class SectionAddNoteData {
  final String note;
  final List<dynamic> files;
  final List<String?> removeIDs;
  SectionAddNoteData(
      {required this.note, required this.files, required this.removeIDs});
}
