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
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/model/response/base/response.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class FoodClient extends FetchClient {
// Lấy danh sách time frame
  Future<List<TimeFrameModel>> fetchFoodTimeFrame({int? time}) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Diet/MealTimeFrame',
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

  // lấy danh sách input thức ăn
  Future<FoodInputDataModel> fetchInput(
      String currentDateTime, String periodFilterType, int page) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Input', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': '$page',
        'size': '10'
      });
      if (response.statusCode == 200) {
        return FoodInputDataModel(
            inputs: MealDayItemModel.toList(response.data['data']['dayItems']),
            hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

//   lấy chi tiết input thức ăn
  Future<FoodInputModel> fetchDetailInput(String? id) async {
    try {
      final Response response =
          await super.fetchData(url: '/App/Diet/Input/$id');
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

// lay danh sach thức ăn
  Future<FoodDataModel> fetchFood() async {
    try {
      final Response response = await super.fetchData(url: '/App/Food');
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

  // lay danh sach thức ăn gần đây
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

  // lay danh sach thức ăn ưa thích
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

  // lay danh mục thức ăn
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

  // lay danh sach thức ăn theo nhóm
  Future<FoodCategoryDataModel> fetchFoodCategory(
      String? foodCategoryId, String? keyword, int? page) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Diet/Food',
          params: foodCategoryId != null
              ? {'foodCategoryId': foodCategoryId}
              : {'searchTerm': keyword, 'page': page.toString(), 'size': '20'});
      if (response.statusCode == 200) {
        return FoodCategoryDataModel(
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

  //nhập chỉ số dinh duỡng
  Future<List<FoodModel>> postFoodImages(List<String> files) async {
    try {
      // Validate input files
      if (files.isEmpty) {
        throw 'No files provided for upload';
      }

      final Map<String, String> params = {};
      final response = await super.postHttp(
        path: '/App/Image/UploadAI',
        params: params,
        files: files,
      );

      final data = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(data);
        if (jsonData['data'] != null && jsonData['data']['items'] != null) {
          return FoodModel.toList(jsonData['data']['items']);
        }
        return [];
      } else {
        // Include response body in error for better debugging
        throw 'Upload failed with status ${response.statusCode}: ${response.reasonPhrase}\nResponse: $data';
      }
    } catch (e) {
      print('Error in postFoodImages: $e');
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //nhập chỉ số dinh duỡng
  Future<bool> postIndexFood(int date, String? timeFrameId, String note,
      List<FoodModel> foods, List<String> files) async {
    try {
      final Map<String, String> params = {
        'date': date.toString(),
        'mealId': timeFrameId ?? '',
        'note': note,
      };
      for (int i = 0; i < foods.length; i++) {
        params['foods[$i].id'] = foods[i].id ?? '';
        params['foods[$i].portion'] =
            foods[i].portion != null ? foods[i].portion.toString() : '1';
        params['foods[$i].quantity'] = foods[i].quantity?.toString() ?? '';
      }
      final response = await super
          .postHttp(path: '/App/Diet/Input', params: params, files: files);
      final data = await response.stream.bytesToString();
      print('Upload response status: ${response.statusCode}, data: $data');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> postIndexFoodAI(int date, String? timeFrameId, String note,
      List<FoodModel> foods, List<String> files) async {
    try {
      final Map<String, String> params = {
        'date': date.toString(),
        'mealId': timeFrameId ?? '',
        'note': note,
        'IsGptResult': 'true',
      };

      for (int i = 0; i < foods.length; i++) {
        final totalCalories = foods[i].calorie != null
            ? foods[i].calorie!.toDouble() * (foods[i].portion ?? 0).toDouble()
            : 0.0;
        final isGptResult =
            (foods[i].id == null || foods[i].id!.isEmpty) ? 'true' : 'false';
        params['foods[$i].id'] =
            foods[i].id ?? '00000000-0000-0000-0000-000000000000';
        params['foods[$i].name'] = foods[i].name ?? '';
        params['foods[$i].portion'] = foods[i].portion?.toString() ?? '1';
        params['foods[$i].foodUnitId'] = foods[i].unit ?? '';
        params['foods[$i].calorie'] = totalCalories.round().toString();
        params['foods[$i].glucose'] = foods[i].glucose?.toString() ?? '';
        params['foods[$i].lipid'] = foods[i].lipid?.toString() ?? '';
        params['foods[$i].protein'] = foods[i].protein?.toString() ?? '';
        params['foods[$i].fibre'] = foods[i].fibre?.toString() ?? '';
        params['foods[$i].liked'] = foods[i].liked?.toString() ?? '';
        params['foods[$i].text'] = foods[i].text ?? '';
        params['foods[$i].description'] = foods[i].description ?? '';
        params['foods[$i].foodCategoryId'] = foods[i].foodCategoryId ?? '';
        params['foods[$i].quantity'] = foods[i].quantity?.toString() ?? '1';
        params['foods[$i].mealId'] = foods[i].mealId ?? '';
        params['foods[$i].timeCode'] = foods[i].timeCode?.toString() ?? '';
        params['foods[$i].foodMenuCode'] = foods[i].foodMenuCode ?? '';
        // Handle image object - you might need to send image ID or URL
        params['foods[$i].imageId'] = foods[i].image?.id ?? '';
        params['foods[$i].imageUrl'] = foods[i].imageUrl ?? '';
        params['foods[$i].IsGptResult'] = isGptResult;
      }
      final response = await super
          .postHttp(path: '/App/Diet/InputAI', params: params, files: files);
      log('params: $params');
      final data = await response.stream.bytesToString();
      print('Upload response status: ${response.statusCode}, data: $data');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //cập nhật chỉ số vận động

  Future<bool> updateIndexFood(
      String? id,
      int date,
      String? timeFrameId,
      String note,
      List<FoodModel> foods,
      List<String?> removalImageIds,
      List<String> files) async {
    try {
      final Map<String, String> params = {
        'id': id ?? '',
        'date': date.toString(),
        'mealId': timeFrameId ?? '',
        'note': note,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      for (int i = 0; i < foods.length; i++) {
        params['foods[$i].id'] = foods[i].id ?? '';
        params['foods[$i].portion'] =
            foods[i].portion != null ? foods[i].quantity.toString() : '1';
      }
      final response = await super
          .putHttp(path: '/App/Diet/Input', params: params, files: files);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // xóa chỉ số vận động
  Future<bool> deleteInputFood(String? id) async {
    try {
      final Response response = await super.delete(url: '/App/Diet/Input/$id');
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

  // lấy biểu đồ năng luợng
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

// lấy biểu đồ tinh bột
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

  // lấy biểu đồ dinh duong đã nạp theo ngày
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

  // lấy biểu đồ xu huớng dinh duong
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

  // lấy biểu đồ năng luợng phân bổ
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

  // lấy biểu đồ phân bổ theo nhóm thực phẩm (Tinh bột, Chất đạm, Chất béo, Rau củ, Hoa quả)
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

  // lay danh sach cuong do van dong

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
}
