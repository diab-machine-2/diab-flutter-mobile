import 'dart:math';
import 'dart:io' show Platform;

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/meeting/meeting_page.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingPreparePage extends StatelessWidget {
  const MeetingPreparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Prepare'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Diab Meeting"),
            // SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                child: Text('Start Meeting'),
                onPressed: () async {
                  bool ok = await _grantPermission();
                  if (!ok) {
                    return;
                  }
                  String sessionName = "ses-1";
                  String displayName = "Test Meeting";
                  String token = _generateToken();
                  String sessionIdleTimeoutMins = "40";
                  String sessionPassword = "1";

                  Navigator.pushNamed(
                    context,
                    NavigatorName.meeting,
                    arguments: MeetingArguments(
                      token: token,
                      sessionName: sessionName,
                      displayName: displayName,
                      sessionIdleTimeoutMins: sessionIdleTimeoutMins,
                      sessionPassword: sessionPassword,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  String _generateToken() {
    // var user = AppSettings.userInfo;
    String userId = _makeId(10);
    // if (user != null) {
    //   userId = user.id.toString();
    // }
    const Map configs = {
      'ZOOM_SDK_KEY': 'hsfKYyjnTkmQ1fxaB_mZbQ',
      'ZOOM_SDK_SECRET': 'z242HVf7X6je0NzOA97WFfP3GgqtUTKseyYm',
    };
    try {
      var iat = DateTime.now();
      var exp = DateTime.now().add(Duration(days: 2));
      final jwt = JWT(
        {
          'app_key': configs["ZOOM_SDK_KEY"],
          'version': 1,
          'user_identity': _makeId(10),
          'iat': (iat.millisecondsSinceEpoch / 1000).round(),
          'exp': (exp.millisecondsSinceEpoch / 1000).round(),
          'tpc': 'ses-1',
          'role_type': 0,
          'cloud_recording_option': 0,
        },
      );
      var token = jwt.sign(SecretKey(configs["ZOOM_SDK_SECRET"]));
      return token;
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<bool> _grantPermission() async {
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

    if (!microGranted) {
      await openAppSettings();
      return false;
    }
    return microGranted;
  }
}
