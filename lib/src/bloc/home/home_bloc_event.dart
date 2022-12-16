part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class FetchHome extends HomeEvent {
  FetchHome();
}

class SyncHealthApp extends HomeEvent {
  SyncHealthApp();
}
