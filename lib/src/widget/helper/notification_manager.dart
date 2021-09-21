import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/main.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();

  factory NotificationManager() {
    return instance;
  }

  NotificationManager._internal();

  Future requestFirebaseToken() async {
    firebaseConfigure();
    final deviceInfor = await getDeviceInformation();
    var deviceId = deviceInfor != null ? deviceInfor['uuid'] : '';
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print(token);
      await LoginClient().syncToken(deviceId, token, Platform.isIOS ? 1 : 2);
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(
      RemoteMessage message) async {
    final model = NotificationModel(
        title: message.notification!.title,
        body: message.notification!.body ?? '',
        data: NotificationData.fromJson(message.data));
    DartNotificationCenter.post(channel: 'reload_notification');
    NotificationManager.instance.navigateNotification(model);
  }

  void firebaseConfigure() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message);
      final model = NotificationModel(
          title: message.notification!.title,
          body: message.notification!.body ?? '',
          data: NotificationData.fromJson(message.data));
      DartNotificationCenter.post(channel: 'reload_notification');
      Message.showNotificationMessage(
          model: model,
          callback: (model) {
            navigateNotification(model!);
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final model = NotificationModel(
          title: message.notification!.title,
          body: message.notification!.body ?? '',
          data: NotificationData.fromJson(message.data));
      DartNotificationCenter.post(channel: 'reload_notification');
      navigateNotification(model);
    });

    FirebaseMessaging.onBackgroundMessage(
        (message) => myBackgroundMessageHandler(message));

    // RemoteMessage initialMessage =
    //     await FirebaseMessaging.instance.getInitialMessage();
    // if (initialMessage != null) {
    //   final model = NotificationModel(
    //       title: initialMessage.notification.title,
    //       body: initialMessage.notification.body ?? '',
    //       data: NotificationData.fromJson(initialMessage.data));
    //   navigateNotification(model);
    // }
  }

  navigateNotification(NotificationModel model) {
    NotificationClient().readNotification(
        model.id == null ? model.data!.communicationId : model.id,
        AppSettings.userInfo!.id,
        model.data!.notificationType,
        true);
    if (model.data!.notificationType == 1) {
      Navigator.pushNamed(
          navigatorKey.currentState!.context, NavigatorName.notification_detail,
          arguments: {'id': model.data!.communicationId});
    } else if (model.data!.notificationType == 2) {
      Navigator.pushNamed(navigatorKey.currentState!.context, NavigatorName.add_reminder,
          arguments: {'type': 'update', 'id': model.data!.remindId});
    } else if (model.data!.notificationType == 3) {
      Navigator.pushNamed(navigatorKey.currentState!.context, NavigatorName.add_blood_sugar,
          arguments: {'type': 'input', 'id': null});
    }
  }

  Future<Map<String, dynamic>?> getDeviceInformation() async {
    Map<String, dynamic>? deviceInformation;
    DeviceInfoPlugin infor = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await infor.iosInfo;
        deviceInformation = {
          'uuid': iosDeviceInfo.identifierForVendor,
          'localizedModel': iosDeviceInfo.localizedModel,
          'model': iosDeviceInfo.model,
          'name': iosDeviceInfo.name,
          'systemName': iosDeviceInfo.systemName,
          'systemVersion': iosDeviceInfo.systemVersion,
          'utsname': iosDeviceInfo.utsname.machine,
          'isPhysicalDevice': iosDeviceInfo.isPhysicalDevice
        };
      } else {
        AndroidDeviceInfo androidDeviceInfo = await infor.androidInfo;
        deviceInformation = {
          'uuid': androidDeviceInfo.id,
          'androidId': androidDeviceInfo.androidId,
          'board': androidDeviceInfo.board,
          'bootloader': androidDeviceInfo.bootloader,
          'brand': androidDeviceInfo.brand,
          'device': androidDeviceInfo.device,
          'display': androidDeviceInfo.display,
          'fingerprint': androidDeviceInfo.fingerprint,
          'hardware': androidDeviceInfo.hardware,
          'host': androidDeviceInfo.host,
          'manufacturer': androidDeviceInfo.manufacturer,
          'model': androidDeviceInfo.model,
          'product': androidDeviceInfo.product,
          //'systemFeatures': androidDeviceInfo.systemFeatures,
          'tags': androidDeviceInfo.tags,
          'version': androidDeviceInfo.version,
          'isPhysicalDevice': androidDeviceInfo.isPhysicalDevice
        };
      }
    } catch (exception) {}
    return deviceInformation;
  }
}
