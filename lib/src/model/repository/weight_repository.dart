import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/model/response/bmi_get_analyze_weight_index_response.dart';
import 'package:medical/src/model/response/bmi_get_analyze_weight_trend_response.dart';
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
      final BmiGetAnalyzeWeightIndexResponse response =
          await appClient.analyzeWeightIndex(id);
      return ApiResult.success(data: response.data ?? "");
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
      final BmiGetAnalyzeWeightTrendResponse response =
          await appClient.analyzeWeightTrend(
        currentTime: currentTime ~/ 1000,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
      );
      return ApiResult.success(data: response.data ?? "");
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<CommonResponse>> submitWeightRecord(
      SubmitWeightRecordRequest request) async {
    try {
      final CommonResponse response = await appClient.submitWeightRecord(
        date: request.date ~/ 1000,
        weight: request.weight,
        height: request.height,
        waist: request.waist,
        note: request.note,
        images:
            request.images?.map((e) => MultipartFile.fromFileSync(e)).toList(),
      );
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
        currentTime: currentTime ~/ 1000,
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
      final BmiGetWeightDetailResponse response =
          await appClient.getWeightDetail(id);
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<List<BmiWeightLesson>>> getWeightLessons() async {
    try {
      final BmiGetWeightLessonsResponse response =
          await appClient.getWeightLessons();
      return ApiResult.success(data: response.data ?? []);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiStatistical>> getBmiStatisticalData({
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
      final BmiStatisticalResponse response =
          await appClient.getBmiStatisticalData(
        currentTime: currentTime ~/ 1000,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
        reverseItems: reverseItems,
        thresholdType: thresholdType,
        patientId: patientId,
        takeAll: takeAll,
      );
      return ApiResult.success(data: response.data!);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiWaistStatistical>> getWaistStatisticalData({
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
      final BmiWaistStatisticalResponse response =
          await appClient.getWaistStatisticalData(
        currentTime: currentTime ~/ 1000,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
        reverseItems: reverseItems,
        thresholdType: thresholdType,
        patientId: patientId,
        takeAll: takeAll,
      );
      return ApiResult.success(data: response.data!);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<BmiWeightStatistical>> getWeightStatisticalData({
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
      final BmiWeightStatisticalResponse response =
          await appClient.getWeightStatisticalData(
        currentTime: currentTime ~/ 1000,
        periodFilterType: periodFilterType,
        page: page,
        size: size,
        reverseItems: reverseItems,
        thresholdType: thresholdType,
        patientId: patientId,
        takeAll: takeAll,
      );
      return ApiResult.success(data: response.data!);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }
}
