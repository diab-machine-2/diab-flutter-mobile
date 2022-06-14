import 'notification_type.dart';

class NotificationModel {
  final String? id;
  String? notificationId;
  String? calendarId;
  String? title;
  String? body;
  String? topic;
  final String? imageUrl;
  final int? sentDateTime;
  final bool? isRead;
  final String? hyperText;
  final String? hyperLink;
  final NotificationData? data;
  final String? notificationType;

  NotificationModel(
      {this.id,
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
      this.data,
      this.notificationType});

  NotificationActionType get actionType =>
      NotificationActionExtend.getNotificationActionTypeFromIndex(data?.notificationType ?? notificationType);

  @override
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final notification = json['notification'] ?? json;
    final dataNoti = json['data'];
    return NotificationModel(
      id: notification['id'],
      notificationId: notification['notificationId'],
      calendarId: notification['calendarId'],
      title: notification['title'],
      body: notification['body'],
      topic: notification['topic'],
      imageUrl: notification['imageUrl'] is Map ? notification['imageUrl']['url'] : notification['imageUrl'],
      sentDateTime: notification['sentDateTime'],
      isRead: notification['isRead'] ?? false,
      hyperText: notification['hyperText'],
      hyperLink: notification['hyperLink'],
      data: dataNoti == null ? null : NotificationData.fromJson(dataNoti),
      notificationType: notification['data'] is Map
          ? notification['data']['notificationType'] != null
              ? notification['data']['notificationType']
              : notification['notificationType']
          : notification['notificationType'],
    );
  }

  static List<NotificationModel> toList(List<dynamic> items) {
    return items.map((item) => NotificationModel.fromJson(item)).toList();
  }
}

class NotificationData {
  final String? communicationId;
  final String? remindId;
  final String? calendarId;
  final String notificationType;
  final String? notificationId;
  final String? referalCode;

  NotificationData({required this.notificationId, required this.calendarId, required this.communicationId, required this.remindId, required this.notificationType, required this.referalCode});

  @override
  factory NotificationData.fromJson(dynamic json) {
    return NotificationData(
        notificationId: json['notificationId'],
        communicationId: json['communicationId'],
        remindId: json['remindId'],
        calendarId: json['calendarId'],
        referalCode: json['referalCode'],
        notificationType: json['notificationType']);
  }

  static List<NotificationData> toList(List<dynamic> items) {
    return items.map((item) => NotificationData.fromJson(item)).toList();
  }
}
