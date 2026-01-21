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
      NotificationActionExtend.getNotificationActionTypeFromIndex(
          data?.notificationType ?? notificationType);

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
      imageUrl: notification['imageUrl'] is Map
          ? notification['imageUrl']['url']
          : notification['imageUrl'],
      sentDateTime: notification['sentDateTime'],
      isRead: notification['isRead'] ?? false,
      hyperText: notification['hyperText'],
      hyperLink: notification['hyperLink'],
      data: dataNoti == null ? null : NotificationData.fromJson(dataNoti),
      notificationType: () {
        dynamic type;
        if (notification['data'] is Map) {
          final dataMap = notification['data'] as Map;
          // Check if data is empty Map
          if (dataMap.isEmpty) {
            type = null;
          } else {
            type =
                dataMap['notificationType'] ?? notification['notificationType'];
          }
        } else {
          type = notification['notificationType'];
        }
        // Default to "4" if null or empty
        if (type == null) {
          return "4";
        }
        final typeString = type.toString();
        return (typeString.isEmpty) ? "4" : typeString;
      }(),
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
  final String? notificationType;
  final String? notificationId;
  final String? referalCode;
  final String? surveyId;

  NotificationData(
      {this.surveyId,
      required this.notificationId,
      required this.calendarId,
      required this.communicationId,
      required this.remindId,
      required this.notificationType,
      required this.referalCode});

  @override
  factory NotificationData.fromJson(dynamic json) {
    // Check if json is an empty Map
    final isEmptyMap = json is Map && json.isEmpty;
    // Get notificationType, default to "4" if null, empty, or data is empty Map
    final notificationTypeRaw = json['notificationType'];
    final notificationTypeValue = isEmptyMap ||
            notificationTypeRaw == null ||
            (notificationTypeRaw is String && notificationTypeRaw.isEmpty)
        ? "4"
        : notificationTypeRaw.toString();

    return NotificationData(
        notificationId: json['notificationId'],
        communicationId: json['communicationId'],
        remindId: json['remindId'],
        calendarId: json['calendarId'],
        referalCode: json['referalCode'],
        surveyId: json['surveyId'],
        notificationType: notificationTypeValue);
  }

  static List<NotificationData> toList(List<dynamic> items) {
    return items.map((item) => NotificationData.fromJson(item)).toList();
  }
}
