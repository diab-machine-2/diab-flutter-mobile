import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_zoom_meeting/zoom_options.dart';
import 'package:flutter_zoom_meeting/zoom_view.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
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
      NavigatorName.meeting_wait_room,
      arguments: args,
    );
  }

  void launchZoomMeeting(String meetingID, String password) async {
    bool ok = await grantPermission();
    if (!ok) {
      return;
    }

    try {
      BotToast.showLoading();

      String username = AppSettings.userInfo?.fullName ?? "Test Meeting";
      String jwtToken = _generateToken(username);

      ZoomOptions zoomOptions = ZoomOptions(
        domain: "zoom.us",
        jwtToken: jwtToken,
      );

      final meetingOptions = ZoomMeetingOptions(
        // zoomAccessToken:zoomAccessToken,
        meetingId: meetingID,
        meetingPassword: password,
        displayName: username,

        /// pass meeting password for join meeting only
        disableDialIn: "true",
        disableDrive: "true",
        disableTitlebar: "false",
        viewOptions: "true",
        autoConnectInternetAudio: "true",
        muteAudioWhenJoinMeeting: "true",
        meetingInviteHidden: "true",
        meetingInviteUrlHidden: "true",
        meetingShareHidden: "true",
        recordButtonHidden: "true",
        meetingPasswordHidden: "true",
      );

      final zoom = ZoomView();
      final results = await zoom.initZoom(zoomOptions);
      if (results[0] == 0) {
        zoom.onMeetingStatus().listen((status) {
          if (kDebugMode) {
            print("[Meeting Status Stream] : " + status[0] + " - " + status[1]);
          }
          if (_isMeetingEnded(status[0])) {
            _unInitialize();
            if (kDebugMode) {
              print("[Meeting Status] :- Ended");
            }
          }
        });
        if (kDebugMode) {
          print("listen on event channel");
        }
        zoom.joinMeeting(meetingOptions).then((joinMeetingResult) {});
      } else {
        if (kDebugMode) {
          print("[Error] : $results");
        }
      }
    } catch (e, s) {
      print("$e, $s");
      TrackingManager.recordError(e, s);
      BotToast.showText(text: "Lỗi kết nối");
    } finally {
      BotToast.closeAllLoading();
    }
  }

  String _generateToken(String username) {
    const Map configs = {
      'ZOOM_SDK_KEY': 'NKVBsW7GQNij99U4d0r2Ug',
      'ZOOM_SDK_SECRET': 'bn5QLW7Ed40RpoqGZW3iuGOkyZIC9j0C',
    };

    try {
      var iat = DateTime.now();
      var exp = DateTime.now().add(Duration(days: 2));
      final jwt = JWT(
        {
          'appKey': configs["ZOOM_SDK_KEY"],
          'iat': (iat.millisecondsSinceEpoch / 1000).round(),
          'exp': (exp.millisecondsSinceEpoch / 1000).round(),
          'tokenExp': (exp.millisecondsSinceEpoch / 1000).round(),
          // 'version': 1,
          // 'user_identity': username,
          // 'role_type': 0,
          // 'cloud_recording_option': 0,
        },
      );
      var token = jwt.sign(SecretKey(configs["ZOOM_SDK_SECRET"]));
      return token;
    } catch (e, s) {
      print("$e, $s");
      throw e;
    }
  }

  bool _isMeetingEnded(String status) {
    bool result = false;

    if (Platform.isAndroid) {
      result = status == "MEETING_STATUS_DISCONNECTING" ||
          status == "MEETING_STATUS_FAILED";
    } else {
      result = status == "MEETING_STATUS_IDLE";
    }

    return result;
  }

  void _unInitialize() async {
    final zoom = ZoomView();
    await zoom.unInitialize();
     BranchioLinkConfig.instance.lastMeetingEndTime = DateTime.now();
    BranchioLinkConfig.instance.removeMeetingId();
  }

  Future<MeetingArguments?> generateMeetingArgument(
      String roomId, String displayName) async {
    final response = await AppRepository()
        .getZoomToken(roomId: roomId, displayName: displayName);
    final result = response.when(
        success: (ZoomTokenResponse data) => data, failure: (e) => null);
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

    List<Permission> permissions = (Platform.isAndroid
        ? platformPermissions["android"]
        : platformPermissions["ios"])!;
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    // at least microphone permission is granted
    bool microGranted =
        statuses[Permission.microphone] == PermissionStatus.granted;

    // log if any permission is denied
    if (statuses.isNotEmpty &&
        statuses.entries.any((e) => e.value == PermissionStatus.denied)) {
      final entries = statuses.entries;
      String message = "Permissions " +
          entries
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
}

class MeetingArguments {
  final String token;
  final String sessionName;
  final String displayName;
  final String sessionPassword;
  final String sessionIdleTimeoutMins;

  bool isCameraOn = false;
  bool isCameraInitializedFailed = false;
  bool isMicOn = false;
  bool isMicInitializedFailed = false;

  MeetingArguments({
    required this.token,
    required this.sessionName,
    required this.displayName,
    required this.sessionPassword,
    required this.sessionIdleTimeoutMins,
  });
}
