import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';

part 'hba1c_intro_lesson_bloc_state.dart';

class HbA1cIntroLessonBloc extends Cubit<HbA1cIntroLessonState> {
  HbA1cIntroLessonBloc() : super(HbA1cIntroLessonInitial()) {
    fetchHbA1cIntroLesson();
  }

  void fetchHbA1cIntroLesson({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        print('🔄 Force refreshing HbA1C lessons...');
        emit(HbA1cIntroLessonInitial()); // Reset to initial state
      }

      // Use new HbA1C Lessons endpoint
      final lessons = await HbA1CClient().fetchHbA1CLessons();
      print('📚 Emitting ${lessons.length} lessons to UI');
      emit(HbA1cIntroLessonLoaded(lessons: lessons));
    } catch (e) {
      print('❌ Error fetching HbA1C lessons: $e');
      emit(HbA1cIntroLessonError());
    }
  }
}
