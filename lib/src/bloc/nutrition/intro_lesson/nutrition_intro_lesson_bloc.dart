import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';

part 'nutrition_intro_lesson_bloc_state.dart';

class NutritionIntroLessonBloc extends Cubit<NutritionIntroLessonState> {
  NutritionIntroLessonBloc() : super(NutritionIntroLessonInitial()) {
    fetchNutritionIntroLesson();
  }

  void fetchNutritionIntroLesson() async {
    // "int get _currentWeek" of HomeBloc
    int type = 1;
    int week = 0;
    if (AppSettings.userInfo?.ownPackage?.ownRoadmap?.currentWeek != null) {
      week = AppSettings.userInfo!.ownPackage!.ownRoadmap!.currentWeek!;
    }
    try {
      final lessons = await LearningClient()
          .fetchNutritionIntroLessons(type: type, week: week);
      emit(NutritionIntroLessonLoaded(lessons: lessons));
    } catch (e) {
      emit(NutritionIntroLessonError());
    }
  }
}
