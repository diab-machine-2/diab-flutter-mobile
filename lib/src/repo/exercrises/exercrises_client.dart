import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/exercrises/excercise_rank_model.dart';
import 'package:medical/src/modal/exercrises/exercrise_Input_data_model.dart';
import 'package:medical/src/modal/exercrises/exercrise_Input_detail_model.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:medical/src/modal/exercrises/exercrise_summary.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_calo.dart';
import 'package:medical/src/modal/exercrises/exercrise_trend_time.dart';
import 'package:medical/src/modal/exercrises/exercrise_walk_summary.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/modal/exercrises/exercrises_active.dart';
import 'package:medical/src/modal/exercrises/exercrises_data_model.dart';
import 'package:medical/src/modal/exercrises/exercises_intensity.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class ExercrisesClient extends FetchClient {
  // lấy danh sách vận động
  Future<ExercrisesDataModel> fetchCategory(int? page) async {
    try {
      Map<String, String> params = {'takeAll': 'true'};

      if (page != null) {
        params['page'] = page.toString();
      }
      print(params);
      final Response response = await super.fetchData(url: '/App/Exercise/Category', params: params);
      if (response.statusCode == 200) {
        return ExercrisesDataModel(inputs: ExercrisesListCategoryModel.fromJson(response.data['data']));
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  // lay danh sach cuong do van dong

  Future<List<ExerciseIntensityModel>> fetchIntensity(String? exerciseCategoryId) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Exercise/Intensity', params: {'takeAll': 'true', 'exerciseCategoryId': exerciseCategoryId});
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

  // lay danh sach hinh thuc van dong
  Future<List<ExercriseActiveModel>> fetchActive(String? exerciseCategoryId, String? exerciseIntensityId) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise', params: {
        'exerciseCategoryId': exerciseCategoryId,
        'exerciseIntensityId': exerciseIntensityId,
        'takeAll': 'true'
      });
      if (response.statusCode == 200) {
        return ExercriseActiveModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // lay luong calories tieu hao
  Future fetchCalories(
      String? exerciseCategoryId, String? exerciseIntensityId, String? exerciseId, int duration) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/Calculator', params: {
        'exerciseId': exerciseId,
        'exerciseIntensityId': exerciseIntensityId,
        'exerciseCategoryId': exerciseCategoryId,
        'duration': '$duration'
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

  // lấy danh sách vận động
  Future<InputExercrisesDataModel> fetchInput(String? currentDateTime, String? periodFilterType, int? page) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/Input', params: {
        'currentDateTime': currentDateTime,
        'periodFilterType': periodFilterType,
        'page': '$page',
        'size': '10'
      });
      if (response.statusCode == 200) {
        return InputExercrisesDataModel(
            inputs: InputDataExercriseModel.toList(response.data['data']), hasMore: response.data['meta']['canNext']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //lấy hoạt động trong ngày
  Future<ExercriseSummaryModel> fetchDailyExercrise(String? currentDateTime) async {
    try {
      final Response response = await super.fetchData(url: 'App/Exercise/Summary', params: {
        'currentDateTime': '$currentDateTime',
      });
      if (response.statusCode == 200) {
        return ExercriseSummaryModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<ExercriseWalkSummaryModel?> fetchWalkExercrise(String? currentDateTime) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/WalkSummary', params: {
        'currentDateTime': '$currentDateTime',
      });
      if (response.statusCode == 200) {
        return response.data['data'] == null ? null : ExercriseWalkSummaryModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //nhập chỉ số vận động
  Future<bool> postIndexExercrises(
      int date, String? timeFrameId, String note, List<ExercrisesCategoryModel> exercises, List<String> files) async {
    try {
      Map<String, String> params = {
        'date': date.toString(),
        'timeFrameId': timeFrameId ?? '',
        'note': note,
      };
      for (int i = 0; i < exercises.length; i++) {
        params['exercises[$i].exerciseId'] = exercises[i].exerciseId ?? '';
        params['exercises[$i].seq'] = exercises[i].order.toString();
        params['exercises[$i].description'] = exercises[i].description ?? '';
        params['exercises[$i].duration'] = exercises[i].duration.toString();
        params['exercises[$i].burnedCalorie'] = exercises[i].burnedCalorie.toString();
      }
      final response = await super.postHttp(path: '/App/Exercise/Input', params: params, files: files);
      if (response.statusCode == 200) {
        return true;
      } else {
        String error = await response.stream.bytesToString();
        print('error = $error');
        throw Error.fromString(error);
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //lấy chi tiết vận động
  Future<InputDetailExercriseModel> fetchDetail(String? id) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/Input/$id');
      if (response.statusCode == 200) {
        return InputDetailExercriseModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //lấy xu hướng thời gian
  Future<ExercriseTrendTimeModel> fetchExercriseTimeTrend(String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/Trend/Duration', params: {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'takeAll': 'true',
      });
      if (response.statusCode == 200) {
        return ExercriseTrendTimeModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
  //cập nhật chỉ số vận động

  Future<bool> updateExercrises(String? id, int date, String? timeFrameId, String note,
      List<ExercrisesCategoryModel> exercises, List<String?> removalImageIds, List<String> files) async {
    try {
      Map<String, String> params = {
        'id': id ?? '',
        'date': date.toString(),
        'timeFrameId': timeFrameId ?? '',
        'note': note,
        'removalImageIdsStr': removalImageIds.join(';')
      };
      for (int i = 0; i < exercises.length; i++) {
        params['exercises[$i].exerciseId'] = exercises[i].exerciseId ?? '';
        params['exercises[$i].seq'] = i.toString();
        params['exercises[$i].duration'] = exercises[i].duration.toString();
        params['exercises[$i].burnedCalorie'] = exercises[i].burnedCalorie.toString();
      }
      print(params);
      final response = await super.putHttp(path: '/App/Exercise/Input', params: params, files: files);

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

  // xóa chỉ số vận động
  Future<bool> deleteExercrises(String? id) async {
    try {
      final Response response = await super.delete(url: '/App/Exercise/Input/$id');
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

  //lấy xu hướng đốt calo
  Future<ExercriseTrendCaloModel> fetchExercriseCaloTrend(String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/Trend/Calorie', params: {
        'currentDateTime': '$currentDateTime',
        'periodFilterType': '$periodFilterType',
        'takeAll': 'true',
      });
      if (response.statusCode == 200) {
        return ExercriseTrendCaloModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  //lấy hoạt động gần nhất
  Future<List<ExercrisesCategoryModel>> fetchExercriseRegularly() async {
    try {
      final Response response = await super.fetchData(url: '/App/Exercise/Regularly');
      if (response.statusCode == 200) {
        return ExercrisesCategoryModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // thêm mục tiêu vận động mới
  Future<bool> addExercriseTarget(
      int targetExerciseType, int targetExerciseUnitType, double value, String? exerciseCategoryId) async {
    try {
      Map<String, String?> params = {
        'targetExerciseType': targetExerciseType.toString(),
        'targetExerciseUnitType': targetExerciseUnitType.toString(),
        'value': value.toString(),
        'exerciseCategoryId': exerciseCategoryId
      };
      if (exerciseCategoryId != null) {
        params['exerciseCategoryId'] = exerciseCategoryId;
      }
      final Response response = await super.postUri(baseOption: true, url: '/App/TargetExercise', params: params);
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

  // lấy xếp hạng

  Future<ExerciseRankModel> fetchRank(String? currentDateTime, String? periodFilterType) async {
    try {
      final Response response = await super.fetchData(
          url: '/App/Exercise/Rank',
          params: {'currentDateTime': currentDateTime, 'periodFilterType': periodFilterType});
      if (response.statusCode == 200) {
        return ExerciseRankModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
