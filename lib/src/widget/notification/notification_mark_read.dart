import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/notification/notification_list_model.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

/// Marks [notification] read on the server, and only then tells the
/// notification lists (`read_notification`) to show it as read — so a failed
/// `MarkReadUnread` never leaves an item looking read while the server (and
/// the Home badge) still count it unread. Errors are logged, not shown: the
/// tap still navigates as usual.
///
/// Skipped when [NotificationListModel.notificationId] is missing: the
/// backend rejects those (ERR-1, appointment notifications).
Future<void> markNotificationRead(NotificationListModel notification) async {
  if (notification.notificationId?.isNotEmpty != true) return;
  // A second tap while the first call is in flight would broadcast twice and
  // add the item to the "Đã đọc" tab twice.
  final key = notification.id ?? notification.notificationId!;
  if (!_pendingIds.add(key)) return;
  try {
    await NotificationClient().readNotification(
        notification.id,
        notification.notificationId,
        AppSettings.userInfo?.id,
        notification.notificationType.toString(),
        true);
    Observable.instance.notifyObservers([],
        notifyName: "read_notification", map: {'notification': notification});
  } catch (e, s) {
    TrackingManager.recordError(e, s);
  } finally {
    _pendingIds.remove(key);
  }
}

final Set<String> _pendingIds = {};
