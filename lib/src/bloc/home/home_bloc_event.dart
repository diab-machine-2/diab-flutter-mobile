part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class FetchHome extends HomeEvent {
  FetchHome();
}

class HomeFetchActivityEvent extends HomeEvent {
  HomeFetchActivityEvent();
}

class HomeFetchReminderEvent extends HomeEvent {
  HomeFetchReminderEvent();
}

class HomeFetchLessonEvent extends HomeEvent {
  HomeFetchLessonEvent();
}

class HomeFetchNewsEvent extends HomeEvent {
  HomeFetchNewsEvent();
}

class HomeFetchBannersEvent extends HomeEvent {
  HomeFetchBannersEvent();
}

class HomeFetchCustomerReceivesUser extends HomeEvent {
  HomeFetchCustomerReceivesUser();
}

// class SyncHealthApp extends HomeEvent {
//   SyncHealthApp();
// }
