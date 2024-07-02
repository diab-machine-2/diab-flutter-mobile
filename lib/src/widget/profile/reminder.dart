import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/schedule_reminder_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class ReminderController extends StatefulWidget {
  @override
  _ReminderControllerState createState() => _ReminderControllerState();
}

class _ReminderControllerState extends State<ReminderController> with Observer  {
  List<ScheduleReminderModel>? models;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    // DartNotificationCenter.subscribe(
    //     channel: 'schedule_change',
    //     observer: this,
    //     onNotification: (_) {
    //       loadData();
    //     });
    loadData();
    firebaseSetup();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "remind", 
      screenClass: "ReminderController"
    );
    AppSettings.currentScreenName = 'remind';
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'schedule_change') {
      loadData();
    }
  }

  Future<bool> loadData() async {
    final result = await UserClient().fetchScheduleReminders();
    models = result.models;
    setState(() {});
    return true;
  }


  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    // DartNotificationCenter.unsubscribe(
    //     channel: 'schedule_change', observer: this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        R.color.color0xFFFDC798.withOpacity(0.3),
                        R.color.greenbg.withOpacity(0.9),
                      ],
                      begin: FractionalOffset(1, 1),
                      end: FractionalOffset(0.9, 0.5),
                      stops: [0.0, 1.0])),
              child: Column(children: [
                CustomAppBar(
                  backgroundColor: R.color.transparent,
                  title: Text(R.string.reminder_calendar.tr(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: R.color.textDark)),
                  leadingIcon: IconButton(
                      splashColor: R.color.transparent,
                      highlightColor: R.color.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.textDark),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                Expanded(
                    child: SafeArea(
                        top: false,
                        child: RefreshIndicator(
                          onRefresh: loadData,
                          child: models == null
                              ? Center(child: CircularProgressIndicator())
                              : ListView(
                                  padding: EdgeInsets.all(0),
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior
                                          .onDrag,
                                  children: [
                                    Column(
                                      children: [
                                        Image.asset(
                                            R.drawable.img_reminder,
                                            height: 113),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              top: 32,
                                              bottom: 32),
                                          child: Text(
                                              R.string.let_diab_remind_you.tr(),
                                              style:
                                                  TextStyle(fontSize: 16),
                                              textAlign: TextAlign.center),
                                        )
                                      ],
                                    ),
                                    ListView.separated(
                                      padding: EdgeInsets.all(0),
                                      physics:
                                          NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: models!.length,
                                      separatorBuilder:
                                          (BuildContext context,
                                              int index) {
                                        return Container(
                                            height: 1,
                                            color: R.color.color0xffE5E5E5);
                                      },
                                      itemBuilder: (BuildContext context,
                                          int index) {
                                        return buildItem(index);
                                      },
                                    )
                                  ]),
                        ))),
                SizedBox(height: 32)
              ])),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await TrackingManager.analytics.logEvent(
                name: 'cta_button_clicked',
                parameters: {
                  "screen_name": 'remind',
                  'cta_button_name': 'cta_remind_add',
                },
              );
              Navigator.pushNamed(context, NavigatorName.add_reminder,
                  arguments: {'type': 'input'});
            },
            child: Image.asset(R.drawable.ic_button_plus,
                width: 80, height: 80),
          )),
    );
  }

  Widget buildItem(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.add_reminder,
            arguments: {'type': 'update', 'id': models![index].id});
      },
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        secondaryActions: [
          IconSlideAction(
            color: R.color.color0xffFF5552,
            iconWidget:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(R.drawable.ic_trash2,
                  width: 24, height: 24),
              SizedBox(height: 4),
              Text(R.string.detele_notificaiton.tr(),
                  style: TextStyle(
                      color: R.color.white, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
            ]),
            onTap: () {
              _showDialogDelete(context, models![index]);
            },
          ),
        ],
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Container(
            color: R.color.transparent,
            padding: EdgeInsets.only(top: 16, bottom: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(models![index].name ?? "",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                CupertinoSwitch(
                  activeColor: R.color.greenGradientBottom,
                  value: models![index].isActive!,
                  onChanged: (value) async {
                    await TrackingManager.analytics.logEvent(
                      name: 'component_clicked',
                      parameters: {
                        "screen_name": 'remind',
                        'component_name': 'switcher_remind_${value ? "on" : "off"}',
                        'object_title': models![index].name ?? "",
                        'object_index': index,
                      },
                    );
                    edit(models![index]);
                  },
                )
              ]),
              models![index].content == null || models![index].content!.isEmpty
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(models![index].content!,
                          style: TextStyle(
                              color: R.color.primaryGreyColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400)),
                    ),
              SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Image.asset(R.drawable.ic_stopwatch,
                    width: 24, height: 24),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                      'Khung giờ nhắc nhở: ' + getTimeFrame(models![index]),
                      style: TextStyle(
                          color: Color(0xff666666),
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                )
              ])
            ]),
          ),
        ),
      ),
    );
  }

  String getTimeFrame(ScheduleReminderModel model) {
    List<String> names = [];
    if (model.isWakeUp == true) {
      names.add(R.string.wake_up.toLowerCase());
    }
    if (model.isBreakfast == true) {
      names.add('ăn sáng');
    }
    if (model.isLunch == true) {
      names.add('ăn trưa');
    }
    if (model.isDinner == true) {
      names.add('ăn tối');
    }
    if (model.isSleeping == true) {
      names.add('đi ngủ');
    }
    return names.join(', ');
  }

  edit(ScheduleReminderModel model) async {
    try {
      model.isActive = !(model.isActive ?? true);
      BotToast.showLoading();
      await UserClient().editScheduleReminder(model);
      loadData();
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

  delete(ScheduleReminderModel model) async {
    try {
      BotToast.showLoading();
      await UserClient().deleteScheduleReminder(model.id);
      loadData();
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

  _showDialogDelete(BuildContext context, ScheduleReminderModel model) {
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
                      Image.asset(R.drawable.ic_earse,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.mes_detele_notificaiton.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.mes_detele_notificaiton.tr(),
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
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
                                        child: Text(R.string.later.tr(),
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
                                    delete(model);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Center(
                                      child: Text(R.string.delete.tr(),
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
}
