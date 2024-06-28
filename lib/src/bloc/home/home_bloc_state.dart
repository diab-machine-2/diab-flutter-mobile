part of 'home_bloc.dart';

@immutable
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeError extends HomeState {
  final String? message;

  HomeError({
    required this.message,
  });
}

class HomeLoading extends HomeState {
  final HomeModel? model;

  HomeLoading({required this.model});
}

class HomeLoaded extends HomeState {
  final HomeModel model;

  final List<HomeActivityData>? activities;
  final List<HomeReminderData>? reminders;
  final List<HomeUtilityData>? utilities;
  final List<LearningPostModel>? news;
  final List<LessonModel>? lessons;

  HomeLoaded({
    required this.model,
    this.activities,
    this.reminders,
    this.utilities,
    this.news,
    this.lessons,
  });

  @override
  List<Object> get props => [
        model,
        if (activities != null) activities!,
        if (reminders != null) reminders!,
        if (utilities != null) utilities!,
        if (news != null) news!,
        if (lessons != null) lessons!,
      ];

  // copyWith method to create a new instance of HomeLoaded
  HomeLoaded copyWith({
    HomeModel? model,
    List<HomeActivityData>? activities,
    List<HomeReminderData>? reminders,
    List<HomeUtilityData>? utilities,
    List<LearningPostModel>? news,
    List<LessonModel>? lessons,
  }) {
    return HomeLoaded(
      model: model ?? this.model,
      activities: activities ?? this.activities,
      reminders: reminders ?? this.reminders,
      utilities: utilities ?? this.utilities,
      news: news ?? this.news,
      lessons: lessons ?? this.lessons,
    );
  }
}
