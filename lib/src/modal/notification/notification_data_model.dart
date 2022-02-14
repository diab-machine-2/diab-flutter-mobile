import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:meta/meta.dart';
@immutable
class NotificationDataModel {
  final List<NotificationModel> models;
  final bool? hasMore;

  const NotificationDataModel({required this.models, required this.hasMore});
}
