import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/user/goal_info.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/horizontal_picker/horizontal_numberpicker_wrapper.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';

class GoalSettingController extends StatefulWidget {
  @override
  _GoalSettingControllerState createState() => _GoalSettingControllerState();
}

class _GoalSettingControllerState extends State<GoalSettingController> {
  final AppRepository _appRepository = AppRepository();
  GoalInfoModel? model;
  int total = 0;

  TextEditingController dailyTargetBurnedCalorie = TextEditingController();
  TextEditingController dailyTargetDuration = TextEditingController();
  TextEditingController dailyWalkTargetDuration = TextEditingController();
  double? goalWaist;
  TextEditingController goalWeight = TextEditingController();
  TextEditingController weeklyTargetBurnedCalorie = TextEditingController();
  TextEditingController weeklyTargetDuration = TextEditingController();

  String initDailyKcal = '';

  @override
  void initState() {
    super.initState();
    loadData();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Goal Setting');
  }

  loadData() async {
    BotToast.showLoading();
    model = await UserClient().fetchGoalInfo();
    if (model!.dailyTargetBurnedCalorie != 0) {
      total += 1;
      dailyTargetBurnedCalorie.text =
          roundNumber1(model!.dailyTargetBurnedCalorie!);
    }
    if (model!.dailyTargetDuration != 0) {
      total += 1;
      dailyTargetDuration.text = roundNumber1(model!.dailyTargetDuration!);
    }
    if (model!.dailyWalkTargetDuration != 0) {
      total += 1;
      dailyWalkTargetDuration.text =
          roundNumber1(model!.dailyWalkTargetDuration!);
    }
    if (model!.goalWaist != 0) {
      total += 1;
      goalWaist = model!.goalWaist;
    } else {
      goalWaist = 0;
    }
    if (model!.goalWeight != null && model!.goalWeight != 0) {
      total += 1;
      goalWeight.text = roundNumber1(model!.goalWeight!);
    }
    if (model!.dailyEnergyGoal != 0) {
      total += 1;
      weeklyTargetBurnedCalorie.text = roundNumber1(model!.dailyEnergyGoal!);
      initDailyKcal = roundNumber1(model!.dailyEnergyGoal!);
    }
    if (model!.weeklyTargetDuration != 0) {
      total += 1;
      weeklyTargetDuration.text = roundNumber1(model!.weeklyTargetDuration!);
    }
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
                        R.color.color0xFFFDC798.withOpacity(0.3),
                        R.color.greenbg.withOpacity(0.9),
                      ],
                      begin: const FractionalOffset(1, 1),
                      end: const FractionalOffset(0.9, 0.5),
                      stops: const [0.0, 1.0])),
              child: Column(children: [
                CustomAppBar(
                  backgroundColor: R.color.transparent,
                  title: Text(R.string.goal_setting.tr(),
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
                  child: ListView(
                      padding: const EdgeInsets.all(0),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        Stack(
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              Image.asset(R.drawable.img_goal),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, top: 20),
                                child: Row(children: [
                                  Image.asset(R.drawable.ic_fist,
                                      width: 44, height: 47),
                                  const SizedBox(width: 16),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(R.string.goal_setting_done.tr()),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          Text('$total/7',
                                              style: TextStyle(
                                                  color: R.color.mainColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(width: 4),
                                          Text(R.string.muc_tieu.tr())
                                        ])
                                      ])
                                ]),
                              )
                            ]),
                        buildItem(R.string.so_phut_di_bo_moi_ngay.tr(),
                            R.string.minute.tr(), dailyWalkTargetDuration),
                        buildItem(R.string.so_phut_van_dong_moi_ngay.tr(),
                            R.string.minute.tr(), dailyTargetDuration),
                        buildItem(R.string.minutes_exercise_per_week.tr(),
                            R.string.minute.tr(), weeklyTargetDuration),
                        buildItem(R.string.nang_luong_dot_chay_tren_ngay.tr(),
                            R.string.kcal.tr(), dailyTargetBurnedCalorie),
                        buildItem(R.string.energy_take_per_day.tr(),
                            R.string.kcal.tr(), weeklyTargetBurnedCalorie),
                        buildItem(R.string.muc_tieu_can_nang.tr(),
                            R.string.kg.tr(), goalWeight),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 32, left: 16, right: 16, bottom: 16),
                          child: Text(R.string.muc_tieu_vong_eo.tr(),
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ),
                        if (goalWaist == null)
                          const SizedBox()
                        else
                          HorizontalNumberPickerWrapper(
                            initialValue: goalWaist!.toInt(),
                            minValue: 0,
                            maxValue: 200,
                            step: 1,
                            unit: R.string.cm.tr(),
                            widgetWidth:
                                MediaQuery.of(context).size.width.round(),
                            subGridCountPerGrid: 10,
                            subGridWidth: 8,
                            titleTextColor: R.color.black,
                            scaleColor: R.color.grayComponentBorder,
                            indicatorColor: R.color.mainColor,
                            onSelectedChanged: (value) {
                              goalWaist = value.toDouble();
                            },
                          )
                      ]),
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

  Widget buildItem(
      String title, String unit, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 16, left: 16, right: 16),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title,
                  style: TextStyle(
                      color: R.color.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            SizedBox(
              width: 140,
              child: Row(children: [
                Column(children: [
                  SizedBox(
                    width: 100,
                    child: CupertinoTextField(
                        controller: controller,
                        decoration: BoxDecoration(color: R.color.transparent),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w700),
                        placeholder: '--',
                        placeholderStyle: TextStyle(
                            color: R.color.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                  ),
                  Container(
                      height: 1, width: 72, color: R.color.grayComponentBorder)
                ]),
                Text(unit)
              ]),
            )
          ]),
    );
  }

  submitData() async {
    if (model == null) return;
    try {
      if (initDailyKcal != weeklyTargetBurnedCalorie.text) {
        final result = await showDialog(
          barrierColor: R.color.color0xff003F38.withOpacity(0.5),
          context: context,
          builder: (_) => NoticeChangePage(
              description: R.string.consumption,
              onClick: () {
                Future.delayed(const Duration(milliseconds: 200), () {
                  _appRepository.createMenu(model!.createMenuRequest(
                      double.parse(weeklyTargetBurnedCalorie.text).toInt()));
                });
                NavigationUtil.pop(context, result: true);
              }),
        );
        if (result is! bool || !result) {
          return;
        }
      }
      BotToast.showLoading();
      await UserClient().updateGoalInfo(GoalInfoModel(
          dailyWalkTargetDuration: double.parse(
              dailyWalkTargetDuration.text.isEmpty
                  ? '0'
                  : dailyWalkTargetDuration.text),
          dailyTargetDuration: double.parse(dailyTargetDuration.text.isEmpty
              ? '0'
              : dailyTargetDuration.text),
          weeklyTargetDuration: double.parse(weeklyTargetDuration.text.isEmpty
              ? '0'
              : weeklyTargetDuration.text),
          dailyTargetBurnedCalorie: double.parse(
              dailyTargetBurnedCalorie.text.isEmpty
                  ? '0'
                  : dailyTargetBurnedCalorie.text),
          dailyEnergyGoal: double.parse(weeklyTargetBurnedCalorie.text.isEmpty
              ? '0'
              : weeklyTargetBurnedCalorie.text),
          goalWaist: goalWaist,
          goalWeight:
              double.parse(goalWeight.text.isEmpty ? '0' : goalWeight.text)));
      Observable.instance.notifyObservers([], notifyName: "goal_calo_changed");
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
