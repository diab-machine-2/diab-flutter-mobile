import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:medical/src/app.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/notification/notification_model.dart';
import 'package:medical/src/modal/notification/notification_type.dart';
import 'package:medical/src/repo/login/login_client.dart';
import 'package:medical/src/repo/notification/notification_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/question_answer/all_question_answer/model/question_model.dart';
import 'package:medical/src/widget/voucher/presentation/voucher_modals/voucher_reward_modal.dart';
import 'package:medical/src/widgets/share_profile_popup.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();
  bool _hasHandledInitialMessage = false;

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
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      print('Firebase Messaging - token: $token');
      // Clipboard.setData(new ClipboardData(text: token)).then((_){
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(token ?? 'Copied'), duration: Duration(minutes: 3),));
      // });

      await LoginClient().syncToken(deviceId, token, Platform.isIOS ? 1 : 2);
    } catch (e) {
      print(e);
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(
      RemoteMessage message) async {
    NotificationManager.instance.navigateNotification(message);
  }

  Future<void> firebaseConfigure() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Firebase Messaging - onMessage ");
      final model = NotificationModel(
          title: message.notification?.title,
          body: message.notification?.body ?? '',
          data: NotificationData.fromJson(message.data));

      if (model.actionType == NotificationActionType.share_profile) {
        ShareProfilePopup.instance.onHasSharedCode(
            requestFromDoctor: true, code: model.data?.referalCode ?? "");
        return;
      } else if (model.actionType ==
          NotificationActionType.register_referral_success) {
        VoucherModalReward.showModal(
            navigatorKey.currentState!.context, model.data!.surveyId!);
        return;
      }
      // Observable.instance
      //     .notifyObservers([], notifyName: "reload_notification");

      // if(model.body != null){
      //   model.body = parseHtmlString(model.body!);
      // }

      Message.showNotificationMessage(
          model: model,
          callback: (model) {
            if (model != null) {
              navigateNotification(message);
            }
          });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Firebase Messaging - onMessageOpenedApp ");
      if (!_hasHandledInitialMessage) {
        _hasHandledInitialMessage = true;
        navigateNotification(message);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("Firebase Messaging - getInitialMessage ");
      if (message != null && !_hasHandledInitialMessage) {
        _hasHandledInitialMessage = true;
        navigateNotification(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }

  navigateNotification(RemoteMessage? message) {
    print("Firebase Messaging - navigateNotification");
    if (message == null) return;
    // Observable.instance.notifyObservers([], notifyName: "reload_notification");
    var user = AppSettings.userInfo;

    NotificationModel model = NotificationModel(
      title: message.notification?.title,
      body: message.notification?.body ?? '',
      notificationType: message.data['notificationType'],
      data: NotificationData.fromJson(message.data),
    );

    if (user?.fullName != null) {
      if (model.title != null) {
        model.title = model.title!.replaceAll('{Username}}', user!.fullName!);
      }
      if (model.body != null) {
        model.body = model.body!.replaceAll('{Username}}', user!.fullName!);
      }
      if (model.topic != null) {
        model.topic = model.topic!.replaceAll('{Username}}', user!.fullName!);
      }
    }

    // if(model.body != null){
    //   model.body = parseHtmlString(model.body!);
    // }

    if (user?.packageName != null && user!.packageName!.isNotEmpty) {
      model.body = model.body!.replaceAll('{Packagename}}', user.packageName!);
    }

    if (model.actionType == NotificationActionType.share_profile) {
      ShareProfilePopup.instance.onHasSharedCode(
          requestFromDoctor: true, code: model.data?.referalCode ?? "");
      return;
    }

    if (model.actionType != NotificationActionType.register_referral_success) {
      NotificationClient().readNotification(
          model.data?.communicationId,
          model.id ?? model.data?.notificationId,
          AppSettings.userInfo?.id,
          model.data?.notificationType,
          true);
    }

    if (model.calendarId == null) {
      switch (model.actionType) {
        case NotificationActionType.redirect_to_activity_tab:
          Navigator.pushReplacementNamed(
              navigatorKey.currentState!.context, NavigatorName.tabbar,
              arguments: {
                'id': model.data?.communicationId,
                'isRedirectFromNotification': true,
              });
          break;
        case NotificationActionType.redirect_to_url:
          Navigator.pushNamed(navigatorKey.currentState!.context,
              NavigatorName.notification_detail, arguments: {
            'id': model.data?.notificationId,
            'communicationId': model.data?.communicationId
          });
          break;
        case NotificationActionType.add_reminder:
          Navigator.pushNamed(
              navigatorKey.currentState!.context, NavigatorName.add_reminder,
              arguments: {'type': 'update', 'id': model.data?.remindId});
          break;
        case NotificationActionType.add_blood_sugar:
          Navigator.pushNamed(navigatorKey.currentState!.context,
              NavigatorName.add_blood_sugar_new,
              arguments: {'type': 'input', 'id': model.data?.communicationId});
          break;
        case NotificationActionType.none:
          break;
        case NotificationActionType.share_profile:
          break;
        case NotificationActionType.redirect_date_detail:
          break;
        case NotificationActionType.redirect_survey:
          break;
        case NotificationActionType.register_referral_success:
          VoucherModalReward.showModal(
              navigatorKey.currentState!.context, model.data!.surveyId!);
          break;
        case NotificationActionType.doctor_answer_question:
          QuestionModel questionModel =
              QuestionModel(id: model.data!.surveyId!);
          Navigator.pushNamed(
              navigatorKey.currentState!.context, NavigatorName.question_detail,
              arguments: {'questionModel': questionModel, 'isAll': true});
          break;
      }
    }
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
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
          'androidId': androidDeviceInfo.id,
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
