import 'notification_type.dart';

class NotificationListModel {
  final String? id;
  String? notificationId;
  String? calendarId;
  String? title;
  String? body;
  String? topic;
  final String? imageUrl;
  final int? sentDateTime;
  bool? isRead;
  final String? hyperText;
  final String? hyperLink;
  final int? notificationType;
  final int? messageType;
  final String? surveyId;

  NotificationActionType get actionType =>
      NotificationActionExtend.getNotificationActionTypeFromIndexInteger(
          notificationType);

  NotificationListModel({
    this.id,
    this.notificationId,
    this.calendarId,
    required this.title,
    required this.body,
    this.topic,
    this.imageUrl,
    this.sentDateTime,
    this.isRead,
    this.hyperText,
    this.hyperLink,
    this.notificationType,
    this.surveyId,
    this.messageType,
  });

  @override
  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    final notification = json['notification'] ?? json;
    final dataNoti = json['data'];
    return NotificationListModel(
      id: notification['id'],
      notificationId: notification['notificationId'],
      calendarId: notification['calendarId'],
      title: notification['title'],
      body: notification['body'],
      topic: notification['topic'],
      imageUrl: notification['imageUrl'] is Map
          ? notification['imageUrl']['url']
          : notification['imageUrl'],
      sentDateTime: notification['sentDateTime'],
      isRead: notification['isRead'] ?? false,
      hyperText: notification['hyperText'],
      hyperLink: notification['hyperLink'],
      notificationType: notification['notificationType'],
      messageType: notification['messageType'],
      surveyId: notification['surveyId'],
    );
  }

  static List<NotificationListModel> toList(List<dynamic> items) {
    return items.map((item) => NotificationListModel.fromJson(item)).toList();
  }
}
