import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../modal/exercrises/exercrise_Input_detail_model.dart';
import '../helper/show_message.dart';

class ExercisesNoteWithMedia extends StatefulWidget {
  final String? note;
  final List<dynamic> mediaUrls;
  final int maxMedia;
  final Function(String note) onChangedNote;
  final Function(List<dynamic> mediaUrls) onChangedMediaUrls;
  final Function(String fileId)? onFileRemoved;

  const ExercisesNoteWithMedia({
    Key? key,
    this.note,
    required this.mediaUrls,
    this.maxMedia = 5,
    required this.onChangedNote,
    required this.onChangedMediaUrls,
    this.onFileRemoved,
  }) : super(key: key);

  @override
  _ExercisesNoteWithMediaState createState() => _ExercisesNoteWithMediaState();
}

class _ExercisesNoteWithMediaState extends State<ExercisesNoteWithMedia> {
  List<dynamic> files = [];
  TextEditingController _controllerNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    files = List.from(widget.mediaUrls);
    if (widget.note != null) {
      _controllerNote.text = widget.note!;
    }
  }

  @override
  void didUpdateWidget(covariant ExercisesNoteWithMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaUrls != widget.mediaUrls) {
      setState(() {
        files = List.from(widget.mediaUrls);
      });
    }
    if (oldWidget.note != widget.note) {
      setState(() {
        _controllerNote.text = widget.note ?? '';
      });
    }
  }

  @override
  void dispose() {
    _controllerNote.dispose();
    super.dispose();
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  R.string.ghi_chu.tr(),
                  style: TextStyle(
                    color: R.color.color0xff111515,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                  width: double.infinity,
                  child: TextFormField(
                    // initialValue: widget.note ?? '',
                    controller: _controllerNote,
                    maxLines: 5,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    //count number character of text
                    maxLength: 250,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (value) => widget.onChangedNote(value),
                    //set only one line border at the bottom
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        right: 8,
                        top: 8,
                        bottom: 8,
                      ),
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
                        child: Image.asset(
                          files.length == 5
                              ? R.drawable.exercise_upload_images_disable
                              : R.drawable.ic_upload_images,
                          width: 24,
                          height: 24,
                        ),
                        onTap: () {
                          // Clear the text field
                          showActionSheet(context);
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              files.isEmpty
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
                                child: _buildImageWidget(files[index]),
                              ),
                              // IconButton Positioned top right corner to remove image background red
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        // Call onFileRemoved if it's a server file
                                        if (files[index] is ImagesUrlModel &&
                                            widget.onFileRemoved != null) {
                                          final file =
                                              files[index] as ImagesUrlModel;
                                          widget.onFileRemoved!(file.id ?? '');
                                        }
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

  Widget _buildImageWidget(dynamic file) {
    if (file is XFile) {
      // Local file
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(file.path),
          fit: BoxFit.cover,
        ),
      );
    } else if (file is Map<String, dynamic> && file.containsKey('url')) {
      // Server file with URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: NetWorkImageWidget(
          imageUrl: file['url'],
          height: 56,
          width: 56,
          fit: BoxFit.cover,
        ),
      );
    } else if (file is String) {
      // Simple URL string
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: NetWorkImageWidget(
          imageUrl: file,
          height: 56,
          width: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback
    return Container(
      color: R.color.primaryGreyColor.withOpacity(0.3),
      child: Icon(
        Icons.broken_image,
        color: R.color.primaryGreyColor,
      ),
    );
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (files.length < widget.maxMedia) {
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
              Navigator.pop(context);
              _openGallery(context);
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
        if (files.length < widget.maxMedia) {
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
        if (files.length < widget.maxMedia) {
          await Future.delayed(Duration.zero);
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
