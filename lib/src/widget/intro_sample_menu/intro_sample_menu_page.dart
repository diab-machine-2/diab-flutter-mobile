import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/body_parameter/body_parameter_page.dart';
import 'package:medical/src/widget/kcal_parameter/kcal_parameter.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widget/upgrade_account/upgrade_account.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/upgrade_package_widget.dart';

import 'intro_sample_menu.dart';

class IntroSampleMenuPage extends StatefulWidget {
  @override
  _IntroSampleMenuPageState createState() => _IntroSampleMenuPageState();
}

class _IntroSampleMenuPageState extends State<IntroSampleMenuPage> {
  late IntroSampleMenuCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = IntroSampleMenuCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<IntroSampleMenuCubit, IntroSampleMenuState>(
          listener: (context, state) {
            if (state is IntroSampleMenuFailure) {
              Utils.showErrorSnackBar(context, state.error);
            }
            if (state is IntroSampleMenuLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
          },
          builder: (
            BuildContext context,
            IntroSampleMenuState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, IntroSampleMenuState state) {
    return Scaffold(
      body: CommonPage(
        background: R.drawable.bg_welcome,
        title: R.string.sample_menu.tr(),
        child: ListView(
          padding: EdgeInsets.all(16.h),
          shrinkWrap: true,
          children: [
            Visibility(
                visible: _cubit.isBasic,
                child: UpgradePackageWidget(onClickUpgrade: () {
                  NavigationUtil.navigatePage(context, UpgradeAccountPage(code: Const.PRO,));
                })),
            Visibility(
              visible: !_cubit.isBasic,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    R.drawable.img_cooking,
                    width: double.infinity,
                    height: 240.h,
                  ),
                  SizedBox(
                    height: 32.h,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      R.string.text_intro_menu.tr(),
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16.sp,
                        letterSpacing: 0.4,
                        height: 1.375,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(horizontal: 20.h),
                    child: RichText(
                      text: TextSpan(
                        text: R.string.step_1.tr(),
                        style: TextStyle(
                          color: R.color.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          letterSpacing: 0.4,
                          height: 1.375,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: R.string.text_step_1.tr(),
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                                letterSpacing: 0.4,
                                height: 1.375,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(horizontal: 20.h),
                    child: RichText(
                      text: TextSpan(
                        text: R.string.step_2.tr(),
                        style: TextStyle(
                          color: R.color.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          letterSpacing: 0.4,
                          height: 1.375,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: R.string.text_step_2.tr(),
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                                letterSpacing: 0.4,
                                height: 1.375,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34.h,
                  ),
                  Container(
                    width: 128.w,
                    child: ButtonWidget(
                      title: R.string.start.tr(),
                      onPressed: () {
                        showDialog(
                          barrierColor:
                              R.color.color0xff003F38.withOpacity(0.5),
                          context: context,
                          builder: (_) => KcalParameterPage(callback: (number) {
                            // TODO
                            // NavigationUtil.pushAndRemoveUtilPage(context, widget)
                          },),
                        );
                        // NavigationUtil.pop(context);
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
