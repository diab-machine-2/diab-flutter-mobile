import 'package:dio/dio.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/revise_weight_record_request.dart';
import 'package:medical/src/model/request/submit_weight_record_request.dart';
import 'package:medical/src/model/response/bmi_get_analyze_weight_index_response.dart';
import 'package:medical/src/model/response/bmi_get_analyze_weight_trend_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_detail_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/model/response/bmi_get_weight_list_response.dart';
import 'package:medical/src/model/response/bmi_statistical_response.dart';
import 'package:medical/src/model/response/bmi_waist_statistical_response.dart';
import 'package:medical/src/model/response/bmi_weight_statistical_response.dart';
import 'package:medical/src/model/response/calculate_bmi_response.dart';
import 'package:medical/src/model/response/delete_weight_record_response.dart';
import 'package:medical/src/model/response/get_weight_threshold_response.dart';
import 'package:medical/src/model/response/submit_weight_record_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

class WeightRepository {
  WeightRepository._();

  static final WeightRepository _instance = WeightRepository._();

  static WeightRepository get instance => _instance;

  Future<ApiResult<List<WeightThreshold>>> getWeightThreshold({
    int? thresholdType,
    int? date,
    double? height,
    double? weight,
    double? waist,
  }) async {
    try {
      final GetWeightThresholdResponse response =
          await appClient.getWeightThreshold(
        thresholdType: thresholdType,
        date: date != null ? date ~/ 1000 : null,
        height: height,
        weight: weight,
        waist: waist,
      );
      return ApiResult.success(data: response.data ?? []);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

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

  Future<ApiResult<CaculateBmiModel>> calculateBmi({
    required double weight,
    required int height,
  }) async {
    try {
      final response = await appClient.calculateBmi(
        weight: weight,
        height: height,
      );
      return ApiResult.success(data: response.data!);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<SubmitWeightRecordResponse>> submitWeightRecord(
      SubmitWeightRecordRequest request) async {
    try {
      final SubmitWeightRecordResponse response =
          await appClient.submitWeightRecord(
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

  Future<ApiResult<SubmitWeightRecordResponse>> reviseWeightRecord(
      ReviseWeightRecordRequest request) async {
    try {
      final SubmitWeightRecordResponse response =
          await appClient.reviseWeightRecord(
        id: request.id,
        date: request.date ~/ 1000,
        weight: request.weight,
        height: request.height,
        waist: request.waist,
        note: request.note,
        removalImageIds: request.removalImageIds,
        images:
            request.images?.map((e) => MultipartFile.fromFileSync(e)).toList(),
      );
      return ApiResult.success(data: response);
    } catch (e) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(e));
    }
  }

  Future<ApiResult<bool>> deleteWeightRecord({
    required String id,
  }) async {
    try {
      final DeleteWeightRecordResponse response =
          await appClient.deleteWeightRecord(id: id);
      return ApiResult.success(data: response.data ?? false);
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

  Future<ApiResult<List<BmiWeightLesson>>> getWeightLessonsSupport() async {
    try {
      final BmiGetWeightLessonsResponse response =
          await appClient.getWeightLessonsSupport();
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
