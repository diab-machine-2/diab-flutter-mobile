import 'package:dio/dio.dart';
import 'package:medical/src/modal/exercrises/exercrises_intensity.dart';
import 'package:medical/src/modal/food/food_calo_model.dart';
import 'package:medical/src/modal/food/food_category_model.dart';
import 'package:medical/src/modal/food/food_data_model.dart';
import 'package:medical/src/modal/food/food_input_data_model.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/food/food_statistic_diet_model.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/modal/food/food_statistic_trend_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';

class FoodClient extends FetchClient {
// Lấy danh sách time frame
  Future<List<TimeFrameModel>> fetchFoodTimeFrame({int time}) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

//   lấy chi tiết input thức ăn
  Future<FoodInputModel> fetchDetailInput(String id) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lay danh sach thức ăn theo nhóm
  Future<FoodCategoryDataModel> fetchFoodCategory(
      String foodCategoryId, String keyword, int page) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> addFoodToFavorite(String foodId) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> romoveFoodFromFavorite(String foodId) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  //nhập chỉ số dinh duỡng
  Future<bool> postIndexFood(int date, String timeFrameId, String note,
      List<FoodModel> foods, List<String> files) async {
    try {
      Map<String, String> params = {
        'date': date.toString(),
        'mealId': timeFrameId,
        'note': note,
      };
      for (int i = 0; i < foods.length; i++) {
        params['foods[$i].id'] = foods[i].id;
        params['foods[$i].portion'] = foods[i].quantity.toString();
      }
      final response = await super
          .postHttp(path: '/App/Diet/Input', params: params, files: files);
      if (response.statusCode == 200) {
        return true;
      } else {
        print(await response.stream.bytesToString());
        throw response.reasonPhrase;
      }
    } catch (e) {
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  //cập nhật chỉ số vận động

  Future<bool> updateIndexFood(
      String id,
      int date,
      String timeFrameId,
      String note,
      List<FoodModel> foods,
      List<String> removalImageIds,
      List<String> files) async {
    try {
      Map<String, String> params = {
        'id': id,
        'date': date.toString(),
        'mealId': timeFrameId,
        'note': note,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      for (int i = 0; i < foods.length; i++) {
        params['foods[$i].id'] = foods[i].id;
        params['foods[$i].portion'] = foods[i].quantity.toString();
      }
      final response = await super
          .putHttp(path: '/App/Diet/Input', params: params, files: files);

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

  // xóa chỉ số vận động
  Future<bool> deleteInputFood(String id) async {
    try {
      final Response response = await super.delete(url: '/App/Diet/Input/$id');
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy biểu đồ dinh duỡng đã nạp theo ngày
  Future<FoodDietModel> fetchStatisticDetail(
      String currentDateTime, String periodFilterType) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy biểu đồ xu huớng dinh duỡng
  Future<FoodTrendModel> fetchStatisticTrend(
      String currentDateTime, String periodFilterType) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lấy biểu đồ năng luợng phân bổ
  Future<FoodDistributeModel> fetchStatisticDistribute(
      String currentDateTime, String periodFilterType) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  // lay danh sach cuong do van dong

  Future<List<ExercriseIntensityModel>> fetchIntensity() async {
    try {
      final Response response =
          await super.fetchData(url: '/App/ActivityLevel');
      if (response.statusCode == 200) {
        return ExercriseIntensityModel.toList(response.data['data']);
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

  Future<double> fetchTDEE(
      int weight, int height, int yearOfBirth, String activityLevelId) async {
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
      throw e is Error
          ? e
          : 'diaB không kết nối được với máy chủ, vui lòng kiểm tra lại kết nối Internet hoặc liên lạc với Hotline của chúng tôi';
    }
  }

  Future<bool> updateTargetEnergy(int goal) async {
    try {
      final response = await super
          .postHttp2(path: '/App/Patient/EnergyGoal', params: goal.toString());
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
}
