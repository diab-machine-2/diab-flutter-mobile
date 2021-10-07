import 'package:medical/src/modal/notification/notification_data_model.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

class NotificationModel {
  final String? id;
  final String? title;
  final String? body;
  final String? topic;
  final String? imageUrl;
  final int? sentDateTime;
  final bool? isRead;
  final String? hyperText;
  final String? hyperLink;
  final NotificationData? data;
  final int? notificationType;

  NotificationModel(
      {this.id,
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

  @override
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final notification =
        json['notification'] == null ? json : json['notification'];
    final dataNoti = json['data'];
    return NotificationModel(
        id: notification['id'],
        title: notification['title'],
        body: notification['body'],
        topic: notification['topic'],
        imageUrl: notification['imageUrl'] is Map
            ? notification['imageUrl']['url']
            : notification['imageUrl'],
        sentDateTime: notification['sentDateTime'],
        isRead: notification['isRead'],
        hyperText: notification['hyperText'],
        hyperLink: notification['hyperLink'],
        data: dataNoti == null ? null : NotificationData.fromJson(dataNoti),
        notificationType: notification['notificationType']);
  }

  static List<NotificationModel> toList(List<dynamic> items) {
    return items.map((item) => NotificationModel.fromJson(item)).toList();
  }
}

class NotificationData {
  final String? communicationId;
  final String? remindId;
  final int notificationType;

  NotificationData(
      {required this.communicationId,
      required this.remindId,
      required this.notificationType});

  @override
  factory NotificationData.fromJson(dynamic json) {
    return NotificationData(
        communicationId: json['communicationId'],
        remindId: json['remindId'],
        notificationType: int.parse(json['notificationType']));
  }

  static List<NotificationData> toList(List<dynamic> items) {
    return items.map((item) => NotificationData.fromJson(item)).toList();
  }
}
