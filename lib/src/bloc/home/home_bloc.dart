import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/learning_post_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    add(FetchHome());
  }
  final timeToRetry = 10;
  final DateFormat _reminderFormatter = DateFormat("h:mm");

  HomeLoaded? _cached;
  bool _firstLoad = false;
  bool _hasWeightRecord = false;

  int get _currentWeek {
    if (AppSettings.userInfo?.ownPackage?.ownRoadmap?.currentWeek != null) {
      int week = AppSettings.userInfo!.ownPackage!.ownRoadmap!.currentWeek!;
      return week < 0 ? 0 : week;
    }
    return 0;
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is HomeFetchActivityEvent) {
      yield* _fetchActivities();
    } else if (event is HomeFetchReminderEvent) {
      yield* _fetchReminders();
    } else if (event is HomeFetchLessonEvent) {
      yield* _fetchLessons();
    } else if (event is HomeFetchNewsEvent) {
      yield* _fetchNews();
    } else if (event is HomeFetchBannersEvent) {
      yield* _fetchBanners();
    } else if (event is FetchHome) {
      // Fetch all data
      yield* _fetchHomes();
    }
    // if (event is SyncHealthApp) {
    //   yield* _syncHealthApp();
    // }
  }

  Stream<HomeState> _fetchHomes() async* {
    // init load from cache
    if (_cached == null) {
      // try first load from cache (shared preference)
      try {
        // try to load from cache
        final model =
            (AppSettings.popPrecachedHome() ?? await AppSettings.getHome());
        if (model != null) {
          AppSettings.hasBundle = model.hasBundle;
          // if have cache
          _cached = HomeLoaded(
            model: model,
            utilities: this.getAllUtilities(
                full: false,
                bcbStatus: model.bcbStatus,
                hasBundle: model.hasBundle),
            activities: model.activities,
            reminders: model.reminders,
            activityLoading: false,
            measurementLoading: false,
            reminderLoading: false,
          );
          yield _cached!;
        } else {
          // if no cache
          _firstLoad = true;
          yield HomeLoading(model: null);
        }
        _hasWeightRecord = model?.weightCard?.weight != null &&
            model?.weightCard?.weight != 0.0;
      } catch (e, s) {
        // init load failed
        TrackingManager.recordError(e, s);
      }
    }

    final client = HomeClient();

    int retry = 1;
    while (retry <= 3) {
      try {
        // Load measurements
        final home = await client.fetchHomes();
        AppSettings.hasBundle = home.hasBundle;
        _hasWeightRecord =
            home.weightCard?.weight != null && home.weightCard?.weight != 0.0;
        home.inlineMeasurements = _castInlineMeasurements(home);
        home.measurements = await _castMeasurements(home);
        // at this point, home will lost "activities" data
        HomeLoaded currentState =
            (_cached?.copyWith(model: home) ?? HomeLoaded(model: home))
                .copyWith(
          utilities: this.getAllUtilities(
              full: false,
              bcbStatus: home.bcbStatus,
              hasBundle: home.hasBundle),
          measurementLoading: false,
          activityLoading: _firstLoad,
          reminderLoading: _firstLoad,
        );
        yield currentState;

        // Reminders / activities / banners / news / lessons are all
        // independent of each other and of the measurements load above —
        // none of their handlers reads another's result. Firing all 5 here
        // (instead of the previous yield*-per-domain chain, which made each
        // one wait for every domain before it to fully finish) means the
        // network calls run concurrently: total wait becomes roughly the
        // slowest single domain instead of the sum of all 5. Each `_fetchX
        // Patch()` call starts its network request immediately (before this
        // line finishes), independent of when its Future is later awaited.
        final remindersFuture = _fetchRemindersPatch();
        final activitiesFuture = _fetchActivitiesPatch();
        final bannersFuture = _fetchBannersPatch();
        final newsFuture = _fetchNewsPatch();
        final lessonsFuture = _fetchLessonsPatch();

        // Apply results in the order we want the UI to update — banner and
        // news first (previously loaded dead last, behind reminders and
        // activities, despite appearing near the top of the screen).
        currentState = (await bannersFuture)(currentState);
        yield currentState;

        currentState = (await newsFuture)(currentState);
        yield currentState;

        currentState = (await remindersFuture)(currentState);
        // set "reminders" data
        home.reminders = currentState.reminders;
        yield currentState;

        currentState = await (await activitiesFuture)(currentState);
        // set "activities" data
        home.activities = currentState.activities;
        yield currentState;

        // then do cache — only after reminders/activities are attached to
        // `home`, same invariant as before, so a cold-start cache read has
        // both populated.
        AppSettings.saveHome(home.toJson()).catchError((e) {
          print(e);
          return true;
        });

        // // load customer receives user
        // yield* _fetchCustomerReceivesUser();

        currentState = (await lessonsFuture)(currentState);
        yield currentState;

        _firstLoad = false;
        _cached = currentState;

        break; // Break the loop if successful
      } catch (e, _) {
        if (e is Error) {
          await Future.delayed(Duration(seconds: timeToRetry));
        } else {
          yield HomeError(
              message: R.string.error_can_not_connect_to_server.tr());
          break; // Break the loop if a non-retryable error occurs
        }
      }
      retry++;
    }

    if (retry == 10) {
      yield HomeError(message: "Maximum retry limit reached");
    }
  }

  // ---------------------------------------------------------------------
  // Standalone event handlers below (`_fetchActivities`, `_fetchReminders`,
  // `_fetchNews`, `_fetchBanners`, `_fetchLessons`) are thin wrappers: they
  // read the live `state`, apply the corresponding `_fetchXPatch()`, and
  // yield once — same observable contract as before. The actual fetch +
  // business logic for each domain now lives ONLY in the matching
  // `_fetchXPatch()` method below it, so `_fetchHomes()` can fire all 5
  // concurrently without duplicating this logic in two places.
  //
  // Of the five, only `HomeFetchActivityEvent` is ever actually dispatched
  // (from home_v2.dart, for "back_to_home"/"refresh_home_activity"). The
  // other four events are wired into `mapEventToState` but never `.add()`-ed
  // anywhere in the app today — kept working regardless, in case that
  // changes.
  // ---------------------------------------------------------------------

  Stream<HomeState> _fetchActivities() async* {
    final patch = await _fetchActivitiesPatch();
    yield await patch(state as HomeLoaded);
  }

  Stream<HomeState> _fetchReminders() async* {
    final patch = await _fetchRemindersPatch();
    yield patch(state as HomeLoaded);
  }

  Stream<HomeState> _fetchNews() async* {
    final patch = await _fetchNewsPatch();
    yield patch(state as HomeLoaded);
  }

  Stream<HomeState> _fetchBanners() async* {
    final patch = await _fetchBannersPatch();
    yield patch(state as HomeLoaded);
  }

  Stream<HomeState> _fetchLessons() async* {
    final patch = await _fetchLessonsPatch();
    yield patch(state as HomeLoaded);
  }

  /// Fires the "today's activities" network call immediately and returns an
  /// applier that computes the resulting state. Split in two like this
  /// (fetch now, apply later) so `_fetchHomes()` can kick this off at the
  /// same time as reminders/banners/news/lessons instead of waiting for
  /// each in turn.
  ///
  /// The applier itself is `async` (unlike the other four patches) because
  /// whether the fallback "target recommendation" call is needed depends on
  /// `currentState.activities` *at apply time* — exactly the same
  /// dependency the original sequential code had — so that decision (and
  /// the fallback call itself) has to happen inside the applier, not in the
  /// eager part.
  Future<Future<HomeLoaded> Function(HomeLoaded)> _fetchActivitiesPatch() async {
    final repository = AppRepository();
    final dateTime0 = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    final currentDay = DateUtil.getDayInMillis(dateTime0);

    ApiResult<SmartGoalListReponse>? apiResult;
    try {
      apiResult = await repository.getListSmartGoal(
          day: currentDay, week: _currentWeek);
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }

    return (HomeLoaded state) async {
      HomeLoaded currentState = state;
      if (apiResult != null) {
        apiResult.when(
          success: (SmartGoalListReponse response) {
            List<HomeActivityData> combinedActivities = [];
            if (response.data?.daily?.isNotEmpty == true ||
                response.data?.weekly?.isNotEmpty == true) {
              final dailyActivities = (response.data?.daily ?? [])
                  .where((e) => e != null)
                  .map((e) => e!)
                  .map((e) {
                final ScheduleType type =
                    ScheduleTypeExtend.getTypeFromIndexWithLessonData(e.type,
                        lessonData: e.lessonData,
                        lessonNested: e.lesson,
                        activityName: e.name,
                        activityDescription: e.description);
                final activity = HomeActivityData(
                  id: e.id!,
                  icon: type.icon,
                  title: e.name ?? type.title,
                  type: type,
                  smartGoal: e,
                  description: e.description,
                );
                return activity;
              }).toList();
              combinedActivities.addAll(dailyActivities);
              final weeklyActivities = (response.data?.weekly ?? [])
                  .where((e) => e != null)
                  .map((e) => e!)
                  .map((e) {
                final ScheduleType type =
                    ScheduleTypeExtend.getTypeFromIndexWithLessonData(e.type,
                        lessonData: e.lessonData,
                        lessonNested: e.lesson,
                        activityName: e.name,
                        activityDescription: e.description);
                final activity = HomeActivityData(
                  id: e.id!,
                  icon: type.icon,
                  title: e.description != null
                      ? type.title
                      : (e.name ?? type.title),
                  type: type,
                  smartGoal: e,
                  description: e.description,
                );
                return activity;
              }).toList();
              combinedActivities.addAll(weeklyActivities);
              bool isCompletedAll = combinedActivities.isEmpty ||
                  combinedActivities
                      .every((element) => element.smartGoal.state == 1);
              bool stillLoading = isCompletedAll;
              currentState = currentState.copyWith(
                activities: combinedActivities,
                activityLoading: _firstLoad && stillLoading,
              );
            } else {
              currentState = currentState
                  .copyWith(activityLoading: false, activities: []);
            }
          },
          failure: (error) {
            TrackingManager.recordError(error, null);
            currentState = currentState.copyWith(activityLoading: false);
          },
        );
      } else {
        // The primary call itself threw (already logged above) — leave
        // whatever activities currentState already has untouched, same as
        // the original `failure` branch did.
        currentState = currentState.copyWith(activityLoading: false);
      }

      // check fetch target recommendation
      bool needFetchRecommend =
          currentState.activities == null || currentState.activities!.isEmpty;
      // or completed all
      needFetchRecommend = needFetchRecommend ||
          currentState.activities!
              .every((element) => element.smartGoal.state == 1);

      // do fetch target recommendation
      if (needFetchRecommend) {
        try {
          final targetRecommend =
              await HomeClient().fetchTargetRecommendation(week: _currentWeek);
          if (targetRecommend != null) {
            // If have target recommendation => override
            final ScheduleType type =
                ScheduleTypeExtend.getTypeFromIndex(targetRecommend.type);
            final activity = HomeActivityData(
              id: '####',
              icon: type.icon,
              title: targetRecommend.title,
              type: type,
              smartGoal: SmartGoalList(
                  state: targetRecommend.type == 29 ? 1 : 0,
                  type: targetRecommend.type),
            );
            currentState = currentState
                .copyWith(activities: [activity], activityLoading: false);
          } else {
            // else, just keep the current state, stop loading
            currentState = currentState.copyWith(activityLoading: false);
          }
        } catch (e, s) {
          TrackingManager.recordError(e, s);
          currentState = currentState.copyWith(activityLoading: false);
        }
      }
      return currentState;
    };
  }

  /// Fires the reminders network call immediately; returns a sync applier
  /// (reminders never need a second, dependent call the way activities do).
  Future<HomeLoaded Function(HomeLoaded)> _fetchRemindersPatch() async {
    try {
      final remindersResponse =
          await UserClient().fetchScheduleRemindersForHomePage();
      if (remindersResponse.isNotEmpty) {
        final reminders = remindersResponse.map((e) {
          final time = DateUtil.parseTimespanToDateTime(e.time).toLocal();
          final timeString = _reminderFormatter.format(time);

          return HomeReminderData(
            id: e.id,
            icon: R.drawable.ic_reminder,
            title: e.name,
            time: timeString +
                " " +
                (e.timeFrameName?.toLowerCase() ?? "hôm nay"),
            navigatorName: "TODO",
          );
        }).toList();
        return (HomeLoaded state) =>
            state.copyWith(reminders: reminders, reminderLoading: false);
      }
      return (HomeLoaded state) =>
          state.copyWith(reminders: [], reminderLoading: false);
    } catch (e, s) {
      // Reminders failing shouldn't take down the rest of the home screen —
      // leave whatever reminders are already showing (e.g. from cache) and
      // just stop the spinner. The original sequential version had no
      // try/catch here at all, so this exception would have propagated up
      // and shown a full-screen HomeError instead — this is a deliberate,
      // narrow improvement, not just a refactor.
      TrackingManager.recordError(e, s);
      return (HomeLoaded state) => state.copyWith(reminderLoading: false);
    }
  }

  /// Fires the "featured news" network call immediately; returns a sync
  /// applier.
  Future<HomeLoaded Function(HomeLoaded)> _fetchNewsPatch() async {
    try {
      final learningClient = LearningClient();
      final newsResponse = await learningClient.fetchLearningPost(1);
      if (newsResponse.isNotEmpty) {
        return (HomeLoaded state) => state.copyWith(news: newsResponse);
      }
      return (HomeLoaded state) => state;
    } catch (e, s) {
      // Same reasoning as reminders above — the original had no try/catch
      // here either, so a news-fetch failure used to blank the whole home
      // screen with HomeError.
      TrackingManager.recordError(e, s);
      return (HomeLoaded state) => state;
    }
  }

  /// Fires the banners network call immediately; returns a sync applier.
  Future<HomeLoaded Function(HomeLoaded)> _fetchBannersPatch() async {
    try {
      final ApiResult<LearningPostListResponse> apiResult =
          await AppRepository().getBanners(position: 9);
      List<LearningPostModel>? bannersResp;
      apiResult.when(success: (LearningPostListResponse response) {
        bannersResp = response.data?.map((e) => e).toList();
      }, failure: (error) {
        TrackingManager.recordError(error, null);
      });
      final banners = bannersResp ?? [];
      if (banners.isNotEmpty) {
        return (HomeLoaded state) => state.copyWith(banners: banners);
      }
      return (HomeLoaded state) => state;
    } catch (e, s) {
      TrackingManager.recordError(e, s);
      return (HomeLoaded state) => state;
    }
  }

  /// Fires the lessons network call immediately; returns a sync applier.
  Future<HomeLoaded Function(HomeLoaded)> _fetchLessonsPatch() async {
    final learningClient = LearningClient();
    final lessonsResponse = await learningClient
        .fetchLesson(week: _currentWeek)
        .catchError((e, s) {
      TrackingManager.recordError(e, s);
      return <LessonModel>[];
    }, test: (error) => true);
    return (HomeLoaded state) => state.copyWith(lessons: lessonsResponse);
  }

  Future<void> shareLesson(String lessonId, BuildContext context) async {
    try {
      BotToast.showLoading();
      final ApiResult<LessonSectionListResponse> apiResult =
          await AppRepository().getListLessonSection(lessonId);
      List<LessonSectionItem>? lessonSections;
      String? featureImage;
      String? lessonDescription;
      apiResult.when(success: (LessonSectionListResponse response) {
        lessonSections = response.data?.lessonSections
            ?.where((e) => e != null)
            .map((e) => e!)
            .toList();
        lessonDescription = response.data?.description;
        featureImage = response.data?.image?.url;
      }, failure: (error) {
        TrackingManager.recordError(error, null);
      });
      final lessons = lessonSections ?? [];
      if (lessons.isNotEmpty) {
        // Do share
        final lesson = lessons.first;
        String shareLink = await BranchioLinkConfig.instance
            .createShareLessonLink(
                lesson: lesson,
                featureImage: featureImage,
                lessonDescription: lessonDescription);
        AppShare.instance.lessonDetail(context, shareLink, lesson.name ?? "");
      }
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      BotToast.closeAllLoading();
    }

    return;
  }

  // Stream<HomeState> _syncHealthApp() async* {}

  List<HomeUtilityData> getAllUtilities(
      {bool full = false, bool bcbStatus = false, bool hasBundle = false}) {
    String? preOrder = FirebaseRemoteSetting.instance.utilitiesOrder;
    final moreItem = HomeUtilityData(
      icon: R.drawable.ic_home_more,
      title: R.string.more.tr(),
      slug: "xem-them",
      navigatorName: NavigatorName.utilities,
    );
    final all = [
      HomeUtilityData(
        icon: R.drawable.ic_home_glucose_calendar,
        title: R.string.blood_sugar_schedule_single_line.tr(),
        slug: "lich-do-duong-huyet",
        navigatorName: NavigatorName.schedule_glucose,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_sample_menu,
        title: R.string.food_menu.tr(),
        slug: "thuc-don-mau",
        navigatorName: NavigatorName.food_menu,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_goal,
        title: R.string.goal_setting.tr(),
        slug: "thiet-lap-muc-tieu",
        navigatorName: NavigatorName.goal_setting,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_peripheral,
        title: R.string.connect_device_home.tr(),
        slug: "ket-noi-thiet-bi",
        navigatorName: NavigatorName.connect_device_app,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_referral,
        title: R.string.diab_refferal.tr(),
        slug: "moi-ban-be",
        navigatorName: "share",
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_medicine,
        title: R.string.schedule_medicine.tr(),
        slug: "lich-uong-thuoc",
        navigatorName: NavigatorName.medicine_check,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_reminder,
        title: R.string.reminder_calendar.tr(),
        slug: "lich-nhac-nho",
        navigatorName: NavigatorName.reminder,
      ),
      // HomeUtilityData(
      //   icon: R.drawable.ic_home_reminder,
      //   title: "Book lịch tại cơ sở y tế",
      //   slug: "book-lich-tai-co-so-y-te",
      //   navigatorName: NavigatorName.reminder,
      // ),
      HomeUtilityData(
        icon: R.drawable.ic_home_doctor_consult,
        title: R.string.healthy_lifestyle_consulting.tr(),
        slug: "tu-van-song-khoe",
        navigatorName: NavigatorName.dsmes_booking,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_booking_clinic,
        title: R.string.book_medical_appointment.tr(),
        slug: "dat-lich-kham-benh",
        navigatorName: NavigatorName.booking_clinic,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_booking_doctor,
        title: R.string.kham_tu_xa.tr(),
        slug: "kham-tu-xa",
        navigatorName: NavigatorName.booking_doctor,
      ),
      if (bcbStatus && hasBundle == true)
        HomeUtilityData(
          icon: R.drawable.ic_lab_result,
          title: R.string.bcb_medical_examination_result.tr(),
          slug: "ket-qua-kham",
          navigatorName: NavigatorName.view_test_result,
        ),
    ];

    if (preOrder?.isNotEmpty == true) {
      final preOrderSlug =
          preOrder!.split(",").where((e) => e.trim().isNotEmpty).toList();
      // Filter to only include items that exist in preOrderSlug
      final filteredAll =
          all.where((item) => preOrderSlug.contains(item.slug)).toList();
      filteredAll.sort((a, b) {
        final aIndex = preOrderSlug.indexOf(a.slug);
        final bIndex = preOrderSlug.indexOf(b.slug);
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex - bIndex;
      });

      return full ? filteredAll : [...filteredAll.take(7), moreItem];
    }

    return full ? all : [...all.take(7), moreItem];
  }

  List<HomeMeasurementIndex> getAllMeasurements() {
    String weightNavigatorName =
        _hasWeightRecord ? NavigatorName.bmiInputPage : NavigatorName.add_bmi;

    return [
      HomeMeasurementIndex(
        title: R.string.duong_huyet.tr(),
        icon: R.drawable.ic_home_measurement_glucose,
        navigatorName: NavigatorName.add_blood_sugar_new,
        args: {'type': 'input'},
      ),
      HomeMeasurementIndex(
        title: R.string.huyet_ap.tr(),
        icon: R.drawable.ic_home_measurement_blood,
        navigatorName: NavigatorName.add_blood_pressure,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.van_dong.tr(),
        icon: R.drawable.ic_home_measurement_exercise,
        navigatorName: NavigatorName.exercrise_onboarding,
        // args: {'type': 'input'},
      ),
      HomeMeasurementIndex(
        title: R.string.dinh_duong.tr(),
        icon: R.drawable.ic_home_measurement_nutrition,
        navigatorName: NavigatorName.add_food,
        args: {'type': 'input'},
      ),
      // HomeMeasurementIndex(
      //   title: R.string.cam_xuc.tr(),
      //   icon: R.drawable.ic_home_measurement_emotion,
      //   navigatorName: NavigatorName.add_emo,
      //   args: {'type': 'input', 'id': null},
      // ),
      HomeMeasurementIndex(
        title: R.string.hba1c.tr(),
        icon: R.drawable.ic_home_measurement_hb1ac,
        navigatorName: NavigatorName.add_hba1c,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.can_nang.tr(),
        icon: R.drawable.ic_home_measurement_weight,
        navigatorName: weightNavigatorName,
        args: {'type': 'input'},
      ),
    ];
  }

  int _haveValueTitleColor = 0xFF008479;
  int _noValueTitleColor = 0xFF9C9C9C;
  int _noValueColor = 0xFF172823;
  int _convertHexStringToInt(String hexString) {
    // from "#000000" to "0xFF000000"
    if (hexString.isEmpty) return _noValueColor;
    return int.parse("0xFF" + hexString.substring(1));
  }

  List<HomeMeasurementInlineData>? _castInlineMeasurements(HomeModel? model) {
    // Hb1Ac
    // Check both index value and createDateTime to determine if there's real data
    // Backend may return default value (e.g., 9.0) even when there's no actual data
    // createDateTime will be null or 0 when there's no data

    // Debug log to check actual values
    print('🔍 HbA1C Data Check:');
    print('  index: ${model?.hbA1CIndex.index}');
    print('  createDateTime: ${model?.hbA1CIndex.createDateTime}');
    print('  color: ${model?.hbA1CIndex.color}');

    // Check if there's real data:
    // 1. Index must exist and > 0
    // 2. CreateDateTime must exist and > 0 (not null or 0)
    // 3. Exclude default value of 9.0 when createDateTime is null/0
    final hasValidDateTime = model?.hbA1CIndex.createDateTime != null &&
        model!.hbA1CIndex.createDateTime! > 0;

    final haveHba1c = model?.hbA1CIndex.index != null &&
        model!.hbA1CIndex.index! > 0 &&
        hasValidDateTime;

    print('  hasValidDateTime: $hasValidDateTime');
    print('  haveHba1c: $haveHba1c');

    final hba1c = HomeMeasurementInlineData(
      title: "HbA1C",
      titleColor: haveHba1c ? _haveValueTitleColor : _noValueTitleColor,
      value: haveHba1c ? roundNumber(model.hbA1CIndex.index!) : "--",
      color: model?.hbA1CIndex.color != null
          ? _convertHexStringToInt(model!.hbA1CIndex.color!)
          : _noValueColor,
      unit: model?.hbA1CIndex.unit ?? "%",
      navigatorName: haveHba1c
          ? NavigatorName.detail_hba1c
          : NavigatorName.hba1c_intro_1st_page,
      args: null,
    );

    // Weight
    final haveWeight =
        model?.weightCard?.weight != null && model!.weightCard!.weight! > 0;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Const.hasWeightRecord, haveWeight);
    });
    final weight = HomeMeasurementInlineData(
      title: "Cân nặng",
      icon: R.drawable.ic_home_weight,
      titleColor: haveWeight ? _haveValueTitleColor : _noValueTitleColor,
      value: haveWeight ? roundNumber(model.weightCard!.weight!) : "--",
      color: model?.weightCard?.weightColorCode != null
          ? 0xFF008479
          : _noValueColor,
      unit: model?.weightCard?.unit ?? "kg",
      navigatorName: NavigatorName.add_bmi,
      args: haveWeight ? null : {'type': 'input'},
    );

    // BMI
    final haveBmi = model?.bmiCard != null && model!.bmiCard!.bmi > 0;
    final bmi = HomeMeasurementInlineData(
      title: "BMI",
      titleColor: haveBmi ? _haveValueTitleColor : _noValueTitleColor,
      value: haveBmi ? roundNumber(model.bmiCard!.bmi) : "--",
      unit: model?.bmiCard?.unit ?? "kg/m²",
      color: model?.bmiCard?.color != null
          ? _convertHexStringToInt(model!.bmiCard!.color)
          : _noValueColor,
      navigatorName: NavigatorName.add_bmi,
      args: haveBmi ? null : {'type': 'input'},
    );

    return [
      hba1c,
      weight,
      bmi,
    ];
  }

  Future<List<HomeMeasurementData>?> _castMeasurements(HomeModel? model) async {
    // Glucose
    final haveGlucose =
        model?.glucoseIndex.index != null && model!.glucoseIndex.index! > 0;
    final glucose = HomeMeasurementData(
      title: R.string.duong_huyet.tr(),
      titleColor: haveGlucose ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveGlucose
          ? R.drawable.ic_home_measurement_glucose
          : R.drawable.ic_home_measurement_glucose_inactive,
      value1: haveGlucose ? roundNumber(model.glucoseIndex.index!) : "--",
      value1Color: haveGlucose
          ? _convertHexStringToInt(model.glucoseIndex.color!)
          : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.glucoseIndex.unit ?? 'mmol/l',
      navigatorName: haveGlucose
          ? NavigatorName.detail_blood_sugar
          : NavigatorName.add_blood_sugar_new,
      args: haveGlucose ? null : {'type': 'input'},
    );

    // Blood Pressure
    final hasValidDateTime = model?.bloodPressureIndex.createDateTime != null &&
        model!.bloodPressureIndex.createDateTime! > 0;

    print('🔍 Blood Pressure Data Check:');
    print('  systolic: ${model?.bloodPressureIndex.systolic}');
    print('  diastolic: ${model?.bloodPressureIndex.diastolic}');
    print('  createDateTime: ${model?.bloodPressureIndex.createDateTime}');
    print('  hasValidDateTime: $hasValidDateTime');

    final systolic = model?.bloodPressureIndex.systolic;
    final diastolic = model?.bloodPressureIndex.diastolic;

    // final isDefaultValue = (systolic != null && diastolic != null) &&
    //     ((systolic == 120.0 || systolic == 120) &&
    //         (diastolic == 90.0 || diastolic == 90));

    // print('  isDefaultValue: $isDefaultValue');

    final haveBloodPressure = systolic != null &&
        systolic > 0 &&
        diastolic != null &&
        diastolic > 0 &&
        hasValidDateTime 
        // &&
        // !isDefaultValue
        ;

    print('  haveBloodPressure: $haveBloodPressure');
    final bloodPressure = HomeMeasurementData(
      title: R.string.huyet_ap.tr(),
      titleColor: haveBloodPressure ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveBloodPressure
          ? R.drawable.ic_home_measurement_blood
          : R.drawable.ic_home_measurement_blood_inactive,
      value1: haveBloodPressure
          ? roundNumber(model.bloodPressureIndex.systolic!)
          : "--",
      value1Color:
          haveBloodPressure && model.bloodPressureIndex.colorSystolic != null
              ? _convertHexStringToInt(model.bloodPressureIndex.colorSystolic!)
              : _noValueColor,
      value2: haveBloodPressure
          ? roundNumber(model.bloodPressureIndex.diastolic!)
          : null,
      value2Color:
          haveBloodPressure && model.bloodPressureIndex.colorDiastolic != null
              ? _convertHexStringToInt(model.bloodPressureIndex.colorDiastolic!)
              : null,
      unit: model?.bloodPressureIndex.unit ?? "mmHg",
      navigatorName: haveBloodPressure
          ? NavigatorName.detail_blood_pressure
          : NavigatorName.add_blood_pressure,
      args: haveBloodPressure ? null : {'type': 'input'},
    );

    // Exercise
    final haveExercise =
        (model?.exercise?.index != null && model!.exercise!.index! > 0) ||
            model?.exercise?.isDataNotEmpty == true;
    final exercise = HomeMeasurementData(
      title: R.string.van_dong.tr(),
      titleColor: haveExercise ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveExercise
          ? R.drawable.ic_home_measurement_exercise
          : R.drawable.ic_home_measurement_exercise_inactive,
      value1: haveExercise ? roundNumber(model?.exercise!.index ?? 0) : "--",
      value1Color: haveExercise ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.exercise?.unit ?? "kcal",
      navigatorName: haveExercise
          ? NavigatorName.exercrise_dashboard
          : NavigatorName.exercrise_onboarding,
      args: haveExercise ? null : {'type': 'input'},
    );

    // Nutrition (Food)
    final double displayEnergy = model?.energyCard?.consumedEnergy ?? 0;
    final haveNutrition = displayEnergy > 0;
    final nutrition = HomeMeasurementData(
      title: R.string.dinh_duong.tr(),
      titleColor: haveNutrition ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveNutrition
          ? R.drawable.ic_home_measurement_nutrition
          : R.drawable.ic_home_measurement_nutrition_inactive,
      value1: haveNutrition ? roundNumber(displayEnergy) : "--",
      value1Color: haveNutrition ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.energyCard?.unit ?? "kcal",
      navigatorName: haveNutrition
          ? NavigatorName.detail_food
          : NavigatorName.nutrient_intro_1st_page,
      args: haveNutrition ? null : null,
    );

    // Emotion
    // final haveEmotion = model?.emotionCard?.details != null &&
    //     model!.emotionCard!.details!.isNotEmpty;
    // final emotion = HomeMeasurementData(
    //   title: "Cảm Xúc",
    //   titleColor: haveEmotion ? _haveValueTitleColor : _noValueTitleColor,
    //   icon: haveEmotion
    //       ? R.drawable.ic_home_measurement_emotion
    //       : R.drawable.ic_home_measurement_emotion_inactive,
    //   value1: haveEmotion ? model.emotionCard!.details![0].text : "--",
    //   value1Color: haveEmotion ? _haveValueTitleColor : _noValueColor,
    //   value2: null,
    //   value2Color: null,
    //   unit: "",
    //   navigatorName:
    //       haveEmotion ? NavigatorName.detail_emotion : NavigatorName.add_emo,
    //   args: haveEmotion ? null : {'type': 'input'},
    // );

    // Compose
    return [
      glucose,
      bloodPressure,
      exercise,
      nutrition,
      // if (haveEmotion) emotion,
    ];
  }
}
