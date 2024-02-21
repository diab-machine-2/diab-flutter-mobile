import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class SettingScheduleGlucoseController extends StatefulWidget {
  @override
  _SettingScheduleGlucoseControllerState createState() =>
      _SettingScheduleGlucoseControllerState();
}

class _SettingScheduleGlucoseControllerState
    extends State<SettingScheduleGlucoseController> {
  List<String> icons = [
    R.drawable.ic_before_eat_selected,
    R.drawable.ic_after_eat_selected,
    R.drawable.ic_before_sleep_selected
  ];

  ScheduleGlucoseTimeModel? timeModel;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    try {
      BotToast.showLoading();
      timeModel = await UserClient().fetchScheduleGlucoseSetting();
      setState(() {});
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
                  title: Text(R.string.setup.tr(),
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
                Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                  child: Text(R.string.setup_reminder_time_and_unit.tr()),
                ),
                timeModel == null
                    ? SizedBox()
                    : Expanded(
                        child: ListView(padding: EdgeInsets.all(0), children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(R.string.thoi_gian.tr(),
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          buildItem(
                              R.string.truoc_an.tr(), R.string.minute.tr(), 0),
                          buildItem(
                              R.string.sau_an.tr(), R.string.minute.tr(), 1),
                          buildItem(R.string.before_sleep.tr(),
                              R.string.minute.tr(), 2),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(R.string.setup_reminder_time_and_unit.tr(),
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 32,
                                  child: CupertinoSlidingSegmentedControl(
                                      groupValue:
                                          timeModel!.glucoseUnit == 2 ? 0 : 1,
                                      backgroundColor:
                                          R.color.mainColor.withOpacity(0.15),
                                      children: {
                                        0: SizedBox(
                                            height: 46,
                                            child: Center(
                                                child: Text(
                                                    R.string.mmol_l.tr(),
                                                    style: TextStyle(
                                                        color: timeModel!
                                                                    .glucoseUnit ==
                                                                2
                                                            ? R.color.mainColor
                                                            : R.color
                                                                .primaryGreyColor,
                                                        fontWeight: timeModel!
                                                                    .glucoseUnit ==
                                                                2
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .w400)))),
                                        1: SizedBox(
                                            height: 46,
                                            child: Center(
                                                child: Text(R.string.mg_dl.tr(),
                                                    style: TextStyle(
                                                        color: timeModel!
                                                                    .glucoseUnit ==
                                                                1
                                                            ? R.color.mainColor
                                                            : R.color
                                                                .primaryGreyColor,
                                                        fontWeight: timeModel!
                                                                    .glucoseUnit ==
                                                                1
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .w400))))
                                      },
                                      onValueChanged: (dynamic i) {
                                        setState(() {
                                          timeModel = ScheduleGlucoseTimeModel(
                                              beforeEat: timeModel!.beforeEat,
                                              afterEat: timeModel!.afterEat,
                                              beforeSleeping:
                                                  timeModel!.beforeSleeping,
                                              glucoseUnit: i == 0 ? 2 : 1);
                                        });
                                      }),
                                )
                              ],
                            ),
                          ),
                        ]),
                      ),
                GestureDetector(
                  onTap: () async {
                    submitData();
                  },
                  child: SafeArea(
                    top: false,
                    child: Container(
                        margin: EdgeInsets.only(top: 16, bottom: 16),
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
              ]))),
    );
  }

  Widget buildItem(String title, String unit, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0, top: 16, left: 16, right: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(icons[index], width: 30, height: 30),
                SizedBox(width: 16),
                Text(title,
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                  context: context,
                  builder: (_) => CustomNumPicker(
                      callback: (number) {
                        if (index == 0) {
                          timeModel = ScheduleGlucoseTimeModel(
                              beforeEat: number,
                              afterEat: timeModel!.afterEat,
                              beforeSleeping: timeModel!.beforeSleeping,
                              glucoseUnit: timeModel!.glucoseUnit);
                        } else if (index == 1) {
                          timeModel = ScheduleGlucoseTimeModel(
                              beforeEat: timeModel!.beforeEat,
                              afterEat: number,
                              beforeSleeping: timeModel!.beforeSleeping,
                              glucoseUnit: timeModel!.glucoseUnit);
                        } else {
                          timeModel = ScheduleGlucoseTimeModel(
                              beforeEat: timeModel!.beforeEat,
                              afterEat: timeModel!.afterEat,
                              beforeSleeping: number,
                              glucoseUnit: timeModel!.glucoseUnit);
                        }

                        setState(() {});
                      },
                      title: R.string.nhap_thoi_gian.tr(),
                      max: index == 1 ? 150 : 30,
                      range: index == 1 ? 5 : 1,
                      numberDefault: index == 0
                          ? timeModel!.beforeEat
                          : index == 1
                              ? timeModel!.afterEat
                              : timeModel!.beforeSleeping,
                      unit: R.string.minute.tr()),
                );
              },
              child: Container(
                color: R.color.transparent,
                padding: EdgeInsets.all(8.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 20),
                  Column(children: [
                    Text(
                        (index == 0
                                ? timeModel!.beforeEat
                                : index == 1
                                    ? timeModel!.afterEat
                                    : timeModel!.beforeSleeping)
                            .toString(),
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w700)),
                    Container(
                        height: 1,
                        width: 120,
                        color: R.color.grayComponentBorder)
                  ]),
                  Text(unit,
                      style: TextStyle(
                          color: R.color.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400))
                ]),
              ),
            )
          ]),
    );
  }

  submitData() async {
    try {
      BotToast.showLoading();
      await UserClient().updateScheduleGlucoseSetting(timeModel!);
      await UserClient().fetchUser();
      Observable.instance
          .notifyObservers([], notifyName: "setup_schedule_change");
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
      // DartNotificationCenter.post(channel: 'setup_schedule_change');
      // DartNotificationCenter.post(channel: 'refresh_home');
      BotToast.closeAllLoading();
      Navigator.pop(context);
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
