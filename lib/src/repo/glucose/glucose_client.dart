import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/glucose/Glucose_Input_data_model.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/modal/glucose/glucose_distribution.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class GlucoseClient extends FetchClient {
  Future<List<TimeFrameModel>> fetchFlucoseTimeFrame({int? time}) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/TimeFrame',
          params: time == null ? {} : {'time': time.toString()});
      if (response.statusCode == 200) {
        return TimeFrameModel.toList(response.data['data']);
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

//============ lấy tần suất phân bổ =============/

  Future<DistributionModel> fetchFlucoseDistribution(
      String? currentDateTime, String? periodFilterType, String? page) async {
    // Map<String, String> params = {'page': '$page', 'size': '10'};
    // if (currentDateTime != null && periodFilterType != null) {
    //   params['currentDateTime'] = '$currentDateTime';
    //   params['periodFilterType'] = '$periodFilterType';
    // }
    try {
      final Response response =
          await super.fetchData(url: '/App/Glucose/Distribution', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': page
      });
      if (response.statusCode == 200) {
        return DistributionModel.fromJson(response.data['data']);
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
  //============ lấy tất cả chỉ số Đường huyết theo chu kỳ =============/

  Future<InputGlucoseDataModel> fetchInput(
    String? currentDateTime,
    String? periodFilterType,
    int? page,
    String? timeFrameType,
    String? glucoseDistributionType,
  ) async {
    try {
      Map<String, String> params = {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'size': '20'
      };
      if (timeFrameType != null && timeFrameType != 'null') {
        params['timeFrameType'] = timeFrameType.toString();
      }
      if (glucoseDistributionType != null &&
          glucoseDistributionType != 'null') {
        params['glucoseDistributionType'] = glucoseDistributionType.toString();
      }
      if (page != null) {
        params['page'] = page.toString();
      }
      final Response response =
          await super.fetchData(url: '/App/Glucose/Input', params: params);

      if (response.statusCode == 200) {
        return InputGlucoseDataModel(
            inputs: InputGlucoseModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
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
//============ lấy chi tiết chỉ số Đường huyết =============/

  Future<InputGlucoseModel> fetchDetail(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Glucose/Input/$id');
      if (response.statusCode == 200) {
        return InputGlucoseModel.fromJson(response.data['data']);
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

  //============ nhập chỉ số Đường huyết =============/

  Future<bool> postIndexGlucose(
      String? timeFrameId,
      int date,
      String glucoseInput,
      String? reason,
      String note,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'timeFrameId': timeFrameId ?? '',
        'createDate': date.toString(),
        'unitType': AppSettings.userInfo!.glucoseUnit.toString(),
        'glucoseInput': glucoseInput,
        'note': note
      };
      if (reason != null) {
        params['reason'] = reason;
      }
      final response = await super
          .postHttp(path: '/App/Glucose/Input', params: params, files: files);

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ xóa chỉ số Đường huyết =============/

  Future<bool> deleteIndexGlucose(String? glucoseId) async {
    try {
      final Response response =
          await super.delete(url: '/App/Glucose/Input/$glucoseId');
      print(response);
      if (response.statusCode == 200) {
        print('delete success');
        return true;
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

  //============ lấy xu hướng =============/
  Future<TrendDataModel> fetchGlucoseTrend(String? timeFrameId,
      String? currentDateTime, String? periodFilterType, String? page) async {
    // Map<String, String> params = {'page': '$page', 'size': '10'};
    // if (currentDateTime != null && periodFilterType != null) {
    //   params['currentDateTime'] = '$currentDateTime';
    //   params['periodFilterType'] = '$periodFilterType';
    // }
    try {
      final Response response = await super.fetchData(
          url: '/App/Glucose/Trend',
          params: timeFrameId == null
              ? {
                  'currentDateTime': currentDateTime,
                  'periodFilterType': periodFilterType,
                  'page': page
                }
              : {
                  'timeFrameType': timeFrameId,
                  'currentDateTime': currentDateTime,
                  'periodFilterType': periodFilterType,
                  'page': page
                });
      if (response.statusCode == 200) {
        return TrendDataModel.fromJson(response.data['data']);
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

  //============ lấy so sánh =============/

  Future<List<ComparerModel>> fetchFlucoseComparer(String? currentDateTime,
      String? periodFilterType, String? page, String? comparerType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Glucose/Comparer', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': page,
        'comparerType': comparerType
      });
      if (response.statusCode == 200) {
        return ComparerModel.toList(response.data['data']);
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
  //============ update chỉ số đường huyết =============/

  Future<bool> putIndexGlucose(
      String? id,
      String? timeFrameId,
      int date,
      String glucoseInput,
      String? reason,
      String note,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'id': id ?? '',
        'timeFrameId': timeFrameId ?? '',
        'createDate': date.toString(),
        'glucoseInput': glucoseInput,
        'unitType': AppSettings.userInfo!.glucoseUnit.toString(),
        'note': note,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      if (reason != null) {
        params['reason'] = reason;
      }
      final response = await super
          .putHttp(path: '/App/Glucose/Input', params: params, files: files);

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
