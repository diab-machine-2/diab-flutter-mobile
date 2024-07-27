import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());
  final timeToRetry = 10;
  final DateFormat _reminderFormatter = DateFormat("h:mm");

  HomeLoaded? _cached;

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
    } else if (event is FetchHome) {
      // Fetch all data
      yield* _fetchHomes();
    }
    // if (event is SyncHealthApp) {
    //   yield* _syncHealthApp();
    // }
  }

  Stream<HomeState> _fetchHomes() async* {
    final client = HomeClient();

    int retry = 1;
    while (retry <= 10) {
      try {
        HomeModel? model;
        // Load cached home data
        if (_cached == null) {
          // shared preference
          try {
            // if any, just ignore the error
            model = await AppSettings.getHome();
          } catch (e) {}
        }
        // other is mem cache
        yield _cached?.copyWith(model: model) ?? HomeLoading(model: model);

        // Load measurements
        final home = await client.fetchHomes();
        home.inlineMeasurements = _castInlineMeasurements(home);
        home.measurements = _castMeasurements(home);
        HomeLoaded currentState = _cached?.copyWith(model: home) ??
            HomeLoaded(
              model: home,
              utilities: this.getAllUtilities(full: false),
              measurementLoading: false,
            );
        yield currentState;

        // do cache
        AppSettings.saveHome(home.toJson()).catchError((e) {
          print(e);
          return true;
        });

        // load today target
        yield* _fetchActivities();

        // load reminders
        yield* _fetchReminders();

        // load news (learning post)
        yield* _fetchNews();

        // load lessons
        yield* _fetchLessons();

        _cached = currentState;

        break; // Break the loop if successful
      } catch (e, _) {
        if (e is Error) {
          await Future.delayed(Duration(seconds: timeToRetry));
        } else {
          yield HomeError(message: R.string.error_can_not_connect_to_server.tr());
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
    final currentDay = DateUtil.getCurrentDayInMillis();
    final apiResult = await repository.getListSmartGoal(day: currentDay, week: _currentWeek);
    HomeLoaded currentState = state as HomeLoaded;
    apiResult.when(
      success: (SmartGoalListReponse response) {
        List<HomeActivityData> combinedActivities = [];
        if (response.data?.daily?.isNotEmpty == true || response.data?.weekly?.isNotEmpty == true) {
          final dailyActivities =
              (response.data?.daily ?? []).where((e) => e != null).map((e) => e!).map((e) {
            final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(e.type);
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
          final weeklyActivities =
              (response.data?.weekly ?? []).where((e) => e != null).map((e) => e!).map((e) {
            final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(e.type);
            final activity = HomeActivityData(
              id: e.id!,
              icon: type.icon,
              title: type.title,
              type: type,
              smartGoal: e,
              description: e.description,
            );
            return activity;
          }).toList();
          combinedActivities.addAll(weeklyActivities);
          bool isCompletedAll = combinedActivities.isEmpty ||
              combinedActivities.every((element) => element.smartGoal.state == 1);
          bool stillLoading = isCompletedAll;
          currentState =
              currentState.copyWith(activities: combinedActivities, activityLoading: stillLoading);
        } else {
          currentState = currentState.copyWith(activityLoading: false, activities: []);
        }
      },
      failure: (error) {
        TrackingManager.recordError(error, null);
        currentState = currentState.copyWith(activityLoading: false);
      },
    );

    // check fetch target recommendation
    bool needFetchRecommend = currentState.activities == null || currentState.activities!.isEmpty;
    // or completed all
    needFetchRecommend = needFetchRecommend || currentState.activities!.every((element) => element.smartGoal.state == 1);

    // do fetch target recommendation
    if (needFetchRecommend) {
      final targetRecommend = await HomeClient().fetchTargetRecommendation(week: _currentWeek);
      if (targetRecommend != null) {
        // If have target recommendation => override
        final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(targetRecommend.type);
        final activity = HomeActivityData(
          id: '####',
          icon: type.icon,
          title: targetRecommend.title,
          type: type,
          smartGoal:
              SmartGoalList(state: targetRecommend.type == 29 ? 1 : 0, type: targetRecommend.type),
        );
        currentState = currentState.copyWith(activities: [activity], activityLoading: false);
      } else {
        // else, just keep the current state, stop loading
        currentState = currentState.copyWith(activityLoading: false);
      }
    }
    yield currentState;
  }

  Stream<HomeState> _fetchReminders() async* {
    HomeLoaded currentState = state as HomeLoaded;
    final remindersResponse = await UserClient().fetchScheduleRemindersForHomePage();
    if (remindersResponse.isNotEmpty) {
      final reminders = remindersResponse
      .where((e) {
        final time = DateUtil.parseTimespanToDateTime(e.time);
        return time.isAfter(DateTime.now());
      })
      .map((e) {
        final time = DateUtil.parseTimespanToDateTime(e.time);
        final timeString = _reminderFormatter.format(time);

        return HomeReminderData(
          id: e.id,
          icon: R.drawable.ic_home_measurement_glucose_inactive,
          title: e.name,
          time: timeString + " " + (e.timeFrameName?.toLowerCase() ?? "hôm nay"),
          navigatorName: "TODO",
        );
      }).toList();
      currentState = currentState.copyWith(reminders: reminders, reminderLoading: false);
    } else {
      currentState = currentState.copyWith(reminderLoading: false);
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
        lessonSections =
            response.data?.lessonSections?.where((e) => e != null).map((e) => e!).toList();
        lessonDescription = response.data?.description;
        featureImage = response.data?.image?.url;
      }, failure: (error) {
        TrackingManager.recordError(error, null);
      });
      final lessons = lessonSections ?? [];
      if (lessons.isNotEmpty) {
        // Do share
        final lesson = lessons.first;
        String shareLink = await DynamicLinkConfig.instance.createShareLessonLink(
            lesson: lesson, featureImage: featureImage, lessonDescription: lessonDescription);
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

  List<HomeUtilityData> getAllUtilities({bool full = false}) {
    return [
      HomeUtilityData(
        icon: R.drawable.ic_home_goal,
        title: "Thiết lập mục tiêu",
        navigatorName: NavigatorName.goal_setting,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_glucose_calendar,
        title: "Lịch đo đường huyết",
        navigatorName: NavigatorName.schedule_glucose,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_reminder,
        title: "Lịch nhắc nhở",
        navigatorName: NavigatorName.reminder,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_sample_menu,
        title: "Thực đơn mẫu",
        navigatorName: NavigatorName.food_menu,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_peripheral,
        title: "Kết nối thiết bị",
        navigatorName: NavigatorName.connect_device_app,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_medicine,
        title: "Lịch uống thuốc",
        navigatorName: "medicine",
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_referral,
        title: "Mời bạn bè",
        navigatorName: "share",
      ),
      if (full) ...[
        HomeUtilityData(
          icon: R.drawable.ic_home_doctor_consult,
          title: "Tư vấn bác sĩ",
          navigatorName: "consult",
        ),
      ] else
        HomeUtilityData(
          icon: R.drawable.ic_home_more,
          title: "Xem thêm",
          navigatorName: NavigatorName.utilities,
        ),
    ];
  }

  List<HomeMeasurementIndex> getAllMeasurements() {
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
        navigatorName: NavigatorName.add_exercrises,
        args: {'type': 'input'},
      ),
      HomeMeasurementIndex(
        title: R.string.dinh_duong.tr(),
        icon: R.drawable.ic_home_measurement_nutrition,
        navigatorName: NavigatorName.add_food,
        args: {'type': 'input'},
      ),
      HomeMeasurementIndex(
        title: R.string.cam_xuc.tr(),
        icon: R.drawable.ic_home_measurement_emotion,
        navigatorName: NavigatorName.add_emo,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.hba1c.tr(),
        icon: R.drawable.ic_home_measurement_hb1ac,
        navigatorName: NavigatorName.add_hba1c,
        args: {'type': 'input', 'id': null},
      ),
      HomeMeasurementIndex(
        title: R.string.can_nang.tr(),
        icon: R.drawable.ic_home_measurement_weight,
        navigatorName: NavigatorName.add_bmi,
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
    final haveHba1c = model?.hbA1CIndex.index != null && model!.hbA1CIndex.index! > 0;
    final hba1c = HomeMeasurementInlineData(
      title: "HbA1C",
      titleColor: haveHba1c ? _haveValueTitleColor : _noValueTitleColor,
      value: haveHba1c ? model.hbA1CIndex.index!.toString() : "--",
      color: model?.hbA1CIndex.color != null
          ? _convertHexStringToInt(model!.hbA1CIndex.color!)
          : _noValueColor,
      unit: model?.hbA1CIndex.unit ?? "%",
      navigatorName: haveHba1c ? NavigatorName.detail_hba1c : NavigatorName.add_hba1c,
      args: haveHba1c ? null : {'type': 'input'},
    );

    // Weight
    final haveWeight = model?.weightCard?.weight != null && model!.weightCard!.weight! > 0;
    final weight = HomeMeasurementInlineData(
      title: "Cân nặng",
      icon: R.drawable.ic_home_weight,
      titleColor: haveWeight ? _haveValueTitleColor : _noValueTitleColor,
      value: haveWeight ? model.weightCard!.weight!.toString() : "--",
      color: model?.weightCard?.weightColorCode != null
          ? 0xFF008479
          : _noValueColor,
      unit: model?.weightCard?.unit ?? "kg",
      navigatorName: haveWeight ? NavigatorName.detail_bmi : NavigatorName.add_bmi,
      args: haveWeight ? null : {'type': 'input'},
    );

    // BMI
    final haveBmi = model?.bmiCard != null && model!.bmiCard!.bmi > 0;
    final bmi = HomeMeasurementInlineData(
      title: "BMI",
      titleColor: haveBmi ? _haveValueTitleColor : _noValueTitleColor,
      value: haveBmi ? model.bmiCard!.bmi.toString() : "--",
      unit: model?.bmiCard?.unit ?? "kg/m²",
      color: model?.bmiCard?.color != null
          ? _convertHexStringToInt(model!.bmiCard!.color)
          : _noValueColor,
      navigatorName: haveWeight ? NavigatorName.detail_bmi : NavigatorName.add_bmi,
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
    final haveGlucose = model?.glucoseIndex.index != null && model!.glucoseIndex.index! > 0;
    final glucose = HomeMeasurementData(
      title: "Đường Huyết",
      titleColor: haveGlucose ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveGlucose
          ? R.drawable.ic_home_measurement_glucose
          : R.drawable.ic_home_measurement_glucose_inactive,
      value1: haveGlucose ? model.glucoseIndex.index!.toString() : "--",
      value1Color: haveGlucose ? _convertHexStringToInt(model.glucoseIndex.color!) : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.glucoseIndex.unit ?? 'mmol/l',
      navigatorName:
          haveGlucose ? NavigatorName.detail_blood_sugar : NavigatorName.add_blood_sugar_new,
      args: haveGlucose ? null : {'type': 'input'},
    );

    // Blood Pressure
    final haveBloodPressure = model?.bloodPressureIndex.systolic != null &&
        model!.bloodPressureIndex.systolic! > 0 &&
        model.bloodPressureIndex.diastolic != null &&
        model.bloodPressureIndex.diastolic! > 0;
    final bloodPressure = HomeMeasurementData(
      title: "Huyết Áp",
      titleColor: haveBloodPressure ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveBloodPressure
          ? R.drawable.ic_home_measurement_blood
          : R.drawable.ic_home_measurement_blood_inactive,
      value1: haveBloodPressure ? model.bloodPressureIndex.systolic!.toString() : "--",
      value1Color: model?.bloodPressureIndex.colorSystolic != null
          ? _convertHexStringToInt(model!.bloodPressureIndex.colorSystolic!)
          : _noValueColor,
      value2: haveBloodPressure ? model.bloodPressureIndex.diastolic!.toString() : "--",
      value2Color: model?.bloodPressureIndex.colorDiastolic != null
          ? _convertHexStringToInt(model!.bloodPressureIndex.colorDiastolic!)
          : _noValueColor,
      unit: model?.bloodPressureIndex.unit ?? "mmHg",
      navigatorName: haveBloodPressure
          ? NavigatorName.detail_blood_pressure
          : NavigatorName.add_blood_pressure,
      args: haveBloodPressure ? null : {'type': 'input'},
    );

    // Exercise
    final haveExercise = model?.exercise?.index != null && model!.exercise!.index! > 0;
    final exercise = HomeMeasurementData(
      title: "Vận Động",
      titleColor: haveExercise ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveExercise
          ? R.drawable.ic_home_measurement_exercise
          : R.drawable.ic_home_measurement_exercise_inactive,
      value1: haveExercise ? model.exercise!.index!.toString() : "--",
      value1Color: haveExercise ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.exercise?.unit ?? "kcal",
      navigatorName: haveExercise ? NavigatorName.detail_exercrises : NavigatorName.add_exercrises,
      args: haveExercise ? null : {'type': 'input'},
    );

    // Nutrition (Food)
    final haveNutrition =
        model?.energyCard?.consumedEnergy != null && model!.energyCard!.consumedEnergy! > 0;
    final nutrition = HomeMeasurementData(
      title: "Dinh Dưỡng",
      titleColor: haveNutrition ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveNutrition
          ? R.drawable.ic_home_measurement_nutrition
          : R.drawable.ic_home_measurement_nutrition_inactive,
      value1: haveNutrition ? model.energyCard!.consumedEnergy!.toString() : "--",
      value1Color: haveNutrition ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model?.energyCard?.unit ?? "kcal",
      navigatorName: haveNutrition ? NavigatorName.detail_food : NavigatorName.add_food,
      args: haveNutrition ? null : {'type': 'input'},
    );

    // Emotion
    final haveEmotion =
        model?.emotionCard?.details != null && model!.emotionCard!.details!.isNotEmpty;
    final emotion = HomeMeasurementData(
      title: "Cảm Xúc",
      titleColor: haveEmotion ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveEmotion
          ? R.drawable.ic_home_measurement_emotion
          : R.drawable.ic_home_measurement_emotion_inactive,
      value1: haveEmotion ? model.emotionCard!.details![0].text : "--",
      value1Color: haveEmotion ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: "",
      navigatorName: haveEmotion ? NavigatorName.detail_emotion : NavigatorName.add_emo,
      args: haveEmotion ? null : {'type': 'input'},
    );

    // Compose
    return [
      glucose,
      bloodPressure,
      exercise,
      nutrition,
      if (haveEmotion) emotion,
    ];
  }
}
