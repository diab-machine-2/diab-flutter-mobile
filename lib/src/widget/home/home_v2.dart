import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/bloc/home/home_bloc.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/home/package_account_home_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/complete_smart_goal_request.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/blood_sugar_functions.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/widgets/custom_height_picker.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/widgets/custome_weight_picker.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/HbA1C/widget/course_suggest.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/widget/header.dart';
import 'package:medical/src/widget/home/widget/home_lesson.dart';
import 'package:medical/src/widget/home/widget/home_reminder.dart';
import 'package:medical/src/widget/home/widget/home_utilities.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/my_plan_screens/exercise_tab/exercise_detail/exercise_detail_page.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
import 'package:medical/src/widget/profile/user_info.dart';
import 'package:medical/src/widget/survey_screens/introduce_survey/introduce_survey.dart';
import 'package:medical/src/widget/tabbar/tabbar_v2.dart';
import 'package:medical/src/widget/voucher/presentation/widgets/voucher_popup.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../service/rating_service.dart';
import 'welcome_package_screen/welcome_package_screen.dart';
import 'package:medical/src/widget/nipro/health_app/blocs/healthApp_bloc.dart';

import 'widget/add_measurement.dart';
import 'widget/home_activity.dart';
import 'widget/home_measurement_summary.dart';
import 'widget/home_news.dart';
import 'widget/sync_modal.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key, this.sharedCode});
  final String? sharedCode;

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController>
    with Observer, AutomaticKeepAliveClientMixin<HomeController> {
  final GlobalKey<CourseSuggestState> _courseSuggestKey = GlobalKey();
  final HomeBloc _homeBloc = HomeBloc();
  final String _screenName = "home";

  int page = 1;
  bool _isDisplayedWelcome = false;

  var user = AppSettings.userInfo;
  var popupStore = PopupStore;
  HomeModel? model;
  String _urlPopup = '';

  bool _isActivityExpanded = false;
  bool _isReminderExpanded = false;

  // trigger reload when complete lesson
  bool _isReloadLesson = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);

    if (user?.isShare == true) {
      ShareProfilePopup.instance.onHasSharedCode(
          requestFromDoctor: true, code: user?.shareRefCode ?? '');
    }
    _firebaseSetup();
    _initHealthApp();
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  void _initHealthApp() async {
    await AppSettings.setIsSyncing(false);
    final String? lessonId = DynamicLinkConfig.instance.lessonId;
    final String? meetingId = BranchioLinkConfig.instance.meetingId;
    final String? activityId = DynamicLinkConfig.instance.activityId;
    _checkShowRating();

    Future.delayed(Duration.zero, () async {
      String? username = AppSettings.userInfo!.userName;
      String? firstLinked = AppSettings.userInfo!.firstLinkedAccount;
      bool isFirstDownload = await AppSettings.getIsFirstDownload();
      bool isZaloAccountAndNotSynchronized = firstLinked != null &&
          firstLinked.toLowerCase() == "zalo" &&
          username != null &&
          !username.startsWith("+84");
      if (isZaloAccountAndNotSynchronized && isFirstDownload) {
        _showModalSyncAccount();
      }
      if (AppSettings.isSyncSuccess) {
        _showDialogSuccess();
        AppSettings.isSyncSuccess = false;
      }
    });

    if (lessonId == null && meetingId == null && activityId == null) {
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

  Future<void> _checkShowRating() async {
    int turn = await AppSettings.numberOfOpenHome();
    if (turn > 3) return;
    if (turn > 0 && turn <= 3) RatingService.showRating();
    await AppSettings.increaseNumberOfOpenHome();
  }

  void _firebaseSetup() async {
    await TrackingManager.analytics
        .logScreenView(screenName: "home", screenClass: "HomeController");
    AppSettings.currentScreenName = 'home';
  }

  void _showModalSyncAccount() {
    try {
      SyncAccountModal.show(
        context,
        onTapSync: () async {
          Navigator.pushNamed(context, NavigatorName.sync_screen);
          await TrackingManager.analytics.logEvent(
            name: 'zalo_select_sync',
            parameters: {
              "screen_name": "home",
              'cta_button_name': 'cta_zalo_sync_yes',
            },
          );
        },
        onTapCancel: () async {
          Navigator.pop(context);
          await AppSettings.setIsFirstDownload(false);
          try {
            await TrackingManager.analytics.logEvent(
              name: 'zalo_select_sync',
              parameters: {
                "screen_name": "home",
                'cta_button_name': 'cta_zalo_sync_no',
              },
            );
          } catch (e) {
            print(e);
          }
        },
      );
    } catch (e) {
      print("key diab => " + e.toString());
    }
  }

  @override
  void update(Observable observable, String? notifyName,
      Map<dynamic, dynamic>? map) async {
    // case back from lesson tab when complete recommend lesson
    if (_isReloadLesson && notifyName == 'back_to_home') {
      _homeBloc.add(HomeFetchActivityEvent());
      _isReloadLesson = false;
      return;
    }
    if (notifyName == 'refresh_home_activity') {
      _homeBloc.add(HomeFetchActivityEvent());
      return;
    }
    if (notifyName == 'schedule_change' || notifyName == 'user_info_change') {
      _refresh();
      return;
    }
    if (notifyName == 'refresh_home') {
      _refresh();
      return;
    }
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
    // After add exercise
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
    _homeBloc.add(FetchHome());
    return true;
  }

  Future<bool> _pullToRefresh() async {
    _courseSuggestKey.currentState?.loadData();
    page = 1;
    // _homeBloc.add(FetchHome());
    user = await UserClient().fetchUser();
    AppSettings.isReloadCurrentUserInfo = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<HomeBloc>.value(
        value: _homeBloc,
        child: BlocBuilder<HomeBloc, HomeState>(
            builder: (BuildContext context, HomeState state) {
          if (state is HomeInitial) {
            // Skip first load, just after user change info then load (Logged in state)
            // BlocProvider.of<HomeBloc>(context).add(FetchHome());
          }
          if (state is HomeLoading) {
            model = state.model;
          }
          HomeLoaded? stateLoaded;
          if (state is HomeLoaded) {
            model = state.model;
            stateLoaded = state;
            if (false == model?.packageAccount?.isDisplayedWelcome && !_isDisplayedWelcome) {
              _isDisplayedWelcome = true;
              if (AppSettings.isDisplayedWelcome == false) {
                Future.delayed(Duration.zero, () async {
                  _showWelcomeDialog(model?.packageAccount);
                });
              } else {}
            }
          }

          Widget reminderW = HomeReminder(
            reminders: stateLoaded?.reminders ?? [],
            loading: stateLoaded?.reminderLoading ?? false,
            onAdd: () {
              Navigator.pushNamed(context, NavigatorName.add_reminder,
                  arguments: {'type': 'input'});
            },
            onItemTap: (reminder) {
              Navigator.pushNamed(context, NavigatorName.add_reminder,
                  arguments: {'type': 'update', 'id': reminder.id});
            },
            expanded: _isReminderExpanded,
            onExpand: () {
              setState(() {
                _isReminderExpanded = true;
              });
            },
            onCollapse: () {
              setState(() {
                _isReminderExpanded = false;
              });
            },
          );

          Widget utilitiesW = HomeUtilities(
            utilities: stateLoaded?.utilities ?? [],
            onTap: (utility) {
              // track event
              final String eventName = "home_select_utility";
              TrackingManager.trackEvent(eventName, _screenName, params: {
                "object_title": utility.title,
              });

              final routeName = utility.navigatorName;
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
          );

          bool needSwapReminderAndUtilities =
              stateLoaded?.activityLoading == false &&
                  !(stateLoaded?.reminders?.isNotEmpty == true);

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
                            onAddMeasurement: () =>
                                _showAddMeasurement(context),
                            onHealthProfile: () {},
                            onMeasurement: (routeName, args, title) {
                              // track event
                              final String eventName = "home_select_kpi";
                              TrackingManager.trackEvent(eventName, _screenName, params: {
                                "object_title": title,
                              });
                              // case require weight input
                              if (_checkWeightInputDialog(routeName,
                                      args: args) ==
                                  false) {
                                return;
                              }
                              // case input glucose
                              if (_showGlucoseAddBottomSheet(routeName) ==
                                  false) {
                                return;
                              }
                              // others
                              if (routeName != null) {
                                Navigator.pushNamed(context, routeName,
                                    arguments: args);
                              }
                            },
                            loading: stateLoaded?.measurementLoading ?? true,
                          ),

                          const SizedBox(height: 16.0),

                          // Activities
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeActivity(
                              activities: stateLoaded?.activities ?? [],
                              expanded: _isActivityExpanded,
                              loading: stateLoaded?.activityLoading ?? false,
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
                                Navigator.pushNamed(
                                    context, NavigatorName.add_goal);
                              },
                              onViewMore: _viewMoreActivity,
                              onActivityTap: (activity) => _onSelectGoal(
                                  activity.type,
                                  smartGoal: activity.smartGoal,
                                  title: activity.title),
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Reminder >< Utilities
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: needSwapReminderAndUtilities
                                ? utilitiesW
                                : reminderW,
                          ),

                          const SizedBox(height: 16.0),

                          // Utilities >< Reminder
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: needSwapReminderAndUtilities
                                ? reminderW
                                : utilitiesW,
                          ),

                          const SizedBox(height: 16.0),

                          // Lessons
                          if (stateLoaded?.lessons != null &&
                              stateLoaded!.lessons!.isNotEmpty) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: HomeLesson(
                                lessons: stateLoaded.lessons!,
                                onLessonTap: (lesson) async {
                                  ActivityListTracking.clickLessonItem(
                                    objectId: lesson.id,
                                    objectIndex:
                                        stateLoaded!.lessons!.indexOf(lesson),
                                    objectTitle: lesson.name,
                                  );

                                  await NavigationUtil.navigatePage(
                                    context,
                                    LessonDetailPage(
                                      lessonType: lesson.type,
                                      lessonId: lesson.id,
                                      onComplete: (_, __) {},
                                    ),
                                  );
                                },
                                onLike: (lesson) {},
                                onComment: (lesson) {},
                                onShare: (lesson) {
                                  _homeBloc.shareLesson(lesson.id, context);
                                },
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],

                          // Popular News
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: HomeNews(
                              items: stateLoaded?.news ?? [],
                              onViewMore: () {},
                              onNewsTap: (news) {
                                if (news.enableLink) {
                                  _launchInBrowser(news.link!);
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    NavigatorName.news_detail,
                                    arguments: {'id': news.id},
                                  );
                                }
                              },
                              onLike: (news) {},
                              onComment: (news) {},
                              onShare: (news) {},
                            ),
                          ),

                          const SizedBox(height: 32.0),

                          // Extend tabbar
                          const SizedBox(height: 56.0),
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

  // Button "Thêm chỉ số"
  void _showAddMeasurement(BuildContext context) {
    // track event
    final String eventName = "home_add_kpi";
    TrackingManager.trackEvent(eventName, _screenName);
    // show add measurement screen
    final measurementIndexes =
        BlocProvider.of<HomeBloc>(context).getAllMeasurements();
    final dialog = AddMeasurement(
      measurements: measurementIndexes,
      onItemTap: (item) {
        // track event
        final String eventName = "home_add_kpi_item";
        TrackingManager.trackEvent(eventName, _screenName, params: {
          "object_title": item.title,
        });
        Navigator.pop(context);
        // case require weight input
        if (_checkWeightInputDialog(item.navigatorName, args: item.args) ==
            false) {
          return;
        }
        // case input glucose
        if (_showGlucoseAddBottomSheet(item.navigatorName) == false) {
          return;
        }
        // others
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

  // return allow next route
  bool _checkWeightInputDialog(String? routeName, {dynamic args}) {
    if (routeName == NavigatorName.add_exercrises) {
      if (AppSettings.userInfo?.weight == null ||
          AppSettings.userInfo!.weight == 0) {
        showPopupWeight(nextRoute: routeName, args: args);
        return false;
      }
    }
    return true;
  }

  // return allow next route
  bool _showGlucoseAddBottomSheet(String? routeName) {
    if (routeName == NavigatorName.add_blood_sugar_new ||
        routeName == NavigatorName.add_blood_sugar) {
      if (AppSettings.isUS) {
        return true;
      }
      BloodSugarFunctions.showModalAddData(context);
      return false;
    }
    return true;
  }

  void _launchInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // #region Copy from lib\src\widget\my_plan_screens\activity_tab\activity_tab\activity_tab_page.dart
  // Copy from lib\src\widget\my_plan_screens\activity_tab\activity_tab\activity_tab_page.dart
  Future<void> _onSelectGoal(ScheduleType type,
      {SmartGoalList? smartGoal, required String title}) async {
    // track event
    final String eventName = "home_select_activity";
    TrackingManager.trackEvent(eventName, _screenName, params: {
      "object_title": title,
    });
    Observable.instance.notifyObservers([], notifyName: Const.HIDE_OVERLAY_KEY);
    _isReloadLesson = type == ScheduleType.lesson_recommend;
    switch (type) {
      case ScheduleType.blood_sugar:
      case ScheduleType.blood_sugar_recommend:
        _showGlucoseAddBottomSheet(NavigatorName.add_blood_sugar_new);
        // await Navigator.pushNamed(context, NavigatorName.add_blood_sugar_new,
        //     arguments: {'type': 'input', 'goalId': smartGoal?.id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.blood_pressure:
      case ScheduleType.blood_pressure_recommend:
        await Navigator.pushNamed(context, NavigatorName.add_blood_pressure,
            arguments: {'type': 'input', 'goalId': smartGoal?.id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.weight_recommend:
        _showInputWeightDialog();
        break;
      case ScheduleType.height_recommend:
        _showInputHeightDialog();
        break;
      case ScheduleType.weight:
        await Navigator.pushNamed(context, NavigatorName.add_bmi,
            arguments: {'type': 'input', 'goalId': smartGoal?.id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.emotion:
        // await Navigator.pushNamed(context, NavigatorName.add_emo,
        //     arguments: {'type': 'input', 'goalId': smartGoal?.id});
        //    _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.food:
      case ScheduleType.food_recommend:
        await NavigationUtil.navigatePage(
          context,
          DailyNutritionPage(type: 'input', id: null, goalId: smartGoal?.id),
        );
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.exercise:
      case ScheduleType.exercise_recommend:
        await Navigator.pushNamed(context, NavigatorName.add_exercrises,
            arguments: {'type': 'input', 'goalId': smartGoal?.id});
        // _cubit.refreshData(isRefresh: true);
        break;
      case ScheduleType.exercise_movement:
        if (smartGoal?.exerciseData == null) break;
        if (smartGoal?.exerciseData?.exerciseMovementStates == null ||
            smartGoal?.state == Const.LESSON_LOCKED) {
          _showLockedDialog(
            title: R.string.exercise_lesson_locked.tr(),
            description: R.string.exercise_lesson_locked_warning.tr(),
          );
          break;
        }
        await NavigationUtil.navigatePage(
            context, ExerciseDetail(exerciseData: smartGoal?.exerciseData));
        // _cubit.refreshData(isRefresh: true);
        Observable.instance
            .notifyObservers([], notifyName: "refresh_exercise_tab");
        Observable.instance.notifyObservers([], notifyName: "refresh_home");
        break;
      case ScheduleType.custom:
        _showCustomGoalPopup(
          smartGoal: smartGoal,
        );
        break;
      case ScheduleType.book_1_1:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.book_1_n:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.survey:
        //_showCoachingPopup();
        _showSurveyPopup(survey: smartGoal);
        break;
      case ScheduleType.lesson_recommend:
        Observable.instance
            .notifyObservers([], notifyName: Const.NAVIGATE_TO_LESSON_TAB);
        break;
      case ScheduleType.lesson:
        final LessonSectionListResponseData? lessonDetail =
            smartGoal?.lessonData;
        if (smartGoal?.state == Const.LESSON_LOCKED) {
          // if (lessonDetail?.learningStatus == null || lessonDetail?.learningStatus == Const.LESSON_LOCKED) {
          _showLockedDialog(
              title: R.string.lesson_locked.tr(),
              description: R.string.lesson_locked_warning.tr());
          return;
        }
        await NavigationUtil.navigatePage(
            context,
            LessonDetailPage(
              lessonType: lessonDetail?.type,
              lessonId: lessonDetail?.id ?? '',
              onComplete: (String, int) {},
            ));
        // _cubit.refreshData(isRefresh: true);
        Observable.instance
            .notifyObservers([], notifyName: "refresh_lesson_tab");
        Observable.instance.notifyObservers([], notifyName: "refresh_home");
        break;
      case ScheduleType.io_evaluate:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.update_profile:
      case ScheduleType.update_profile_recommend:
        await Navigator.pushNamed(context, NavigatorName.profile_info,
            arguments: {
              'id': smartGoal?.state != 1 ? smartGoal?.id : null,
            });
        break;
      case ScheduleType.output_assessment:
        _showCoachingPopup(smartGoal);
        break;
      case ScheduleType.hba1c_recommend:
        await Navigator.pushNamed(context, NavigatorName.add_hba1c,
            arguments: {'type': 'input'});
        break;
      case ScheduleType.schedule_glucose_recommend:
        await Navigator.pushNamed(context, NavigatorName.schedule_glucose);
        break;
      case ScheduleType.food_menu:
        await Navigator.pushNamed(context, NavigatorName.food_menu);
        break;
      case ScheduleType.goal_setting_recommend:
        await Navigator.pushNamed(context, NavigatorName.goal_setting);
        break;
      case ScheduleType.schedule_recommend:
        await Navigator.pushNamed(context, NavigatorName.reminder);
        break;
      case ScheduleType.peripheral_recommend:
        await Navigator.pushNamed(context, NavigatorName.connect_device_app);
        break;
      case ScheduleType.completed:
        // Do nothing
        break;
    }
  }

  void _viewMoreActivity() {
    Observable.instance
        .notifyObservers([], notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB);
    Observable.instance.notifyObservers([], notifyName: "activity_tab_reload");
  }

  void _showPopup({
    required BuildContext context,
    required Widget child,
    String? buttonTitle,
    VoidCallback? onTap,
    bool isDisableCompleteButton = false,
  }) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => GestureDetector(
        onTap: () {
          NavigationUtil.pop(context);
        },
        child: Scaffold(
          backgroundColor: R.color.transparent,
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          R.color.white,
                          R.color.main_6,
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          child,
                          Visibility(
                            visible: onTap != null,
                            child: SizedBox(height: 16),
                          ),
                          Visibility(
                            visible: onTap != null,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: ButtonWidget(
                                backgroundColor: isDisableCompleteButton
                                    ? R.color.white
                                    : R.color.accentColor,
                                title: buttonTitle ?? '',
                                textSize: 14,
                                onPressed:
                                    isDisableCompleteButton ? null : onTap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 4,
                      right: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: 24,
                        onPressed: () {
                          NavigationUtil.pop(context);
                        },
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showCustomGoalPopup({SmartGoalList? smartGoal}) {
    String description = '';
    if (smartGoal?.executeType == 0) {
      description = 'Thời gian: ${smartGoal?.executeDayTimes} phút';
    } else if (smartGoal?.executeType == 1) {
      description = 'Số lần: ${smartGoal?.executeDayTimes} lần';
    }
    return _showPopup(
      context: context,
      buttonTitle: R.string.complete_lesson.tr(),
      isDisableCompleteButton: DateUtil.isAfter(
              smartGoal?.appointmentDate, AppSettings.currentDateTime) ??
          false,
      onTap: smartGoal?.isCompleted == true
          ? null
          : () {
              _completeSmartGoal(
                smartGoal?.id,
                smartGoal?.executeDayTimes,
                smartGoal?.type,
                smartGoal?.appointmentDate,
              );
              NavigationUtil.pop(context);
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
            child: Image.asset(R.drawable.img_custom_goal),
          ),
          Text(
            smartGoal?.name ?? '',
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
                color: R.color.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  _showSurveyPopup({SmartGoalList? survey}) {
    NavigationUtil.navigatePage(context, IntroduceSurveyPage(survey: survey));
    // return _showPopup(
    //   context: context,
    //   buttonTitle: R.string.start_survey.tr(),
    //   onTap: () {
    //     NavigationUtil.pop(context);
    //     NavigationUtil.navigatePage(context, IntroduceSurveyPage(survey: survey));
    //   },
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 57, vertical: 10),
    //         child: Image.asset(R.drawable.img_survey_4),
    //       ),
    //       Text(
    //         'Khảo sát',
    //         style: TextStyle(color: R.color.textDark, fontSize: 20, fontWeight: FontWeight.w700),
    //       ),
    //       const SizedBox(height: 6),
    //       Text(
    //         'Tìm hiểu về thói quen sinh hoạt',
    //         style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w400),
    //       ),
    //     ],
    //   ),
    // );
  }

  _showCoachingPopup(SmartGoalList? smartGoal) {
    if (smartGoal?.calendar == null) return;
    return _showPopup(
      context: context,
      buttonTitle: R.string.join.tr(),
      isDisableCompleteButton: !DateUtil.isSameDay(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          smartGoal?.appointmentDate),
      onTap: () async {
        Navigator.pop(context);
        if (smartGoal?.calendar?.meetingLink != null) {
          PermissionStatus statusMicrophone =
              await Permission.microphone.status;
          if (statusMicrophone.isDenied) {
            await Permission.microphone.request();
          }
          PermissionStatus statusCamera = await Permission.camera.request();
          Console.log('PHUONG statusCamera', statusCamera);
          if (statusCamera.isDenied) {
            await Permission.camera.request();
          }
          Navigator.pushNamed(context, NavigatorName.zoom, arguments: {
            'id': smartGoal?.calendarId,
            'isCompleted': smartGoal?.isCompleted,
          });
          //   await canLaunch(smartGoal!.calendar!.meetingLink!)
          //       ? await launch(smartGoal.calendar!.meetingLink!,
          //           forceSafariVC: false, forceWebView: false)
          //       : throw 'Could not launch ${smartGoal.calendar!.meetingLink!}';
        } else {
          // await _cubit.markCompletedCalendar(smartGoal?.calendarId);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${getWeekDay(smartGoal?.appointmentDate ?? 0)}, ${convertToUTC(smartGoal?.appointmentDate ?? 0, "dd/MM/yyyy")}",
            style: TextStyle(
                color: R.color.main_1,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          if ((smartGoal?.description != null &&
              smartGoal!.description!.isNotEmpty))
            Text(
              smartGoal.description ?? "",
              style: TextStyle(
                  color: R.color.main_1,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          if (smartGoal?.description != null &&
              smartGoal!.description!.isNotEmpty)
            const SizedBox(height: 12),
          if ((smartGoal?.calendar?.goal != null &&
              smartGoal!.calendar!.goal!.isNotEmpty))
            Text(
              smartGoal.calendar?.goal ?? "",
              style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          if ((smartGoal?.calendar?.goal != null &&
              smartGoal!.calendar!.goal!.isNotEmpty))
            const SizedBox(height: 16),
          if (smartGoal?.calendar?.performer != null)
            Row(
              children: [
                NetWorkImageWidget(
                    imageUrl: smartGoal!.calendar!.performer!.avatar?.url ?? "",
                    width: 44,
                    height: 44),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach',
                      style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      smartGoal.calendar!.performer!.fullName ?? "",
                      style: TextStyle(
                          color: R.color.main_1,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }

  void _showLockedDialog({required String title, required String description}) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      barrierDismissible: true,
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: GestureDetector(
            child: Container(
              width: 344,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    R.color.white,
                    R.color.main_6,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(84.w, 0, 84.w, 20),
                    child: Image.asset(
                      R.drawable.img_lesson_locked,
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: R.style.normalTextStyle,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ButtonWidget(
                      height: 43,
                      title: R.string.agree.tr(),
                      onPressed: () {
                        NavigationUtil.pop(context);
                      },
                      textSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDialogConfirmCreateGoal(
      BuildContext context, String title, VoidCallback onContinue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Stack(children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 36.0, bottom: 10, left: 16, right: 16),
                      child: Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        color: R.color.grayBorder),
                                    child: Center(
                                      child: Text(R.string.back.tr(),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    )),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  onContinue();
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: R.color.mainColor,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(R.string.tiep_tuc.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                    icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ]));
      },
    );
  }
  // #endregion

  Future<void> _completeSmartGoal(String? smartGoalId, int? executeDayTimes,
      int? type, int? appointmentDate) async {
    if (smartGoalId == null) return;
    try {
      BotToast.showLoading();
      final CompleteSmartGoalRequest request = CompleteSmartGoalRequest(
          id: smartGoalId,
          executeTimes: executeDayTimes,
          type: type,
          appointmentDate: appointmentDate);
      final apiResult = await AppRepository().completeSmartGoal(request);
      apiResult.when(success: (response) {
        _refresh();
      }, failure: (error) {
        TrackingManager.recordError(error, null);
      });
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      BotToast.closeAllLoading();
    }
  }

  void _showInputHeightDialog() {
    showDialog(
      //   barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      barrierDismissible: true,
      builder: (_) => CustomNumPicker(
          callback: (data) {
            if (data == null || data <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_height_must_greater_than_zero.tr());
              return;
            }
            final userInfo = AppSettings.userInfo!;
            ProfileInfoController.updateUserInfo(
              context,
              userInfo.copyWith(
                height: data.toDouble(),
              ),
            );
          },
          title: R.string.enter_height.tr(),
          max: 250,
          numberDefault: (AppSettings.userInfo!.height == null ||
                      AppSettings.userInfo!.height == 0
                  ? 150
                  : AppSettings.userInfo!.height)!
              .toInt(),
          unit: ''),
    );
  }

  void _showInputWeightDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => CustomWeightPicker(
          callback: (weight) {
            if (weight <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_weight_must_greater_than_zero.tr());
              return;
            }
            final userInfo = AppSettings.userInfo!;
            ProfileInfoController.updateUserInfo(
              context,
              userInfo.copyWith(
                weight: weight.toDouble(),
              ),
            );
          },
          title: R.string.enter_weight.tr(),
          max: 180,
          numberDefault: (AppSettings.userInfo!.weight == null ||
                      AppSettings.userInfo!.weight == 0
                  ? 50
                  : AppSettings.userInfo!.weight)!
              .toInt(),
          unit: ''),
    );
  }
}
