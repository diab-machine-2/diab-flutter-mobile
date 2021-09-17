import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/patient_time_frame.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/horizontal_picker/horizontal_numberpicker.dart';
import 'package:medical/src/widget/components/horizontal_picker/horizontal_numberpicker_wrapper.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class SettingScheduleGlucoseController extends StatefulWidget {
  @override
  _SettingScheduleGlucoseControllerState createState() =>
      _SettingScheduleGlucoseControllerState();
}

class _SettingScheduleGlucoseControllerState
    extends State<SettingScheduleGlucoseController> {
  List<String> icons = [
    'assets/images/before_eat_selected.png',
    'assets/images/after_eat_selected.png',
    'assets/images/before_sleep_selected.png'
  ];

  ScheduleGlucoseTimeModel timeModel;

  @override
  void initState() {
    super.initState();
    TrackingManager.analytics
        .setCurrentScreen(screenName: 'Setting Schedule Glucose');
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
                        Color(0xFFFDC798).withOpacity(0.3),
                        Color(0xFFE6F6ED).withOpacity(0.9),
                      ],
                      begin: FractionalOffset(1, 1),
                      end: FractionalOffset(0.9, 0.5),
                      stops: [0.0, 1.0])),
              child: Column(children: [
                CustomAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text('Thiết lập',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark)),
                  leadingIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back, color: textDark),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                  child: Text(
                      'Đặt lại thời gian nhắc nhở cho mỗi khung giờ và đơn vị đo phù hợp với nhu cầu của bạn'),
                ),
                timeModel == null
                    ? SizedBox()
                    : Expanded(
                        child: ListView(padding: EdgeInsets.all(0), children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Thời gian',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          buildItem('Trước ăn', 'phút', 0),
                          buildItem('Sau ăn', 'phút', 1),
                          buildItem('Trước khi ngủ', 'phút', 2),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Đơn vị đo dường huyết',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 16),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 32,
                                  child: CupertinoSlidingSegmentedControl(
                                      groupValue:
                                          timeModel.glucoseUnit == 2 ? 0 : 1,
                                      backgroundColor:
                                          mainColor.withOpacity(0.15),
                                      children: {
                                        0: SizedBox(
                                            height: 46,
                                            child: Center(
                                                child: Text('mmol/L',
                                                    style: TextStyle(
                                                        color: timeModel
                                                                    .glucoseUnit ==
                                                                2
                                                            ? mainColor
                                                            : Color(0xff666666),
                                                        fontWeight: timeModel
                                                                    .glucoseUnit ==
                                                                2
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .w400)))),
                                        1: SizedBox(
                                            height: 46,
                                            child: Center(
                                                child: Text('mg/dL',
                                                    style: TextStyle(
                                                        color: timeModel
                                                                    .glucoseUnit ==
                                                                1
                                                            ? mainColor
                                                            : Color(0xff666666),
                                                        fontWeight: timeModel
                                                                    .glucoseUnit ==
                                                                1
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .w400))))
                                      },
                                      onValueChanged: (i) {
                                        setState(() {
                                          timeModel = ScheduleGlucoseTimeModel(
                                              beforeEat: timeModel.beforeEat,
                                              afterEat: timeModel.afterEat,
                                              beforeSleeping:
                                                  timeModel.beforeSleeping,
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
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  barrierColor: Color(0xff003F38).withOpacity(0.5),
                  context: context,
                  builder: (_) => CustomNumPicker(
                      callback: (number) {
                        if (index == 0) {
                          timeModel = ScheduleGlucoseTimeModel(
                              beforeEat: number,
                              afterEat: timeModel.afterEat,
                              beforeSleeping: timeModel.beforeSleeping,
                              glucoseUnit: timeModel.glucoseUnit);
                        } else if (index == 1) {
                          timeModel = ScheduleGlucoseTimeModel(
                              beforeEat: timeModel.beforeEat,
                              afterEat: number,
                              beforeSleeping: timeModel.beforeSleeping,
                              glucoseUnit: timeModel.glucoseUnit);
                        } else {
                          timeModel = ScheduleGlucoseTimeModel(
                              beforeEat: timeModel.beforeEat,
                              afterEat: timeModel.afterEat,
                              beforeSleeping: number,
                              glucoseUnit: timeModel.glucoseUnit);
                        }

                        setState(() {});
                      },
                      title: 'Nhập thời gian',
                      max: 60,
                      numberDefault: index == 0
                          ? timeModel.beforeEat
                          : index == 1
                              ? timeModel.afterEat
                              : timeModel.beforeSleeping,
                      unit: 'phút'),
                );
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.all(8.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 20),
                  Column(children: [
                    Text(
                        (index == 0
                                ? timeModel.beforeEat
                                : index == 1
                                    ? timeModel.afterEat
                                    : timeModel.beforeSleeping)
                            .toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w700)),
                    Container(height: 1, width: 120, color: Color(0xffDDDDDD))
                  ]),
                  Text(unit,
                      style: TextStyle(
                          color: Colors.black,
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
      await UserClient().updateScheduleGlucoseSetting(timeModel);
      await UserClient().fetchUser();
      DartNotificationCenter.post(channel: 'setup_schedule_change');
      DartNotificationCenter.post(channel: 'refresh_home');
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
