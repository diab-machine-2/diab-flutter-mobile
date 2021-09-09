import 'dart:ui';
import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/modal/user/schedule_reminder_model.dart';
import 'package:medical/repo/user/user_client.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/widget/base/base_state.dart';
import 'package:medical/widget/base/custom_appbar.dart';
import 'package:medical/widget/helper/show_message.dart';
import 'package:medical/widget/tabbar/fillter_bloodSugar_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/modal/error/error_model.dart';

class AddReminderController extends StatefulWidget {
  final String type;
  final String id;

  AddReminderController({this.type, this.id});
  @override
  _AddReminderControllerState createState() => _AddReminderControllerState();
}

class _AddReminderControllerState extends BaseState<AddReminderController> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  int selectedMinute = 0;
  int selectedHour = 0;

  int selectedTimeFrame = 0;
  String name = 'Hàng ngày';

  bool status = true;
  bool tempStatus = true;

  ScheduleReminderModel model;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    }
  }

  loadDetail() async {
    BotToast.showLoading();
    model = await UserClient().fetchScheduleReminderDetail(widget.id);
    BotToast.closeAllLoading();

    status = model.isActive;
    tempStatus = model.isActive;
    final date = DateTime.fromMillisecondsSinceEpoch(model.time * 1000);
    selectedHour = date.hour;
    selectedMinute = date.minute;
    selectedTimeFrame = model.remindType - 1;
    getTimeName();
    titleController.text = model.name ?? '';
    descriptionController.text = model.content ?? '';
    setState(() {});
  }

  getTimeName() {
    name = selectedTimeFrame == 0
        ? 'Hàng ngày'
        : selectedTimeFrame == 1
            ? 'Hàng tuần'
            : selectedTimeFrame == 2
                ? 'Hàng ngày trừ Chủ Nhật'
                : 'Mỗi 30 phút';
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
                    image: AssetImage('assets/images/background_splash.png'),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                CustomAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                      widget.type == 'update'
                          ? 'Chỉnh sửa lịch nhắc nhở'
                          : 'Thêm lịch nhắc nhở',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  leadingIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back, color: textDark),
                      onPressed: () {
                        _showDialogSave();
                      }),
                ),
                Expanded(
                  child: ListView(padding: EdgeInsets.all(16),
                      // physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Image.asset('assets/images/icon_clock.png',
                                    width: 24, height: 24),
                                SizedBox(width: 8),
                                Text('Trạng thái',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ]),
                              CupertinoSwitch(
                                activeColor: Color(0xff008479),
                                value: status,
                                onChanged: (value) {
                                  setState(() {
                                    status = value;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(children: [
                            Row(children: [
                              Image.asset('assets/images/stopwatch.png',
                                  width: 24, height: 24),
                              SizedBox(width: 8),
                              Text('Thời gian nhắc nhở',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ]),
                            GestureDetector(
                              onTap: () {
                                int hour = selectedHour;
                                int minute = selectedMinute;
                                showDialog(
                                    barrierColor:
                                        Color(0xff003F38).withOpacity(0.5),
                                    context: context,
                                    builder: (_) => GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Scaffold(
                                            backgroundColor: Colors.transparent,
                                            body: Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                'Nhập thời gian',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                            SizedBox(height: 8),
                                                            CustomTimePicker(
                                                                selectedHour:
                                                                    hour,
                                                                selectedMinute:
                                                                    minute,
                                                                callback:
                                                                    (h, m) {
                                                                  hour = h;
                                                                  minute = m;
                                                                }),
                                                            SizedBox(
                                                                height: 20),
                                                            Row(children: [
                                                              SizedBox(
                                                                  width: 16),
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Container(
                                                                      height:
                                                                          43,
                                                                      decoration: BoxDecoration(
                                                                          color: Color(
                                                                              0xffE2E4E7),
                                                                          borderRadius: BorderRadius.circular(
                                                                              21.5)),
                                                                      child: Center(
                                                                          child: Text(
                                                                              'Huỷ',
                                                                              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)))),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 16),
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    if (hour ==
                                                                            0 &&
                                                                        minute ==
                                                                            0) {
                                                                      Message.showToastMessage(
                                                                          context,
                                                                          'Bạn chưa chọn thời gian');
                                                                      return;
                                                                    }
                                                                    selectedHour =
                                                                        hour;
                                                                    selectedMinute =
                                                                        minute;
                                                                    setState(
                                                                        () {});
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: Container(
                                                                      height:
                                                                          43,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              mainColor,
                                                                          borderRadius: BorderRadius.circular(
                                                                              200),
                                                                          gradient: LinearGradient(
                                                                              begin: Alignment.topLeft,
                                                                              end: Alignment.centerRight,
                                                                              colors: [
                                                                                greenGradientTop,
                                                                                greenGradientBottom
                                                                              ])),
                                                                      child: Center(
                                                                          child: Text(
                                                                              'Đồng ý',
                                                                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)))),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 16),
                                                            ])
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ));
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 32, left: 32, bottom: 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                  selectedHour == null
                                                      ? '--'
                                                      : selectedHour.toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Viga',
                                                      fontSize: 40)),
                                              Container(
                                                  height: 1,
                                                  color: Color(0xffDDDDDD))
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text('Giờ'),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 32, left: 32, bottom: 16),
                                          child: Column(
                                            children: [
                                              Text(
                                                  selectedMinute == null
                                                      ? '--'
                                                      : selectedMinute
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: 'Viga',
                                                      fontSize: 40)),
                                              Container(
                                                  height: 1,
                                                  color: Color(0xffDDDDDD))
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text('Phút'),
                                      SizedBox(width: 32)
                                    ]),
                              ),
                            )
                          ]),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(children: [
                            GestureDetector(
                              onTap: () {
                                showTimeFrame(context);
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Image.asset(
                                            'assets/images/icon_clock.png',
                                            width: 24,
                                            height: 24),
                                        SizedBox(width: 8),
                                        Text('Lặp lại',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500))
                                      ]),
                                      Text(name,
                                          style: TextStyle(
                                            fontSize: 16,
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                      height: 1, color: Color(0xffE5E5E5)),
                                  SizedBox(height: 8),
                                ]),
                              ),
                            )
                          ]),
                        ),
                        SizedBox(height: 8),
                        Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              Row(children: [
                                Image.asset('assets/images/comment-checked.png',
                                    width: 24, height: 24),
                                SizedBox(width: 8),
                                Text('Tên nhắc nhở',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ]),
                              SizedBox(height: 16),
                              SizedBox(
                                height: 40,
                                child: CupertinoTextField(
                                    controller: titleController,
                                    decoration: BoxDecoration(),
                                    placeholder: 'Nhập tên nhắc nhở'),
                              ),
                              Container(height: 1, color: Color(0xffE5E5E5)),
                              SizedBox(height: 32),
                              Row(children: [
                                Image.asset('assets/images/note-text.png',
                                    width: 24, height: 24),
                                SizedBox(width: 8),
                                Text('Nội dung nhắc nhở',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ]),
                              SizedBox(height: 16),
                              CupertinoTextField(
                                  controller: descriptionController,
                                  decoration: BoxDecoration(),
                                  placeholder: 'Nhập nội dung nhắc nhở',
                                  maxLines: null,
                                  maxLength: 1000),
                              Container(height: 1, color: Color(0xffE5E5E5)),
                              SizedBox(height: 8),
                            ]))
                      ]),
                ),
                GestureDetector(
                  onTap: () async {
                    if (widget.type == 'input') {
                      submit();
                    } else {
                      edit();
                    }
                  },
                  child: SafeArea(
                    top: false,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 16, top: 16),
                        height: 48,
                        width: 195,
                        decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(200),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  greenGradientTop,
                                  greenGradientBottom
                                ])),
                        child: Center(
                            child: Text('Lưu',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _showDialogSave() {
    final title = titleController.text ?? '';
    final des = descriptionController.text ?? '';

    if (model != null) {
      final name = model.name ?? '';
      final content = model.content ?? '';
      if (name == title &&
          content == des &&
          selectedTimeFrame + 1 == model.remindType &&
          status == tempStatus) {
        Navigator.pop(context);
        return;
      }
    } else if (title.isEmpty &&
        des.isEmpty &&
        selectedHour == 0 &&
        selectedMinute == 0 &&
        selectedTimeFrame == 0 &&
        status == tempStatus) {
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
                      Image.asset('assets/images/backIcon.png',
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn quay lại ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Dữ liệu đang nhập sẽ không được lưu lại, bạn vẫn chắc chắn muốn thoát?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: textDark,
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
                                          color: grayBorder),
                                      child: Center(
                                        child: Text('Vẫn ở lại',
                                            style: TextStyle(
                                                color: textDark,
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
                                        color: red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              greenGradientTop,
                                              greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text('Thoát',
                                          style: TextStyle(
                                              color: Colors.white,
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
                      icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  showTimeFrame(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FillterBloodPanel(
            selectedIndex: selectedTimeFrame,
            data: [
              'Hàng ngày',
              'Hàng tuần',
              'Hàng ngày trừ Chủ Nhật',
              'Mỗi 30 phút'
            ],
            callback: (value, index) {
              setState(() {
                name = value;
                selectedTimeFrame = index;
              });
            }));
  }

  submit() async {
    final title = titleController.text ?? '';
    final des = descriptionController.text ?? '';
    if (title.isEmpty) {
      Message.showToastMessage(context, 'Bạn chưa nhập tên nhắc nhở');
      return;
    }

    if (selectedHour == 0 && selectedMinute == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian nhắc nhở');
      return;
    }

    try {
      BotToast.showLoading();
      await UserClient().inputScheduleReminder(
          title,
          selectedTimeFrame + 1,
          DateTime(DateTime.now().year, 1, 1, selectedHour, selectedMinute)
                  .millisecondsSinceEpoch ~/
              1000,
          des,
          status);
      DartNotificationCenter.post(channel: 'schedule_change');
      Navigator.pop(context);
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

  edit() async {
    final title = titleController.text ?? '';
    final des = descriptionController.text ?? '';
    if (title.isEmpty) {
      Message.showToastMessage(context, 'Bạn chưa nhập tên nhắc nhở');
      return;
    }

    if (selectedHour == 0 && selectedMinute == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian nhắc nhở');
      return;
    }
    try {
      BotToast.showLoading();
      await UserClient().editScheduleReminder(
          widget.id,
          title,
          selectedTimeFrame + 1,
          DateTime(DateTime.now().year, 1, 1, selectedHour, selectedMinute)
                  .millisecondsSinceEpoch ~/
              1000,
          des,
          status);
      DartNotificationCenter.post(channel: 'schedule_change');
      Navigator.pop(context);
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
}
