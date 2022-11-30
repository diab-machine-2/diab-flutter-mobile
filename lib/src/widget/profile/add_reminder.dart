import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/schedule_reminder_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import 'popup_reminder.dart';

class AddReminderController extends StatefulWidget {
  final String? type;
  final String? id;

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
  String name = R.string.every_day.tr();

  List<String> timeFrame = [
    'Thức giấc',
    'Ăn sáng',
    'Ăn trưa',
    'Ăn tối',
    'Đi ngủ'
  ];
  ScheduleReminderModel model = ScheduleReminderModel();
  ScheduleReminderModel tempModel = ScheduleReminderModel();

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    }
    TrackingManager.analytics.setCurrentScreen(screenName: "Reminder");
  }

  loadDetail() async {
    BotToast.showLoading();
    final data = await UserClient().fetchScheduleReminderDetail(widget.id);
    BotToast.closeAllLoading();
    model = data;
    tempModel = data;

    getName();
    titleController.text = model.name ?? '';
    descriptionController.text = model.content ?? '';
    setState(() {});
  }

  loadTimeFrame() async {
    BotToast.showLoading();
    model = await UserClient().fetchScheduleReminderDetail(widget.id);
    BotToast.closeAllLoading();
    setState(() {});
  }

  String getName() {
    String name = '';
    if (model.remindType == 1) {
      name = R.string.every_day_except_sunday.tr();
    } else {
      List<String> weeks = [];
      model.days?.forEach((element) {
        weeks.add(element == 7 ? 'CN' : 'T${(element + 1)}');
      });
      name = weeks.join(', ');
    }

    return name;
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
                          ? R.string.edit_reminder_calendar.tr()
                          : R.string.add_reminder_calendar.tr(),
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
                ),
                Expanded(
                  child: ListView(padding: EdgeInsets.all(16),
                      // physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Image.asset(R.drawable.ic_clock,
                                    width: 24, height: 24),
                                SizedBox(width: 8),
                                Text(R.string.status.tr(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ]),
                              CupertinoSwitch(
                                activeColor: R.color.greenGradientBottom,
                                value: model.isActive == true,
                                onChanged: (value) {
                                  setState(() {
                                    model.isActive = value;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(children: [
                            Row(children: [
                              Image.asset(R.drawable.ic_stopwatch,
                                  width: 24, height: 24),
                              SizedBox(width: 8),
                              Text(R.string.time_reminder.tr(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500))
                            ]),
                            SizedBox(height: 12),
                            ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                itemCount: timeFrame.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(height: 12);
                                },
                                itemBuilder: (BuildContext context, int index) {
                                  bool checked = false;
                                  if (index == 0) {
                                    checked = model.isWakeUp == true;
                                  }
                                  if (index == 1) {
                                    checked = model.isBreakfast == true;
                                  }
                                  if (index == 2) {
                                    checked = model.isLunch == true;
                                  }
                                  if (index == 3) {
                                    checked = model.isDinner == true;
                                  }
                                  if (index == 4) {
                                    checked = model.isSleeping == true;
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      if (index == 0) {
                                        model.isWakeUp = !(model.isWakeUp ?? true);
                                      }
                                      if (index == 1) {
                                        model.isBreakfast = !(model.isBreakfast ?? true);
                                      }
                                      if (index == 2) {
                                        model.isLunch = !(model.isLunch ?? true);
                                      }
                                      if (index == 3) {
                                        model.isDinner = !(model.isDinner ?? true);
                                      }
                                      if (index == 4) {
                                        model.isSleeping = !(model.isSleeping ?? true);
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(timeFrame[index],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                            Image.asset(
                                                checked
                                                    ? R.drawable.ic_checkbox_green
                                                    : R.drawable.ic_checkbox,
                                                width: 24,
                                                height: 24)
                                          ]),
                                    ),
                                  );
                                })
                          ]),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: R.color.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(children: [
                            GestureDetector(
                              onTap: () {
                                showTimeFrame(context);
                              },
                              child: Container(
                                color: R.color.transparent,
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Image.asset(
                                            R.drawable.ic_clock,
                                            width: 24,
                                            height: 24),
                                        SizedBox(width: 8),
                                        Text(R.string.repeat.tr(),
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
                                      height: 1, color: R.color.color0xffE5E5E5),
                                  SizedBox(height: 8),
                                ]),
                              ),
                            )
                          ]),
                        ),
                        SizedBox(height: 8),
                        Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              Row(children: [
                                Image.asset(R.drawable.ic_comment_checked,
                                    width: 24, height: 24),
                                SizedBox(width: 8),
                                Text(R.string.reminder_name.tr(),
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
                                    placeholder: R.string.enter_reminder_name.tr()),
                              ),
                              Container(height: 1, color: R.color.color0xffE5E5E5),
                              SizedBox(height: 32),
                              Row(children: [
                                Image.asset(R.drawable.ic_note_text,
                                    width: 24, height: 24),
                                SizedBox(width: 8),
                                Text(R.string.content_reminder.tr(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ]),
                              SizedBox(height: 16),
                              CupertinoTextField(
                                  controller: descriptionController,
                                  decoration: BoxDecoration(),
                                  placeholder: R.string.enter_content_reminder.tr(),
                                  maxLines: null,
                                  maxLength: 1000),
                              Container(height: 1, color: R.color.color0xffE5E5E5),
                              SizedBox(height: 8),
                            ]))
                      ]),
                ),
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    if (model.isWakeUp != true &&
                        model.isBreakfast  != true &&
                        model.isLunch  != true &&
                        model.isDinner != true  &&
                        model.isSleeping != true ) {
                      Message.showToastMessage(
                          context, 'Bạn chưa chọn khung giờ nhắc nhở');
                      return;
                    }
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
                            child: Text(R.string.save.tr(),
                                style: TextStyle(
                                    color: R.color.white,
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
    final title = titleController.text;
    final des = descriptionController.text;

    if (model.isActive == tempModel.isActive &&
        model.content == des &&
        model.name == title &&
        model.days == tempModel.days &&
        model.isBreakfast == tempModel.isBreakfast &&
        model.isDinner == tempModel.isDinner &&
        model.isLunch == tempModel.isLunch &&
        model.isSleeping == tempModel.isSleeping &&
        model.isWakeUp == tempModel.isWakeUp) {
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
                        child: Text(R.string.ban_muon_quay_lai.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            R.string.confirm_to_back.tr(),
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
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
                                        child: Text(R.string.van_o_lai.tr(),
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
                                      child: Text(R.string.exit.tr(),
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

  showTimeFrame(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => PopupReminder(
            selectedIndex: (model.remindType ?? 1) - 1,
            selectedItems: model.days ?? [],
            callback: (index, items) {
              setState(() {
                model.remindType = index + 1;
                model.days = items;
              });
            }));
  }

  submit() async {
    final title = titleController.text;
    final des = descriptionController.text;
    if (title.isEmpty) {
      Message.showToastMessage(context, R.string.mes_reminder_name_empty.tr());
      return;
    }
    model.name = title;
    model.content = des;
    try {
      BotToast.showLoading();
      await UserClient().inputScheduleReminder(model);
      Observable.instance.notifyObservers([], notifyName : "schedule_change");
      // DartNotificationCenter.post(channel: 'schedule_change');
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
    final title = titleController.text;
    if (title.isEmpty) {
      Message.showToastMessage(context, R.string.mes_reminder_name_empty.tr());
      return;
    }

    try {
      BotToast.showLoading();
      await UserClient().editScheduleReminder(model);
      Observable.instance.notifyObservers([], notifyName : "schedule_change");
      // DartNotificationCenter.post(channel: 'schedule_change');
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
