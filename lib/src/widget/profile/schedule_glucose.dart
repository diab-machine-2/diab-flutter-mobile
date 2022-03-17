import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/schedule_glucose_model.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import '../../app_setting/app_setting.dart';
import '../../widgets/button_widget.dart';
import '../blood_sugar_survey_screens/blood_sugar_start_survey/blood_sugar_start_survey.dart';

class ScheduleGlucoseController extends StatefulWidget {
  const ScheduleGlucoseController();
  @override
  _ScheduleGlucoseControllerState createState() => _ScheduleGlucoseControllerState();
}

class _ScheduleGlucoseControllerState extends State<ScheduleGlucoseController> with Observer {
  int selected = 0;
  ScheduleModel? scheduleDay;
  ScheduleGlucoseModel? model;
  ScheduleGlucoseModel? tempModel;
  ScheduleGlucoseTimeModel? timeModel;

  List<bool> hasData = [false, false, false, false, false, false, false];
  var userInfo = AppSettings.userInfo!;

  @override
  void initState() {
    super.initState();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Schedule Glucose');
    final date = DateTime.now();

    selected = date.weekday - 1;

    loadSchedule();
    loadScheduleSetup();
    Observable.instance.addObserver(this);
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'setup_schedule_change') {
      loadScheduleSetup();
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  loadSchedule() async {
    BotToast.showLoading();
    model = await UserClient().fetchScheduleGlucose();
    tempModel = model;
    getScheduleDay();
    checkData();
    BotToast.closeAllLoading();
    setState(() {});
  }

  loadScheduleSetup() async {
    try {
      timeModel = await UserClient().fetchScheduleGlucoseSetting();
      setState(() {});
    } catch (e, _) {
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  getScheduleDay() {
    if (selected == 0) {
      scheduleDay = model!.monday;
    } else if (selected == 1) {
      scheduleDay = model!.tuesday;
    } else if (selected == 2) {
      scheduleDay = model!.wednesday;
    } else if (selected == 3) {
      scheduleDay = model!.thursday;
    } else if (selected == 4) {
      scheduleDay = model!.friday;
    } else if (selected == 5) {
      scheduleDay = model!.saturday;
    } else if (selected == 6) {
      scheduleDay = model!.sunday;
    }
  }

  checkData() {
    hasData[0] = model?.monday?.hasData == true;
    hasData[1] = model?.tuesday?.hasData == true;
    hasData[2] = model?.wednesday?.hasData == true;
    hasData[3] = model?.thursday?.hasData == true;
    hasData[4] = model?.friday?.hasData == true;
    hasData[5] = model?.saturday?.hasData == true;
    hasData[6] = model?.sunday?.hasData == true;
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
            body: Stack(alignment: AlignmentDirectional.topEnd, children: [
          ListView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 76),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Container(
                  color: R.color.color0xffF4DBBD,
                  child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
                    SafeArea(
                      bottom: false,
                      child: Image.asset(R.drawable.img_schedule_glucose, height: 220),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: '${R.string.default_time_to_measure_blood_sugar.tr()} ',
                                          style: TextStyle(color: R.color.primaryGreyColor),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: timeModel == null
                                                    ? R.string.suggest_time_to_measure_blood_sugar.tr()
                                                    : R.string.time_to_measure_blood_sugar.tr(args: [
                                                        '${timeModel!.beforeEat}',
                                                        '${timeModel!.afterEat}',
                                                        '${timeModel!.beforeSleeping}'
                                                      ]),
                                                style: TextStyle(
                                                    color: R.color.black, fontWeight: FontWeight.bold, fontSize: 14))
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 150)
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildButton(
                                        title: R.string.setup.tr(),
                                        icon: R.drawable.ic_alarm,
                                        onTap: () {
                                          Navigator.pushNamed(context, NavigatorName.setting_schedule_glucose);
                                        }),
                                    const SizedBox(width: 16),
                                    _buildButton(
                                      title: R.string.testing_schedule_suggest.tr(),
                                      icon: R.drawable.ic_blood_sugar_testing_suggest,
                                      onTap: doSurvey,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
                if (model == null)
                  const SizedBox()
                else
                  Container(
                      height: 56,
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selected = index;
                                getScheduleDay();
                                checkData();
                              });
                            },
                            child: Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                    color: !hasData[index] ? R.color.transparent : R.color.main_6,
                                    border: Border.all(
                                        color: selected == index
                                            ? (!hasData[index] ? R.color.black : R.color.mainColor)
                                            : (!hasData[index] ? R.color.grayBorder : R.color.main_6)),
                                    borderRadius: BorderRadius.circular(18)),
                                child: Center(
                                    child: Text(
                                        index == 6
                                            ? R.string.sunday.tr()
                                            : R.string.day_in_week.tr(args: ['${index + 2}']),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: selected == index
                                                ? (!hasData[index] ? R.color.black : R.color.mainColor)
                                                : (!hasData[index] ? R.color.primaryGreyColor : R.color.mainColor))))),
                          );
                        }),
                      )),
                Container(height: 0.5, color: R.color.color0xff737072),
                if (model == null)
                  const SizedBox()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.the_morning.tr(),
                            style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Row(children: [
                          buildItem(
                              scheduleDay!.isBeforeBreakfast!,
                              R.string.truoc_an.tr(),
                              scheduleDay!.isBeforeBreakfast!
                                  ? R.drawable.ic_before_eat_selected
                                  : R.drawable.ic_before_eat,
                              0),
                          const SizedBox(width: 16),
                          buildItem(
                              scheduleDay!.isAfterBreakfast!,
                              R.string.sau_an.tr(),
                              scheduleDay!.isAfterBreakfast!
                                  ? R.drawable.ic_after_eat_selected
                                  : R.drawable.ic_after_eat,
                              1)
                        ])
                      ],
                    ),
                  ),
                if (model == null)
                  const SizedBox()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.the_noon.tr(),
                            style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Row(children: [
                          buildItem(
                              scheduleDay!.isBeforeLunch!,
                              R.string.truoc_an.tr(),
                              scheduleDay!.isBeforeLunch!
                                  ? R.drawable.ic_before_eat_selected
                                  : R.drawable.ic_before_eat,
                              2),
                          const SizedBox(width: 16),
                          buildItem(
                              scheduleDay!.isAfterLunch!,
                              R.string.sau_an.tr(),
                              scheduleDay!.isAfterLunch! ? R.drawable.ic_after_eat_selected : R.drawable.ic_after_eat,
                              3)
                        ])
                      ],
                    ),
                  ),
                if (model == null)
                  const SizedBox()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.the_evening.tr(),
                            style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Row(children: [
                          buildItem(
                              scheduleDay!.isBeforeDinner!,
                              R.string.truoc_an.tr(),
                              scheduleDay!.isBeforeDinner!
                                  ? R.drawable.ic_before_eat_selected
                                  : R.drawable.ic_before_eat,
                              4),
                          const SizedBox(width: 16),
                          buildItem(
                              scheduleDay!.isAfterDinner!,
                              R.string.sau_an.tr(),
                              scheduleDay!.isAfterDinner! ? R.drawable.ic_after_eat_selected : R.drawable.ic_after_eat,
                              5)
                        ])
                      ],
                    ),
                  ),
                if (model == null)
                  const SizedBox()
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.sleep_time.tr(),
                            style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            buildItem(
                                scheduleDay!.isBeforeSleeping!,
                                R.string.before_sleep.tr(),
                                scheduleDay!.isBeforeSleeping!
                                    ? R.drawable.ic_before_sleep_selected
                                    : R.drawable.ic_before_sleep,
                                6),
                          ],
                        )
                      ],
                    ),
                  )
              ]),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(R.string.blood_sugar_schedule_single_line.tr(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark)),
              leadingIcon: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.textDark),
                  onPressed: () {
                    _showDialogSave();
                  }),
            ),
            GestureDetector(
              onTap: () async {
                submitData();
              },
              child: SafeArea(
                top: false,
                child: Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    height: 48,
                    width: 195,
                    decoration: BoxDecoration(
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                    child: Center(
                        child: Text(R.string.save.tr(),
                            style: TextStyle(color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16)))),
              ),
            )
          ]),
        ])),
      ),
    );
  }

  Future<void> doSurvey() async {
    if(userInfo.isUserFree) {
      NavigationUtil.showUpdateRequirePopup(context: context, title: R.string.testing_schedule_suggest.tr());
      return;
    }
    await Future.delayed(Duration.zero);
    await NavigationUtil.navigatePage(
      context,
      const BloodSugarStartSurveyPage(),
    );
    loadSchedule();
  }

  Widget buildItem(bool highlight, String title, String icon, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            scheduleDay = scheduleDay?.copyWith(isBeforeBreakfast: !scheduleDay!.isBeforeBreakfast!);
          } else if (index == 1) {
            scheduleDay = scheduleDay?.copyWith(isAfterBreakfast: !scheduleDay!.isAfterBreakfast!);
          } else if (index == 2) {
            scheduleDay = scheduleDay?.copyWith(isBeforeLunch: !scheduleDay!.isBeforeLunch!);
          } else if (index == 3) {
            scheduleDay = scheduleDay?.copyWith(isAfterLunch: !scheduleDay!.isAfterLunch!);
          } else if (index == 4) {
            scheduleDay = scheduleDay?.copyWith(isBeforeDinner: !scheduleDay!.isBeforeDinner!);
          } else if (index == 5) {
            scheduleDay = scheduleDay?.copyWith(isAfterDinner: !scheduleDay!.isAfterDinner!);
          } else if (index == 6) {
            scheduleDay = scheduleDay?.copyWith(isBeforeSleeping: !scheduleDay!.isBeforeSleeping!);
          }

          if (selected == 0) {
            model = model?.copyWith(monday: scheduleDay);
          } else if (selected == 1) {
            model = model = model?.copyWith(tuesday: scheduleDay);
          } else if (selected == 2) {
            model = model?.copyWith(wednesday: scheduleDay);
          } else if (selected == 3) {
            model = model?.copyWith(thursday: scheduleDay);
          } else if (selected == 4) {
            model = model?.copyWith(friday: scheduleDay);
          } else if (selected == 5) {
            model = model?.copyWith(saturday: scheduleDay);
          } else if (selected == 6) {
            model = model?.copyWith(sunday: scheduleDay);
          }
          checkData();
          setState(() {});
        },
        child: Container(
            height: 60,
            decoration: BoxDecoration(
                color: highlight ? R.color.color0xffF4DBBD : R.color.grey_6,
                border: Border.all(color: highlight ? R.color.color0xffE5B440 : R.color.grey_6),
                borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(icon, width: 51, height: 34),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: highlight ? R.color.mainColor : R.color.gray, fontSize: 16))
            ])),
      ),
    );
  }

  _showDialogSave() {
    if (model == tempModel) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: const EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_back_icon, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.ban_muon_quay_lai.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(R.string.confirm_to_back.tr(),
                          textAlign: TextAlign.center, style: R.style.normalTextStyle),
                    ),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(200), color: R.color.grayBorder),
                                child: Center(
                                  child: Text(R.string.van_o_lai.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.w600)),
                                ))),
                      ),
                      const SizedBox(width: 14),
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
                                  borderRadius: BorderRadius.circular(200),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                              child: Center(
                                child: Text(R.string.exit.tr(),
                                    style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
            ]));
      },
    );
  }

  submitData() async {
    try {
      BotToast.showLoading();
      await UserClient().updateScheduleGlucose(model!);
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

Widget _buildButton({
  required String title,
  required String icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 36,
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: R.color.mainColor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

