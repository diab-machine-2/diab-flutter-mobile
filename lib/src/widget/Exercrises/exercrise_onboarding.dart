import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/exercise_tab/exercise_detail/exercise_detail_page.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helper/tracking_manager.dart';

class ExercriseOnboarding extends StatefulWidget {
  const ExercriseOnboarding({Key? key}) : super(key: key);

  @override
  _ExercriseOnboardingState createState() => _ExercriseOnboardingState();
}

class _ExercriseOnboardingState extends State<ExercriseOnboarding>
    with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    firebaseSetup();
    subpabaseInit();
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
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
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
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Message.showToastMessage(context,
                      R.string.exercrise_step_onboarding_action_btn.tr());
                },
                child: Text(
                  R.string.exercrise_step_onboarding_action_btn.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'sfpro',
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
                    R.color.greenGradientMid,
                    R.color.greenGradientBottom
                  ])),
            ),
          ),
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Container(
        height: double.infinity,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: _buildDoYouKnow(),
                ),
                const SizedBox(height: 16),
                ButtonWidget(
                    title: 'Màn hình Dashboard',
                    onPressed: (() => {
                          Navigator.pushNamed(
                              context, NavigatorName.exercrise_dashboard)
                        })),
                const SizedBox(height: 16),
                ButtonWidget(
                    title: 'Màn hình Kết quả',
                    onPressed: (() => {
                          Navigator.pushNamed(
                              context, NavigatorName.exercrise_result)
                        })),
                const SizedBox(height: 16),
                ButtonWidget(
                    title: 'Nhập chỉ số (củ)',
                    onPressed: () => {
                          Navigator.pushNamed(
                              context, NavigatorName.detail_exercrises)
                        }),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: _buildSupportDoYouNeed(),
                ),
              ],
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
          Text('Do you know?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'sfpro',
                  color: R.color.black)),
          const SizedBox(height: 8.0),
          Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget consectetur sagittis, nisl nunc lacinia.',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'sfpro',
                  color: R.color.color0xff636A6B)),
          const SizedBox(height: 16.0),
          // Button
          ButtonWidget(
              title: R.string.exercrise_step_onboarding_input_step_btn.tr(),
              onPressed: (() => {showActivityInputMethodSelection()}))
        ]),
      )
    ]);
  }

  Widget _buildSupportDoYouNeed() {
    return Text('Support do you need?',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'sfpro',
            color: R.color.black));
  }
}

showActivityInputMethodSelection() async {
  if (AppSettings.userInfo!.weight == null ||
      AppSettings.userInfo!.weight == 0) {
    showPopupWeight();
  } else {
    // Logic navigate to glucose input page (saved before)
    String? lastOpenedGlucoseInputType =
        await AppSettings.getLastOpenedExerciseInputType();
    if (lastOpenedGlucoseInputType == 'manual' ||
        lastOpenedGlucoseInputType == 'auto') {
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
                    fontFamily: 'sfpro',
                    color: R.color.textDark),
              ),
              subtitle: Text(subTitle,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'sfpro',
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
                    'Tự động nhập chỉ số một cách nhanh chóng và chính xác.',
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
                    'Nhập chỉ số đường huyết của bạn bằng cách nhập thủ công từ kết quả đo đã có sẵn.',
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
