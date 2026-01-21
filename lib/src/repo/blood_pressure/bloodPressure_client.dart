import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/base/keyvalue.dart';
import 'package:medical/src/modal/blood_pressure/bloodPressure_Input_data_model.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_distribution.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_heart_rate.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_statistic.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/src/modal/blood_pressure/bloodpressure_lesson.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/model/response/config/blood_pressure_color_config.dart';
import 'package:medical/src/utils/api_methods.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class BloodPressureClient extends FetchClient {
// lấy nhịp yim và huyết áp
  Future<BloodPressureHeartRateModel> fetchBloodPressureHeartRate(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Statistic/Period',
          params: {
            'currentDateTime': '$currentDateTime',
            'periodFilterType': '$periodFilterType'
          });
      if (response.statusCode == 200) {
        return BloodPressureHeartRateModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<BloodPressureColorConfig>?> fetchColorConfig() async {
    final Response response =
        await super.fetchData(url: '/App/BloodPressure/Config/Status', params: {});

    if (response.statusCode == 200) {
      final listResponse = ListResponse.fromJson(
        response.data as Map<String, dynamic>,
        BloodPressureColorConfig.fromJson,
      );
      return listResponse.data;
    }
    return null;
  }

  Future<List<KeyValue>> fetchReasons() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/BloodPressure/Input/Reasons', params: {});

      if (response.statusCode == 200) {
        final listData = response.data as List<dynamic>;
        return KeyValue.toList(listData);
      }
    } catch (e, stack) {
      TrackingManager.recordError(e, stack);
    }
    return [];
  }

  Future<bool> updateReasons(String id, List<String> reasons) async {
    try {
      final Map<String, dynamic> params = {
        'reasons': reasons,
      };
      final response = await super.putData(
        url: '/App/BloodPressure/Input/Reason/$id',
        params: params,
      );
      return response.statusCode == 200;
    } catch (e, stack) {
      TrackingManager.recordError(e, stack);
    }
    return false;
    
  }

  // lấy danh sách huyết áp
  Future<BloodPressureDataModel> fetchBloodPressureInput(
      String? currentDateTime,
      String? periodFilterType,
      String? bloodPressureType,
      int? page,
      {String size = '10'}) async {
    try {
      Map<String, String> params = {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'size': size
      };
      if (bloodPressureType != null && bloodPressureType != 'null') {
        params['bloodPressureType'] = bloodPressureType;
      }
      if (page != null) {
        params['page'] = page.toString();
      }
      final Response response = await super
          .fetchData(url: '/App/BloodPressure/Input', params: params);

      if (response.statusCode == 200) {
        return BloodPressureDataModel(
            inputs: BloodPressureModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // lấy chỉ số huyết áp và nhịp tim gần nhất
  Future<BloodPressureModel?> fetchBloodPressureLatest() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/BloodPressure/Input/Latest');
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['data'] != null) {
        return BloodPressureModel.fromJson(response.data['data']);
      } else {
        return null;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

// lấy chỉ số huyết áp và nhịp tim theo chu kỳ
  Future<BloodPressureStatisticModel> fetchBloodPressurePeriod(
      int currentDateTime, int periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Statistic/Period',
          params: {
            'currentDateTime': '$currentDateTime',
            'periodFilterType': '$periodFilterType'
          });
      if (response.statusCode == 200) {
        return BloodPressureStatisticModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // lấy xu huớng huyết áp
  Future<BloodPressureTrendModel> fetchBloodPressureTrend(
      int? currentDateTime, int? periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Trend',
          params: {
            'currentDateTime': '$currentDateTime',
            'periodFilterType': '$periodFilterType',
            'page': '1',
            'size': '100',
            'IsFromLatestTime': 'true'
          });
      if (response.statusCode == 200) {
        return BloodPressureTrendModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // lấy xu huớng nhịp tim
  Future<BloodPressureTrendModel> fetchPulseRateTrend(
      int? currentDateTime, int? periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Trend/PulseRate',
          params: {
            'currentDateTime': '$currentDateTime',
            'periodFilterType': '$periodFilterType',
            'page': '1',
            'size': '100',
          });
      if (response.statusCode == 200) {
        return BloodPressureTrendModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  
  Future<List<TimeFrameModel>> fetchBloodPressureTimeFrame({int? time}) async {
    final Response response = await super.fetchData(
        url: '/app/timeframe/kpi/blood-pressure',
        params: time == null ? {} : {'time': time.toString()});

    if (response.statusCode == 200) {
      return TimeFrameModel.toList(response.data['data']);
    } else {
      final error = Error.fromJson(response);
      throw error;
    }
  }

  // nhập chỉ số huyết áp
  Future<BloodPressureInputResult?> postBloodPressureInput(
      String systolic,
      String diastolic,
      String pulseRate,
      int date,
      String? timeFrameId,
      String note,
      String reason,
      List<String> files) async {
    final Map<String, String> params = {
      'systolic': systolic,
      'diastolic': diastolic,
      'pulseRate': pulseRate,
      'date': date.toString(),
      'timeFrameId': timeFrameId ?? '',
      'reason': reason,
      'note': note,
    };

    log('Blood pressure input params: $params');

    final response = await super.postHttp(
        path: '/App/BloodPressure/Input', params: params, files: files);

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
        final jsonData = jsonDecode(data);
        String? id = jsonData['data'];
        if (id != null) {
          try {
            final detailResponse = await fetchBloodPressureDetail(id);
            return BloodPressureInputResult(
              id: detailResponse.id ?? id,
              images: detailResponse.images,
              pulseRateStatus: detailResponse.pulseRateStatus ?? '-',
              bloodPressureStatus: detailResponse.bloodPressureType ?? '-',
            );
          } catch (e) {
            print(e);
          }
        }
      return null;
    } else {
      throw response.reasonPhrase!;
    }
  }

  Future<bool> postBloodPressureInputs(
      List<Map<String, dynamic>> bloodPressureDataList) async {
    try {
      final response = await ApiMethods.post(
          path: '/App/BloodPressure/Inputs', data: bloodPressureDataList);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// cập nhỉ chỉ số huyết áp
  Future<BloodPressureInputResult?> updateBloodPressureInput(
      String? id,
      String systolic,
      String diastolic,
      String pulseRate,
      int date,
      String? timeFrameId,
      String note,
      String reason,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      final Map<String, String> params = {
        'id': id ?? '',
        'systolic': systolic,
        'diastolic': diastolic,
        'pulseRate': pulseRate,
        'date': date.toString(),
        'timeFrameId': timeFrameId ?? '',
        'note': note,
        'reason': reason,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      final response = await super.putHttp(
          path: '/App/BloodPressure/Input', params: params, files: files);

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = jsonDecode(data);
        String? id = jsonData['data'];
        if (id != null) {
          try {
            final detailResponse = await fetchBloodPressureDetail(id);
            return BloodPressureInputResult(
              id: detailResponse.id ?? id,
              images: detailResponse.images,
              pulseRateStatus: detailResponse.pulseRateStatus ?? '-',
              bloodPressureStatus: detailResponse.bloodPressureType ?? '-',
            );
          } catch (e) {
            print(e);
          }
        }
        return null;
      } else {
        throw response.reasonPhrase ?? '';
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<String?> fetchBloodPressureInputAnalysis(
    String id,
  ) async {
    Map<String, String> params = {
      'id': id,
    };
    // Fetch blood pressure analysis data
    final Response response = await super.fetchData(
      url: '/App/BloodPressure/Analysis/Index',
      params: params,
    );

    if (response.statusCode == 200) {
      final singleResponse = SingleResponse.fromJsonTypeString(
        response.data as Map<String, dynamic>,
      );
      return singleResponse.data;
    }
    return null;
  }

  Future<String?> fetchBloodPressureAlltimeAnalysis(int periodFilterType) async {
    final Response response = await super.fetchData(
      url: '/App/BloodPressure/Analysis/HealthTrend',
      params: {
        'periodFilterType': periodFilterType.toString(),
        'currentDateTime': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        'page': '1',
        'size': '100',
      },
    );

    if (response.statusCode == 200) {
      final singleResponse = SingleResponse.fromJsonTypeString(
        response.data as Map<String, dynamic>,
      );
      return singleResponse.data;
    }
    return null;
  }

  // lấy chi tiết huyết áp
  Future<BloodPressureModel> fetchBloodPressureDetail(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/BloodPressure/Input/$id');
      // print(response);
      if (response.statusCode == 200) {
        return BloodPressureModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // xoá chỉ số huyết áp
  Future<bool> deleteBloodPressureInput(String? id) async {
    try {
      final Response response =
          await super.delete(url: '/App/BloodPressure/Input/$id');
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<String?> checkBloodPressureInput(
      String systolic, String diastolic) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Input/Validate',
          params: {'systolic': '$systolic', 'diastolic': '$diastolic'});
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // lấy tần suất phân bổ huyết ap
  Future<BloodPressureDistributionModel> fetchBloodDistribution(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Distribution',
          params: {
            'currentDateTime': currentDateTime,
            'periodFilterType': periodFilterType
          });
      if (response.statusCode == 200) {
        return BloodPressureDistributionModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<Map<String, List<int>>> fetchRange() async {
    try {
      final Response response = await super.fetchData(
        url: '/App/BloodPressure/Range',
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        Map<String, List<int>> processedData = {};

        responseData.forEach((key, value) {
          List<int> list = List<int>.from(value);
          processedData[key] = list;
        });

        return processedData;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<BloodPressureLesson>?> fetchBloodPressureLessons() async {
    final Response response = await super.fetchData(url: '/app/lesson/support/blood-pressure', params: {});

    if (response.statusCode == 200) {
      final listResponse = ListResponse.fromJson(
        response.data as Map<String, dynamic>,
        BloodPressureLesson.fromJson,
      );
      return listResponse.data;
    }
    return null;
  }
}

class BloodPressureInputResult {
  final String id;
  final List<ImagesModel> images;
  final String pulseRateStatus;
  final String bloodPressureStatus;

  BloodPressureInputResult({
    required this.id,
    required this.images,
    required this.pulseRateStatus,
    required this.bloodPressureStatus,
  });
}
