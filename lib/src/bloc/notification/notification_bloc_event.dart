part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class FetchNotification extends NotificationEvent {
  final int page;
  final bool? isRead;

  FetchNotification({required this.isRead, required this.page});
}
