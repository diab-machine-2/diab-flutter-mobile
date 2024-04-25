import 'dart:io';
import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/widgets.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class ZoomService {
  void launchZoom(
    String roomId,
    String displayName,
    BuildContext context, {
    String? userId,
  }) async {
    bool ok = await grantPermission();
    if (!ok) {
      return;
    }
    MeetingArguments args = generateMeetingArgument(roomId, displayName, userId);
    Navigator.pushNamed(
      context,
      NavigatorName.meeting,
      arguments: args,
    );
  }

  MeetingArguments generateMeetingArgument(String roomId, String displayName, String? userId) {
    String sessionName = roomId;
    String token = _generateToken(roomId, userId);
    String sessionIdleTimeoutMins = "40";
    String sessionPassword = "1";

    return MeetingArguments(
      token: token,
      sessionName: sessionName,
      displayName: displayName,
      sessionIdleTimeoutMins: sessionIdleTimeoutMins,
      sessionPassword: sessionPassword,
    );
  }

  /// At least microphone permission is required to join a meeting
  Future<bool> grantPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }
    Map<String, List<Permission>> platformPermissions = {
      "ios": [
        Permission.camera,
        Permission.microphone,
      ],
      "android": [
        Permission.camera,
        Permission.microphone,
        Permission.bluetoothConnect,
        Permission.phone,
        Permission.storage,
      ],
    };

    List<Permission> permissions =
        (Platform.isAndroid ? platformPermissions["android"] : platformPermissions["ios"])!;
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    // at least microphone permission is granted
    bool microGranted = statuses[Permission.microphone] == PermissionStatus.granted;

    // log if any permission is denied
    if (statuses.isNotEmpty && statuses.entries.any((e) => e.value == PermissionStatus.denied)) {
      final entries = statuses.entries;
      String message = "Permissions " + entries
          .map((e) => "${e.key.toString()}=${e.value.isGranted}")
          .join(", ");
      TrackingManager.recordError(Exception(message), null);
    }

    if (!microGranted) {
      await openAppSettings();
      return false;
    }
    return microGranted;
  }

  String _makeId(int length) {
    String result = "";
    String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    int charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
      result += characters[Random().nextInt(charactersLength)];
    }
    return result;
  }

  String _generateToken(String topic, String? userId) {
    String finalUserId = userId ?? _makeId(10);
    finalUserId = finalUserId.substring(0, 10);
    const Map configs = {
      'ZOOM_SDK_KEY': 'mGEaJOJsQcW8OGAXZzawsg',
      'ZOOM_SDK_SECRET': 'cKwuffl2tTQXLLheIar6YQP7axs8HA3rbVpZ',
    };

    try {
      var iat = DateTime.now();
      var exp = DateTime.now().add(Duration(days: 2));
      final jwt = JWT(
        {
          'app_key': configs["ZOOM_SDK_KEY"],
          'version': 1,
          'user_identity': finalUserId,
          'iat': (iat.millisecondsSinceEpoch / 1000).round(),
          'exp': (exp.millisecondsSinceEpoch / 1000).round(),
          'tpc': topic,
          'role_type': 0,
          'cloud_recording_option': 0,
        },
      );
      var token = jwt.sign(SecretKey(configs["ZOOM_SDK_SECRET"]));
      return token;
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    }
    return '';
  }
}

class MeetingArguments {
  final String token;
  final String sessionName;
  final String displayName;
  final String sessionPassword;
  final String sessionIdleTimeoutMins;

  MeetingArguments({
    required this.token,
    required this.sessionName,
    required this.displayName,
    required this.sessionPassword,
    required this.sessionIdleTimeoutMins,
  });
}
