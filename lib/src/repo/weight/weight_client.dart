import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/bmi/bmi_trend.dart';
import 'package:medical/src/modal/bmi/calculate_bmi.dart';
import 'package:medical/src/modal/bmi/weight_input.dart';
import 'package:medical/src/modal/bmi/weight_input_data_model.dart';
import 'package:medical/src/modal/bmi/weight_trend.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class WeightClient extends FetchClient {
  // nhập chỉ chỉ số cân nặng
  Future<bool> postWeightInput(int date, List<String> files, String weight,
      String? waist, String height, String note, String? timeFrameId) async {
    // try {
    Map<String, String> params = {
      'date': date.toString(),
      'weight': weight,
      'height': height,
      'timeFrameId': timeFrameId ?? '',
      'note': note,
    };
    if (waist != null) {
      params['waist'] = waist;
    }
    final response = await super
        .postHttp(path: '/App/Weight/Input', params: params, files: files);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw response.reasonPhrase!;
    }
    // } catch (e) {
    //   throw e is Error
    //       ? e
    //       : R.string.error_can_not_connect_to_server.tr();
    // }
  }
  // //============ lấy danh sách chỉ số Weight =============/

  // Future<InputWeightDataModel> fetchInput(
  //   String startDateTime,
  //   String endDateTime,
  //   int page,
  // ) async {
  //   try {
  //     Map<String, String> params = {
  //       'startDateTime': '$startDateTime',
  //       'endDateTime': '$endDateTime',
  //       'size': '10'
  //     };

  //     if (page != null) {
  //       params['page'] = page.toString();
  //     }
  //     final Response response =
  //         await super.fetchData(url: '/App/Weight/Input', params: params);

  //     if (response.statusCode == 200) {
  //       return InputWeightDataModel(
  //           inputs: InputWeightDataModel.toList(response.data['data']),
  //           hasMore: response.data['meta']['canNext']);
  //     } else {
  //       final error = Error.fromJson(response);
  //       throw error;
  //     }
  //   } catch (e) {
  //     throw R.string.error_can_not_connect_to_server.tr();
  //   }
  // }
  //============ lấy chi tiết Weight =============/

  // Future<InputBmiModel> fetchDetail(String id) async {
  //   try {
  //     final Response response =
  //         await super.fetchData(url: '/App/Weight/Input/$id ');
  //     if (response.statusCode == 200) {
  //       return InputBmiModel.fromJson(response.data['data']);
  //     } else {
  //       final error = Error.fromJson(response);
  //       throw error;
  //     }
  //   } catch (e) {
  //     throw R.string.error_can_not_connect_to_server.tr();
  //   }
  // }

  //============ xóa chỉ số Weight =============/
  Future<bool> deleteIndexBmi(String? bmiId) async {
    try {
      final Response response =
          await super.delete(url: '/App/Weight/Input/$bmiId');
      print(response);
      if (response.statusCode == 200) {
        print('delete success');
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ cập nhật chỉ số Weight =============/
  Future<bool> putIndexBmi(
      String? id,
      int date,
      String weight,
      String waist,
      String height,
      String note,
      String? timeFrameId,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      final Map<String, String> params = {
        'id': id ?? '',
        'date': date.toString(),
        'weight': weight,
        'waist': waist,
        'height': height,
        'timeFrameId': timeFrameId ?? '',
        'note': note,
      };
      for (int i = 0; i < removalImageIds.length; i++) {
        params['removalImageIds[$i]'] = removalImageIds[i] ?? '';
      }
      final response = await super
          .putHttp(path: '/App/Weight/Input', params: params, files: files);

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ lấy xu hướng =============/
  Future<TrendWeightModel> fetchWeightTrend(
      String? currentDateTime, String? periodFilterType, String? page) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Weight/Statistic/Weight', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': page ?? '10'
      });
      if (response.statusCode == 200) {
        return TrendWeightModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //============ lấy xu hướng =============/
  Future<TrendWeightModel> fetchHipTrend(
      String? currentDateTime, String? periodFilterType, String? page) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Weight/Statistic/Waist', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': page
      });
      if (response.statusCode == 200) {
        return TrendWeightModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //============ lấy tất cả chỉ số Đường huyết theo chu kỳ =============/

  Future<InputWeightDataModel> fetchInput(
    String? currentDateTime,
    String? periodFilterType,
    int? page, {
    int? size,
  }) async {
    try {
      Map<String, String> params = {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'size': size != null ? size.toString() : '10'
      };

      if (page != null) {
        params['page'] = page.toString();
      }
      final Response response =
          await super.fetchData(url: '/App/Weight/Input', params: params);

      if (response.statusCode == 200) {
        return InputWeightDataModel(
            inputs: InputWeightModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //============ lấy chi tiết chỉ số Cân nặng =============/

  Future<InputWeightModel> fetchDetail(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Weight/Input/$id');
      if (response.statusCode == 200) {
        return InputWeightModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //============ calculate BMI =============/

  Future<CaculateBMIModel> fetchCaculateBMI(
    double weight,
    int height,
  ) async {
    try {
      Map<String, String> params = {
        'weight': weight.toString(),
        'height': height.toString(),
      };

      final Response response =
          await super.fetchData(url: '/App/Bmi/Calculate-Bmi', params: params);

      if (response.statusCode == 200) {
        return CaculateBMIModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<TrendBmiModel> fetchTrendBMI(
      String? currentDateTime, String? periodFilterType) async {
    try {
      Map<String, String> params = {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'size': '100'
      };
      final Response response = await super
          .fetchData(url: '/App/Weight/Statistic/Bmi', params: params);
      if (response.statusCode == 200) {
        return TrendBmiModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> addWaistTarget(int value) async {
    try {
      final response = await super
          .postHttp2(path: '/App/Patient/WaistGoal', params: value.toString());
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> addWeightTarget(double value) async {
    try {
      final response = await super
          .postHttp2(path: '/App/Patient/WeightGoal', params: value.toString());
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
