import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/modal/notification/notification_type.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();

  factory NotificationManager() {
    return instance;
  }

  NotificationManager._internal();

  Future requestFirebaseToken(BuildContext context) async {
    firebaseConfigure();
    final Map<String, dynamic>? deviceInfor = await getDeviceInformation();
    final String deviceId = deviceInfor != null ? deviceInfor['uuid'] : '';
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print(token);
      // Clipboard.setData(new ClipboardData(text: token)).then((_){
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(token ?? 'Copied'), duration: Duration(minutes: 3),));
      // });

      await LoginClient().syncToken(deviceId, token, Platform.isIOS ? 1 : 2);
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
    NotificationManager.instance.navigateNotification(message);
  }

  Future<void> firebaseConfigure() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final model = NotificationModel(
          title: message.notification?.title,
          body: message.notification?.body ?? '',
          data: NotificationData.fromJson(message.data));

      if (model.actionType == NotificationActionType.share_profile) {
        ShareProfilePopup.instance.onHasSharedCode(requestFromDoctor: true, code: '123456');
        return;
      }
      Message.showNotificationMessage(
          model: model,
          callback: (model) {
            if (model != null) {
              navigateNotification(message);
            }
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      navigateNotification(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      navigateNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage((message) => myBackgroundMessageHandler(message));
  }

  navigateNotification(RemoteMessage? message) {
    if (message == null) return;
    Observable.instance.notifyObservers([], notifyName: "reload_notification");

    final NotificationModel model = NotificationModel(
      title: message.notification?.title,
      body: message.notification?.body ?? '',
      data: NotificationData.fromJson(message.data),
    );

    if (model.actionType == NotificationActionType.share_profile) {
      ShareProfilePopup.instance.onHasSharedCode(requestFromDoctor: true, code: '123456');
      return;
    }

    NotificationClient().readNotification(
        model.id ?? model.data?.communicationId, AppSettings.userInfo?.id, model.data?.notificationType, true);

    switch (model.actionType) {
      case NotificationActionType.redirect_to_activity_tab:
        Navigator.pushReplacementNamed(navigatorKey.currentState!.context, NavigatorName.tabbar, arguments: {
          'id': model.data?.communicationId,
          'isRedirectFromNotification': true,
        });
        break;
      case NotificationActionType.redirect_to_url:
        Navigator.pushNamed(navigatorKey.currentState!.context, NavigatorName.notification_detail,
            arguments: {'id': model.data?.communicationId});
        break;
      case NotificationActionType.add_reminder:
        Navigator.pushNamed(navigatorKey.currentState!.context, NavigatorName.add_reminder,
            arguments: {'type': 'update', 'id': model.data?.remindId});
        break;
      case NotificationActionType.add_blood_sugar:
        Navigator.pushNamed(navigatorKey.currentState!.context, NavigatorName.add_blood_sugar,
            arguments: {'type': 'input', 'id': model.data?.communicationId});
        break;
      case NotificationActionType.none:
        break;
      case NotificationActionType.share_profile:
        break;
      case NotificationActionType.redirect_date_detail:
        break;
    }
  }

  Future<Map<String, dynamic>?> getDeviceInformation() async {
    Map<String, dynamic>? deviceInformation;
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        final IosDeviceInfo iosDeviceInfo = await info.iosInfo;
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
        final AndroidDeviceInfo androidDeviceInfo = await info.androidInfo;
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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
