import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input_data_model.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_lastestSumary.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/model/response/config/hba1c_color_config.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:easy_localization/easy_localization.dart';

class HbA1CClient extends FetchClient {
  Future<LastestSummaryModel> fetchLastestSumary(
      int currentDateTime, int periodFilterType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/HbA1C/LatestSummary', params: {
        'currentDateTime': currentDateTime.toString(),
        'periodFilterType': periodFilterType.toString()
      });
      if (response.statusCode == 200) {
        return LastestSummaryModel.fromJson(response.data['data']);
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

  Future<List<Hba1cColorConfig>?> fetchColorConfig() async {
    final Response response =
        await super.fetchData(url: '/App/HbA1C/Config/Status', params: {});

    if (response.statusCode == 200) {
      final listResponse = ListResponse.fromJson(
        response.data as Map<String, dynamic>,
        Hba1cColorConfig.fromJson,
      );
      return listResponse.data;
    }
    
    return null;
  }

  Future<InputHbA1CDataModel> fetchInput(
      int currentDateTime, int periodFilterType, int page) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/HbA1C/Input', params: {
        'currentDateTime': currentDateTime.toString(),
        'periodFilterType': periodFilterType.toString(),
        'page': '$page',
        'size': '10'
      });
      if (response.statusCode == 200) {
        return InputHbA1CDataModel(
            inputs: InputHbA1CModel.toList(response.data['data']),
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

  Future<TrendModel> fetchTrend(int type) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/HbA1C/Trend', params: {
        'takeAll': true.toString(),
        'currentDateTime':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        'trendType': type.toString()
      });
      if (response.statusCode == 200) {
        return TrendModel.fromJson(response.data['data']);
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

  Future<InputHbA1CModel> fetchDetail(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/HbA1C/Input/$id');
      if (response.statusCode == 200) {
        return InputHbA1CModel.fromJson(response.data['data']);
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

  Future<bool> postIndexHbA1C(int date, String hbA1CIndex, String description,
      List<String> files) async {
    try {
      final response = await super.postHttp(
          path: '/App/HbA1C/Input',
          params: {
            'date': date.toString(),
            'hbA1CIndex': hbA1CIndex,
            'description': description
          },
          files: files);

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> putIndexHbA1C(
      String? id,
      int date,
      String hbA1CIndex,
      String description,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'id': id ?? '',
        'date': date.toString(),
        'hbA1CIndex': hbA1CIndex,
        'description': description,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      final response = await super
          .putHttp(path: '/App/HbA1C/Input', params: params, files: files);
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> deleteIndexHbA1C(String? hbA1CId) async {
    try {
      final Response response =
          await super.delete(url: '/App/HbA1C/Input/$hbA1CId');
      if (response.statusCode == 200) {
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

  Future<ShortGuiModel> fetchShortGuide(int kPIType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/TermAndCondition/ShortGuide',
          params: {'kPIType': kPIType.toString()});
      if (response.statusCode == 200) {
        return ShortGuiModel.fromJson(response.data);
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

  Future<List<double>> fetchRange() async {
    try {
      final Response response = await super.fetchData(
        url: '/App/HbA1C/Range',
      );
      if (response.statusCode == 200) {
        List<double> data = List<double>.from(response.data);
        return data;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
