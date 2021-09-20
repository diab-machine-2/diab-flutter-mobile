import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/main.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/HbA1C/widget/CalendarPicker/custom_date_picker.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';

class AddHBA1CController extends StatefulWidget {
  final String type;
  final String id;

  AddHBA1CController({this.type, this.id});
  @override
  _AddHBA1CControllerState createState() => _AddHBA1CControllerState();
}

class _AddHBA1CControllerState extends BaseState<AddHBA1CController> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  DateTime time = DateTime.now();
  int maxMedia = 5;
  List<dynamic> files = []; //PickedFile
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime today = DateTime.now();
  bool btnAction = true;

  InputHbA1CModel model;
  List<String> removeIDs = [];

  ShortGuiModel des;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    }
    loadDescription();

    TrackingManager.analytics.setCurrentScreen(screenName: 'HbA1C Input');
  }

  void dispose() {
    _controller.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  loadDetail() async {
    BotToast.showLoading();
    model = await HbA1CClient().fetchDetail(widget.id);
    BotToast.closeAllLoading();
    _controller.text = model.hbA1C.round() == model.hbA1C
        ? model.hbA1C.round().toString()
        : model.hbA1C.toString();
    _controllerNote.text = model.description;
    time = DateTime.fromMillisecondsSinceEpoch(model.date * 1000);
    files.addAll(model.images);
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(5);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          _showDialogSave();
          return false;
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                CustomAppBar(
                  backgroundColor: R.color.transparent,
                  title: Text(
                      widget.type == 'update'
                          ? 'Cập nhật chỉ số HbA1C'
                          : 'Nhập chỉ số HbA1C',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: R.color.textDark)),
                  leadingIcon: IconButton(
                      splashColor: R.color.transparent,
                      highlightColor: R.color.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.textDark),
                      onPressed: () {
                        _showDialogSave();
                      }),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isClicked = !isClicked;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: isClicked
                            ? Image.asset(
                                R.drawable.help_circle_active,
                                width: 24,
                                height: 24)
                            : Image.asset(R.drawable.help_circle,
                                width: 24, height: 24),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.all(0),
                      // physics: NeverScrollableScrollPhysics(),

                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, left: 16, right: 16),
                            child: isClicked
                                ? Description(
                                    input: true,
                                    data: des,
                                    titleDetail:
                                        'Chỉ số HbA1C đối với bệnh tiểu đường')
                                : SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 100,
                                            child: TextField(
                                                controller: _controller,
                                                maxLength: 4,
                                                textAlign: TextAlign.center,
                                                inputFormatters: [],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                style: TextStyle(
                                                    color: R.color.black,
                                                    fontSize: 34,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                decoration: InputDecoration(
                                                    counterText: '',
                                                    hintText: '0,0',
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 8),
                                                    border: InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color:
                                                            R.color.captionColorGray,
                                                        fontSize: 34,
                                                        fontWeight:
                                                            FontWeight.w500))),
                                          ),
                                          Text('%')
                                        ]),
                                  ),
                                  Center(
                                      child: Container(
                                          height: 1,
                                          width: 74,
                                          color: R.color.color0xffE5E5E5)),
                                  SizedBox(height: 8),
                                ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor:
                                        R.color.color0xff003F38.withOpacity(0.5),
                                    context: context,
                                    builder: (_) => DateMultiPicker(
                                        initDate: time,
                                        callback: (value) {
                                          setState(() {
                                            time = value;
                                          });
                                        }),
                                  );
                                },
                                child: Container(
                                  color: R.color.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                              R.drawable.icon_calendar,
                                              width: 24,
                                              height: 24),
                                          SizedBox(width: 8),
                                          Row(
                                            children: [
                                              Text(
                                                  getStringToday(
                                                          time.millisecondsSinceEpoch ~/
                                                              1000) +
                                                      (getStringToday(
                                                                  time.millisecondsSinceEpoch ~/
                                                                      1000)
                                                              .isEmpty
                                                          ? ''
                                                          : ', ') +
                                                      convertToUTC(
                                                          time.millisecondsSinceEpoch ~/
                                                              1000,
                                                          'dd/MM/yyyy'),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ],
                                          )
                                          // : Text(
                                          //     convertToUTC(widget.model.date,
                                          //         'dd/MM/yyyy'),
                                          //     style: TextStyle(
                                          //         fontSize: 16,
                                          //         fontWeight:
                                          //             FontWeight.w400)),
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1, color: R.color.color0xffE5E5E5),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.note_text,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text('Ghi chú',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600))
                                  ]),
                                  SizedBox(height: 24),
                                  TextField(
                                      controller: _controllerNote,
                                      maxLines: 3,
                                      keyboardType: TextInputType.multiline,
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          hintText: 'Nhập ghi chú của bạn',
                                          contentPadding:
                                              EdgeInsets.only(bottom: 8),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: R.color.primaryGreyColor))),
                                  Container(
                                      height: 1, color: R.color.color0xffE5E5E5),
                                  SizedBox(height: 16),
                                  GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: files.length + 1,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              if (index == files.length) {
                                                showActionSheet(context);
                                              }
                                            },
                                            child: index == files.length
                                                ? Container(
                                                    child: Image.asset(
                                                        R.drawable.icon_add_photo))
                                                : Stack(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topEnd,
                                                    children: [
                                                        Positioned.fill(
                                                          child: files[index]
                                                                  is PickedFile
                                                              ? Image.file(
                                                                  File(files[
                                                                          index]
                                                                      .path),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.network(
                                                                  files[index]
                                                                      .url,
                                                                  fit: BoxFit
                                                                      .cover),
                                                        ),
                                                        IconButton(
                                                            icon: Image.asset(
                                                                R.drawable.icon_trash),
                                                            onPressed: () {
                                                              setState(() {
                                                                if (files[index]
                                                                    is PickedFile) {
                                                                  files.removeAt(
                                                                      index);
                                                                } else {
                                                                  removeIDs.add(
                                                                      files[index]
                                                                          .id);
                                                                  files.removeAt(
                                                                      index);
                                                                }
                                                              });
                                                            })
                                                      ]));
                                      })
                                ]),
                          ),
                        ),
                      ]),
                ),
                widget.type == 'input'
                    ? GestureDetector(
                        onTap: () async {
                          _submitData();
                        },
                        child: SafeArea(
                          top: false,
                          child: Container(
                              margin: EdgeInsets.only(bottom: 16, top: 16),
                              height: 48,
                              width: 195,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(200),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        R.color.greenGradientTop,
                                        R.color.greenGradientBottom
                                      ])),
                              child: Center(
                                  child: Text('Lưu',
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)))),
                        ),
                      )
                    : SafeArea(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showDialogDelete(context);
                                    },
                                    child: Container(
                                        height: 48,
                                        width: 164,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            border: Border.all(
                                                color: R.color.red, width: 2)),
                                        child: Center(
                                          child: Text('Xoá dữ liệu',
                                              style: TextStyle(
                                                  color: R.color.red,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      editData();
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          color: R.color.mainColor,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                R.color.greenGradientTop,
                                                R.color.greenGradientBottom
                                              ])),
                                      child: Center(
                                        child: Text('Lưu',
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.earseIcon,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn xoá dữ liệu?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Các thống kê sẽ thay đổi khi dữ liệu bị xoá, bạn vẫn chắc chắn muốn xoá?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Quay lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    deleteData();
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Center(
                                      child: Text('Xoá',
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  _showDialogSave() {
    final note = _controllerNote.text ?? '';
    final numberInput = _controller.text ?? '';
    if (model != null) {
      final des = model.description ?? '';
      final parseTime = DateTime.fromMillisecondsSinceEpoch(model.date * 1000);
      if (note == des &&
          double.parse(numberInput) == model.hbA1C &&
          parseTime.millisecondsSinceEpoch == time.millisecondsSinceEpoch &&
          removeIDs.length == 0 &&
          files.length == model.images.length) {
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty && numberInput.isEmpty && files.length == 0) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_back_icon,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn quay lại ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Dữ liệu đang nhập sẽ không được lưu lại, bạn vẫn chắc chắn muốn thoát?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                      SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Vẫn ở lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ))),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: R.color.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text('Thoát',
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                            ),
                          ])
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  deleteData() async {
    try {
      BotToast.showLoading();
      final result = await HbA1CClient().deleteIndexHbA1C(model.id);
      if (result == true) {
        Message.showToastMessage(context, 'Xoá thành công');
        DartNotificationCenter.post(channel: 'hba1c_change_data');
        Navigator.pop(context);
      }
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  editData() async {
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text ?? '';
    String numberInput = _controller.text ?? '';
    numberInput = numberInput.split(',').join('.');

    if (numberInput == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập chỉ số HbA1C');
      return;
    }
    if (double.parse(numberInput) > 30) {
      Message.showToastMessage(context,
          'Chúng tôi xin lỗi, số liệu mà bạn nhập không trong phạm vi cho phép. Giá trị kỳ vọng nằm trong ngưỡng 1 - 30');
      return;
    }
    if (time == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian');
      return;
    }
    // if (note == '') {
    //   Message.showToastMessage(context, 'Bạn chưa nhập ghi chú');
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final result = await HbA1CClient().putIndexHbA1C(
          model.id,
          (time.millisecondsSinceEpoch ~/ 1000).toInt(),
          numberInput,
          note,
          removeIDs,
          paths);
      if (result == true) {
        Message.showToastMessage(context, 'Lưu thành công');
        DartNotificationCenter.post(channel: 'hba1c_change_data');
        Navigator.pop(context);
      }

      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  _submitData() async {
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text ?? '';
    String numberInput = _controller.text ?? '';
    numberInput = numberInput.split(',').join('.');

    if (numberInput.isEmpty) {
      Message.showToastMessage(context, 'Bạn chưa nhập chỉ số HbA1C');
      return;
    }
    if (double.parse(numberInput) > 30) {
      Message.showToastMessage(context,
          'Chúng tôi xin lỗi, số liệu mà bạn nhập không trong phạm vi cho phép. Giá trị kỳ vọng nằm trong ngưỡng 1 - 30');
      return;
    }
    if (time == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian');
      return;
    }
    // if (note == '') {
    //   Message.showToastMessage(context, 'Bạn chưa nhập ghi chú');
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await HbA1CClient().postIndexHbA1C(
          (time.millisecondsSinceEpoch ~/ 1000).toInt(),
          numberInput,
          note,
          paths);
      if (result == true) {
        DartNotificationCenter.post(channel: 'hba1c_change_data');
        Navigator.pop(context);
      }

      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
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
                  Image.asset(R.drawable.icon_photo,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text("Chọn trong thư viện",
                      style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
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
                  Image.asset(R.drawable.icon_camera_black,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text("Chụp ảnh",
                      style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
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
          child: Text("Huỷ",
              style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      //Message.showToastMessage(context, 'Chỉ đuợc chọn tối đa 5 ảnh');
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
        files.add(pickedFile);

        setState(() {});
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
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Huỷ"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Cấp quyền"),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Thông báo"),
      content: Text("Bạn cần cấp quyền truy cập để sử dụng tính năng này"),
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

typedef TimeCallback = Function(DateTime);

class DateMultiPicker extends StatefulWidget {
  final DateTime initDate;
  final TimeCallback callback;
  DateMultiPicker({this.initDate, this.callback});
  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Chọn ngày',
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                                icon:
                                    Icon(Icons.close, color: R.color.color0xffBEC0C8),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ]),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.initDate == null
                            ? DateTime.now()
                            : widget.initDate,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (DateTime datetime) {
                          print(datetime);
                          // setState(() {
                          selectedDate = datetime;
                          // });
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.grayBorder,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.callback(selectedDate);
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text('Đồng ý',
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                    ]),
                    SizedBox(height: 16)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);

  return 'Tháng ${date.month}, ${date.year}';
}
