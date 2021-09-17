import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/user/patient_time_frame.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/horizontal_picker/horizontal_numberpicker_wrapper.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class ScheduleActivityController extends StatefulWidget {
  @override
  _ScheduleActivityControllerState createState() =>
      _ScheduleActivityControllerState();
}

class _ScheduleActivityControllerState
    extends State<ScheduleActivityController> {
  List<PatientTimeFrameModel> model = [];
  List<PatientTimeFrameModel> tempModel = [];

  List<String> icons = [
    'assets/images/icon_activity_1.png',
    'assets/images/icon_activity_2.png',
    'assets/images/icon_activity_3.png',
    'assets/images/icon_activity_4.png',
    'assets/images/icon_activity_5.png'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Schedule Activity');
  }

  loadData() async {
    BotToast.showLoading();
    model = await UserClient().fetchPatientTimeFrame();
    tempModel = [...model];
    BotToast.closeAllLoading();
    setState(() {});
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
                  backgroundColor: R.color.transparent,
                  title: Text('Lịch sinh hoạt cá nhân',
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
                Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                  child: Text(
                      'Thiết lập lại thời gian cho phù hợp với lịch sinh hoạt cá nhân trong ngày của bạn'),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: model.length,
                    itemBuilder: (context, index) {
                      return buildItem('Thức giấc', 'sáng', index);
                    },
                  ),
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
                            child: Text('Lưu',
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
                Text(model[index].timeFrameName,
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    barrierColor: Color(0xff003F38).withOpacity(0.5),
                    context: context,
                    builder: (_) => CustomInputTimePicker(
                        title: 'Thời gian ' +
                            model[index].timeFrameName.toLowerCase(),
                        time: (model[index].time == null ||
                                model[index].time == 0)
                            ? 0
                            : (DateTime.fromMillisecondsSinceEpoch(
                                                model[index].time * 1000)
                                            .hour *
                                        60 +
                                    DateTime.fromMillisecondsSinceEpoch(
                                            model[index].time * 1000)
                                        .minute)
                                .toDouble(),
                        maxHour: 24,
                        callback: (hour, minute) {
                          setState(() {
                            final date =
                                DateTime(2020, 1, 1, hour, minute, 0, 0);
                            final data = model[index];
                            model[index] = PatientTimeFrameModel(
                                time: date.millisecondsSinceEpoch ~/ 1000,
                                timeFrameId: data.timeFrameId,
                                timeFrameName: data.timeFrameName);
                          });
                        }));
              },
              child: Container(
                color: R.color.transparent,
                padding: EdgeInsets.all(8.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(width: 20),
                  Column(children: [
                    Text(
                        model[index].time == null || model[index].time == 0
                            ? '--'
                            : convertToUTC(model[index].time, 'HH:mm'),
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 40,
                            fontWeight: FontWeight.w700)),
                    Container(height: 1, width: 120, color: Color(0xffDDDDDD))
                  ])
                ]),
              ),
            )
          ]),
    );
  }

  _showDialogSave() {
    for (int i = 0; i < model.length; i++) {
      print(model[i].time);
      print(tempModel[i].time);
      if (model[i].time != tempModel[i].time) {
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
                                                    fontWeight:
                                                        FontWeight.w600)),
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
                          icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    )
                  ])),
            );
          },
        );
        return;
      }
    }

    Navigator.pop(context);
    return;
  }

  submitData() async {
    int total = 0;
    model.forEach((element) {
      total += (element.time != 0 && element.time != null) ? 1 : 0;
    });
    if (total != model.length) {
      Message.showToastMessage(
          context, 'Bạn phải thiết lập thời gian tất cả khung giờ');
      return;
    }
    try {
      BotToast.showLoading();
      await UserClient().updatePatientTimeFrame(model);
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
