import 'package:dio/dio.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/notification/notification_data_model.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationClient extends FetchClient {
  Future<NotificationDataModel?> fetchNotifications(bool? isRead, int page) async {
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
          return NotificationDataModel(
              models: NotificationModel.toList(response.data['data']), hasMore: response.data['meta']['canNext']);
        }
      } else {
        final error = Error.fromJson(response);
        throw error;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<NotificationModel> fetchNotificationDetail(String? id) async {
    try {
      final Response response = await super.fetchData(url: '/App/Communication/$id');
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data['data']);
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

  Future<bool?> readNotification(String? communicationId, String? patientId, int? notificationType, bool isRead) async {
    try {
      final Response response = await super.putData(url: '/App/Communication/MarkReadUnread', params: {
        'notificationId': communicationId,
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

  Future<bool> deleteNotification(String? id) async {
    try {
      final Response response = await super.delete(url: '/App/Communication/Notification/$id');
      print(response);
      if (response.statusCode == 200) {
        print('delete success');
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
