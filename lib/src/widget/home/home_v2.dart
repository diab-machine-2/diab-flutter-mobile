import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/bloc/home/home_bloc.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/home/package_account_home_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/header.dart';
import 'package:medical/src/widget/home/widget/home_lesson.dart';
import 'package:medical/src/widget/home/widget/home_reminder.dart';
import 'package:medical/src/widget/home/widget/home_utilities.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/voucher_popup.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'welcome_package_screen/welcome_package_screen.dart';
import 'package:medical/src/widget/nipro/health_app/blocs/healthApp_bloc.dart';

import 'widget/add_measurement.dart';
import 'widget/home_activity.dart';
import 'widget/home_measurement_summary.dart';
import 'widget/home_news.dart';

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
    _firebaseSetup();
    _initHealthApp();
  }

  void _initHealthApp() async {
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

  Future _firebaseSetup() async {
    await TrackingManager.analytics
        .logScreenView(screenName: "home", screenClass: "HomeController");
    AppSettings.currentScreenName = 'home';
  }

  @override
  void update(Observable observable, String? notifyName, Map<dynamic, dynamic>? map) async {
    if (notifyName == 'BloodPressure_change_data') {
      _refresh();
      _checkScreen(NavigatorName.detail_blood_pressure);
    }
    if (notifyName == 'glucose_change_data') {
      _refresh();
      _checkScreen(NavigatorName.detail_blood_sugar, map: map);
    }
    if (notifyName == 'Weight_change_data') {
      _refresh();
      _checkScreen(NavigatorName.detail_bmi);
    }
    if (notifyName == 'Emotion_change_data') {
      _refresh();
      _checkScreen(NavigatorName.detail_emotion);
    }
    if (notifyName == 'active_change_data') {
      _refresh();
      _checkScreen(NavigatorName.detail_exercrises);
    }
    if (notifyName == 'food_change_data') {
      _refresh();
      // checkScreen(NavigatorName.detail_food);
    }
    if (notifyName == 'hba1c_change_data') {
      _refresh();
      _checkScreen(NavigatorName.detail_hba1c);
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

  void _checkScreen(String routeName, {Map<dynamic, dynamic>? map}) {
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
          HomeLoaded? stateLoaded;
          if (state is HomeLoaded) {
            model = state.model;
            stateLoaded = state;
            if (false == model?.packageAccount?.isDisplayedWelcome) {
              if (AppSettings.isDisplayedWelcome == false) {
                Future.delayed(Duration.zero, () async {
                  _showWelcomeDialog(model?.packageAccount);
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
                            onAddMeasurement: () => _showAddMeasurement(context),
                            onHealthProfile: () {},
                            onMeasurement: (routeName, args) {
                              if (routeName != null) {
                                Navigator.pushNamed(context, routeName, arguments: args);
                              }
                            },
                          ),

                          const SizedBox(height: 16.0),

                          // Activities
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeActivity(
                              activities: stateLoaded?.activities ?? [],
                              expanded: _isActivityExpanded,
                              onExpand: () {
                                setState(() {
                                  _isActivityExpanded = true;
                                });
                              },
                              onCollapse: () {
                                setState(() {
                                  _isActivityExpanded = false;
                                });
                              },
                              onAddActivity: () {
                                Navigator.pushNamed(context, NavigatorName.goal_setting);
                              },
                              onViewMore: () {
                                Observable.instance
                                    .notifyObservers([], notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
                              },
                              onActivityTap: (activity) =>
                                  _onSelectActivity(activity.type, activity.id),
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Reminder
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeReminder(
                              reminders: stateLoaded?.reminders ?? [],
                              onAdd: () {
                                Navigator.pushNamed(context, NavigatorName.add_reminder,
                                    arguments: {'type': 'input'});
                              },
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Utilities
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeUtilities(
                              utilities: stateLoaded?.utilities ?? [],
                              onNavigate: (routeName) {
                                // case show all utilities
                                if (routeName == NavigatorName.utilities) {
                                  final utilities = BlocProvider.of<HomeBloc>(context)
                                      .getAllUtilities(full: true);
                                  Navigator.pushNamed(context, routeName, arguments: utilities);
                                  return;
                                }

                                // other navigate case
                                if (routeName.startsWith("/")) {
                                  Navigator.pushNamed(context, routeName);
                                  return;
                                }

                                // special case for utilities
                                switch (routeName) {
                                  case "share":
                                    String? shareLink = DynamicLinkConfig.instance.shareLink;
                                    if (shareLink != null) {
                                      AppShare.instance.userReferralCode(context, shareLink);
                                    }
                                    return;
                                  default:
                                    break;
                                }
                                Console.log("missing handler for routeName: $routeName");
                                BotToast.showText(text: "Chức năng đang được phát triển");
                              },
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Lessons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeLesson(
                              lessons: stateLoaded?.news ?? [],
                              onLessonTap: (lesson) {
                                if (lesson.enableLink) {
                                  _launchInBrowser(lesson.link!);
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    NavigatorName.news_detail,
                                    arguments: {'id': lesson.id},
                                  );
                                }
                              },
                              onLike: (lesson) {},
                              onComment: (lesson) {},
                              onShare: (lesson) {},
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Popular News
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeNews(
                              items: stateLoaded?.lessons ?? [],
                              onViewMore: () {},
                              onNewsTap: (news) {},
                              onLike: (news) {},
                              onComment: (news) {},
                              onShare: (news) {},
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

  void _showWelcomeDialog(PackageAccountHomeModel? packageAccount) async {
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

  void _showAddMeasurement(BuildContext context) {
    // show add measurement screen
    final measurementIndexes = BlocProvider.of<HomeBloc>(context).getAllMeasurements();
    final dialog = AddMeasurement(
      measurements: measurementIndexes,
      onItemTap: (item) {
        Navigator.pop(context);
        Navigator.pushNamed(context, item.navigatorName, arguments: item.args);
      },
    );
    showModalBottomSheet(
      context: context,
      builder: (context) => dialog,
      isScrollControlled: true,
      elevation: 1,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
    );
  }

  void _launchInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // TODO: More check
  // Copy from lib\src\widget\my_plan_screens\activity_tab\activity_tab\activity_tab_page.dart
  void _onSelectActivity(ScheduleType type, String id) async {
    Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
    switch (type) {
      case ScheduleType.blood_sugar:
        await Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
            arguments: {'type': 'input', 'goalId': id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.blood_pressure:
        await Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
            arguments: {'type': 'input', 'goalId': id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.weight:
        await Navigator.pushNamed(context, NavigatorName.add_bmi,
            arguments: {'type': 'input', 'goalId': id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.emotion:
        await Navigator.pushNamed(context, NavigatorName.add_emo,
            arguments: {'type': 'input', 'goalId': id});
        //    _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.food:
        await NavigationUtil.navigatePage(
          context,
          DailyNutritionPage(type: 'input', id: null, goalId: id),
        );
        //   // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.exercise:
        await Navigator.pushNamed(context, NavigatorName.add_exercrises,
            arguments: {'type': 'input', 'goalId': id});
        // _cubit.refreshData(isRefresh: true);
        break;
      // TODO: Check
      // case ScheduleType.exercise_movement:
      //   if (smartGoal?.exerciseData == null) break;
      //   if (smartGoal?.exerciseData?.exerciseMovementStates == null ||
      //       smartGoal?.state == Const.LESSON_LOCKED) {
      //     _showLockedDialog(
      //       title: R.string.exercise_lesson_locked.tr(),
      //       description: R.string.exercise_lesson_locked_warning.tr(),
      //     );
      //     break;
      //   }
      //   await NavigationUtil.navigatePage(
      //       context, ExerciseDetail(exerciseData: smartGoal?.exerciseData));
      //   _cubit.refreshData(isRefresh: true);
      //   Observable.instance
      //       .notifyObservers([], notifyName: "refresh_exercise_tab");
      //   Observable.instance.notifyObservers([], notifyName: "refresh_home");
      //   break;
      // case ScheduleType.custom:
      //   _showCustomGoalPopup(
      //     smartGoal: smartGoal,
      //   );
      //   break;
      // case ScheduleType.book_1_1:
      //   _showCoachingPopup(smartGoal);
      //   break;
      // case ScheduleType.book_1_n:
      //   _showCoachingPopup(smartGoal);
      //   break;
      // case ScheduleType.survey:
      //   //_showCoachingPopup();
      //   _showSurveyPopup(survey: smartGoal);
      //   break;
      // case ScheduleType.lesson:
      //   final LessonSectionListResponseData? lessonDetail =
      //       smartGoal?.lessonData;
      //   if (smartGoal?.state == Const.LESSON_LOCKED) {
      //     // if (lessonDetail?.learningStatus == null || lessonDetail?.learningStatus == Const.LESSON_LOCKED) {
      //     _showLockedDialog(
      //         title: R.string.lesson_locked.tr(),
      //         description: R.string.lesson_locked_warning.tr());
      //     return;
      //   }
      //   await NavigationUtil.navigatePage(
      //       context,
      //       LessonDetailPage(
      //         lessonType: lessonDetail?.type,
      //         lessonId: lessonDetail?.id ?? '',
      //         onComplete: (String, int) {},
      //       ));
      //   _cubit.refreshData(isRefresh: true);
      //   Observable.instance
      //       .notifyObservers([], notifyName: "refresh_lesson_tab");
      //   Observable.instance.notifyObservers([], notifyName: "refresh_home");
      //   break;
      // case ScheduleType.io_evaluate:
      //   _showCoachingPopup(smartGoal);
      //   break;
      // case ScheduleType.update_profile:
      //   await Navigator.pushNamed(context, NavigatorName.profile_info,
      //       arguments: {
      //         'id': smartGoal?.state != 1 ? smartGoal?.id : null,
      //       });
      //   break;
      // case ScheduleType.output_assessment:
      //   _showCoachingPopup(smartGoal);
      //   break;
      default:
        break;
    }
  }
}
