import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/learning/learning_client.dart';

part 'glucose_intro_lesson_bloc_state.dart';

class GlucoseIntroLessonBloc extends Cubit<GlucoseIntroLessonState> {
  GlucoseIntroLessonBloc() : super(GlucoseIntroLessonInitial()) {
    fetchGlucoseIntroLesson();
  }

  void fetchGlucoseIntroLesson() async {
    // "int get _currentWeek" of HomeBloc
    int type = 1;
    int week = 0;
    if (AppSettings.userInfo?.ownPackage?.ownRoadmap?.currentWeek != null) {
      week = AppSettings.userInfo!.ownPackage!.ownRoadmap!.currentWeek!;
    }
    try {
      final lessons = await LearningClient().fetchGlucoseIntroLessons(type: type, week: week);
      emit(GlucoseIntroLessonLoaded(lessons: lessons));
    } catch (e) {
      emit(GlucoseIntroLessonError());
    }
  }
}
