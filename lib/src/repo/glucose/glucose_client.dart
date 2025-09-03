import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/bloc/nipro/model/glucose_data.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/glucose/Glucose_Input_data_model.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/modal/glucose/glucose_data_trend.dart';
import 'package:medical/src/modal/glucose/glucose_distribution.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_lesson.dart';
import 'package:medical/src/modal/glucose/glucose_range_data.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/model/response/config/glucose_color_config.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io' show Platform;

import '../../widget/home/fliter_enum.dart';

class GlucoseClient extends FetchClient {
  Future<List<TimeFrameModel>> fetchFlucoseTimeFrame({int? time}) async {
    // try {
    final Response response = await super.fetchData(
        url: '/App/TimeFrame',
        params: time == null ? {} : {'time': time.toString()});

    if (response.statusCode == 200) {
      return TimeFrameModel.toList(response.data['data']);
    } else {
      final error = Error.fromJson(response);
      throw error;
    }
    // } catch (e) {
    //   throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }

  Future<List<TimeFrameModel>> fetchFlucoseTimeFrameV2({int? time}) async {
    // try {
    final Response response = await super.fetchData(
        url: '/app/TimeFrame/Glucose',
        params: time == null ? {} : {'time': time.toString()});

    if (response.statusCode == 200) {
      return TimeFrameModel.toList(response.data['data']);
    } else {
      final error = Error.fromJson(response);
      throw error;
    }
  }

  Future<bool> checkGlucoseSchedulerExisting() async {
    final Response response = await super.fetchData(url: '/App/Patient/IsExistPatientGlucoseRemind', params: {});
    if (response.statusCode == 200) {
      return response.data['data'] == true;
    }
    return false;
  }

  Future<List<GlucoseColorConfig>?> fetchColorConfig() async {
    final Response response = await super.fetchData(url: '/App/Glucose/Config/Status', params: {});

    if (response.statusCode == 200) {
      final listResponse = ListResponse.fromJson(
        response.data as Map<String, dynamic>,
        GlucoseColorConfig.fromJson,
      );
      return listResponse.data;
    }
    return null;
  }

  Future<GlucoseLesson?> fetchGlucoseUpcommingLesson() async {
    final Response response = await super.fetchData(url: '/App/Glucose/Lesson/Normal');

    if (response.statusCode == 200) {
      final singleResponse = SingleResponse.fromJson(
        response.data as Map<String, dynamic>,
        GlucoseLesson.fromJson,
      );
      return singleResponse.data;
    }
    return null;
  }

  Future<List<GlucoseLesson>?> fetchGlucoseLessons() async {
    final Response response = await super.fetchData(url: '/App/Lesson/LessonSupport', params: {});

    if (response.statusCode == 200) {
      final listResponse = ListResponse.fromJson(
        response.data as Map<String, dynamic>,
        GlucoseLesson.fromJson,
      );
      return listResponse.data;
    }
    return null;
  }

  Future<String?> fetchGlucoseInputAnalysis(
    String id,
    int unit,
  ) async {
    Map<String, String> params = {
      'id': id,
      'unit': unit.toString(),
    };
    final Response response = await super.fetchData(
      url: '/App/Glucose/Analysis/Index',
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

  Future<String?> fetchGlucoseAlltimeAnalysis(int periodFilterType) async {
    final Response response = await super.fetchData(
      url: '/App/Glucose/Analysis/HealthTrend',
      params: {
        'periodFilterType': periodFilterType.toString(),
        'currentDateTime': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
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

//============ lấy tần suất phân bổ =============/

  Future<DistributionModel> fetchFlucoseDistribution(
      String? currentDateTime, String? periodFilterType, String? page) async {
    // Map<String, String> params = {'page': '$page', 'size': '10'};
    // if (currentDateTime != null && periodFilterType != null) {
    //   params['currentDateTime'] = '$currentDateTime';
    //   params['periodFilterType'] = '$periodFilterType';
    // }
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_SUGAR.index);
      bool isGestationalDiabetes = Utils.isGestationalDiabetes();
      final Response response =
          await super.fetchData(url: '/App/Glucose/Distribution', params: {
        'page': page,
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'thresholdType': isGestationalDiabetes ? '1' : '0',
      });
      if (response.statusCode == 200) {
        return DistributionModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //============ lấy tất cả chỉ số Đường huyết theo chu kỳ =============/

  Future<InputGlucoseDataModel> fetchInput(
      String? currentDateTime,
      String? periodFilterType,
      int? page,
      String? timeFrameType,
      String? glucoseDistributionType,
      {String size = '20'}) async {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_SUGAR.index);
      bool isGestationalDiabetes = Utils.isGestationalDiabetes();
      Map<String, String> params = {
        'size': size,
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'thresholdType': isGestationalDiabetes ? '1' : '0',
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<String> fetchUserManual() async {
    try {
      final Response response = await super.fetchData(
          url: Platform.isIOS
              ? '/App/CommonConfigureTask/Key/Glucose.Device.Bluetooth.Guid.IOS'
              : '/App/CommonConfigureTask/Key/Glucose.Device.Bluetooth.Guid.Android');
      if (response.statusCode == 200) {
        return response.data['data']['description'] ?? '';
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<dynamic>> fetchGlucoseInputNotExist(
      List<GlucoseData> glucoses) async {
    try {
    List<Map<String, dynamic>> params = [];
    glucoses.forEach((element) {
      params.add({
        'glucose': element.glucose,
        'createDate': element.date,
        'unitType': 1
      });
    });
    final response = await super.postHttp2(
        path: '/App/Glucose/GlucoseInputsNotExist',
        params: jsonEncode({'glucoseInputs': params}));

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      return jsonDecode(data)['data'];
    } else {
      throw response.reasonPhrase!;
    }
    } catch (e) {
      print(e.toString());
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> postGlucoseInputs(
    List<Map<String, String>> glucoses, {
    int? type,
    String? modelName,
    String? modelNumber,
  }) async {
    try {
      List<Map<String, dynamic>> params = [];
      glucoses.forEach((element) {
        params.add({
          'glucose': double.tryParse(element['glucose']!) ?? 0,
          'createDate': int.tryParse(element['date']!) ?? 0,
          'unitType': type ?? 1,
          'modelName': modelName,
          'modelNumber': modelNumber,
        });
      });

      final response = await super.postHttp2(
          path: '/App/Glucose/Inputs',
          params: jsonEncode({'glucoseInputs': params}));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //============ nhập chỉ số Đường huyết =============/

  Future<GlucoseInputResult?> postIndexGlucose(String? timeFrameId, int date, String glucoseInput,
      String? reason, String note, bool byDevice, List<String> files) async {
    try {
      bool isGestationalDiabetes = Utils.isGestationalDiabetes();
      Map<String, String> params = {
        'timeFrameId': timeFrameId ?? '',
        'createDate': date.toString(),
        'unitType': AppSettings.userInfo!.glucoseUnit.toString(),
        'glucoseInput': glucoseInput,
        'note': note,
        'byDevice': byDevice.toString(),
        'thresholdType': isGestationalDiabetes ? '1' : '0',
      };
      if (reason != null) {
        params['reason'] = reason;
      }
      final response =
          await super.postHttp(path: '/App/Glucose/Input', params: params, files: files);

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = jsonDecode(data);
        String? id = jsonData['data']?['id'];
        if (id != null) {
          try {
            final detailResponse = await fetchDetail(id);
            return GlucoseInputResult(
              id: detailResponse.id ?? id,
              images: detailResponse.images,
            );
          } catch (e) {
            print(e);
          }
        }
        return null;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ cập nhật Thông tin Thai kỳ =============/
  Future<bool> updatePregnancyInfo({
    required int week,
    required num weight,
  }) async {
    try {
      Map<String, dynamic> params = {
        'week': week,
        'weight': weight,
      };
      final response = await super.postHttp2(
        path: '/App/Glucose/InputGlucosePregnancyConfigures',
        params: jsonEncode(params),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ Lấy ngưỡng đường huyết =============/
  Future<GlucoseRangeData?> getGlucoseRange({
    required int thresholdType,
    required String timeFrameCode,
  }) async {
    // try {
    Map<String, String> params = {
      'thresholdType': thresholdType.toString(),
      'TimeFrameCode': timeFrameCode,
    };
    final response = await super.fetchData(
      url: '/App/Glucose/GetGlucose',
      params: params,
    );

    Console.logJson('hehe', response.data['data']);
    if (response.statusCode == 200) {
      return GlucoseRangeData.fromJson(response.data['data']);
    } else {
      return null;
    }
    // } catch (e) {
    //   throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    // }
  }

  //============ xóa chỉ số Đường huyết =============/

  Future<bool> deleteIndexGlucose(String? glucoseId) async {
    try {
      final Response response =
          await super.delete(url: '/App/Glucose/Input/$glucoseId');
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

  //============ lấy xu hướng =============/
  Future<TrendDataModel> fetchGlucoseTrend(String? timeFrameId,
      String? currentDateTime, String? periodFilterType, String? page) async {
    try {
      // periodFilterType =
      //     await AppSettings.getPeriodByScreen(ScreenList.BLOOD_SUGAR.index);
      bool isGestationalDiabetes = Utils.isGestationalDiabetes();
      Map<String, String?> requestData = {
        'page': page,
        "currentDateTime": currentDateTime,
        'periodFilterType': periodFilterType,
        'thresholdType': isGestationalDiabetes ? '1' : '0',
      };
      if (timeFrameId != null) {
        requestData["timeFrameType"] = timeFrameId;
      }
      final Response response =
          await super.fetchData(url: '/App/Glucose/Trend', params: requestData);
      if (response.statusCode == 200) {
        return TrendDataModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ lấy so sánh =============/

  Future<List<ComparerModel>> fetchFlucoseComparer(String? currentDateTime,
      String? periodFilterType, int? page, String? comparerType) async {
    try {
      periodFilterType =
          await AppSettings.getPeriodByScreen(ScreenList.BLOOD_SUGAR.index);
      final Response response =
          await super.fetchData(url: '/App/Glucose/Comparer', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': page.toString(),
        'comparerType': comparerType,
      });

      if (response.statusCode == 200) {
        return ComparerModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //============ update chỉ số đường huyết =============/

  Future<GlucoseInputResult?> putIndexGlucose(
      String? id,
      String? timeFrameId,
      int date,
      String glucoseInput,
      String? reason,
      String note,
      bool byDevice,
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
        'removalImageIdsStr': removalImageIds.join(';'),
        'byDevice': byDevice.toString()
      };
      if (reason != null) {
        params['reason'] = reason;
      }
      final response = await super
          .putHttp(path: '/App/Glucose/Input', params: params, files: files);

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = jsonDecode(data);
        String? id = jsonData['data']?['id'];
        if (id != null) {
          try {
            final detailResponse = await fetchDetail(id);
            return GlucoseInputResult(
              id: detailResponse.id ?? id,
              images: detailResponse.images,
            );
          } catch (e) {
            print(e);
          }
        }
        return null;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}

class GlucoseInputResult {
  final String id;
  final List<ImagesModel> images;

  GlucoseInputResult({
    required this.id,
    required this.images,
  });
}
