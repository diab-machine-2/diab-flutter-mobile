part of 'bloodpressure_intro_lesson_bloc.dart';

@immutable
abstract class BloodPressureIntroLessonState extends Equatable {
  const BloodPressureIntroLessonState();

  @override
  List<Object> get props => [];
}

class BloodPressureIntroLessonInitial extends BloodPressureIntroLessonState {}

class BloodPressureIntroLessonNoData extends BloodPressureIntroLessonState {}

class BloodPressureIntroLessonError extends BloodPressureIntroLessonState {}

class BloodPressureIntroLessonLoaded extends BloodPressureIntroLessonState {
  final List<LessonModel> lessons;

  BloodPressureIntroLessonLoaded({required this.lessons});
}
