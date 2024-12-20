part of 'glucose_intro_lesson_bloc.dart';

@immutable
abstract class GlucoseIntroLessonState extends Equatable {
  const GlucoseIntroLessonState();

  @override
  List<Object> get props => [];
}

class GlucoseIntroLessonInitial extends GlucoseIntroLessonState {}

class GlucoseIntroLessonNoData extends GlucoseIntroLessonState {}

class GlucoseIntroLessonError extends GlucoseIntroLessonState {}

class GlucoseIntroLessonLoaded extends GlucoseIntroLessonState {
  final List<LessonModel> lessons;

  GlucoseIntroLessonLoaded({required this.lessons});
}
