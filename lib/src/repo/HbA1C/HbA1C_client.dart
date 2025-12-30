import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input_data_model.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_lastestSumary.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_trend.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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
      int currentDateTime, int periodFilterType, int page,
      {bool takeAll = false}) async {
    try {
      Map<String, String> params = {
        'currentDateTime': currentDateTime.toString(),
        'page': '$page',
        'size': takeAll ? '500' : '10',
      };

      // When takeAll is true, use periodFilterType = 3 (24 months) with large size
      // This effectively gets "all" data within a reasonable timeframe
      if (takeAll) {
        params['periodFilterType'] = '3'; // 24 months
      } else {
        params['periodFilterType'] = periodFilterType.toString();
      }

      final Response response =
          await super.fetchData(url: '/App/HbA1C/Input', params: params);
      if (response.statusCode == 200) {
        return InputHbA1CDataModel(
            inputs: InputHbA1CModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<TrendModel> fetchTrend(int type, {bool takeAll = false}) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/HbA1C/Trend', params: {
        'takeAll': takeAll.toString(),
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> postIndexHbA1C(int date, String hbA1CIndex, String description,
      List<String> files) async {
    try {
      final params = {
        'date': date.toString(),
        'hbA1CIndex': hbA1CIndex,
        'description': description
      };
      log('HbA1C input params: $params');
      final response = await super.postHttp(path: '/App/HbA1C/Input', params: params, files: files);

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = (await response.stream.bytesToString());
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
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

  Future<String?> fetchHbA1CInputAnalysis({
    String? id,
    required String hba1cValue,
    required int date,
    String? note,
  }) async {
    try {
      final Response response = await super.fetchData(
        url: '/App/HbA1C/Analysis/Index',
        params: {
          'id': id ?? '',
          'hba1cValue': hba1cValue,
          'date': date.toString(),
          'note': note ?? '',
        },
      );
      if (response.statusCode == 200) {
        return response.data['data'] as String?;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<String?> fetchHbA1CTrendAnalysis(int periodFilterType,
      {bool takeAll = false}) async {
    try {
      Map<String, String> params = {
        'currentDateTime':
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        'page': '1',
        'size': takeAll ? '1000' : '100',
      };

      // When takeAll is true, use periodFilterType = 3 (24 months) with large size
      if (takeAll) {
        params['periodFilterType'] = '3'; // 24 months
      } else {
        params['periodFilterType'] = periodFilterType.toString();
      }

      final Response response = await super.fetchData(
        url: '/App/HbA1C/Analysis/Trend',
        params: params,
      );

      if (response.statusCode == 200) {
        final singleResponse = SingleResponse.fromJsonTypeString(
          response.data as Map<String, dynamic>,
        );
        return singleResponse.data;
      }
      return null;
    } catch (e) {
      print('Error fetching HbA1C trend analysis: $e');
      return null;
    }
  }

  // Fetch HbA1C lessons from /App/HbA1C/Lessons
  Future<List<LessonModel>> fetchHbA1CLessons() async {
    try {
      final Response response = await super.fetchData(
        url: '/App/HbA1C/Lessons',
        params: {},
      );

      print('🔍 HbA1C Lessons API Response: ${response.statusCode}');
      print('🔍 Response data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> rawData = [];

        // Check if response has 'data' field
        if (response.data['data'] != null) {
          rawData = response.data['data'];
        } else {
          rawData = response.data;
        }

        print('🔍 Raw data count: ${rawData.length}');

        // Print each raw item for debugging
        for (int i = 0; i < rawData.length; i++) {
          print(
              '🔍 Raw item [$i]: ${rawData[i]['name']} (ID: ${rawData[i]['id']})');
        }

        // Transform HbA1C API format to match LessonModel
        List<LessonModel> lessons = [];
        Set<String> seenIds = {}; // Track IDs to prevent duplicates

        for (int i = 0; i < rawData.length; i++) {
          var item = rawData[i];
          try {
            final String itemId = item['id'] ?? '';

            // Skip if duplicate ID
            if (seenIds.contains(itemId)) {
              print('⚠️ Skipping duplicate lesson ID: $itemId');
              continue;
            }
            seenIds.add(itemId);

            // Map HbA1C API fields to LessonModel expected fields
            Map<String, dynamic> transformedItem = {
              'id': itemId,
              'name': item['name'] ?? '',
              'status': item['status'] ?? 1,
              'type': item['type'] ?? 1,
              'level': item['lessonLevel'] ?? '', // lessonLevel -> level
              'module': item['lessonModule'] ?? '', // lessonModule -> module
              'learningStatus': item['learningStatus'] ?? 0,
              'percentComplete': item['percentComplete'] ?? 0,
              'order': item['order'] ?? 0,
              'levelOrder':
                  item['orderHighest'] ?? 0, // Use orderHighest as levelOrder
              'isNew': false, // Default to false if not provided
              'activeDateTime': 0, // Default to 0 if not provided
              'description': item['description'],
              'image': item['image'],
            };

            final lesson = LessonModel.fromJson(transformedItem);
            lessons.add(lesson);
            print('✅ Parsed lesson [$i]: ${lesson.name} (ID: ${lesson.id})');
          } catch (e) {
            print('❌ Error parsing lesson item [$i]: $e');
            print('❌ Item data: $item');
          }
        }

        print('🔍 Total lessons parsed: ${lessons.length}');
        print('🔍 Unique lesson IDs: ${seenIds.length}');
        return lessons;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      print('❌ Error fetching HbA1C lessons: $e');
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
