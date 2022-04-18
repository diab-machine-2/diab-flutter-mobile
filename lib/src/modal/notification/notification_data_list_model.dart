import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:meta/meta.dart';

import 'notification_list_model.dart';

@immutable
class NotificationDataListModel {
  final List<NotificationListModel> models;
  final bool? hasMore;

  const NotificationDataListModel({required this.models, required this.hasMore});
}
