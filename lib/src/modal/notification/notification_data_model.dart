import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:meta/meta.dart';

class NotificationDataModel {
  final List<NotificationModel> models;
  final bool hasMore;

  NotificationDataModel({@required this.models, @required this.hasMore});
}
