import 'package:dio/dio.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/response/exercise_lesson_response.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class LearningClient extends FetchClient {
  Future<List<LearningPostModel>> fetchLearningPost(int? position) async {
    final params = {
      'page': '1',
      'size': '1000',
    };
    if (position != null) {
      params['position'] = position.toString();
    }
    try {
      final Response response = await super.fetchData(
        url: '/App/LearningPost',
        params: params,
      );
      if (response.statusCode == 200) {
        return LearningPostModel.toList(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  // /App/Lesson/MyLessonsOptimizedAndCacheLessonPercent
  // Type 1: Bắt buộc, Type 2: Tùy chọn, Type 3: Quiz cấp độ
  Future<List<LessonModel>> fetchLesson({int type = 1, int week = 0}) async {
    final Response response = await super.postUri(
      url: '/App/Lesson/MyLessonsOptimizedAndCacheLessonPercent',
      baseOption: true,
      params: {
        'type': type,
        'isNotCompleted': false,
        "week": week,
        "page": 1,
        "size": 10
      },
    );
    if (response.statusCode == 200) {
      return LessonModel.toList(response.data['data']);
    }
    return [];
  }

  // "/App/Lesson/GlucoseLesson" ~ "/App/Lesson/MyLessonsOptimizedAndCacheLessonPercent"
  // Type 1: Bắt buộc, Type 2: Tùy chọn, Type 3: Quiz cấp độ
  Future<List<LessonModel>> fetchGlucoseIntroLessons(
      {int type = 1, int week = 0}) async {
    final Response response = await super.postUri(
      url: '/App/Lesson/GlucoseLesson',
      baseOption: true,
      params: {
        'type': type,
        'isNotCompleted': false,
        "week": week,
        "page": 1,
        "size": 10
      },
    );
    if (response.statusCode == 200) {
      return LessonModel.toList(response.data['data']);
    }
    return [];
  }

  Future<ExerciseLessonResponse> fetchExerciseLessons() async {
    final Response response = await super.fetchData(
      url: '/App/Lesson/Support/Exercise',
    );
    if (response.statusCode == 200) {
      return ExerciseLessonResponse.fromJson(response.data);
    }
    // Handle error
    return ExerciseLessonResponse(
      data: [],
      message: response.data['message'] ?? 'Unknown error',
      statusCode: response.statusCode,
    );
  }

  Future<List<LessonModel>> fetchBloodPressureIntroLessons(
      {int type = 1, int week = 0}) async {
    final Response response = await super.postUri(
      url: '/App/Lesson/BloodPressureLesson',
      baseOption: true,
      params: {
        'type': type,
        'isNotCompleted': false,
        "week": week,
        "page": 1,
        "size": 10
      },
    );
    if (response.statusCode == 200) {
      return LessonModel.toList(response.data['data']);
    }
    return [];
  }

  // "/App/Lesson/HbA1cLesson" ~ "/App/Lesson/MyLessonsOptimizedAndCacheLessonPercent"
  // Type 1: Bắt buộc, Type 2: Tùy chọn, Type 3: Quiz cấp độ
  Future<List<LessonModel>> fetchHbA1cIntroLessons(
      {int type = 1, int week = 0}) async {
    final Response response = await super.postUri(
      url: '/App/Lesson/HbA1cLesson',
      baseOption: true,
      params: {
        'type': type,
        'isNotCompleted': false,
        "week": week,
        "page": 1,
        "size": 10
      },
    );
    if (response.statusCode == 200) {
      return LessonModel.toList(response.data['data']);
    }
    return [];
  }

  // "/App/Lesson/NutritionLesson" ~ "/App/Lesson/MyLessonsOptimizedAndCacheLessonPercent"
  // Type 1: Bắt buộc, Type 2: Tùy chọn, Type 3: Quiz cấp độ
  Future<List<LessonModel>> fetchNutritionIntroLessons(
      {int type = 1, int week = 0}) async {
    final Response response = await super.postUri(
      url: '/App/Lesson/NutrientLesson',
      baseOption: true,
      params: {
        'type': type,
        'isNotCompleted': false,
        "week": week,
        "page": 1,
        "size": 10
      },
    );
    if (response.statusCode == 200) {
      return LessonModel.toList(response.data['data']);
    }
    return [];
  }
}
