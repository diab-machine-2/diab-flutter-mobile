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
  final List<LearningPostModel>? banners;
  final String zaloGroup;

  // Control loading state
  final bool measurementLoading;
  final bool activityLoading;
  final bool reminderLoading;

  HomeLoaded({
    required this.model,
    this.activities,
    this.reminders,
    this.utilities,
    this.news,
    this.lessons,
    this.banners,
    this.measurementLoading = true,
    this.activityLoading = true,
    this.reminderLoading = true,
    this.zaloGroup = "",
  });

  @override
  List<Object> get props => [
        measurementLoading,
        activityLoading,
        reminderLoading,
        model,
        if (activities != null) activities!,
        if (reminders != null) reminders!,
        if (utilities != null) utilities!,
        if (news != null) news!,
        if (lessons != null) lessons!,
        if (banners != null) banners!,
        zaloGroup,
      ];

  // copyWith method to create a new instance of HomeLoaded
  HomeLoaded copyWith({
    HomeModel? model,
    List<HomeMeasurementInlineData>? inlineMeasurements,
    List<HomeMeasurementData>? measurements,
    List<HomeActivityData>? activities,
    List<HomeReminderData>? reminders,
    List<HomeUtilityData>? utilities,
    List<LearningPostModel>? news,
    List<LearningPostModel>? banners,
    List<LessonModel>? lessons,
    bool? measurementLoading,
    bool? activityLoading,
    bool? reminderLoading,
    String? zaloGroup,
  }) {
    return HomeLoaded(
      model: model ?? this.model,
      activities: activities ?? this.activities,
      reminders: reminders ?? this.reminders,
      utilities: utilities ?? this.utilities,
      news: news ?? this.news,
      lessons: lessons ?? this.lessons,
      banners: banners ?? this.banners,
      measurementLoading: measurementLoading ?? this.measurementLoading,
      activityLoading: activityLoading ?? this.activityLoading,
      reminderLoading: reminderLoading ?? this.reminderLoading,
      zaloGroup: zaloGroup ?? this.zaloGroup,
    );
  }
}
