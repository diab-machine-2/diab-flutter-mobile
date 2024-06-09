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
        await AppSettings.saveHome(response.data['data']);
        final model = HomeModel.fromJson(response.data['data']);
        // TODO:
        model.inlineMeasurements = _seedInlineMeasurements();
        model.measurements = _seedMeasurements();
        model.activities = _seedActivities();
        model.reminders = _seedReminders();
        model.utilities = _seedUtilities();
        model.lessons = _seedLessons();
        //
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

  List<HomeMeasurementInlineData>? _seedInlineMeasurements() {
    return [
      HomeMeasurementInlineData(
        title: "HbA1C",
        value: "9,0",
        unit: "%",
        color: 0xFF008479,
      ),
      HomeMeasurementInlineData(
        title: "Cân nặng",
        icon: R.drawable.ic_home_weight,
        value: "58",
        unit: "Kg",
        color: 0xFF008479,
      ),
      HomeMeasurementInlineData(
        title: "BMI",
        value: "25,4",
        unit: "Kg/m²",
        color: 0xFFD97708,
      ),
    ];
  }

  List<HomeMeasurementData>? _seedMeasurements() {
    return [
      HomeMeasurementData(
        title: "Đường Huyết",
        icon: R.drawable.ic_home_measurement,
        value1: "108",
        value1Color: 0xFFD97708,
        value2: null,
        value2Color: null,
        unit: "mol/L",
      ),
      HomeMeasurementData(
        title: "Huyết Áp",
        icon: R.drawable.ic_home_measurement,
        value1: "108",
        value1Color: 0xFFDC2625,
        value2: "102",
        value2Color: 0xFF008479,
        unit: "mmHg",
      ),
      HomeMeasurementData(
        title: "Vận động",
        icon: R.drawable.ic_home_measurement,
        value1: "14.108",
        value1Color: 0xFF008479,
        value2: null,
        value2Color: null,
        unit: "Phút",
      ),
      HomeMeasurementData(
        title: "Dinh Dưỡng",
        icon: R.drawable.ic_home_measurement,
        value1: null,
        value1Color: 0xFF008479,
        value2: null,
        value2Color: null,
        unit: "kCal",
      ),
    ];
  }

  List<HomeActivityData>? _seedActivities() {
    return [
      HomeActivityData(
        icon: R.drawable.ic_home_activity,
        title: "Nhập thông tin cá nhân",
        description: "Số điện thoại, tình trạng sức khỏe",
      ),
      HomeActivityData(
        icon: R.drawable.ic_home_activity,
        title: "Nhập chỉ số Đường huyết",
      ),
      HomeActivityData(
        icon: R.drawable.ic_home_activity,
        title: "Xem bài học",
      ),
      HomeActivityData(
        icon: R.drawable.ic_home_activity,
        title: "Nhập chỉ số Đường huyết",
      ),
      HomeActivityData(
        icon: R.drawable.ic_home_activity,
        title: "Xem bài học",
      ),
    ];
  }

  List<HomeReminderData>? _seedReminders() {
    return [
      HomeReminderData(
        icon: R.drawable.ic_home_measurement,
        title: "Đo đường huyết",
        time: "07:00 sáng",
        navigatorName: NavigatorName.add_blood_sugar,
      ),
      HomeReminderData(
        icon: R.drawable.ic_home_measurement,
        title: "Uống thuốc",
        time: "09:00 tối",
        navigatorName: NavigatorName.add_blood_sugar,
      ),
    ];
  }

  List<HomeUtilityData>? _seedUtilities() {
    final d = [
      HomeUtilityData(
        icon: R.drawable.ic_home_utility,
        title: "Thiết lập mục tiêu",
        navigatorName: NavigatorName.add_blood_sugar,
      ),
      HomeUtilityData(
        icon: R.drawable.ic_home_utility,
        title: "Lịch đo đường huyết",
        navigatorName: NavigatorName.add_blood_sugar,
      ),
    ];
    return [...d, ...d, ...d, ...d, ...d];
  }

  List<HomeLessonData>? _seedLessons() {
    return [
      HomeLessonData(
        id: "1",
        icon: R.drawable.ic_lesson_category,
        category: "Bài học",
        title: "Chế độ dinh dưỡng dành cho bệnh đái tháo đường bạn đã biết.",
        imageUrl: "https://picsum.photos/654/348",
      ),
      HomeLessonData(
        id: "2",
        icon: R.drawable.ic_lesson_category,
        category: "Bài học",
        title: "Chế độ dinh dưỡng dành cho bệnh đái tháo đường bạn đã biết.",
        imageUrl: "https://picsum.photos/654/348",
      ),
      HomeLessonData(
        id: "3",
        icon: R.drawable.ic_lesson_category,
        category: "Bài học",
        title: "Chế độ dinh dưỡng dành cho bệnh đái tháo đường bạn đã biết.",
        imageUrl: "https://picsum.photos/654/348",
      ),
      HomeLessonData(
        id: "4",
        icon: R.drawable.ic_lesson_category,
        category: "Bài học",
        title: "Chế độ dinh dưỡng dành cho bệnh đái tháo đường bạn đã biết.",
        imageUrl: "https://picsum.photos/654/348",
      ),
    ];
  }
}
