import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';

part 'hba1c_intro_lesson_bloc_state.dart';

class HbA1cIntroLessonBloc extends Cubit<HbA1cIntroLessonState> {
  HbA1cIntroLessonBloc() : super(HbA1cIntroLessonInitial()) {
    fetchHbA1cIntroLesson();
  }

  void fetchHbA1cIntroLesson() async {
    // "int get _currentWeek" of HomeBloc
    int type = 1;
    int week = 0;
    if (AppSettings.userInfo?.ownPackage?.ownRoadmap?.currentWeek != null) {
      week = AppSettings.userInfo!.ownPackage!.ownRoadmap!.currentWeek!;
    }
    try {
      final lessons =
          await LearningClient().fetchHbA1cIntroLessons(type: type, week: week);
      emit(HbA1cIntroLessonLoaded(lessons: lessons));
    } catch (e) {
      emit(HbA1cIntroLessonError());
    }
  }
}

