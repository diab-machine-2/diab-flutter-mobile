import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../model/request/complete_smart_goal_request.dart';
import '../../model/response/common_response.dart';
import '../../model/response/smart_goal_list_reponse.dart';
import '../../model/service/api_result.dart';
import '../../model/service/network_exceptions.dart';

class HomeClient extends FetchClient {
  final AppRepository repository = AppRepository();

  Future<HomeModel> fetchHomes() async {
    try {
      final Response response = await super.fetchData(url: '/App/Home');
      if (response.statusCode == 200) {
        await AppSettings.saveHome(response.data['data']);
        return HomeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<void> completeSmartGoal(DateTime selectedDate, String? id, int? executeDayTimes, int? type) async {
    if (id == null) return;
    DateTime dateTime0 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0);
    int startDate = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();
    
    final CompleteSmartGoalRequest request =
        CompleteSmartGoalRequest(id: id, executeTimes: executeDayTimes, type: type, appointmentDate: startDate);
    final ApiResult<CommonResponse> apiResult = await repository.completeSmartGoal(request);
    apiResult.when(success: (CommonResponse response) {
      print('completeSmartGoal success');
    }, failure: (NetworkExceptions error) {
      print('completeSmartGoal error');
    });
  }
}
