import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/src/widget/helper/show_message.dart';

import '../../../res/R.dart';
import '../../modal/user/goal_info.dart';
import '../../repo/user/user_client.dart';
import '../helper/helper.dart';
import 'package:medical/src/modal/error/error_model.dart';

class ExercisesGuide extends StatefulWidget {
  const ExercisesGuide({super.key});

  @override
  State<ExercisesGuide> createState() => _ExercisesGuideState();
}

class _ExercisesGuideState extends State<ExercisesGuide> {
  TextEditingController dailyTargetDuration = TextEditingController();
  TextEditingController dailyTargetBurnedCalorie = TextEditingController();
  GoalInfoModel? model;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    model = await UserClient().fetchGoalInfo();
    if (model!.dailyTargetDuration != 0) {
      dailyTargetDuration.text = roundNumber1(model!.dailyTargetDuration!);
    }
    if (model!.dailyTargetBurnedCalorie != 0) {
      dailyTargetBurnedCalorie.text =
          roundNumber1(model!.dailyTargetBurnedCalorie!);
    }
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  void dispose() {
    dailyTargetDuration.clear();
    dailyTargetBurnedCalorie.clear();
    dailyTargetDuration.dispose();
    dailyTargetBurnedCalorie.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.backgroundColorNew,
        appBar: AppBar(
          leading: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Transform(
            transform: Matrix4.translationValues(-20, 0.0, 0.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                R.string.exercrise_step_onboarding_action_btn.tr(),
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          backgroundColor: R.color.transparent, //No more green
          elevation: 0.0, //Shadow gone
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  R.color.greenGradientMid,
                  R.color.greenGradientBottom
                ])),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildSupportDoYouNeed(),
              _inputTarget(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Image.asset(
                  R.drawable.exercise_guide_image,
                ),
              ),
              SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportDoYouNeed() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.glucose_intro_help_title.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'sfpro',
              color: R.color.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _customBoxSupport(
                icon: R.drawable.ic_manual_input,
                title: R.string.setup_personal_exercise.tr(),
                onClick: () {},
              ),
              _customBoxSupport(
                icon: R.drawable.ic_health_connect_input,
                title: R.string.connect_to_health.tr(),
                onClick: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customBoxSupport({
    required String icon,
    required String title,
    Function()? onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 23,
        height: 156.h,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: R.color.black.withOpacity(0.12),
                blurRadius: 8,
                offset: Offset(1, 2),
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              width: 72.w,
              height: 72.h,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'sfpro',
                  color: R.color.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputTarget() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            R.string.goal.tr(),
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 18,
              fontFamily: 'sfpro',
              fontWeight: FontWeight.w900,
            ),
          ),
          buildItem(
            R.string.so_phut_van_dong_moi_ngay.tr(),
            R.string.minute.tr(),
            dailyTargetDuration,
            (newTargetDuration) {
              debugPrint('new target Duration $newTargetDuration');
              submitData(true, newTargetDuration);
            },
          ),
          buildItem(
            R.string.kcal_burned_per_day.tr(),
            R.string.kcal.tr(),
            dailyTargetBurnedCalorie,
            (newTargetBurnedCalorie) {
              debugPrint('new target Burned $newTargetBurnedCalorie');
              submitData(false, newTargetBurnedCalorie);
            },
          ),
        ],
      ),
    );
  }

  Widget buildItem(
    String title,
    String unit,
    TextEditingController controller,
    Function(String)? onSubmitted,
  ) {
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
                        onSubmitted: onSubmitted,
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

  submitData(bool isEditTargetDuration, String newValue) async {
    if (model == null) return;
    try {
      BotToast.showLoading();
      GoalInfoModel goalInfo = model!;
      await UserClient().updateGoalInfo(
        isEditTargetDuration
            ? goalInfo.copyWith(
                dailyTargetDuration:
                    double.parse(newValue.isEmpty ? '0' : newValue),
              )
            : goalInfo.copyWith(
                dailyTargetBurnedCalorie:
                    double.parse(newValue.isEmpty ? '0' : newValue),
              ),
      );
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
}
