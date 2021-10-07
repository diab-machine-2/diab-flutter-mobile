part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

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

  HomeLoaded({required this.model});
}
