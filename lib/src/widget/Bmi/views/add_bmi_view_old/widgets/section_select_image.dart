import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/bmi/views/add_bmi_view_old/widgets/add_bmi_mixin.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/btn_add_photo.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../add_bmi_cubit.dart';

class SectionSelectImage extends StatelessWidget with AddBmiMixin {
  final AddBmiCubit cubit;
  const SectionSelectImage({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: cubit.files.length + 1,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
              onTap: () {
                if (index == cubit.files.length) {
                  showActionSheet(context);
                }
              },
              child: index == cubit.files.length
                  ? ButtonAddPhoto()
                  : GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/photo_view', arguments: {
                          'cubit.files': cubit.files,
                          'index': index
                        });
                      },
                      child: Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            Positioned.fill(
                              child: cubit.files[index] is PickedFile
                                  ? Image.file(
                                      File(cubit.files[index].path),
                                      fit: BoxFit.cover,
                                    )
                                  : NetWorkImageWidget(
                                      imageUrl: cubit.files[index].url,
                                      fit: BoxFit.cover),
                            ),
                            IconButton(
                                icon: Image.asset(R.drawable.ic_trash),
                                onPressed: () {
                                  if (cubit.files[index] is PickedFile) {
                                    cubit.files.removeAt(index);
                                  } else {
                                    cubit.removeIDs.add(cubit.files[index].id);
                                    cubit.files.removeAt(index);
                                  }
                                  cubit.infoChanged();
                                })
                          ]),
                    ));
        });
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (cubit.files.length < cubit.maxMedia) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
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
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
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
      Message.showToastMessage(context, R.string.max_image_select.tr());
    }
  }

  _openCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        cubit.files.add(pickedFile);
        cubit.infoChanged();
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        cubit.files.add(pickedFile);
        cubit.infoChanged();
      }
    } catch (_) {
      showAlertDialog(context);
    }
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
}
