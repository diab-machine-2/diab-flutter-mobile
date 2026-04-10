import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/exercrises/exercises_intensity.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_input_data_model.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/food/food_statistic_diet_model.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/modal/food/nutrition_lesson.dart';
import 'package:medical/src/modal/food/nutrition_summary_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodClient extends FetchClient {
  // ============================================================
  // TimeFrame - NEW: /App/TimeFrame
  // ============================================================

  /// Lấy danh sách time frame
  /// NEW endpoint: GET /App/TimeFrame
  Future<List<TimeFrameModel>> fetchFoodTimeFrame({int? time}) async {
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
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // ============================================================
  // Nutrition Input - NEW: /App/Nutrition/Input
  // ============================================================

  /// Lấy danh sách input dinh dưỡng theo range (grouped by date)
  /// NEW endpoint: GET /App/Nutrition/Input?range=X
  /// range: 0=today, 1=7d, 2=14d, 3=30d, 4=90d
  Future<FoodInputDataModel> fetchInput(
      String currentDateTime, String periodFilterType, int page,
      {int size = 10}) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Nutrition/Input', params: {
        'range': periodFilterType,
        'page': page.toString(),
        'pageSize': size.toString(),
      });
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null && data['groups'] != null) {
          // New format: groups[]
          return FoodInputDataModel(
              inputs: MealDayItemModel.toList(data['groups']),
              hasMore: false);
        }
        // Fallback to old format
        return FoodInputDataModel(
            inputs: data != null && data['dayItems'] != null
                ? MealDayItemModel.toList(data['dayItems'])
                : [],
            hasMore: response.data['meta']?['canNext'] ?? false);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// Lấy chi tiết nutrition input
  /// NEW endpoint: GET /App/Nutrition/Input/{id}
  Future<FoodInputModel> fetchDetailInput(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Nutrition/Input/$id');
      if (response.statusCode == 200) {
        return FoodInputModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // ============================================================
  // Food Search - NEW: /App/Food
  // ============================================================

  /// Tìm kiếm món ăn
  /// NEW endpoint: GET /App/Food?keyword=X&page=X&pageSize=X
  Future<FoodDataModel> fetchFood() async {
    try {
      final Response response = await super.fetchData(url: '/App/Food');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        // Support new format (data.items[]) and old format (data[])
        final items = data is Map ? (data['items'] ?? []) : (data ?? []);
        return FoodDataModel(
            foods: FoodModel.toList(items),
            hasMore: data is Map
                ? (data['totalCount'] != null &&
                    (data['totalCount'] as int) > (items as List).length)
                : (response.data['meta']?['canNext'] ?? false));
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// Tìm kiếm món ăn gần đây
  Future<FoodDataModel> fetchFoodLatest() async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Diet/FoodLatest',
          params: {'periodFilterType': '1', 'currentDateTime': '1615348913'});
      if (response.statusCode == 200) {
        return FoodDataModel(
            foods: FoodModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// Tìm kiếm món ăn ưa thích
  Future<FoodDataModel> fetchFoodFavorite() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/FoodFavorite');
      if (response.statusCode == 200) {
        return FoodDataModel(
            foods: FoodModel.toList(response.data['data']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// Tìm kiếm danh mục món ăn
  Future<List<FoodCategoryModel>> fetchCategory() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/FoodCategory');
      if (response.statusCode == 200) {
        return FoodCategoryModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// Tìm kiếm món ăn theo nhóm/keyword
  /// NEW: uses /App/Food?keyword=X&page=X&pageSize=X for keyword search
  Future<FoodCategoryDataModel> fetchFoodCategory(
      String? foodCategoryId, String? keyword, int? page) async {
    try {
      Response response;
      if (foodCategoryId != null) {
        // Category search - keep old endpoint
        response = await super.fetchData(
            url: '/App/Diet/Food',
            params: {'foodCategoryId': foodCategoryId});
      } else {
        // Keyword search - NEW endpoint
        response = await super.fetchData(url: '/App/Food', params: {
          'keyword': keyword,
          'page': page.toString(),
          'pageSize': '20'
        });
      }
      if (response.statusCode == 200) {
        final data = response.data['data'];
        // Support new format
        final items = data is Map ? (data['items'] ?? []) : (data ?? []);
        return FoodCategoryDataModel(
            foods: FoodModel.toList(items),
            hasMore: data is Map
                ? (data['totalCount'] != null &&
                    (data['totalCount'] as int) > (items as List).length)
                : (response.data['meta']?['canNext'] ?? false));
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> addFoodToFavorite(String? foodId) async {
    try {
      final Response response = await super.postUri(
          baseOption: true,
          url: '/App/Diet/FoodFavorite',
          params: {'foodId': foodId});
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

  Future<bool> romoveFoodFromFavorite(String? foodId) async {
    try {
      final Response response =
          await super.delete(url: '/App/Diet/FoodFavorite/$foodId');
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

  // ============================================================
  // Upload AI Image - NEW: /App/Image/UploadAI/MealScore
  // ============================================================

  /// Upload ảnh AI và phân tích MealScore
  /// NEW endpoint: POST /App/Image/UploadAI/MealScore
  /// Response includes: imageUrl, totalMealScore, scoreRange, carbPercent,
  /// proteinPercent, fatPercent, vegetablePercent, fruitPercent, aiAdvice, items[]
  Future<List<FoodModel>> postFoodImages(List<String> files) async {
    try {
      if (files.isEmpty) {
        throw 'No files provided for upload';
      }

      final Map<String, String> params = {};
      final response = await super.postHttp(
        path: '/App/Image/UploadAI/MealScore',
        params: params,
        files: files,
      );

      final data = await response.stream.bytesToString();
      print('📸 [UploadAI/MealScore] Status: ${response.statusCode}');
      print('📸 [UploadAI/MealScore] Response: $data');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(data);
        print(
            '📸 [UploadAI/MealScore] data keys: ${jsonData['data']?.keys?.toList()}');
        if (jsonData['data'] != null && jsonData['data']['items'] != null) {
          final items = FoodModel.toList(jsonData['data']['items']);
          print('📸 [UploadAI/MealScore] Parsed ${items.length} food items');
          return items;
        }
        print('📸 [UploadAI/MealScore] No items found in response data');
        return [];
      } else {
        throw 'Upload failed with status ${response.statusCode}: ${response.reasonPhrase}\nResponse: $data';
      }
    } catch (e) {
      print('Error in postFoodImages: $e');
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// Call MealScore API to get full nutrition analysis and score
  /// NEW endpoint: POST /App/Image/UploadAI/MealScore
  /// Returns all MealScore data to be saved with Nutrition Input
  Future<Map<String, dynamic>?> postMealScore(List<String> files) async {
    try {
      if (files.isEmpty) return null;

      final Map<String, String> params = {};
      final response = await super.postHttp(
        path: '/App/Image/UploadAI/MealScore',
        params: params,
        files: files,
      );

      final data = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(data);
        if (jsonData['data'] != null) {
          return jsonData['data'] as Map<String, dynamic>;
        }
        return null;
      } else {
        print('MealScore API failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in postMealScore: $e');
      return null;
    }
  }

  // ============================================================
  // Create Nutrition Input - NEW: POST /App/Nutrition/Input
  // ============================================================

  /// Manual Flow: Lưu bữa ăn (user chọn từ DB)
  /// NEW endpoint: POST /App/Nutrition/Input (multipart/form-data)
  /// Params: timeFrameId, note, isFromAI=false, items[X].foodId, items[X].portion
  /// Response: { "success": true, "data": "nutrition-input-guid" }
  Future<String?> postIndexFood(int date, String? timeFrameId, String note,
      List<FoodModel> foods, List<String> files) async {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      final dateStr = dt.toIso8601String();
      final Map<String, String> params = {
        'timeFrameId': timeFrameId ?? '',
        'note': note,
        'date': dateStr,
        'createDatetime': dateStr,
        'isFromAI': 'false',
      };
      for (int i = 0; i < foods.length; i++) {
        params['items[$i].foodId'] = foods[i].id ?? '';
        params['items[$i].portion'] =
            foods[i].portion != null ? foods[i].portion.toString() : '1';
      }
      final response = await super
          .postHttp(path: '/App/Nutrition/Input', params: params, files: files);
      final data = await response.stream.bytesToString();
      print('Upload response status: ${response.statusCode}, data: $data');
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(data);
        return jsonResponse['data']?.toString();
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  /// AI Flow: Lưu bữa ăn từ kết quả phân tích AI
  /// NEW endpoint: POST /App/Nutrition/Input (JSON body)
  /// Body: isFromAI=true + all MealScore fields
  Future<String?> postIndexFoodAI(
    int date,
    String? timeFrameId,
    String note,
    List<FoodModel> foods,
    List<String> files, {
    Map<String, dynamic>? mealScoreData,
  }) async {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      final dateStr = dt.toIso8601String();
      
      // Build JSON params
      final Map<String, dynamic> params = {
        'timeFrameId': timeFrameId ?? '',
        'note': note,
        'date': dateStr,
        'createDatetime': dateStr,
        'isFromAI': true,
      };

      // Add MealScore data if available
      if (mealScoreData != null) {
        params['totalMealScore'] = mealScoreData['totalMealScore'];
        params['scoreRange'] = mealScoreData['scoreRange'];
        params['carbPercent'] = mealScoreData['carbPercent'] ?? 0;
        params['proteinPercent'] = mealScoreData['proteinPercent'] ?? 0;
        params['fatPercent'] = mealScoreData['fatPercent'] ?? 0;
        params['vegetablePercent'] = mealScoreData['vegetablePercent'] ?? 0;
        params['fruitPercent'] = mealScoreData['fruitPercent'] ?? 0;
        params['aiAdvice'] = mealScoreData['aiAdvice'] ?? '';
        
        // If MealScore provided an imageUrl (e.g. from previous upload), we can set it so backend knows
        if (mealScoreData['imageUrl'] != null && mealScoreData['imageUrl'].toString().isNotEmpty) {
          params['imageUrl'] = mealScoreData['imageUrl'];
        }
      }

      // Build items array for JSON JSON binding
      params['items'] = foods.map((f) => {
        'foodId': f.id ?? '',
        'name': f.name ?? '',
        'unit': f.unit ?? '',
        'portion': f.portion ?? 1,
        'calorie': f.calorie?.round() ?? 0,
        'glucose': f.glucose ?? 0,
        'lipid': f.lipid ?? 0,
        'protein': f.protein ?? 0,
        'fibre': f.fibre ?? 0,
      }).toList();

      log('input AI nutrition params: $params');

      // Send as application/json
      final response = await super.postUri(
        baseOption: true,
        url: '/App/Nutrition/Input',
        params: params,
      );

      print('Upload AI JSON response status: ${response.statusCode}, data: ${response.data}');
      if (response.statusCode == 200) {
        return response.data['data']?.toString();
      } else {
        throw response.statusMessage ?? 'Unknown error';
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // ============================================================
  // Update Nutrition Input - NEW: PUT /App/Nutrition/Input/{id}
  // ============================================================

  /// Cập nhật nutrition input
  /// NEW endpoint: PUT /App/Nutrition/Input/{id} (multipart/form-data)
  Future<bool> updateIndexFood(
      String? id,
      int date,
      String? timeFrameId,
      String note,
      List<FoodModel> foods,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      final dateStr = dt.toIso8601String();
      final Map<String, String> params = {
        'timeFrameId': timeFrameId ?? '',
        'note': note,
        'date': dateStr,
        'createDatetime': dateStr,
      };
      for (int i = 0; i < foods.length; i++) {
        params['items[$i].foodId'] = foods[i].id ?? '';
        params['items[$i].portion'] = foods[i].portion?.toString() ?? '1';
      }
      final response = await super.putHttp(
          path: '/App/Nutrition/Input/$id', params: params, files: files);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // ============================================================
  // Delete Nutrition Input - NEW: DELETE /App/Nutrition/Input/{id}
  // ============================================================

  /// Xóa nutrition input
  /// NEW endpoint: DELETE /App/Nutrition/Input/{id}
  Future<bool> deleteInputFood(String? id) async {
    try {
      final Response response =
          await super.delete(url: '/App/Nutrition/Input/$id');
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

  // ============================================================
  // Nutrition Summary - NEW: GET /App/Nutrition/Summary
  // ============================================================

  /// Lấy thống kê dinh dưỡng tổng hợp
  /// NEW endpoint: GET /App/Nutrition/Summary?range=X
  Future<NutritionSummaryModel> fetchNutritionSummary(int range) async {
    try {
      print('🔍 [NutritionSummary] Calling API: /App/Nutrition/Summary?range=$range');
      final Response response = await super.fetchData(
          url: '/App/Nutrition/Summary',
          params: {'range': range.toString()});
      print('✅ [NutritionSummary] Status code: ${response.statusCode}');
      print('📦 [NutritionSummary] Response data: ${response.data}');
      if (response.statusCode == 200) {
        print('📊 [NutritionSummary] data[\'data\'] keys: ${response.data['data']?.keys?.toList()}');
        print('📈 [NutritionSummary] trendData: ${response.data['data']?['trendData']}');
        return NutritionSummaryModel.fromJson(response.data['data']);
      } else {
        print('⚠️ [NutritionSummary] Non-200 status: ${response.statusCode}');
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      print('❌ [NutritionSummary] Error: $e');
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // ============================================================
  // Legacy Statistic Endpoints (kept for backward compatibility)
  // ============================================================

  Future<FoodCaloModel> fetchStatisticCalo() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Statistic/calo');
      if (response.statusCode == 200) {
        return FoodCaloModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<FoodCaloModel> fetchStatisticCarb() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Statistic/carb');
      if (response.statusCode == 200) {
        return FoodCaloModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<FoodDietModel> fetchStatisticDetail(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Statistic/detail', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'takeAll': 'true'
      });
      if (response.statusCode == 200) {
        return FoodDietModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<FoodTrendModel> fetchStatisticTrend(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Statistic/trend', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'takeAll': 'true'
      });
      if (response.statusCode == 200) {
        return FoodTrendModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<FoodDistributeModel> fetchStatisticDistribute(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Statistic/distribute', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'takeAll': 'true'
      });
      if (response.statusCode == 200) {
        return FoodDistributeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<FoodDistributeModel> fetchFoodGroupDistribute(
      String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super
          .fetchData(url: '/App/Admin/Diet/Statistic/distribute', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'takeAll': 'true'
      });
      if (response.statusCode == 200) {
        return FoodDistributeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // ============================================================
  // Other endpoints (kept as-is)
  // ============================================================

  Future<List<ExerciseIntensityModel>> fetchIntensity() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/ActivityLevel');
      if (response.statusCode == 200) {
        return ExerciseIntensityModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<double?> fetchTDEE(double weight, int height, int yearOfBirth,
      String? activityLevelId) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/TDEE', params: {
        'weight': weight.toString(),
        'height': height.toString(),
        'yearOfBirth': yearOfBirth.toString(),
        'activityLevelId': activityLevelId
      });
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

  Future<bool> updateTargetEnergy(int goal) async {
    try {
      final response = await super
          .postHttp2(path: '/App/Patient/EnergyGoal', params: goal.toString());
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<NutritionLesson>?> fetchNutritionLessons() async {
    final Response response =
        await super.fetchData(url: '/App/Lesson/LessonSupport', params: {});

    if (response.statusCode == 200) {
      final listResponse = ListResponse.fromJson(
        response.data as Map<String, dynamic>,
        NutritionLesson.fromJson,
      );
      final data = listResponse.data;
      if (data == null) return null;
      // Filter out inactive lessons (status == 2)
      return data.where((e) => e.status != 2).toList();
    }
    return null;
  }

  // Lấy AI analysis cho dinh dưỡng
  Future<String?> fetchDietAnalysis(int periodFilterType) async {
    try {
      print(
          '🔍 Fetching Diet AI Analysis with periodFilterType: $periodFilterType');
      final Response response = await super.fetchData(
        url: '/App/Diet/Analysis/HealthTrend',
        params: {
          'periodFilterType': periodFilterType.toString(),
        },
      );
      print('✅ API Response Status: ${response.statusCode}');
      print('📦 API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final result = response.data['data'] as String?;
        print('✨ AI Analysis Result: $result');
        return result;
      }
      print('⚠️ Non-200 status code');
      return null;
    } catch (e) {
      print('❌ fetchDietAnalysis Error: $e');
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
