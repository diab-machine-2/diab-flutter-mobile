import 'package:dio/dio.dart';
import 'package:medical/modal/blood_pressure/bloodPressure_Input_data_model.dart';
import 'package:medical/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_distribution.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_heart_rate.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_statistic.dart';
import 'package:medical/modal/blood_pressure/blood_pressure_trend.dart';
import 'package:medical/widget/helper/http_helper.dart';
import 'package:medical/modal/error/error_model.dart';

class BloodPressureClient extends FetchClient {
// lấy nhịp yim và huyết áp
  Future<BloodPressureHeartRateModel> fetchBloodPressureHeartRate(
      String currentDateTime, String periodFilterType) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy danh sách huyết áp
  Future<BloodPressureDataModel> fetchBloodPressureInput(String currentDateTime,
      String periodFilterType, String bloodPressureType, int page) async {
    try {
      Map<String, String> params = {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'size': '10'
      };
      if (bloodPressureType != null && bloodPressureType != 'null') {
        params['bloodPressureType'] = bloodPressureType;
      }
      if (page != null) {
        params['page'] = page.toString();
      }
      print(params);
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy chỉ số huyết áp và nhịp tim gần nhất
  Future<BloodPressureModel> fetchBloodPressureLatest() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/BloodPressure/Input/Latest');
      if (response.statusCode == 200) {
        return BloodPressureModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy xu huớng huyết áp
  Future<BloodPressureTrendModel> fetchBloodPressureTrend(
      int currentDateTime, int periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Trend',
          params: {
            'currentDateTime': '$currentDateTime',
            'periodFilterType': '$periodFilterType'
          });
      if (response.statusCode == 200) {
        return BloodPressureTrendModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy xu huớng nhịp tim
  Future<BloodPressureTrendModel> fetchPulseRateTrend(
      int currentDateTime, int periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/BloodPressure/Trend/PulseRate',
          params: {
            'currentDateTime': '$currentDateTime',
            'periodFilterType': '$periodFilterType'
          });
      if (response.statusCode == 200) {
        return BloodPressureTrendModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // nhập chỉ số huyết áp
  Future<bool> postBloodPressureInput(
      String systolic,
      String diastolic,
      String pulseRate,
      int date,
      String timeFrameId,
      String note,
      String reason,
      List<String> files) async {
    try {
      final response = await super.postHttp(
          path: '/App/BloodPressure/Input',
          params: {
            'systolic': systolic,
            'diastolic': diastolic,
            'pulseRate': pulseRate,
            'date': date.toString(),
            'timeFrameId': timeFrameId,
            'reason': reason,
            'note': note,
          },
          files: files);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  /// cập nhỉ chỉ số huyết áp
  Future<bool> updateBloodPressureInput(
      String id,
      String systolic,
      String diastolic,
      String pulseRate,
      int date,
      String timeFrameId,
      String note,
      String reason,
      List<String> removalImageIds,
      List<String> files) async {
    try {
      final response = await super.putHttp(
          path: '/App/BloodPressure/Input',
          params: {
            'id': id,
            'systolic': systolic,
            'diastolic': diastolic,
            'pulseRate': pulseRate,
            'date': date.toString(),
            'timeFrameId': timeFrameId,
            'note': note,
            'reason': reason,
            'removalImageIdsStr': removalImageIds.join(';')
          },
          files: files);

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        throw response.reasonPhrase;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy chi tiết huyết áp
  Future fetchBloodPressureDetail(String id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/BloodPressure/Input/$id');
      print(response);
      if (response.statusCode == 200) {
        return BloodPressureModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // xoá chỉ số huyết áp
  Future<bool> deleteBloodPressureInput(String id) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<String> checkBloodPressureInput(
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy tần suất phân bổ huyết ap
  Future<BloodPressureDistributionModel> fetchBloodDistribution(
      String currentDateTime, String periodFilterType) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }
}
