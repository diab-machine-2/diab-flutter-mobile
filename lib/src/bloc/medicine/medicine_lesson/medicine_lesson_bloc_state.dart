part of 'medicine_lesson_bloc.dart';

@immutable
abstract class MedicineLessonState extends Equatable {
  const MedicineLessonState();

  @override
  List<Object> get props => [];
}

class MedicineLessonInitial extends MedicineLessonState {}

class MedicineLessonNoData extends MedicineLessonState {}

class MedicineLessonError extends MedicineLessonState {}

class MedicineLessonLoaded extends MedicineLessonState {
  final List<LessonModel> lessons;

  MedicineLessonLoaded({required this.lessons});
}
