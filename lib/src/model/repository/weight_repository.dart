import 'package:http/http.dart' as http;

import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/model/response/bmi_get_weight_detail_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/bmi_statistical_response.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

class WeightRepository {
  WeightRepository._();

  static final WeightRepository _instance = WeightRepository._();

  static WeightRepository get instance => _instance;

  Future<ApiResult<String>> analyzeWeightIndex(String id) async {
    try {
      final SingleResponse<String> response =
          await appClient.analyzeWeightIndex(id);
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<String>> analyzeWeightTrend({
    required int currentTime,
    required int periodFilterType,
    int page = 1,
    int? size,
  }) async {
    try {
      final SingleResponse<String> response =
          await appClient.analyzeWeightTrend(
        currentTime: currentTime,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
      );
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> submitWeightRecord(
      SubmitWeightRecordRequest request) async {
    try {
      final CommonResponse response =
          await appClient.submitWeightRecord(request);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiGetWeightListResponse>> getWeightIndexList({
    required int currentTime,
    required int periodFilterType,
    int page = 1,
    int? size,
  }) async {
    try {
      final BmiGetWeightListResponse response =
          await appClient.getWeightIndexList(
        currentTime: currentTime,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
      );
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiGetWeightDetailResponse>> getWeightDetail(
      String id) async {
    try {
      final SingleResponse<BmiGetWeightDetailResponse> response =
          await appClient.getWeightDetail(id);
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<List<BmiGetWeightLessonsResponse>>>
      getWeightLessons() async {
    try {
      final ListResponse<BmiGetWeightLessonsResponse> response =
          await appClient.getWeightLessons();
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiStatisticalResponse>> getBmiStatisticalData({
    required int currentTime,
    required int periodFilterType,
    int page = 1,
    int? size,
    bool? reverseItems,
    int? thresholdType,
    String? patientId,
    bool? takeAll,
  }) async {
    try {
      final SingleResponse<BmiStatisticalResponse> response =
          await appClient.getBmiStatisticalData(
        currentTime: currentTime,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
        reverseItems: reverseItems,
        thresholdType: thresholdType,
        patientId: patientId,
        takeAll: takeAll,
      );
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiWaistStatisticalResponse>> getWaistStatisticalData({
    required int currentTime,
    required int periodFilterType,
    int page = 1,
    int? size,
    bool? reverseItems,
    int? thresholdType,
    String? patientId,
    bool? takeAll,
  }) async {
    try {
      final SingleResponse<BmiWaistStatisticalResponse> response =
          await appClient.getWaistStatisticalData(
        currentTime: currentTime,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
        reverseItems: reverseItems,
        thresholdType: thresholdType,
        patientId: patientId,
        takeAll: takeAll,
      );
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiWeightStatisticalResponse>> getWeightStatisticalData({
    required int currentTime,
    required int periodFilterType,
    int page = 1,
    int? size,
    bool? reverseItems,
    int? thresholdType,
    String? patientId,
    bool? takeAll,
  }) async {
    try {
      final SingleResponse<BmiWeightStatisticalResponse> response =
          await appClient.getWeightStatisticalData(
        currentTime: currentTime,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
        reverseItems: reverseItems,
        thresholdType: thresholdType,
        patientId: patientId,
        takeAll: takeAll,
      );
      return ApiResult.success(data: response.data);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
}
