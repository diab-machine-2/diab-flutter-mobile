import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../res/R.dart';
import '../../modal/user/goal_info.dart';
import '../../repo/user/user_client.dart';
import '../helper/helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/app_setting/app_setting.dart';

class ExercisesGuide extends StatefulWidget {
  const ExercisesGuide({super.key});

  @override
  State<ExercisesGuide> createState() => _ExercisesGuideState();
}

class _ExercisesGuideState extends State<ExercisesGuide> {
  TextEditingController dailyTargetDuration = TextEditingController();
  TextEditingController dailyTargetBurnedCalorie = TextEditingController();
  FocusNode durationFocus = FocusNode();
  FocusNode burnedCalorieFocus = FocusNode();
  GoalInfoModel? model;

  @override
  void initState() {
    super.initState();
    loadData();
    durationFocus.addListener(_onFocusChangeDuration);
    burnedCalorieFocus.addListener(_onFocusChange);
  }

  void _onFocusChangeDuration() {
    if (!durationFocus.hasFocus) {
      submitData(true, dailyTargetDuration.text);
    }
  }

  void _onFocusChange() {
    if (!burnedCalorieFocus.hasFocus) {
      submitData(false, dailyTargetBurnedCalorie.text);
    }
  }

  loadData() async {
    BotToast.showLoading();
    model = await UserClient().fetchGoalInfo();
    if (model!.dailyTargetDuration != 0) {
      dailyTargetDuration.text = roundNumber1(model!.dailyTargetDuration!);
      AppSettings.targetDuration = double.parse(dailyTargetDuration.text);
    } else {
      submitData(true, '30');
    }
    if (model!.dailyTargetBurnedCalorie != 0) {
      dailyTargetBurnedCalorie.text =
          roundNumber1(model!.dailyTargetBurnedCalorie!);
      AppSettings.userInfo = AppSettings.userInfo?.copyWith(
        energyGoal: double.parse(
          dailyTargetBurnedCalorie.text.isEmpty
              ? '0'
              : dailyTargetBurnedCalorie.text,
        ),
      );
    } else {
      submitData(false, '100');
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
          leadingWidth: 30,
          leading: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Align(
            alignment: Alignment.topLeft,
            child: Text(
              R.string.exercrise_step_onboarding_action_btn.tr(),
              style: TextStyle(
                color: R.color.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 20 * 0.002,
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
                  Color(0xFF0DAB9C),
                  Color(0xFF01847A),
                ])),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // _buildSupportDoYouNeed(),
              SizedBox(height: 12),
              _inputTarget(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      R.drawable.exercise_guide_image,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${R.string.reference_source.tr()}:",
                            style: TextStyle(
                              fontSize: 14,
                              color: R.color.color0xffBFC6C6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                'https://www.betterhealth.vic.gov.au/health/healthyliving/exercise-intensity',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              'https://www.betterhealth.vic.gov.au/health/healthyliving/exercise-intensity',
                              style: TextStyle(
                                fontSize: 14,
                                color: R.color.color0xffBFC6C6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
      margin: EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            R.string.goal.tr(),
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          buildItem(
            R.string.so_phut_van_dong_moi_ngay.tr(),
            R.string.minute_upperCase_first_character.tr(),
            dailyTargetDuration,
            (newTargetDuration) {
              debugPrint('new target Duration $newTargetDuration');
              submitData(true, newTargetDuration);
            },
            durationFocus,
            3,
          ),
          buildItem(
            R.string.kcal_burned_per_day.tr(),
            R.string.kcal.tr(),
            dailyTargetBurnedCalorie,
            (newTargetBurnedCalorie) {
              debugPrint('new target Burned $newTargetBurnedCalorie');
              submitData(false, newTargetBurnedCalorie);
            },
            burnedCalorieFocus,
            4,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget buildItem(
    String title,
    String unit,
    TextEditingController controller,
    Function(String)? onSubmitted,
    FocusNode focusNode,
    int maxLength,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 16, left: 8),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    color: R.color.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            Container(
              width: 140.w,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.zero,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        width: 100.w,
                        height: 42.h,
                        child: CupertinoTextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration:
                                BoxDecoration(color: R.color.transparent),
                            maxLength: maxLength,
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
                          height: 1,
                          width: 90.w,
                          color: R.color.grayComponentBorder)
                    ]),
                    Text(
                      unit,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        height: 0,
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    )
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
