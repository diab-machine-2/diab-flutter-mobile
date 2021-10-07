part of 'notification_bloc.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationError extends NotificationState {
  final String? message;

  NotificationError({
    required this.message,
  });
}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final NotificationDataModel? model;
  NotificationLoaded({required this.model});
}
