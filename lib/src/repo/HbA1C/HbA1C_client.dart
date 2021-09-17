import 'package:dio/dio.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input_data_model.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_lastestSumary.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

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
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
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
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
        print(response);
        return TrendModel.fromJson(response.data['data']);
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

  Future<InputHbA1CModel> fetchDetail(String id) async {
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
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
        print(await response.stream.bytesToString());
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> putIndexHbA1C(
      String id,
      int date,
      String hbA1CIndex,
      String description,
      List<String> removalImageIds,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'id': id,
        'date': date.toString(),
        'hbA1CIndex': hbA1CIndex,
        'description': description,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      final response = await super
          .putHttp(path: '/App/HbA1C/Input', params: params, files: files);
      print(response);
      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> deleteIndexHbA1C(String hbA1CId) async {
    try {
      final Response response =
          await super.delete(url: '/App/HbA1C/Input/$hbA1CId');
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
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }
}
