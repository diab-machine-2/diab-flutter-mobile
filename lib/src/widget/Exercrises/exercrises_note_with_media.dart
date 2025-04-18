import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helper/show_message.dart';

class ExercisesNoteWithMedia extends StatefulWidget {
  final String? note;
  final List<String> mediaUrls;
  final Function(String note) onChangedNote;
  final Function(List<XFile> mediaUrls) onChangedMediaUrls;

  const ExercisesNoteWithMedia({
    Key? key,
    this.note,
    required this.mediaUrls,
    required this.onChangedNote,
    required this.onChangedMediaUrls,
  }) : super(key: key);

  @override
  _ExercisesNoteWithMediaState createState() => _ExercisesNoteWithMediaState();
}

class _ExercisesNoteWithMediaState extends State<ExercisesNoteWithMedia> {
  final int maxMedia = 5;
  List<XFile> files = [];
  @override
  void initState() {
    super.initState();
    files = widget.mediaUrls.map((url) => XFile(url)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: R.color.color0xffDFE4E4,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  child: TextFormField(
                    initialValue: widget.note,
                    maxLines: 5,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    //count number character of text
                    maxLength: 250,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (value) {
                      widget.onChangedNote(value);
                    },
                    //set only one line border at the bottom
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                          left: 8, right: 8, top: 8, bottom: 0),
                      hintText: R.string.nhap_ghi_chu_cua_ban.tr(),
                      hintStyle: TextStyle(
                          fontSize: 16,
                          color: R.color.primaryGreyColor,
                          fontWeight: FontWeight.normal),
                      // set border bottom only
                      border: UnderlineInputBorder(
                          borderSide: BorderSide.lerp(
                              BorderSide(
                                  color: R.color.primaryGreyColor, width: 1),
                              BorderSide(
                                  color: R.color.primaryGreyColor, width: 1),
                              0.5)),
                      suffixIcon: InkWell(
                        child: Icon(Icons.image,
                            color: R.color.primaryGreyColor, size: 24),
                        onTap: () {
                          // Clear the text field
                          showActionSheet(context);
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              files.length == 0
                  ? Container()
                  : Container(
                      height: 56,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                  width: 56,
                                  height: 56,
                                  margin: EdgeInsets.only(right: 8, top: 4),
                                  child: NetWorkImageWidget(
                                    imageUrl: files[index].path,
                                    height: 56,
                                    width: 56,
                                    fit: BoxFit.cover,
                                  )),
                              // IconButton Positioned top right corner to remove image background red
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        files.removeAt(index);
                                        widget.onChangedMediaUrls(files);
                                      });
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      alignment: Alignment.center,
                                      transformAlignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: R.color.red,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Icon(
                                        Icons.close,
                                        color: R.color.white,
                                        size: 12,
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        },
                      ),
                    ),
            ]));
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (files.length < maxMedia) {
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
      Message.showToastMessage(context, R.string.max_image_select.tr());
    }
  }

  _openCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        if (files.length < maxMedia) {
          setState(() {
            files.add(pickedFile);
          });
          widget.onChangedMediaUrls(files);
        } else {
          Message.showToastMessage(context, R.string.max_image_select.tr());
        }
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        if (files.length < maxMedia) {
          setState(() {
            files.add(pickedFile);
          });
          widget.onChangedMediaUrls(files);
        } else {
          Message.showToastMessage(context, R.string.max_image_select.tr());
        }
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
