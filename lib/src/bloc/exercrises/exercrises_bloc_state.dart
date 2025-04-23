part of 'exercrises_bloc.dart';

@immutable
abstract class ExercrisesState {}

class ExercrisesInitial extends ExercrisesState {}

class ExercrisesError extends ExercrisesState {
  final String? message;

  ExercrisesError({
    required this.message,
  });
}

class ExercrisesLoading extends ExercrisesState {}

class ExercrisesLoaded extends ExercrisesState {
  ExercrisesLoaded(List<TimeFrameModel> list);
}

class ExercrisesCategoryModelLoaded extends ExercrisesState {
  final ExercrisesListCategoryModel? category;
  final ExercrisesListCategoryModel? categorySearch;
  final List<ExercrisesCategoryModel>? selectedModel;

  ExercrisesCategoryModelLoaded(
      {required this.category, this.selectedModel, this.categorySearch});
}

class ExercrisesDataLoaded extends ExercrisesState {
  final List<InputDataExercriseModel> inputExercrisesModel;
  final bool? hasMore;
  ExercrisesDataLoaded(
      {required this.inputExercrisesModel, required this.hasMore});
}

class ExercriseDataDailyLoaded extends ExercrisesState {
  final ExercriseSummaryModel exercriseSummaryModel;
  final ExercriseWalkSummaryModel? exercriseWalkSummaryModel;

  ExercriseDataDailyLoaded(
      {required this.exercriseSummaryModel,
      required this.exercriseWalkSummaryModel});
}

class TimeTrendTrendLoaded extends ExercrisesState {
  final ExercriseTrendTimeModel model;
  TimeTrendTrendLoaded({required this.model});
}

class CaloTrendLoaded extends ExercrisesState {
  final ExercriseTrendCaloModel model;
  CaloTrendLoaded({required this.model});
}

class RankLoaded extends ExercrisesState {
  final ExerciseRankModel model;
  RankLoaded({required this.model});
}

class ExercriseTrendTimeLoaded extends ExercrisesState {
  final ExercriseTrendTimeModel trend;

  ExercriseTrendTimeLoaded({
    required this.trend,
  });

  ExercriseTrendTimeLoaded copyWith({
    ExercriseTrendTimeModel? trend,
  }) {
    return ExercriseTrendTimeLoaded(
      trend: trend ?? this.trend,
    );
  }
}

class ExercriseLessonsLoaded extends ExercrisesState {
  final List<LessonModel>? lessons;

  ExercriseLessonsLoaded({
    required this.lessons,
  });

  ExercriseLessonsLoaded copyWith({
    List<LessonModel>? lessons,
  }) {
    return ExercriseLessonsLoaded(
      lessons: lessons ?? this.lessons,
    );
  }
}

class ExerciseSupportLessonsLoaded extends ExercrisesState {
  final List<ExerciseLesson>? exercises;

  ExerciseSupportLessonsLoaded({
    required this.exercises,
  });

  ExerciseSupportLessonsLoaded copyWith({
    List<ExerciseLesson>? exercises,
  }) {
    return ExerciseSupportLessonsLoaded(
      exercises: exercises ?? this.exercises,
    );
  }
}
