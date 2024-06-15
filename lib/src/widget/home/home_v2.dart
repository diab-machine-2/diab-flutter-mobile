import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/bloc/home/home_bloc.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/home/package_account_home_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/widget/energy_chart.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/header.dart';
import 'package:medical/src/widget/home/widget/home_lesson.dart';
import 'package:medical/src/widget/home/widget/home_reminder.dart';
import 'package:medical/src/widget/home/widget/home_utilities.dart';
import 'package:medical/src/widget/list_service/list_service_page.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/voucher_popup.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';
import 'welcome_package_screen/welcome_package_screen.dart';
import 'package:medical/src/widget/nipro/health_app/blocs/healthApp_bloc.dart';

import 'widget/home_activity.dart';
import 'widget/measurement_summary.dart';

class HomeController extends StatefulWidget {
  const HomeController({this.sharedCode});
  final String? sharedCode;

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> with Observer {
  final GlobalKey<CourseSuggestState> _courseSuggestKey = GlobalKey();

  late BuildContext currentContext;

  int page = 1;
  bool isLoading = false;

  var user = AppSettings.userInfo;
  var popupStore = PopupStore;
  HomeModel? model;
  String _urlPopup = '';

  bool _isActivityExpanded = false;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);

    if (user?.isShare == true) {
      ShareProfilePopup.instance
          .onHasSharedCode(requestFromDoctor: true, code: user?.shareRefCode ?? '');
    }
    firebaseSetup();
    initHealthApp();
  }

  void initHealthApp() async {
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
      await _chooseUrl();
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
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) async {
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
    if (notifyName == 'syncing_heath_app' && AppSettings.currentScreenName != 'welcome') {
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

  void getData() async {
    final result = await AppSettings.getHome();
    if (result != null) {
      setState(() {
        model = result;
      });
    }
  }

  Future<String> _chooseUrl() async {
    try {
      var id = await UserClient().fetchPopupImage();
      if (Const.ENVIRONMENT_DEFAULT == 'product') {
        _urlPopup = Uri.https(Const.DOMAIN, 'App/Image/$id').toString();
      } else {
        _urlPopup = Uri.https(Const.DOMAIN_STAGING, 'App/Image/$id').toString();
      }
      return _urlPopup;
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      const String POPUP_IMAGE_URL_BACKUP =
          'https://api.staging.diab.com.vn/App/Image/9ae088a5-8f56-4b02-7210-08dbce82cedd';
      _urlPopup = POPUP_IMAGE_URL_BACKUP;
    }
    return _urlPopup;
  }

  void checkScreen(String routeName, {Map<dynamic, dynamic>? map}) {
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
    _courseSuggestKey.currentState?.loadData();
    page = 1;
    BlocProvider.of<HomeBloc>(currentContext).add(FetchHome());
    user = await UserClient().fetchUser();
    AppSettings.isReloadCurrentUserInfo = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(),
        child: BlocBuilder<HomeBloc, HomeState>(builder: (BuildContext context, HomeState state) {
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
              backgroundColor: const Color(0xFFE8F3F3),
              body: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment(0.0, 2.0),
                        colors: [
                          Color(0xFF008479),
                          Color(0xFF4BB2AB),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: HomeHeader(sharedCode: widget.sharedCode),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Summary
                          MeasurementSummary(
                            inlineMeasurements: model?.inlineMeasurements ?? [],
                            measurements: model?.measurements ?? [],
                            onAddMeasurement: () {},
                            onHealthProfile: () {},
                          ),

                          const SizedBox(height: 16.0),

                          // Activities
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeActivity(
                              activities: model?.activities ?? [],
                              expanded: _isActivityExpanded,
                              onViewMore: () {
                                setState(() {
                                  _isActivityExpanded = true;
                                });
                              },
                              onViewLess: () {
                                setState(() {
                                  _isActivityExpanded = false;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Activities
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeReminder(
                              reminders: model?.reminders ?? [],
                              onAdd: () {},
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Utilities
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeUtilities(
                              utilities: model?.utilities ?? [],
                              onNavigate: (routeName) {
                                // Navigator.pushNamed(context, routeName);
                              },
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Utilities
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeLesson(
                              lessons: model?.lessons ?? [],
                              onLessonTap: (lesson) {},
                              onLike: (lesson) {},
                              onComment: (lesson) {},
                              onShare: (lesson) {},
                            ),
                          ),

                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  void showWelcomeDialog(PackageAccountHomeModel? packageAccount) async {
    bool isRoadmap = packageAccount?.package?.isRoadmap ?? false;
    final _ = await NavigationUtil.navigatePage(
      context,
      WelcomePackageScreenPage(
        icon: isRoadmap ? R.drawable.ic_package_roadmap : R.drawable.ic_package_experience,
        title: isRoadmap ? R.string.package_roadmap.tr() : R.string.package_experience.tr(),
        subTitle: isRoadmap
            ? R.string.package_roadmap_subtitle.tr()
            : R.string.package_experience_subtitle.tr(),
        onSkip: () async {},
        onNavigateToMyPlan: () async {},
      ),
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
            decoration:
                BoxDecoration(color: R.color.white, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(R.string.hba1c.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        getStringToday(model.createDateTime ?? 0).isEmpty
                            ? convertToUTC(model.createDateTime ?? 0, 'dd/MM/yyyy')
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
                    : (model.energyExerciseCard!.value! / model.energyExerciseCard!.energyGoal!),
                startColor: toColor(model.energyExerciseCard!.corlorCode).withOpacity(0.3),
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
            decoration:
                BoxDecoration(color: R.color.transparent, borderRadius: BorderRadius.circular(10)),
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            model.energyCard == null
                                ? ''
                                : getStringToday(model.energyCard!.consumedEnergyDateTime ?? 0)
                                        .isEmpty
                                    ? convertToUTC(
                                        model.energyCard!.consumedEnergyDateTime ?? 0, 'dd/MM/yyyy')
                                    : getStringToday(model.energyCard!.consumedEnergyDateTime ?? 0),
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
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                            model.exercise!.createDateTime == 0
                                ? ''
                                : getStringToday(model.exercise!.createDateTime ?? 0).isEmpty
                                    ? convertToUTC(
                                        model.exercise!.createDateTime ?? 0, 'dd/MM/yyyy')
                                    : getStringToday(model.exercise!.createDateTime ?? 0),
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
                            Image.asset(R.drawable.ic_home_energy, width: 20, height: 20),
                            const SizedBox(width: 4),
                            Text(R.string.da_nap.tr(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                model.energyCard == null
                                    ? '0'
                                    : formatNumber(model.energyCard!.consumedEnergy),
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
                            Image.asset(R.drawable.ic_home_excercise, width: 20, height: 20),
                            const SizedBox(width: 4),
                            Text(R.string.tieu_hao.tr(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
        Positioned(top: 16, child: Container(width: 1, height: 20, color: R.color.color0xffC0C2C5)),
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
                      color: R.color.captionColorGray, fontSize: 11, fontWeight: FontWeight.w400)),
              Text(model.energyExerciseCard!.text!,
                  style: TextStyle(
                      color: R.color.captionColorGray, fontSize: 11, fontWeight: FontWeight.w400)),
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
          style: TextStyle(color: R.color.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          NavigationUtil.rootNavigatePage(context, const ListServicePage());
        },
      ),
    );
  }
}
