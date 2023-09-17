import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:permission_handler/permission_handler.dart';

import '../make_question.dart';

class ImagePickerItem extends StatelessWidget {
  final MakeQuestionCubit cubit;
  const ImagePickerItem({Key? key, required this.cubit}) : super(key: key);
  static int maxMedia = 3;

  @override
  Widget build(BuildContext context) {
    final MakeQuestionCubit _cubit = cubit;
    return BlocBuilder<MakeQuestionCubit, MakeQuestionState>(
        builder: (context, state) {
      List<File> _mediaList = _cubit.mediaList;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.select_your_image.tr(),
            style: TextStyle(
              color: R.color.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              if (_mediaList.length < 3)
                InkWell(
                  onTap: () => showActionSheet(
                    context,
                    mediaList: _mediaList,
                    onChanged: (value) async {
                      _mediaList.add(value);
                      await _cubit.setMediaList(_mediaList);
                    },
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: [3, 4],
                      strokeWidth: 1,
                      padding: EdgeInsets.all(0),
                      radius: Radius.circular(12),
                      color: R.color.color0xffA1A3A6,
                      child: Container(
                        height: 68,
                        width: 68,
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 28,
                          color: R.color.color0xffE7E7E7,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  children: _mediaList.map((file) {
                    int index = _mediaList.indexOf(file);
                    return _mediaItem(
                      file: file,
                      onDelete: () async {
                        _mediaList.removeAt(index);
                        await _cubit.setMediaList(_mediaList);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            R.string.note_max_media.tr(),
            style: TextStyle(
              color: R.color.color0xffA1A3A6,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    });
  }

  Widget _mediaItem({
    required GestureTapCallback onDelete,
    required File file,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(right: 15),
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(
                File(file.path),
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          right: 10,
          child: InkWell(
            onTap: onDelete,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: R.color.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: R.color.color0xffA1A3A6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  showActionSheet(
    BuildContext context, {
    required List<File> mediaList,
    required Function onChanged,
  }) {
    FocusScope.of(context).unfocus();
    if (mediaList.length < maxMedia) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
                  SizedBox(width: 16),
                  Text(
                    "Chọn trong thư viện",
                    style: TextStyle(color: Color(0xff333333), fontSize: 14),
                  ),
                ],
              ),
            ),
            onPressed: () {
              _openGallery(
                context,
                onChanged: (value) => onChanged(value),
              );
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
                  Text(
                    "Chụp ảnh",
                    style: TextStyle(color: Color(0xff333333), fontSize: 14),
                  ),
                ],
              ),
            ),
            onPressed: () {
              _openCamera(
                context,
                onChanged: (value) => onChanged(value),
              );
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(R.string.cancel,
              style: TextStyle(color: Color(0xff333333), fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      Message.showToastMessage(context, R.string.max_image_select);
    }
  }

  _openGallery(BuildContext context, {required Function onChanged}) async {
    // try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1000,
        maxWidth: 1000,
      );
      if (pickedFile != null) {
        onChanged(File(pickedFile.path));
      }
    // } catch (_) {
    //   showAlertDialog(context);
    // }
  }

  showAlertDialog(BuildContext context) {
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

  _openCamera(BuildContext context, {required Function onChanged}) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile = await picker.pickImage(
          maxWidth: 1000,
          maxHeight: 1000,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        onChanged(File(pickedFile.path));
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }
}
