import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/bloc/home/home_bloc.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/home/package_account_home_model.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/service/rating_service.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/base/text_field_custom.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/header.dart';
import 'package:medical/src/widget/home/widget/sync_modal.dart';
import 'package:medical/src/widget/list_service/list_service_page.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/create_goal/create_goal_page.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/shared_profile/pages/share_app_detail/widgets/banner_share_app.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/voucher_popup.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';
import '../../repo/user/user_client.dart';
import '../my_plan_screens/activity_tab/my_progress/my_progress.dart';
import 'welcome_package_screen/welcome_package_screen.dart';
import 'package:medical/src/widget/nipro/health_app/blocs/healthApp_bloc.dart';

class HomeController extends StatefulWidget {
  const HomeController({this.sharedCode, this.syncAccountAccess});
  final String? sharedCode;
  final bool? syncAccountAccess;

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> with Observer {
  GlobalKey<CourseSuggestState> courseSuggestKey = GlobalKey();
  final GlobalKey<TextFieldCustomState> phoneKey = GlobalKey();
  FocusNode phoneFocusNode = FocusNode();
  String phone = '';

  var data = [
    {
      'name': R.string.duong_huyet,
      'image': R.drawable.bg_blood,
      'icon': R.drawable.ic_blood_sugar,
      'dataDetail': [],
    },
    {
      'name': R.string.huyet_ap,
      'image': R.drawable.bg_blood_presser,
      'icon': R.drawable.ic_heart_presse,
      'dataDetail': []
    },
    {
      'name': R.string.can_nang,
      'image': R.drawable.bg_weight,
      'icon': R.drawable.ic_weight_plus,
      'dataDetail': []
    },
    {
      'name': R.string.cam_xuc,
      'image': R.drawable.bg_emotion,
      'icon': R.drawable.ic_emotion_plus,
      'dataDetail': [
        {'name': R.string.vui_ve, 'image': R.drawable.ic_laughing},
        {'name': R.string.buon_ngu, 'image': R.drawable.ic_sleeping},
        {'name': R.string.om, 'image': R.drawable.ic_sick}
      ]
    },
    {
      'name': R.string.dinh_duong,
      'image': R.drawable.bg_food,
      'icon': R.drawable.ic_food,
      'dataDetail': [],
    },
    {
      'name': R.string.van_dong,
      'image': R.drawable.bg_exercise,
      'icon': R.drawable.ic_exercise_menu,
      'dataDetail': [],
    },
    {
      'name': R.string.progress,
      'image': '',
      'icon': R.drawable.ic_progress,
      'dataDetail': [],
    },
    {
      'name': R.string.hba1c,
      'image': R.drawable.bg_hba1c,
      'icon': R.drawable.ic_hba1c_menu,
      'dataDetail': [],
    },
  ];

  var dataDetail = [{}];
  late BuildContext currentContext;

  int page = 1;
  bool isLoading = false;

  var user = AppSettings.userInfo;
  var popupStore = PopupStore;
  HomeModel? model;

  bool isSyncAccount = false;

  String _urlPopup = '';

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);

    if (user?.isShare == true) {
      ShareProfilePopup.instance.onHasSharedCode(
          requestFromDoctor: true, code: user?.shareRefCode ?? '');
    }
    firebaseSetup();
    initHealthApp();
    _checkShowRating();

    Future.delayed(Duration.zero, () async {
      if (AppSettings.isFirstTimeLoginZalo) {
        _showModalSyncAccount(context);
        await AppSettings.setIsFirstTimeLoginZalo(false);
      }
      if (AppSettings.isSyncSuccess) {
        _showDialogSuccess();
        AppSettings.isSyncSuccess = false;
      }
    });
  }

  Future<void> _checkShowRating() async {
    int turn = await AppSettings.numberOfOpenHome();
    if (turn > 2) return;
    RatingService.showRating();
    await AppSettings.increaseNumberOfOpenHome();
  }

  initHealthApp() async {
    await AppSettings.setIsSyncing(false);
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? zoomId = DynamicLinkConfig.instance.zoomId;
    final String? activityId = DynamicLinkConfig.instance.activityId;
    if (lessonId == null && zoomId == null && activityId == null) {
      Future.delayed(Duration(milliseconds: 1000), () async {
        bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
        if (hasHealthConnection == true) {
          HealthAppBloc()..add(SubmitSyncData(true));
        }
      });
      await ChooseUrl();
      // Future.delayed(Duration(seconds: 3), () async {
      //   _showPopupStore();
      // });
    }
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics
        .logScreenView(screenName: "home", screenClass: "HomeController");
    AppSettings.currentScreenName = 'home';
  }

  @override
  void update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    if (notifyName == 'BloodPressure_change_data') {
      _refresh();
      checkScreen(NavigatorName.detail_blood_pressure);
    }
    if (notifyName == 'glucose_change_data') {
      _refresh();
      checkScreen(NavigatorName.detail_blood_sugar, map: map);
    }
    if (notifyName == 'Weight_change_data') {
      _refresh();
      checkScreen(NavigatorName.detail_bmi);
    }
    if (notifyName == 'Emotion_change_data') {
      _refresh();
      checkScreen(NavigatorName.detail_emotion);
    }
    if (notifyName == 'active_change_data') {
      _refresh();
      checkScreen(NavigatorName.detail_exercrises);
    }
    if (notifyName == 'food_change_data') {
      _refresh();
      // checkScreen(NavigatorName.detail_food);
    }
    if (notifyName == 'hba1c_change_data') {
      _refresh();
      checkScreen(NavigatorName.detail_hba1c);
    }
    if (notifyName == 'goal_calo_changed' || notifyName == 'refresh_home') {
      _refresh();
    }
    if (notifyName == 'syncing_heath_app' &&
        AppSettings.currentScreenName != 'welcome') {
      bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
      if (hasHealthConnection == true) {
        HealthAppBloc()..add(SubmitSyncData(true));
      }
    }

    if (notifyName == Const.NAVIGATE_TO_PROFILE_TAB) {
      _refresh();
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);

    super.dispose();
  }

  getData() async {
    final result = await AppSettings.getHome();
    if (result != null) {
      setState(() {
        model = result;
      });
    }
  }

  _showPopupStore() {
    UserModel userInfo = AppSettings.userInfo!;

    if (userInfo.checked == true) {
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        useSafeArea: true,
        builder: (context) => PopupStore(_urlPopup),
      );
    }
  }

  ChooseUrl() async {
    const String POPUP_IMAGE_URL_BACKUP =
        'https://api.staging.diab.com.vn/App/Image/9ae088a5-8f56-4b02-7210-08dbce82cedd';

    try {
      var id = await UserClient().fetchPopupImage();
      if (Const.ENVIRONMENT_DEFAULT == 'product') {
        _urlPopup = Uri.https(Const.DOMAIN, 'App/Image/$id').toString();
      } else {
        _urlPopup = Uri.https(Const.DOMAIN_STAGING, 'App/Image/$id').toString();
      }
      print(_urlPopup);
      return _urlPopup;
    } catch (e) {
      print('An error occurred: $e');
      _urlPopup = POPUP_IMAGE_URL_BACKUP;
      return _urlPopup;
    }
  }

  checkScreen(String routeName, {Map<dynamic, dynamic>? map}) {
    Navigator.popUntil(context, (route) {
      if (route.settings.name == routeName) {
        return true;
      } else if (route.isFirst) {
        Navigator.pushNamed(context, routeName, arguments: map);
        return true;
      }
      return false;
    });
  }

  Future<bool> _refresh() async {
    page = 1;
    BlocProvider.of<HomeBloc>(currentContext).add(FetchHome());
    return true;
  }

  Future<bool> _pullToRefresh() async {
    courseSuggestKey.currentState?.loadData();
    page = 1;
    BlocProvider.of<HomeBloc>(currentContext).add(FetchHome());
    user = await UserClient().fetchUser();
    AppSettings.isReloadCurrentUserInfo = true;
    return true;
  }

  void _showModalSyncAccount(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              EdgeInsets.all(10), // Adjust padding to fit screen better
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Adjust the radius here
          ),
          child: Container(
            width: deviceWidth * 0.9,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(R.drawable.sync_account_theme),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Bạn đã từng dùng số điện thoại để đăng nhập DiaB chưa?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: Text(
                    'Cập nhật số điện thoại đã từng sử dụng để đồng bộ thông tin và bảo mật tài khoản tốt hơn',
                    textAlign: TextAlign.center,
                    style: R.style.normalTextStyle,
                  ),
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: deviceWidth * 0.35,
                        height: 43,
                        decoration: BoxDecoration(
                          color: R.color.gray_btn,
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Center(
                          child: Text(
                            R.string.not_yet.tr(),
                            style: TextStyle(
                              color: R.color.dark,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, NavigatorName.sync_screen);
                      },
                      child: Container(
                        height: 43,
                        width: deviceWidth * 0.35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4BB2AB),
                                  Color(0xFF01857A),
                                  Color(0xFF008479)
                                ])),
                        child: Center(
                          child: Text(
                            R.string.used_to.tr(),
                            style: TextStyle(
                              color: R.color.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 32;
    return BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
        child: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
          currentContext = context;
          if (state is HomeInitial) {
            BlocProvider.of<HomeBloc>(context).add(FetchHome());
          }
          if (state is HomeLoading) {
            model = state.model;
          }
          if (state is HomeLoaded) {
            model = state.model;
            if (false == model?.packageAccount?.isDisplayedWelcome) {
              if (AppSettings.isDisplayedWelcome == false) {
                Future.delayed(Duration.zero, () async {
                  showWelcomeDialog(model?.packageAccount);
                });
              } else {}
            }
            isLoading = false;
          }
          return RefreshIndicator(
            onRefresh: _pullToRefresh,
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage(R.drawable.bg_home),
                  fit: BoxFit.fill,
                )),
                child: Column(
                  children: [
                    HomeHeader(sharedCode: widget.sharedCode),
                    Expanded(
                      child: SafeArea(
                        top: false,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 16),
                          children: [
                            GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                itemCount: data.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 24,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 160 / 140),
                                itemBuilder: (BuildContext context, int index) {
                                  final name = data[index]['name'];
                                  final image = data[index]['image'];
                                  final icon = data[index]['icon'];
                                  if (index == 0 &&
                                      model != null &&
                                      model!.glucoseIndex.index != 0) {
                                    return _buildBloodSugar(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.glucoseIndex);
                                  }
                                  if (index == 1 &&
                                      model != null &&
                                      model!.bloodPressureIndex.diastolic !=
                                          0) {
                                    return _buildBloodPressure(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.bloodPressureIndex);
                                  }
                                  if (index == 2 &&
                                      model != null &&
                                      model!.weightCard!.weight != 0) {
                                    return _buildWeight(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.weightCard!);
                                  }
                                  if (index == 3 &&
                                      model != null &&
                                      model!.emotionCard!.details != null) {
                                    return _buildEmotion(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.emotionCard!);
                                  }

                                  if (index == 4 &&
                                      model != null &&
                                      model!.energyCard!.consumedEnergy != 0) {
                                    return _buildFood(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.energyCard!);
                                  }
                                  if (index == 5 &&
                                      model != null &&
                                      model!.exercise!.targetExercise != 0) {
                                    return _buildExcercise(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.exercise!);
                                  }
                                  if (index == 6 &&
                                      model != null &&
                                      model!.processCard != null &&
                                      model!.processCard!.target != 0) {
                                    return _buildProgress(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.processCard!);
                                  }
                                  if (index == 7 &&
                                      model != null &&
                                      model!.hbA1CIndex.index != 0) {
                                    return _buildHbA1C(
                                        context,
                                        index,
                                        name as String?,
                                        image as String?,
                                        icon as String?,
                                        model!.hbA1CIndex);
                                  }

                                  return _buildItem(
                                      context,
                                      index,
                                      name as String?,
                                      image as String?,
                                      icon as String?);
                                }),
                            //   const SizedBox(height: 16),
                            Visibility(
                              visible: false,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: model != null &&
                                          (model!.energyCard!.consumedEnergy !=
                                                  0 ||
                                              model!.exercise!.index != 0)
                                      ? buildFoodAndExcercise(model!)
                                      : Container(
                                          height: width * 160 / 343,
                                          child: Stack(children: [
                                            Positioned.fill(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    color: R.color.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                    R.string
                                                        .dinh_duong_va_van_dong
                                                        .tr(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                            Positioned(
                                                top: 60,
                                                bottom: 0,
                                                left: 0,
                                                child: Image.asset(R.drawable
                                                    .bg_food_and_excersire)),
                                            Center(
                                                child: Image.asset(
                                                    R.drawable
                                                        .ic_food_and_excersire,
                                                    width: 58,
                                                    height: 58)),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          NavigatorName
                                                              .detail_food);
                                                    },
                                                    child: Container(
                                                        color: R
                                                            .color.transparent),
                                                  )),
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          NavigatorName
                                                              .detail_exercrises);
                                                    },
                                                    child: Container(
                                                        color: R
                                                            .color.transparent),
                                                  ))
                                                ])
                                          ]),
                                        )),
                            ),
                            const SizedBox(height: 8),
                            Visibility(
                              visible: false,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, NavigatorName.detail_hba1c);
                                    },
                                    child: model != null &&
                                            model!.hbA1CIndex.index != 0
                                        ? buildHbA1C(model!.hbA1CIndex)
                                        : Container(
                                            height: width * 90 / 343,
                                            child: Stack(children: [
                                              Positioned.fill(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                      color: R.color.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                      R.string.hba1c.tr(),
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              ),
                                              Positioned(
                                                  top: 0,
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Image.asset(
                                                      R.drawable.bg_hba1c)),
                                              Center(
                                                  child: Image.asset(
                                                      R.drawable.ic_hba1cn,
                                                      width: 58,
                                                      height: 58))
                                            ]),
                                          )),
                              ),
                            ),
                            BannerShareApp(),
                            CourseSuggest(key: courseSuggestKey, position: 1),
                            SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }

  showWelcomeDialog(PackageAccountHomeModel? packageAccount) async {
    bool isRoadmap = packageAccount?.package?.isRoadmap ?? false;
    final result = await NavigationUtil.navigatePage(
      context,
      WelcomePackageScreenPage(
        icon: isRoadmap
            ? R.drawable.ic_package_roadmap
            : R.drawable.ic_package_experience,
        title: isRoadmap
            ? R.string.package_roadmap.tr()
            : R.string.package_experience.tr(),
        subTitle: isRoadmap
            ? R.string.package_roadmap_subtitle.tr()
            : R.string.package_experience_subtitle.tr(),
        onSkip: () async {},
        onNavigateToMyPlan: () async {},
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, String? name,
      String? image, String? icon) {
    return GestureDetector(
      onTap: () async {
        if (index == 0)
          Navigator.pushNamed(context, NavigatorName.detail_blood_sugar);
        else if (index == 1) {
          Navigator.pushNamed(context, NavigatorName.detail_blood_pressure);
        } else if (index == 2) {
          Navigator.pushNamed(context, NavigatorName.detail_bmi);
        } else if (index == 3) {
          Navigator.pushNamed(context, NavigatorName.detail_emotion);
        } else if (index == 4) {
          Navigator.pushNamed(context, NavigatorName.detail_food);
        } else if (index == 5) {
          Navigator.pushNamed(context, NavigatorName.detail_exercrises);
        } else if (index == 6) {
          await NavigationUtil.navigatePage(
              context, CreateGoalPage(AppSettings.smartGoalDayList));
          //    Navigator.pushNamed(context, NavigatorName.my_progress);
        } else if (index == 7) {
          Navigator.pushNamed(context, NavigatorName.detail_hba1c);
        }

        return;
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Text(name ?? '',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))
                .tr(),
          ),
        ),
        if (image?.isNotEmpty != true)
          const SizedBox()
        else
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Image.asset(image ?? R.drawable.ic_error_image)),
        Center(
            child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(icon ?? R.drawable.ic_error_image,
                    width: 58, height: 58)))
      ]),
    );
  }

  Widget _buildBloodSugar(BuildContext context, int index, String? name,
      String? image, String? icon, GloucoseIndexModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_blood_sugar);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? "",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.createDateTime!).isEmpty
                          ? convertToUTC(model.createDateTime!, 'dd/MM/yyyy')
                          : getStringToday(model.createDateTime!),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(roundNumber(model.index!),
                            style: TextStyle(
                                fontFamily: 'Viga',
                                color: toColor(model.color),
                                fontSize: 26,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(model.unit,
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
                if (model.indexChange == 0)
                  const SizedBox(height: 25)
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // NetWorkImageWidget(
                      //     imageUrl: model.icon?.url ?? '',
                      //     width: 25,
                      //     height: 25),
                      // const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                            (model.indexChange! > 0 ? '+' : '') +
                                roundNumber(roundAsFixed(model.indexChange!)),
                            style: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      )
                    ],
                  ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildBloodPressure(BuildContext context, int index, String? name,
      String? image, String? icon, BloodPressureIndexModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_blood_pressure);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.createDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.createDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.createDateTime ?? 0),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                            model.systolic!.round().toString() +
                                '/' +
                                model.diastolic!.round().toString(),
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: 'Viga',
                                color: toColor(model.color),
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(R.string.mm_hg.tr(),
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // NetWorkImageWidget(
                    //     imageUrl: model.icon?.url ?? '', width: 25, height: 25),
                    // const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                          (model.systolicChange! > 0 ? '+' : '') +
                              model.systolicChange!.round().toString() +
                              '/' +
                              (model.diastolicChange! > 0 ? '+' : '') +
                              model.diastolicChange!.round().toString(),
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildWeight(BuildContext context, int index, String? name,
      String? image, String? icon, WeightCardModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_bmi);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.weightDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.weightDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.weightDateTime ?? 0),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(model.weight!.round().toString(),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: toColor(model.weightColorCode),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                          '/ ${model.goalWeight! == 0 ? "--" : model.goalWeight!.round()} kg',
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildEmotion(BuildContext context, int index, String? name,
      String? image, String? icon, EmotionCardModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_emotion);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.emotionDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.emotionDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.emotionDateTime ?? 0),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Column(
                  children: List.generate(
                    model.details!.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(model.details![index].text!,
                              style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          // const SizedBox(width: 4),
                          // NetWorkImageWidget(
                          //     imageUrl: model.details![index].icon!.url ?? '',
                          //     width: 25,
                          //     height: 25),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildFood(BuildContext context, int index, String? name,
      String? image, String? icon, EnergyCardModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_food);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.consumedEnergyDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.consumedEnergyDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.consumedEnergyDateTime ?? 0),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.asset(R.drawable.ic_home_energy,
                        width: 16, height: 16),
                    const SizedBox(width: 4),
                    Text(R.string.da_nap.tr(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400)),
                  ],
                ),
                const SizedBox(height: 0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        model == null
                            ? '0'
                            : roundNumberToInt(model.consumedEnergy ?? 0),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: R.color.black,
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(R.string.kcal.tr(),
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget _buildExcercise(BuildContext context, int index, String? name,
      String? image, String? icon, ExerciseIndexModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_exercrises);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.createDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.createDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.createDateTime ?? 0),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(model.facExercise!.round().toString(),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: toColor(model.color),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    SizedBox(width: 2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            '/${model.targetExercise!.round().toString()} ${R.string.minute}',
                            style: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   getExerciseIcon(
                    //       model.facExercise ?? 0, model.targetExercise ?? 0),
                    //   width: 25,
                    //   height: 25,
                    //   errorBuilder: (context, error, stackTrace) {
                    //     return Container();
                    //   },
                    // ),
                    // const SizedBox(width: 6),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Text(
                          getPercentExercise(model),
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  void _showDialogSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        final deviceWidth = MediaQuery.of(context).size.width;

        return Dialog(
          insetPadding:
              EdgeInsets.all(10), // Adjust padding to fit screen better
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Adjust the radius here
          ),
          child: Container(
            width: deviceWidth * 0.9,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  R.drawable.sync_success,
                  width: deviceWidth * 0.6,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Cập nhật thành công',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: Text(
                    'Tài khoản của bạn đã được đồng bộ và bảo vệ',
                    textAlign: TextAlign.center,
                    style: R.style.normalTextStyle,
                  ),
                ),
                SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 43,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4BB2AB),
                              Color(0xFF01857A),
                              Color(0xFF008479)
                            ])),
                    child: Center(
                      child: Text(
                        'Quay về trang chủ',
                        style: TextStyle(
                          color: R.color.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getExerciseIcon(double targetComplete, double target) {
    if (target == 0) return R.drawable.ic_complete;
    double percent = targetComplete / target * 100;
    if (percent >= 0 && percent <= 33) {
      return R.drawable.ic_not_complete1;
    } else if (percent > 33 && percent <= 66) {
      return R.drawable.ic_not_complete2;
    } else if (percent > 66 && percent <= 100) {
      return R.drawable.ic_complete;
    } else {
      return R.drawable.ic_complete;
    }
  }

  String getProgressIcon(ProcessCardModel model) {
    if (model.exerciseCompeleted! < model.exercise!) {
      return R.drawable.ic_not_complete_exercise;
    } else {
      return R.drawable.ic_complete_exercise;
    }
  }

  Widget buildHbA1C(HbA1CIndexModel model) {
    return Container(
      height: 95,
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(R.string.hba1c.tr(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        getStringToday(model.createDateTime ?? 0).isEmpty
                            ? convertToUTC(
                                model.createDateTime ?? 0, 'dd/MM/yyyy')
                            : getStringToday(model.createDateTime ?? 0),
                        style: TextStyle(
                            color: R.color.captionColorGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w400))
                  ],
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(roundNumber(model.index!),
                              style: TextStyle(
                                  fontFamily: 'Viga',
                                  color: toColor(model.color),
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('%',
                                style: TextStyle(
                                    color: R.color.captionColorGray,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400)),
                          )
                        ],
                      ),
                      if (model.indexChange == 0)
                        const SizedBox()
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // NetWorkImageWidget(
                            //     imageUrl: model.icon?.url ?? '',
                            //     width: 25,
                            //     height: 25),
                            // const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                  (model.indexChange! > 0 ? '+' : '') +
                                      formatNumber(model.indexChange!) +
                                      R.string.ti_le_so_voi_lan_truoc.tr(),
                                  style: TextStyle(
                                      color: R.color.captionColorGray,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            )
                          ],
                        )
                    ])
              ],
            ),
          ),
        )
      ]),
    );
  }

  _buildProgress(BuildContext context, int index, String? name, String? image,
      String? icon, ProcessCardModel model) {
    return GestureDetector(
      onTap: () async {
        if (model.target != null && model.target != 0) {
          if (user!.isUserFree) {
            // await Navigator.pushReplacementNamed(context, NavigatorName.tabbar, arguments: {
            //   'isRedirectFromNotification': true,
            // });
            Observable.instance
                .notifyObservers([], notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
          } else {
            if (user!.isUserHasRoadmap) {
              final result = await NavigationUtil.navigatePage(
                  context,
                  MyProgressPage(
                    isFromHomePage: true,
                  ));
            } else {
              Observable.instance.notifyObservers([],
                  notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
            }
          }
        }
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(R.string.today.tr(),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(model.targetCompeleted!.round().toString(),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: getProgressColor(model),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    SizedBox(width: 2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            '/${model.target!.round().toString()} mục tiêu ngày',
                            style: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w400)),
                      ),
                    ),
                  ],
                ),
                (user!.isUserSubcription || user!.isUserFree)
                    ? Container()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(getProgressIcon(model),
                              width: 25, height: 25),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                getProgressStatus(model),
                                style: TextStyle(
                                    color: R.color.captionColorGray,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                                maxLines: 2,
                              ),
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  getProgressStatus(ProcessCardModel model) {
    if (model.exerciseCompeleted! < model.exercise!) {
      return '${R.string.chua_hoan_thanh.tr()}\n${R.string.smart_goal_exercise_lesson.tr().toLowerCase()}';
    } else {
      return '${R.string.hoan_thanh.tr()}\n${R.string.smart_goal_exercise_lesson.tr().toLowerCase()}';
    }
  }

  Color getProgressColor(ProcessCardModel model) {
    if (model.targetCompeleted! == model.target!) {
      return R.color.greenGradientBottom;
    } else {
      return R.color.red;
    }
  }

  String getPercentExercise(ExerciseIndexModel model) {
    if (model.targetExercise != 0) {
      double percent = model.facExercise! / model.targetExercise! * 100;
      if (percent > 100) percent = 100;
      return percent.round().toString() + '%';
    } else {
      return '0%';
    }
  }

  Widget _buildHbA1C(BuildContext context, int index, String? name,
      String? image, String? icon, HbA1CIndexModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, NavigatorName.detail_hba1c);
      },
      child: Stack(children: [
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600))
                      .tr(),
                  const SizedBox(height: 4),
                  Text(
                      getStringToday(model.createDateTime ?? 0).isEmpty
                          ? convertToUTC(
                              model.createDateTime ?? 0, 'dd/MM/yyyy')
                          : getStringToday(model.createDateTime ?? 0),
                      style: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                ]),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(model.index!.toStringAsFixed(1),
                        style: TextStyle(
                            fontFamily: 'Viga',
                            color: toColor(model.color),
                            fontSize: 26,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('%',
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // NetWorkImageWidget(
                    //     imageUrl: model.icon?.url ?? '', width: 25, height: 25),
                    // const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 2),
                      child: Text(
                          (model.indexChange! > 0
                                  ? ' Tăng '
                                  : model.indexChange! == 0
                                      ? ''
                                      : 'Giảm ') +
                              model.indexChange!.toStringAsFixed(1) +
                              ' %',
                          style: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  Widget buildFoodAndExcercise(HomeModel model) {
    final width = MediaQuery.of(context).size.width - 32;
    final height = width / 1029 * 480;
    final heightApple = 126 * height / 160;

    final heightLA = height * 14 / 160;
    final top = height * 42 / 160;

    return Container(
      height: height,
      width: width,
      child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
        Stack(alignment: AlignmentDirectional.topCenter, children: [
          SizedBox(
              width: heightApple,
              height: heightApple,
              child: CustomPaint(
                  painter: GradientArcPainter(
                progress: 1,
                startColor: R.color.white,
                endColor: R.color.white,
                width: 36,
              ))),
          SizedBox(
              width: heightApple,
              height: heightApple,
              child: CustomPaint(
                  painter: GradientArcPainter(
                progress: model.energyExerciseCard!.value! < 0
                    ? 1
                    : (model.energyExerciseCard!.value! /
                        model.energyExerciseCard!.energyGoal!),
                startColor: toColor(model.energyExerciseCard!.corlorCode)
                    .withOpacity(0.3),
                endColor: toColor(model.energyExerciseCard!.corlorCode),
                width: 36.0,
              ))),
        ]),
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: Center(
              child: Container(
                  height: heightLA,
                  width: heightLA * 4,
                  color: toColor(model.energyExerciseCard!.corlorCode))),
        ),
        Image.asset(R.drawable.bg_apple_home),
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: R.color.transparent,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(R.string.dinh_duong.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            model.energyCard == null
                                ? ''
                                : getStringToday(model.energyCard!
                                                .consumedEnergyDateTime ??
                                            0)
                                        .isEmpty
                                    ? convertToUTC(
                                        model.energyCard!
                                                .consumedEnergyDateTime ??
                                            0,
                                        'dd/MM/yyyy')
                                    : getStringToday(model.energyCard!
                                            .consumedEnergyDateTime ??
                                        0),
                            style: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w400))
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(R.string.van_dong.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            model.exercise!.createDateTime == 0
                                ? ''
                                : getStringToday(
                                            model.exercise!.createDateTime ?? 0)
                                        .isEmpty
                                    ? convertToUTC(
                                        model.exercise!.createDateTime ?? 0,
                                        'dd/MM/yyyy')
                                    : getStringToday(
                                        model.exercise!.createDateTime ?? 0),
                            style: TextStyle(
                                color: R.color.captionColorGray,
                                fontSize: 12,
                                fontWeight: FontWeight.w400))
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(R.drawable.ic_home_energy,
                                width: 20, height: 20),
                            const SizedBox(width: 4),
                            Text(R.string.da_nap.tr(),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                model.energyCard == null
                                    ? '0'
                                    : formatNumber(
                                        model.energyCard!.consumedEnergy),
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    color: R.color.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(R.string.kcal.tr(),
                                  style: TextStyle(
                                      color: R.color.captionColorGray,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(R.drawable.ic_home_excercise,
                                width: 20, height: 20),
                            const SizedBox(width: 4),
                            Text(R.string.tieu_hao.tr(),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(formatNumber(model.exercise!.index),
                                style: TextStyle(
                                    fontFamily: 'Viga',
                                    color: R.color.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(R.string.kcal.tr(),
                                  style: TextStyle(
                                      color: R.color.captionColorGray,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
            top: 16,
            child: Container(
                width: 1, height: 20, color: R.color.color0xffC0C2C5)),
        Stack(alignment: AlignmentDirectional.bottomCenter, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                  (model.energyExerciseCard!.value! < 0 ? '-' : '') +
                      formatNumber(model.energyExerciseCard!.value),
                  style: TextStyle(
                      fontFamily: 'Viga',
                      color: toColor(model.energyExerciseCard!.corlorCode),
                      fontSize: 24,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 3),
              Text('/' + formatNumber(model.energyExerciseCard!.energyGoal),
                  style: TextStyle(
                      color: R.color.captionColorGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
              Text(model.energyExerciseCard!.text!,
                  style: TextStyle(
                      color: R.color.captionColorGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
              SizedBox(height: height * 34 / 160)
            ],
          )
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, NavigatorName.detail_food);
            },
            child: Container(color: R.color.transparent),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, NavigatorName.detail_exercrises);
            },
            child: Container(color: R.color.transparent),
          ))
        ])
      ]),
    );
  }

  Widget buildServiceButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4BB2AB), Color(0xFF01857A), Color(0xFF008479)],
        ),
      ),
      child: MaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
        child: Text(
          R.string.upgrade_account.tr(),
          style: TextStyle(
              color: R.color.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          NavigationUtil.rootNavigatePage(context, const ListServicePage());
        },
      ),
    );
  }
}
