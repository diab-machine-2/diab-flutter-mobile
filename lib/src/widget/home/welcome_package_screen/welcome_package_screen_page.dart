import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../model/repository/app_repository.dart';
import 'welcome_package_screen.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomePackageScreenPage extends StatefulWidget {
  final String? icon;
  final String? title;
  final String? subTitle;
  final VoidCallback? onSkip;
  final VoidCallback? onNavigateToMyPlan;
  final String? zaloGroup;

  WelcomePackageScreenPage({
    Key? key,
    required this.icon,
    this.title,
    this.subTitle,
    required this.onSkip,
    required this.onNavigateToMyPlan,
    this.zaloGroup,
  }) : super(key: key);

  @override
  _WelcomePackageScreenPageState createState() =>
      _WelcomePackageScreenPageState();
}

class _WelcomePackageScreenPageState extends State<WelcomePackageScreenPage> {
  late WelcomePackageScreenCubit _cubit;
  bool isClickSkip = false;
  static const String EVALUATING_INTERVIEW_LINK =
      "https://app.diab.com.vn/dat-hen-dau-vao";

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = WelcomePackageScreenCubit(appRepository);
    _cubit.getContentWelcome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child:
            BlocListener<WelcomePackageScreenCubit, WelcomePackageScreenState>(
          listener: (context, state) {
            if (state is WelcomePackageScreenLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
          },
          child:
              BlocBuilder<WelcomePackageScreenCubit, WelcomePackageScreenState>(
            builder: (context, state) {
              return _buildPage(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, WelcomePackageScreenState state) {
    return WillPopScope(
      onWillPop: () => _backPressed(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: R.color.backgroundColorNew),
          // padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHeader(),
                              Column(
                                children: [
                                  _buildHeaderTitle(),
                                  GapH(16),
                                  Image.asset(
                                    widget.icon!,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              height: 1.4,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: R.string
                                                    .welcome_dialog_subtitle_1
                                                    .tr(),
                                                style: TextStyle(
                                                    color: Color(0xFF111515)),
                                              ),
                                              TextSpan(
                                                text: R.string
                                                    .welcome_dialog_subtitle_2
                                                    .tr(),
                                                style: TextStyle(
                                                    color: Color(0xFF111515)),
                                              ),
                                              TextSpan(
                                                text: _cubit
                                                        .content?.packageName ??
                                                    '',
                                                style: TextStyle(
                                                    color: Color(0xFFB4802D)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GapH(40),
                                        GestureDetector(
                                          onTap: () => _handleButtonPress(),
                                          child: SafeArea(
                                            top: false,
                                            child: Container(
                                              height: 48,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: R.color.mainColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          200),
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                      colors: [
                                                        R.color
                                                            .greenGradientTop,
                                                        R.color
                                                            .greenGradientBottom
                                                      ])),
                                              child: Center(
                                                child: Text(
                                                  widget.zaloGroup != null &&
                                                          widget.zaloGroup!
                                                              .isNotEmpty
                                                      ? R.string.join_zalo_group
                                                          .tr()
                                                      : R.string.my_plan.tr(),
                                                  style: TextStyle(
                                                      color: R.color.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GapH(16),
                                        GestureDetector(
                                          onTap: () =>
                                              _handleButtonBookingConsultPress(
                                                  EVALUATING_INTERVIEW_LINK),
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: R.color.white,
                                              borderRadius:
                                                  BorderRadius.circular(200),
                                              border: Border.all(
                                                color:
                                                    R.color.greenGradientBottom,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                R.string.booking_consult.tr(),
                                                style: TextStyle(
                                                  color: R.color
                                                      .greenGradientBottom,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GapH(16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Container(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       GestureDetector(
              //         onTap: () async {
              //           if (!isClickSkip) {
              //             isClickSkip = true;
              //             await _backPressed();
              //           }
              //         },
              //         child: SafeArea(
              //           top: false,
              //           child: Container(
              //             height: 48,
              //             width: 100,
              //             child: Center(
              //               child: Text(
              //                 R.string.skip.tr(),
              //                 style: TextStyle(
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.w700,
              //                     color: R.color.mainColor),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       GestureDetector(
              //         onTap: () => _handleButtonPress(),
              //         child: SafeArea(
              //           top: false,
              //           child: _buildActionButton(),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  _buildHeader() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
          stops: [0.01, 0.99],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context)
                .textScaler
                .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
          ),
          child: Text(
            _cubit.content?.packageName ?? '',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: R.color.white),
          ),
        ),
        hideAllBackButton: true,
        actions: [
          InkWell(
            onTap: () async {
              HomeSupportFunctions.showModalAddData(context);
            },
            child: Container(
              height: 36,
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: R.color.color0xffCAFAF5,
                border: Border.all(
                  color: R.color.color0xff8FEBE0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    R.icons.ic_telephone,
                    width: 16,
                    height: 16,
                    color: R.color.greenGradientBottom,
                    fit: BoxFit.scaleDown,
                  ),
                  GapW(4),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: MediaQuery.of(context)
                          .textScaler
                          .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                    ),
                    child: Text(
                      R.string.contact.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'sfpro',
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildHeaderTitle() {
    return Column(
      children: [
        Text(
          R.string.welcome_dialog_title_1.tr(),
          style: TextStyle(
            color: R.color.color0xffB4802D,
            fontSize: 35,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          R.string.welcome_dialog_title_2.tr(),
          style: TextStyle(
            color: R.color.greenGradientBottom,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleButtonPress() async {
    final zaloGroup = widget.zaloGroup ?? '';
    print('[ONBOARDING] handle button press zaloGroup: $zaloGroup');

    if (zaloGroup.isEmpty) {
      _navigateToMyPlan();
    } else {
      _openZaloGroup(zaloGroup);
    }
  }

  Future<void> _handleButtonBookingConsultPress(String url) async {
    isClickSkip = false;
    Navigator.pop(context);
    if (await canLaunch(url)) {
      FlutterBranchSdk.handleDeepLink(url);

      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _navigateToMyPlan() async {
    if (!isClickSkip) {
      isClickSkip = true;
      await _backPressed();
      Observable.instance
          .notifyObservers([], notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
    }
  }

  Future<void> _openZaloGroup(String zaloGroup) async {
    // Always mark welcome as displayed when user clicks join_zalo_group button
    if (!isClickSkip) {
      isClickSkip = true;
      await _backPressed();
    }

    final url = Uri.tryParse(zaloGroup);
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Handle case where URL cannot be launched
      print('[ONBOARDING] Could not launch Zalo group URL: $zaloGroup');
    }
  }

  Widget _buildActionButton() {
    final String? zaloGroup = widget.zaloGroup;
    final bool hasZaloGroup = zaloGroup != null && zaloGroup.isNotEmpty;

    print(
        '[ONBOARDING] _buildActionButton zaloGroup: $zaloGroup, hasZaloGroup: $hasZaloGroup');

    return Container(
      height: 48,
      width: 180,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: R.color.mainColor,
          borderRadius: BorderRadius.circular(200),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
      child: Center(
        child: Text(
          hasZaloGroup ? R.string.join_zalo_group.tr() : R.string.my_plan.tr(),
          style: TextStyle(
              color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<bool> _backPressed() async {
    await _cubit.markDisplayedWelcome();
    isClickSkip = false;
    Navigator.pop(context);
    Observable.instance
        .notifyObservers([], notifyName: Const.UPDATE_SUBSCRIPTION);
    return true;
  }
}
