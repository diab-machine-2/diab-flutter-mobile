import 'package:dio/dio.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../modal/notification/notification_data_list_model.dart';
import '../../modal/notification/notification_list_model.dart';

class NotificationClient extends FetchClient {
  Future<NotificationDataListModel?> fetchNotifications(bool? isRead, int page) async {
    try {
      Map<String, String> params = {'page': page.toString(), 'size': '1000'};
      if (isRead != null) {
        params['isRead'] = isRead.toString();
      }
      final Response response = await super.fetchData(url: '/App/Communication/NotificationDelivered', params: params);
      if (response.statusCode == 200) {
        if (response.data['data'] == null) {
          return null;
        } else {
          return NotificationDataListModel(
              models: NotificationListModel.toList(response.data['data']), hasMore: response.data['meta']['canNext']);
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
