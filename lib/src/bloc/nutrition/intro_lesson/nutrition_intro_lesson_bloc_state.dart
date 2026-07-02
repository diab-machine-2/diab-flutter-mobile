part of 'nutrition_intro_lesson_bloc.dart';

@immutable
abstract class NutritionIntroLessonState extends Equatable {
  const NutritionIntroLessonState();

  @override
  List<Object> get props => [];
}

class NutritionIntroLessonInitial extends NutritionIntroLessonState {}

class NutritionIntroLessonNoData extends NutritionIntroLessonState {}

class NutritionIntroLessonError extends NutritionIntroLessonState {}

class NutritionIntroLessonLoaded extends NutritionIntroLessonState {
  final List<LessonModel> lessons;

  NutritionIntroLessonLoaded({required this.lessons});
}

