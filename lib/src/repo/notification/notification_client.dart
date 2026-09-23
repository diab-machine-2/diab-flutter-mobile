import 'package:dio/dio.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../modal/notification/notification_data_list_model.dart';
import '../../modal/notification/notification_list_model.dart';

class NotificationClient extends FetchClient {
  // Notification list page size. The backend's meta for this endpoint has no
  // canNext/total field to tell us whether more pages exist (unlike other
  // paginated endpoints in this app), so hasMore below is derived from
  // whether a full page came back instead.
  static const int _pageSize = 20;

  Future<NotificationDataListModel?> fetchNotifications(bool? isRead, int page) async {
    try {
      Map<String, String> params = {'page': page.toString(), 'size': '$_pageSize'};
      if (isRead != null) {
        params['isRead'] = isRead.toString();
      }
      final Response response = await super.fetchData(url: '/App/Communication/NotificationDelivered', params: params);
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          final items = NotificationListModel.toList(response.data['data']);
          // Prefer a real canNext if the backend ever starts sending one —
          // only fall back to the heuristic when it's actually missing.
          final canNext = response.data['meta']?['canNext'];
          final hasMore = canNext is bool ? canNext : items.length >= _pageSize;
          return NotificationDataListModel(models: items, hasMore: hasMore);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<NotificationListModel> fetchNotificationDetail(String? id, String? communicationId) async {
    try {
      Map<String, String> params = {'notificationId': id ?? '', 'communicationId': communicationId ?? ''};
      final Response response = await super.fetchData(url: '/App/Communication/NotiDetail', params: params);
      if (response.statusCode == 200) {
        return NotificationListModel.fromJson(response.data['data']);
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<int?> fetchNotificationCount() async {
    try {
      final Response response = await super.fetchData(url: '/App/Communication/CountUnread');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool?> readNotification(String? communicationId, String? notificationId, String? patientId, String? notificationType, bool isRead) async {
    try {
      final Response response = await super.putData(url: '/App/Communication/MarkReadUnread', params: {
        'notificationId': notificationId,
        'communicationId': communicationId,
        'notificationType': notificationType,
        'patientId': patientId,
        'isRead': isRead
      });
      if (response.statusCode == 200) {
        Observable.instance.notifyObservers([], notifyName: "read_notification_success");
        // DartNotificationCenter.post(channel: 'read_notification_success');
        return response.data['data'];
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<bool> deleteNotification(String? id, int? type) async {
    try {
      final Response response = await super.delete(url: '/App/Communication/Notification/$id/$type');
      if (response.statusCode == 200) {
        return true;
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }
}
