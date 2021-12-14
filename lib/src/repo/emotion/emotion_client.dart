import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/emotion/activity_model.dart';
import 'package:medical/src/modal/emotion/emotion_model.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_item_model.dart';
import 'package:medical/src/modal/emotion/emotion_statistic_model.dart';
import 'package:medical/src/modal/emotion/input_emotion_data_model.dart';
import 'package:medical/src/modal/emotion/input_emotion_model.dart';
import 'package:medical/src/modal/emotion/symptom_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class EmotionClient extends FetchClient {
// Lấy danh sách emotion
  Future<List<EmotionModel>> fetchEmotion() async {
    try {
      final Response response = await super.fetchData(url: '/App/Emotion');

      if (response.statusCode == 200) {
        return EmotionModel.toList(response.data['data'][0]['emotions']);
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

  // Lấy danh sách triệu  chứng
  Future<List<SymptomModel>> fetchSymptom() async {
    try {
      final Response response = await super.fetchData(url: '/App/Symptom');

      if (response.statusCode == 200) {
        return SymptomModel.toList(response.data['data']);
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

  // Lấy danh sách vận động
  Future<List<ActivityModel>> fetchActivity() async {
    try {
      final Response response = await super.fetchData(url: '/App/Activity');

      if (response.statusCode == 200) {
        return ActivityModel.toList(response.data['data']);
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

  //============ lấy danh sách input Emotion =============/

  Future<InputEmotionDataModel> fetchInput(
    String? currentDateTime,
    String? periodFilterType,
    String? emotionId,
    int? page,
  ) async {
    try {
      Map<String, String> params = {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'size': '10'
      };
      if (emotionId != null) {
        params['emotionId'] = emotionId;
      }

      final Response response =
          await super.fetchData(url: '/App/Emotion/Input', params: params);

      if (response.statusCode == 200) {
        return InputEmotionDataModel(
            inputs: InputEmotionModel.toList(response.data['data']),
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
  //============ lấy chi tiết chỉ số cảm xúc =============/

  Future<InputEmotionModel> fetchDetail(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Emotion/Input/$id');
      if (response.statusCode == 200) {
        return InputEmotionModel.fromJson(response.data['data']);
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

  // nhập chỉ số cảm xúc
  Future<bool> postEmotionInput(
      String? emotionId,
      List<String?> symptomIds,
      List<String?> activityIds,
      String? otherSymptom,
      String? otherActivity,
      int date,
      String? timeFrameId,
      String note,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'emotionId': emotionId ?? '',
        'date': date.toString(),
        'timeFrameId': timeFrameId ?? '',
        'note': note,
      };
      for (int i = 0; i < symptomIds.length; i++) {
        params['symptomIds[$i]'] = symptomIds[i] ?? '';
      }
      for (int i = 0; i < activityIds.length; i++) {
        params['activityIds[$i]'] = activityIds[i] ?? '';
      }
      if (otherSymptom != null) {
        params['otherSymptom'] = otherSymptom;
      }
      if (otherActivity != null) {
        params['otherActivity'] = otherActivity;
      }
      final response = await super
          .postHttp(path: '/App/Emotion/Input', params: params, files: files);
      if (response.statusCode == 200) {
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

  /// cập nhạt chỉ số cảm xúc
  Future<bool> updateEmotionInput(
      String? id,
      String? emotionId,
      List<String?> symptomIds,
      List<String?> activityIds,
      String? otherSymptom,
      String? otherActivity,
      int date,
      String? timeFrameId,
      String note,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'id': id ?? '',
        'emotionId': emotionId ?? '',
        'date': date.toString(),
        'timeFrameId': timeFrameId ?? '',
        'note': note,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      for (int i = 0; i < symptomIds.length; i++) {
        params['symptomIds[$i]'] = symptomIds[i] ?? '';
      }
      for (int i = 0; i < activityIds.length; i++) {
        params['activityIds[$i]'] = activityIds[i] ?? '';
      }
      if (otherSymptom != null) {
        params['otherSymptom'] = otherSymptom;
      }
      if (otherSymptom != null) {
        params['otherActivity'] = otherActivity ?? '';
      }
      final response = await super
          .putHttp(path: '/App/Emotion/Input', params: params, files: files);

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

  //============ xóa chỉ số Emotion =============/
  Future<bool> deleteIndexEmotion(String? bmiId) async {
    try {
      final Response response =
          await super.delete(url: '/App/Emotion/Input/$bmiId');
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

  // Lấy thống kê emotion
  Future<EmotionStatisticModel> fetchEmotionStatistic(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Emotion/statistic/emotion', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': '1',
        'size': '1000'
      });

      if (response.statusCode == 200) {
        return EmotionStatisticModel.fromJson(response.data['data']);
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

  // Lấy danh sách thống kê triệu chứng
  Future<List<EmotionStatisticItemModel>> fetchSymptomStatistic(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Emotion/statistic/symptom', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': '1',
        'size': '1000'
      });

      if (response.statusCode == 200) {
        return EmotionStatisticItemModel.toList(
            response.data['data']['symptoms']);
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

  // Lấy danh sách thống kê hoạt động
  Future<List<EmotionStatisticItemModel>> fetchActivityStatistic(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super
          .fetchData(url: '/App/Emotion/statistic/activity', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': '1',
        'size': '1000'
      });

      if (response.statusCode == 200) {
        return EmotionStatisticItemModel.toList(
            response.data['data']['activities']);
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
}
