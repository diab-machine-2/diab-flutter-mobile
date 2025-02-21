import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class SectionAddSymptom extends StatefulWidget {
  const SectionAddSymptom({
    super.key,
    this.focusNode,
    this.controllerNote,
    this.maxMedia = 5,
    this.initialFiles,
    this.maxLength = 250,
    this.isDisplayRemove = true,
    this.readOnly = false,
    this.isDisplayTextField = true,
  });

  final FocusNode? focusNode;
  final TextEditingController? controllerNote;
  final int maxMedia;
  final int maxLength;
  final List<dynamic>? initialFiles;
  final bool isDisplayRemove;
  final bool readOnly;
  final bool isDisplayTextField;

  @override
  State<SectionAddSymptom> createState() => SectionAddSymptomState();
}

class SectionAddSymptomState extends State<SectionAddSymptom> {
  List<dynamic> _files = [];
  List<String> _fileNetworkName = [];
  List<String?> _removeIDs = [];
  int _currentLength = 0;
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _files.addAll(widget.initialFiles ?? []);
    _fileNetworkName
        .addAll(widget.initialFiles?.whereType<String>().toList() ?? []);

    _currentLength = widget.controllerNote?.text.length ?? 0;
  }

  void updateFilesAndNote(List<dynamic> files, String note) {
    _files.clear();
    _files.addAll(files);
    widget.controllerNote?.text = note;
    setState(() {});
  }

  bool get _isAddable => _files.length < widget.maxMedia;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [Utils.getBoxShadowDropCard()],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.notice_symptom.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
            ],
          ),
          GapH(12),
          if (widget.readOnly)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: R.color.color0xffF7F8F8,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.controllerNote?.text ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: R.color.color0xff111515,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GapH(16),
                  Row(
                    children: [
                      _buildImageList(),
                    ],
                  ),
                ],
              ),
            ),
          if (widget.isDisplayTextField && !widget.readOnly) GapH(12),
          if (widget.isDisplayTextField && !widget.readOnly)
            TextField(
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                // Update counter when done button is pressed
                setState(() {});
                FocusScope.of(context).unfocus();
              },
              readOnly: widget.readOnly,
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
                suffixIcon: Visibility(
                  visible: widget.isDisplayRemove,
                  child: GestureDetector(
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
          if (widget.isDisplayTextField && !widget.readOnly)
            Container(height: 1, color: R.color.color0xffE5E5E5),
          if (widget.isDisplayTextField && !widget.readOnly)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '$_currentLength/${widget.maxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: R.color.primaryGreyColor,
                  ),
                ),
              ),
            ),
          if (widget.isDisplayTextField && !widget.readOnly) _buildImageList(),
        ],
      ),
    );
  }

  Widget _buildImageList() {
    if (_files.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _files.map((e) {
            final index = _files.indexOf(e);
            return GestureDetector(
              onTap: () {
                _showFullscreenImage(context, index);
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
                        child: _files[index] is PickedFile
                            ? Image.file(
                                File(_files[index].path),
                                fit: BoxFit.cover,
                              )
                            : NetWorkImageWidget(
                                imageUrl:
                                    '${Utils.getHostDocosanUrl()}${_files[index]}',
                                fit: BoxFit.cover),
                      ),
                    ),
                    Visibility(
                      visible: widget.isDisplayRemove,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_files[index] is PickedFile) {
                              _files.removeAt(index);
                              _fileNetworkName.removeAt(index);
                            } else {
                              _removeIDs.add(_files[index]);
                              _files.removeAt(index);
                              _fileNetworkName.removeAt(index);
                            }
                          });
                        },
                        child: Image.asset(R.drawable.ic_close_circle_red,
                            width: 24, height: 24),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showFullscreenImage(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _files[index] is PickedFile
                ? Image.file(
                    File(_files[index].path),
                    fit: BoxFit.contain,
                  )
                : NetWorkImageWidget(
                    imageUrl: '${Utils.getHostDocosanUrl()}${_files[index]}',
                    fit: BoxFit.contain),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
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
              Navigator.of(context, rootNavigator: true).pop();
              _openGallery(context);
              // Navigator.pop(context);
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
              Navigator.of(context, rootNavigator: true).pop();
              _openCamera(context);
              // Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(R.string.cancel.tr(),
              style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
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
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        print('[SYMPTOM] ${pickedFile.path}');
        final filePath = pickedFile.path;
        final fileName = filePath.split('/').last;
        final bytes = await pickedFile.readAsBytes();

        try {
          final imagePath =
              await _cubit.uploadSymptomImage(fileName: fileName, bytes: bytes);
          if (imagePath != null) {
            _fileNetworkName.add(imagePath);
            _files.add(pickedFile);
            setState(() {});
          }
        } catch (apiError) {
          // Handle API upload error specifically
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to upload image. Please try again.')),
            );
          }
        }
      }
    } catch (_) {
      _showAlertDialog(context);
    }
  }

  void _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);

      if (pickedFile != null) {
        print('[SYMPTOM] ${pickedFile.path}');
        final filePath = pickedFile.path;
        final fileName = filePath.split('/').last;
        final bytes = await pickedFile.readAsBytes();

        try {
          final imagePath =
              await _cubit.uploadSymptomImage(fileName: fileName, bytes: bytes);
          if (imagePath != null) {
            _fileNetworkName.add(imagePath);
            _files.add(pickedFile);
            setState(() {});
          }
        } catch (apiError) {
          // Handle API upload error specifically
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to upload image. Please try again.')),
            );
          }
        }
      }
    } catch (permissionError) {
      // Handle permission error
      if (mounted) {
        _showAlertDialog(context);
      }
    }
  }

  void _showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );
    Widget continueButton = TextButton(
      child: Text(R.string.allowed.tr()),
      onPressed: () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          openAppSettings();
        }
      },
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(R.string.notification.tr()),
          content: Text(R.string.ask_for_permission.tr()),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }

  SectionAddSymptomData getNote() {
    return SectionAddSymptomData(
      note: widget.controllerNote?.text ?? '',
      files: _files,
      removeIDs: _removeIDs,
      fileNetworkName: _fileNetworkName,
    );
  }
}

class SectionAddSymptomData {
  final String note;
  final List<dynamic> files;
  final List<String?> removeIDs;
  final List<String> fileNetworkName;
  SectionAddSymptomData(
      {required this.note,
      required this.files,
      required this.removeIDs,
      required this.fileNetworkName});
}
