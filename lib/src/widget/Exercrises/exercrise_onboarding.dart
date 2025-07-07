import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/chat_supabase_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/widget/exercrises_lesson_section.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/exercise_tab/exercise_detail/exercise_detail_page.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app_setting/firebase_tracking/activity_list_tracking.dart';
import '../../repo/exercrises/exercrises_client.dart';
import '../../repo/home/home_client.dart';
import '../../utils/navigation_util.dart';
import '../BloodSugar/bloodSugar_table_distribution.dart';
import '../helper/tracking_manager.dart';
import '../my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';

class ExercriseOnboarding extends StatefulWidget {
  const ExercriseOnboarding({Key? key}) : super(key: key);

  @override
  _ExercriseOnboardingState createState() => _ExercriseOnboardingState();
}

class _ExercriseOnboardingState extends State<ExercriseOnboarding>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _hasExerciseData = false;
  GlobalKey<ExercrisesLessonSectionState> exercrisesLessonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    firebaseSetup();
    subpabaseInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkExerciseData();
    });
  }

  Future<void> checkExerciseData() async {
    final client = HomeClient();
    final exerciseData = await client.fetchHomes();
    bool isChecked = false;
    if (exerciseData.exercise != null) {
      isChecked = exerciseData.exercise!.isDataNotEmpty!;
      _hasExerciseData = isChecked;
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future subpabaseInit() async {
    setState(() {
      _isLoading = true;
    });
    final ApiResult<SupabaseConfigResponse> apiResult =
        await AppRepository().getSupabaseConfig();
    apiResult.when(
        success: ((data) async => {
              await Supabase.initialize(
                url: data.supabaseUrl,
                anonKey: data.supabaseKey,
              ).onError((error, stackTrace) {
                return Supabase.instance;
              }),
            }),
        failure: ((error) => {Console.log('Error: $error')}));
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "exercrise-step-onboarding",
        screenClass: "ExercriseOnboarding");
    AppSettings.currentScreenName = 'exercrise-step-onboarding';
  }

  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      NavigatorName.tabbar,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.backgroundColorNew,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: _goBack),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.exercrise_step_onboarding_title.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 20 * 0.002,
                    fontFamily: 'SFPro',
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, NavigatorName.exercrise_guide);
                },
                child: Text(
                  R.string.exercrise_step_onboarding_action_btn.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SFPro',
                  ),
                ),
              ),
            ],
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
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    void _navigateToLessonDetail(String? id, int type) async {
      ActivityListTracking.clickLessonItem(
        objectId: id,
        objectIndex: null,
        objectTitle: null,
      );

      await NavigationUtil.navigatePage(
        context,
        LessonDetailPage(
          lessonType: type,
          lessonId: id ?? '',
          onComplete: (_, __) {},
        ),
      );
    }

    return Container(
        height: double.infinity,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDoYouKnow(),
                  const SizedBox(height: 16),
                  // Container(
                  //   padding: EdgeInsets.only(bottom: 16),
                  //   alignment: Alignment.centerLeft,
                  //   child: _buildSupportDoYouNeed(),
                  // ),
                  ExercrisesLessonSection(
                    key: exercrisesLessonKey,
                    onLessonTap: (lesson) => _navigateToLessonDetail(
                        lesson.id, lesson.name == 'exercise' ? 1 : 2),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )));
  }

  Widget _buildDoYouKnow() {
    return Column(children: [
      Image.asset(
        R.drawable.exercrise_step_onboarding_banner,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        width: double.infinity,
        height: 200,
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 12,
              spreadRadius: 0,
              color: Color(0xFF000000).withOpacity(0.12),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(R.string.did_you_know.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SFPro',
                  color: R.color.black)),
          const SizedBox(height: 8.0),
          Text(
              'Theo dõi chỉ số vận động giúp bạn hiểu rõ cơ thể mình hơn mỗi ngày – từ đó cải thiện sức khỏe, kiểm soát bệnh mạn tính hiệu quả và sống chủ động hơn.',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SFPro',
                  color: R.color.color0xff636A6B)),
          const SizedBox(height: 16.0),
          // Button
          ButtonWidget(
              title: R.string.exercrise_step_onboarding_input_step_btn.tr(),
              onPressed: (() => {showActivityInputMethodSelection(hasExerciseData: _hasExerciseData)}))
        ]),
      )
    ]);
  }

  Widget _buildSupportDoYouNeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          R.string.glucose_intro_help_title.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'SFPro',
            color: R.color.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _customBoxSupport(
              icon: R.drawable.ic_manual_input,
              title: R.string.setup_personal_exercise.tr(),
              onClick: () {},
            ),
            const SizedBox(width: 11),
            _customBoxSupport(
              icon: R.drawable.ic_health_connect_input,
              title: R.string.connect_to_health.tr(),
              onClick: () {},
            ),
          ],
        ),
      ],
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
                  fontFamily: 'SFPro',
                  color: R.color.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showActivityInputMethodSelection({bool? hasExerciseData}) async {
  if (AppSettings.userInfo!.weight == null ||
      AppSettings.userInfo!.weight == 0) {
    showPopupWeight();
  } else {
    // Logic navigate to glucose input page (saved before)
    String? lastOpenedGlucoseInputType =
        await AppSettings.getLastOpenedExerciseInputType();
    if (hasExerciseData != null && hasExerciseData) {
      // disable diablog if user has already input exercise
      Navigator.pushNamed(
          navigatorKey.currentContext!, NavigatorName.exercrise_dashboard);
      return;
    }

    // Check if the user has granted permission to access the health app
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    if (hasHealthConnection == true) {
      Navigator.pushNamed(
          navigatorKey.currentContext!, NavigatorName.exercrise_add_v2);
    } else {
      String healthIcon = Platform.isIOS
          ? R.drawable.logo_healthkit
          : R.drawable.ic_health_connect_input_btn;
      String healthTitle = Platform.isIOS
          ? R.string.connect_from_Apple_Health.tr()
          : R.string.connect_from_Health_Connect.tr();

      Widget _buildItemMaterialDialog(
        String title,
        String subTitle,
        String icon,
        Function onTap,
      ) {
        return GestureDetector(
          onTap: () {
            onTap();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: R.color.color0xffF2F6F9,
            ),
            child: ListTile(
              leading: Image.asset(
                icon,
                width: 70,
                fit: BoxFit.cover,
              ),
              // margin beween title and subtitle
              titleAlignment: ListTileTitleAlignment.titleHeight,
              title: Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SFPro',
                    color: R.color.textDark),
              ),
              subtitle: Text(subTitle,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SFPro',
                      color: R.color.primaryGreyColor)),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: R.color.primaryGreyColor),
              onTap: () => onTap(),
            ),
          ),
        );
      }

      showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.transparent,
        context: navigatorKey.currentContext!,
        isScrollControlled: true,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height to fit content
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xffF2F2F2)))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 30),
                    Center(
                      child: Text(
                        R.string.choose_how_to_enter.tr(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: R.color.textDark),
                      ),
                    ),
                    IconButton(
                        onPressed: (() {
                          Navigator.pop(context);
                        }),
                        icon: Icon(Icons.close, color: R.color.textDark)),
                  ],
                ),
              ),
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(15),
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildItemMaterialDialog(
                    healthTitle,
                    R.string.enter_healt_connect_details.tr(),
                    healthIcon,
                    () {
                      AppSettings.setLastOpenedExerciseInputType('auto');
                      Navigator.pop(context);
                      RequestHealthConnect.showModal(context, callback: () {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildItemMaterialDialog(
                    R.string.enter_manually.tr(),
                    R.string.enter_manually_details.tr(),
                    R.drawable.ic_manual_input_btn,
                    () {
                      AppSettings.setLastOpenedExerciseInputType('manual');
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, NavigatorName.exercrise_add_v2);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
