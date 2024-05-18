import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/zoom_token_response.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class ZoomService {
  void launchZoom(
    String roomId,
    String displayName,
    BuildContext context,
  ) async {
    bool ok = await grantPermission();
    if (!ok) {
      return;
    }

    MeetingArguments? args = await generateMeetingArgument(roomId, displayName);
    if (args == null) {
      BotToast.showText(text: "Lỗi kết nối");
      return;
    }

    Navigator.pushNamed(
      context,
      NavigatorName.meeting,
      arguments: args,
    );
  }

  Future<MeetingArguments?> generateMeetingArgument(String roomId, String displayName) async {
    final response = await AppRepository().getZoomToken(roomId: roomId, displayName: displayName);
    final result = response.when(success: (ZoomTokenResponse data) => data, failure: (e) => null);
    if (result == null) {
      return null;
    }

    return MeetingArguments(
      token: result.token,
      sessionName: result.sessionName,
      displayName: result.displayName ?? displayName,
      sessionIdleTimeoutMins: result.sessionIdleTimeoutMins,
      sessionPassword: result.sessionPassword,
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
      String message = "Permissions " +
          entries.map((e) => "${e.key.toString()}=${e.value.isGranted}").join(", ");
      TrackingManager.recordError(Exception(message), null);
    }

    if (!microGranted) {
      await openAppSettings();
      return false;
    }
    return microGranted;
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
