part of 'hba1c_intro_lesson_bloc.dart';

@immutable
abstract class HbA1cIntroLessonState extends Equatable {
  const HbA1cIntroLessonState();

  @override
  List<Object> get props => [];
}

class HbA1cIntroLessonInitial extends HbA1cIntroLessonState {}

class HbA1cIntroLessonNoData extends HbA1cIntroLessonState {}

class HbA1cIntroLessonError extends HbA1cIntroLessonState {}

class HbA1cIntroLessonLoaded extends HbA1cIntroLessonState {
  final List<LessonModel> lessons;

  HbA1cIntroLessonLoaded({required this.lessons});
}

