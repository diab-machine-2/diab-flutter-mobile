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
          // if have cache
          _cached = HomeLoaded(
            model: model,
            utilities: this.getAllUtilities(full: false, bcbStatus: model.bcbStatus),
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
        _hasWeightRecord =
            home.weightCard?.weight != null && home.weightCard?.weight != 0.0;
        home.inlineMeasurements = _castInlineMeasurements(home);
        home.measurements = _castMeasurements(home);
        // at this point, home will lost "activities" data
        HomeLoaded currentState =
            (_cached?.copyWith(model: home) ?? HomeLoaded(model: home))
                .copyWith(
          utilities: this.getAllUtilities(full: false, bcbStatus: home.bcbStatus),
          measurementLoading: false,
          activityLoading: _firstLoad,
          reminderLoading: _firstLoad,
        );
        yield currentState;

        // load reminders
        yield* _fetchReminders();
        // set "reminders" data
        if (state is HomeLoaded) {
          home.reminders = (state as HomeLoaded).reminders;
        }

        // load today target
        yield* _fetchActivities();

        // set "activities" data
        if (state is HomeLoaded) {
          home.activities = (state as HomeLoaded).activities;
        }
        // +
        // then do cache
        AppSettings.saveHome(home.toJson()).catchError((e) {
          print(e);
          return true;
        });

        // // load customer receives user
        // yield* _fetchCustomerReceivesUser();

        // load banners
        yield* _fetchBanners();

        // load news (learning post)
        yield* _fetchNews();

        // load lessons
        yield* _fetchLessons();

        _firstLoad = false;
        _cached = state is HomeLoaded ? state as HomeLoaded : null;

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

  Stream<HomeState> _fetchActivities() async* {
    // load today target
    final repository = AppRepository();
    final dateTime0 = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    final currentDay = DateUtil.getDayInMillis(dateTime0);
    final apiResult =
        await repository.getListSmartGoal(day: currentDay, week: _currentWeek);
    HomeLoaded currentState = state as HomeLoaded;
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
              title:
                  e.description != null ? type.title : (e.name ?? type.title),
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
          currentState =
              currentState.copyWith(activityLoading: false, activities: []);
        }
      },
      failure: (error) {
        TrackingManager.recordError(error, null);
        currentState = currentState.copyWith(activityLoading: false);
      },
    );

    // check fetch target recommendation
    bool needFetchRecommend =
        currentState.activities == null || currentState.activities!.isEmpty;
    // or completed all
    needFetchRecommend = needFetchRecommend ||
        currentState.activities!
            .every((element) => element.smartGoal.state == 1);

    // do fetch target recommendation
    if (needFetchRecommend) {
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
    }
    yield currentState;
  }

  Stream<HomeState> _fetchReminders() async* {
    HomeLoaded currentState = state as HomeLoaded;
    final remindersResponse =
        await UserClient().fetchScheduleRemindersForHomePage();
    if (remindersResponse.isNotEmpty) {
      final reminders = remindersResponse
          // .where((e) {
          //   final time = DateUtil.parseTimespanToDateTime(e.time);
          //   return time.isAfter(DateTime.now());
          // })
          .map((e) {
        final time = DateUtil.parseTimespanToDateTime(e.time).toLocal();
        final timeString = _reminderFormatter.format(time);

        return HomeReminderData(
          id: e.id,
          icon: R.drawable.ic_reminder,
          title: e.name,
          time:
              timeString + " " + (e.timeFrameName?.toLowerCase() ?? "hôm nay"),
          navigatorName: "TODO",
        );
      }).toList();
      currentState =
          currentState.copyWith(reminders: reminders, reminderLoading: false);
    } else {
      currentState =
          currentState.copyWith(reminders: [], reminderLoading: false);
    }
    yield currentState;
  }

  Stream<HomeState> _fetchNews() async* {
    final learningClient = LearningClient();
    final newsResponse = await learningClient.fetchLearningPost(1);
    if (newsResponse.isNotEmpty) {
      final currentState = state as HomeLoaded;
      yield currentState.copyWith(news: newsResponse);
    }
  }

  Stream<HomeState> _fetchBanners() async* {
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
      final currentState = state as HomeLoaded;
      yield currentState.copyWith(banners: banners);
    }
  }

  Stream<HomeState> _fetchLessons() async* {
    final learningClient = LearningClient();
    final lessonsResponse = await learningClient
        .fetchLesson(
      week: _currentWeek,
    )
        .catchError((e, s) {
      TrackingManager.recordError(e, s);
      return <LessonModel>[];
    }, test: (error) => true);
    final currentState = state as HomeLoaded;
    yield currentState.copyWith(lessons: lessonsResponse);
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

  List<HomeUtilityData> getAllUtilities({bool full = false, bool bcbStatus = false}) {
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
      if (bcbStatus)
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

  List<HomeMeasurementData>? _castMeasurements(HomeModel? model) {
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
    // Check if there's real data: similar to HbA1C, check createDateTime
    // Backend may return default values (e.g., 120/90) even when there's no actual data
    // createDateTime will be null or 0 when there's no data
    final hasValidDateTime = model?.bloodPressureIndex.createDateTime != null &&
        model!.bloodPressureIndex.createDateTime! > 0;

    // Debug log to check actual values
    print('🔍 Blood Pressure Data Check:');
    print('  systolic: ${model?.bloodPressureIndex.systolic}');
    print('  diastolic: ${model?.bloodPressureIndex.diastolic}');
    print('  createDateTime: ${model?.bloodPressureIndex.createDateTime}');
    print('  hasValidDateTime: $hasValidDateTime');

    // Check if values are default values (120/90) - these are common default values
    // Backend may return these default values even when there's no actual data
    // We need to exclude these default values to prevent showing fake data
    final systolic = model?.bloodPressureIndex.systolic;
    final diastolic = model?.bloodPressureIndex.diastolic;

    // Check if values match the common default pattern (120/90)
    // Use tolerance for double comparison
    final isDefaultValue = (systolic != null && diastolic != null) &&
        ((systolic == 120.0 || systolic == 120) &&
            (diastolic == 90.0 || diastolic == 90));

    print('  isDefaultValue: $isDefaultValue');

    // Only consider it valid data if:
    // 1. Both systolic and diastolic exist and > 0
    // 2. createDateTime is valid (not null and > 0)
    // 3. Values are NOT the default values (120/90) - exclude default values even if createDateTime is valid
    //    This is because backend may return default values with valid createDateTime when there's no real data
    final haveBloodPressure = systolic != null &&
        systolic > 0 &&
        diastolic != null &&
        diastolic > 0 &&
        hasValidDateTime && // Only show data if createDateTime is valid
        !isDefaultValue; // Exclude default values (120/90) even if createDateTime is valid
    // Note: We exclude default values because backend may return them with valid createDateTime
    // when there's no actual user data. If user really has 120/90, they would have entered it,
    // and it would have a different createDateTime or be stored differently.

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
          : null, // Set to null when no data instead of "--"
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
    final haveNutrition = model?.energyCard?.consumedEnergy != null &&
        model!.energyCard!.consumedEnergy! > 0;
    final nutrition = HomeMeasurementData(
      title: R.string.dinh_duong.tr(),
      titleColor: haveNutrition ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveNutrition
          ? R.drawable.ic_home_measurement_nutrition
          : R.drawable.ic_home_measurement_nutrition_inactive,
      value1:
          haveNutrition ? roundNumber(model.energyCard!.consumedEnergy!) : "--",
      value1Color: haveNutrition ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.energyCard?.unit ?? "kcal",
      navigatorName:
          haveNutrition ? NavigatorName.detail_food : NavigatorName.add_food,
      args: haveNutrition ? null : {'type': 'input'},
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
