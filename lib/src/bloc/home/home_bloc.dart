import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:meta/meta.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

part 'home_bloc_event.dart';
part 'home_bloc_state.dart';

HomeModel? _cached;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());
  final timeToRetry = 10;

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchHome) {
      yield* _fetchHomes();
    }
    // if (event is SyncHealthApp) {
    //   yield* _syncHealthApp();
    // }
  }

  Stream<HomeState> _fetchHomes() async* {
    final repository = AppRepository();
    final client = HomeClient();

    int retry = 1;
    while (retry <= 10) {
      try {
        // Load cached home data
        if (_cached == null) {
          // shared preference
          _cached = await AppSettings.getHome();
          if (_cached != null) {
            _cached?.utilities = this.getAllUtilities(full: false);
          }
        }
        // other is mem cache
        yield HomeLoading(model: _cached);

        // Load measurements
        final home = await client.fetchHomes();
        home.inlineMeasurements = _castInlineMeasurements(home);
        home.measurements = _castMeasurements(home);
        home.utilities = getAllUtilities(full: false);
        yield HomeLoaded(model: home);

        // load today target
        final currentDay = 0;
        final currentWeek = 1;
        final apiResult = await repository.getListSmartGoal(day: currentDay, week: currentWeek);
        apiResult.when(
          success: (SmartGoalListReponse response) {
            if (response.data?.daily != null) {
              final activities =
                  response.data!.daily!.where((e) => e != null).map((e) => e!).map((e) {
                final ScheduleType type = ScheduleTypeExtend.getTypeFromIndex(e.type);
                // TODO: Map to icon
                return HomeActivityData(
                  icon: R.drawable.ic_home_activity,
                  title: e.name ?? "-",
                  description: e.description,
                );
              }).toList();
              home.activities = activities;
            }
          },
          failure: (error) {},
        );
        yield HomeLoaded(model: home);

        // load reminders
        final remindersResponse = await UserClient().fetchScheduleReminders();
        if (remindersResponse.models.isNotEmpty) {
          final reminders = remindersResponse.models.map((e) {
            return HomeReminderData(
              icon: R.drawable.ic_home_measurement_glucose_inactive,
              title: e.name ?? "-",
              time: "today",
              // TODO: Map to navigator
              navigatorName: "TODO",
            );
          }).toList();
          home.reminders = reminders;
        }
        AppSettings.saveHome(home.toJson()).catchError((e) {
          print(e);
          return true;
        });
        yield HomeLoaded(model: home);

        // load learning post
        final lessonsResponse = await LearningClient().fetchLearningPost(null);
        if (lessonsResponse.isNotEmpty) {
          final lessons = lessonsResponse;
          home.lessons = lessons;
          // TODO: replace
          final news = lessonsResponse.map((e) {
            return HomeNewsData(
              id: e.id!,
              icon: R.drawable.ic_lesson_category,
              category: "Bài học",
              title: e.title,
              imageUrl: e.imageUrl.url,
            );
          }).toList();
          home.news = news;
        }

        _cached = home;
        yield HomeLoaded(model: home);

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
        navigatorName: NavigatorName.add_nutrition,
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
        args: {'type': 'input', 'id': null},
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

  List<HomeMeasurementInlineData>? _castInlineMeasurements(HomeModel model) {
    // Hb1Ac
    final haveHba1c = model.hbA1CIndex.index != null && model.hbA1CIndex.index! > 0;
    final hba1c = HomeMeasurementInlineData(
      title: "HbA1C",
      titleColor: haveHba1c ? _haveValueTitleColor : _noValueTitleColor,
      value: haveHba1c ? model.hbA1CIndex.index!.toString() : "--",
      color: model.hbA1CIndex.color != null
          ? _convertHexStringToInt(model.hbA1CIndex.color!)
          : _noValueColor,
      unit: "%",
      navigatorName: haveHba1c ? NavigatorName.detail_hba1c : NavigatorName.add_hba1c,
    );

    // Weight
    final haveWeight = model.weightCard?.weight != null && model.weightCard!.weight! > 0;
    final weight = HomeMeasurementInlineData(
      title: "Cân nặng",
      icon: R.drawable.ic_home_weight,
      titleColor: haveWeight ? _haveValueTitleColor : _noValueTitleColor,
      value: haveWeight ? model.weightCard!.weight!.toString() : "--",
      color: model.weightCard?.weightColorCode != null
          ? _convertHexStringToInt(model.weightCard!.weightColorCode!)
          : _noValueColor,
      unit: "Kg",
      navigatorName: haveWeight ? NavigatorName.detail_bmi : NavigatorName.add_bmi,
    );

    // TODO: Check please
    // BMI
    final haveBmi = false;
    final bmi = HomeMeasurementInlineData(
      title: "BMI",
      titleColor: haveBmi ? _haveValueTitleColor : _noValueTitleColor,
      value: "--",
      unit: "Kg/m²",
      color: _noValueColor,
    );

    return [
      hba1c,
      weight,
      bmi,
    ];
  }

  List<HomeMeasurementData>? _castMeasurements(HomeModel model) {
    // Glucose
    final haveGlucose = model.glucoseIndex.index != null && model.glucoseIndex.index! > 0;
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
      unit: model.glucoseIndex.unit,
      navigatorName:
          haveGlucose ? NavigatorName.detail_blood_sugar : NavigatorName.add_blood_sugar_new,
    );

    // TODO: Check please
    // Blood Pressure
    final haveBloodPressure = model.bloodPressureIndex.systolic != null &&
        model.bloodPressureIndex.diastolic != null &&
        model.bloodPressureIndex.systolic! > 0 &&
        model.bloodPressureIndex.diastolic! > 0;
    final bloodPressure = HomeMeasurementData(
      title: "Huyết Áp",
      titleColor: haveBloodPressure ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveBloodPressure
          ? R.drawable.ic_home_measurement_blood
          : R.drawable.ic_home_measurement_blood_inactive,
      value1: haveBloodPressure ? model.bloodPressureIndex.systolic!.toString() : "--",
      value1Color: model.bloodPressureIndex.color != null
          ? _convertHexStringToInt(model.bloodPressureIndex.color!)
          : _noValueColor,
      value2: haveBloodPressure ? model.bloodPressureIndex.diastolic!.toString() : "--",
      value2Color: model.bloodPressureIndex.color != null
          ? _convertHexStringToInt(model.bloodPressureIndex.color!)
          : _noValueColor,
      unit: "mmHg",
      navigatorName: haveBloodPressure
          ? NavigatorName.detail_blood_pressure
          : NavigatorName.add_blood_pressure,
    );

    // Exercise
    final haveExercise = model.exercise?.index != null && model.exercise!.index! > 0;
    final exercise = HomeMeasurementData(
      title: "Vận động",
      titleColor: haveExercise ? _haveValueTitleColor : _noValueTitleColor,
      icon: haveExercise
          ? R.drawable.ic_home_measurement_exercise
          : R.drawable.ic_home_measurement_exercise_inactive,
      value1: haveExercise ? model.exercise!.index!.toString() : "--",
      value1Color: haveExercise ? _haveValueTitleColor : _noValueColor,
      value2: null,
      value2Color: null,
      unit: model.exercise?.unit ?? "--",
      navigatorName: haveExercise ? NavigatorName.detail_exercrises : NavigatorName.add_exercrises,
    );

    // Nutrition (Food)
    final haveNutrition =
        model.energyCard?.consumedEnergy != null && model.energyCard!.consumedEnergy! > 0;
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
      unit: "kCal",
      navigatorName: haveNutrition ? NavigatorName.detail_food : NavigatorName.add_food,
    );

    // Emotion
    final haveEmotion =
        model.emotionCard?.details != null && model.emotionCard!.details!.isNotEmpty;
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
    );

    // Compose
    return [
      glucose,
      bloodPressure,
      exercise,
      nutrition,
      emotion,
    ];
  }

  // Stream<HomeState> _syncHealthApp() async* {}
}
