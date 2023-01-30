import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/api_methods.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models/getStepList_model.dart';
import 'models/requestSyncStep_model.dart';

class StepRepository extends FetchClient {
  Future getStepList(int? periodFilterType) async {
    // 1 = 7 ngày
    // 2 = 14 ngày
    // 3 = 30 ngày
    // 4 = 90 ngày
    // try {
    Map<String, dynamic>? requestData = {};
    if (periodFilterType != null) {
      requestData['periodFilterType'] = periodFilterType;
    }
    final response = await ApiMethods.get(
      path: '/App/Step/dashboard',
      data: requestData,
    );

    if (response.statusCode == 200) {
      return GetStepListModel.fromJson(jsonDecode(response.body)).data;
    } else {
      final error = Error.fromJson(jsonDecode(response.body));
      throw error;
    }
    // } catch (e) {
    //   throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }

  Future<bool> syncStepData(List<RequestSyncStepModel> stepListData) async {
    try {
      List<Map<String, dynamic>> requestData = [];
      stepListData.forEach((element) {
        requestData.add(element.toJson());
      });
      final response = await ApiMethods.post(
          path: '/App/Step/step-async', data: requestData);
          
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
