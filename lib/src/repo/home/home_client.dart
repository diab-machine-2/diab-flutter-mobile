import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/home/schema/measurement_schema.dart';

import '../../model/request/complete_smart_goal_request.dart';
import '../../model/response/common_response.dart';
import '../../model/service/api_result.dart';
import '../../model/service/network_exceptions.dart';

class HomeClient extends FetchClient {
  final AppRepository repository = AppRepository();

  Future<HomeModel> fetchHomes() async {
    try {
      final Response response = await super.fetchData(url: '/App/Home');
      if (response.statusCode == 200) {
        // await AppSettings.saveHome(response.data['data']);
        final model = HomeModel.fromJson(response.data['data']);

        model.inlineMeasurements = _castInlineMeasurements(model);
        model.measurements = _castMeasurements(model);
        model.utilities = getUtilities(full: false);

        return model;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<void> completeSmartGoal(
      DateTime selectedDate, String? id, int? executeDayTimes, int? type) async {
    if (id == null) return;
    DateTime dateTime0 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    int startDate = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();

    final CompleteSmartGoalRequest request = CompleteSmartGoalRequest(
        id: id, executeTimes: executeDayTimes, type: type, appointmentDate: startDate);
    final ApiResult<CommonResponse> apiResult = await repository.completeSmartGoal(request);
    apiResult.when(success: (CommonResponse response) {}, failure: (NetworkExceptions error) {});
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
    // TODO: Check please
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
      navigatorName: NavigatorName.add_bmi,
    );

    // TODO: Check please
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
      navigatorName: haveGlucose ? NavigatorName.blood_sugar_table : NavigatorName.add_blood_sugar,
    );

    // TODO: Check please
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
      navigatorName:
          haveBloodPressure ? NavigatorName.blood_pressure_table : NavigatorName.add_blood_pressure,
    );

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
      navigatorName: haveNutrition ? NavigatorName.detail_food : NavigatorName.food_menu,
    );

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
    return [
      glucose,
      bloodPressure,
      exercise,
      nutrition,
      emotion,
    ];
  }

  List<HomeUtilityData> getUtilities({bool full = false}) {
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
}
