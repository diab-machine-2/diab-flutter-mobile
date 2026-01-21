import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_zoom_meeting/zoom_options.dart';
import 'package:flutter_zoom_meeting/zoom_view.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/service/zalo_service.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

// MethodChannel _channel = const MethodChannel("DiaB_MeetingMC");

class MeetingPreparePage extends StatefulWidget {
  const MeetingPreparePage({super.key});

  @override
  State<MeetingPreparePage> createState() => _MeetingPreparePageState();
}

class _MeetingPreparePageState extends State<MeetingPreparePage> {
  TextEditingController _textController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Prepare'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                ZaloLoginResult result = await ZaloService().login();
                print('ZaloLoginResult: $result');
                print('ZaloLoginResult: ${result.accessToken}');
                BotToast.showText(text: 'Logged in successfully');
              } on ZaloLoginException catch (e) {
                print('ZaloLoginException: ${e.message}');
                BotToast.showText(text: e.message);
              } catch (e) {
                BotToast.showText(text: 'Login failed - Unknown error');
              }
            },
            icon: Icon(Icons.join_full),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to DiaB Meeting", style: TextStyle(fontSize: 20)),
            // SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                child: Text('Start Meeting'),
                onPressed: () => _joinCall(context),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                child: Text('OCR'),
                onPressed: () =>
                    Navigator.pushNamed(context, NavigatorName.test_ocr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinCall(BuildContext context) async {
    if (PictureInPicture.isActive) {
      return;
    }
    ZoomService zoomServiceHelper = ZoomService();
    bool ok = await zoomServiceHelper.grantPermission();
    if (!ok) {
      return;
    }

    Widget dialog = AlertDialog(
      title: Text('Join Meeting'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: "Meeting ID"),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(hintText: "Password"),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    await showDialog(
      context: context,
      builder: (context) => dialog,
    );
    // String topic = _textController.text;
    // var user = AppSettings.userInfo;
    // final args =
    //     await zoomServiceHelper.generateMeetingArgument(topic, user?.fullName ?? "Test Meeting");

    // if (args == null) {
    //   BotToast.showText(text: "Lỗi kết nối");
    //   return;
    // }

    // Navigator.pushNamed(
    //   context,
    //   NavigatorName.meeting_wait_room,
    //   arguments: args,
    // );
    if (_textController.text.isEmpty || _passwordController.text.isEmpty) {
      BotToast.showText(text: "Thiếu thông tin!");
      return;
    }

    try {
      BotToast.showLoading();

      String meetingID = _textController.text;
      String password = _passwordController.text;
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

      // Add timeout and better error handling for method channel calls
      List<dynamic> results;
      try {
        results = await zoom.initZoom(zoomOptions).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (kDebugMode) {
              print("[Zoom Init] Timeout after 10 seconds");
            }
            throw TimeoutException('Zoom SDK initialization timed out');
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print("[Init Zoom Error] : $e");
        }
        TrackingManager.recordError(e, null);
        rethrow;
      }

      print('---------- pip pip success initialize zoom sdk');

      // Check if results is valid and initialization succeeded
      if (results.isNotEmpty && results[0] == 0) {
        // Set up meeting status listener with error handling
        zoom.onMeetingStatus().listen(
          (status) {
            if (kDebugMode) {
              print("[Meeting Status Stream] : " +
                  (status.isNotEmpty ? status[0] : "unknown") +
                  " - " +
                  (status.length > 1 ? status[1] : "no message"));
            }
            if (status.isNotEmpty && _isMeetingEnded(status[0])) {
              _unInitialize();
              if (kDebugMode) {
                print("[Meeting Status] :- Ended");
              }
            }
          },
          onError: (error) {
            if (kDebugMode) {
              print("[Meeting Status Stream Error] : $error");
            }
            TrackingManager.recordError(error, null);
          },
        );

        if (kDebugMode) {
          print("listen on event channel");
        }

        // Join meeting with timeout and error handling
        try {
          final joinMeetingResult =
              await zoom.joinMeeting(meetingOptions).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              if (kDebugMode) {
                print("[Zoom Join] Timeout after 15 seconds");
              }
              throw TimeoutException('Join meeting timed out');
            },
          );
          if (kDebugMode) {
            print("[Join Meeting Result] : $joinMeetingResult");
          }
        } catch (error) {
          if (kDebugMode) {
            print("[Join Meeting Error] : $error");
          }
          TrackingManager.recordError(error, null);
          BotToast.showText(text: "Lỗi kết nối cuộc họp");
          rethrow;
        }
      } else {
        if (kDebugMode) {
          print("[Error] : $results");
        }
        throw Exception("Zoom SDK initialization failed: $results");
      }

      // bool authenticated = await _channel.invokeMethod("initZoom", {
      //   "jwtToken": jwtToken,
      // });

      // if (!authenticated) {
      //   BotToast.closeAllLoading();
      //   BotToast.showText(text: "Lỗi kết nối");
      //   return;
      // }

      // _channel.invokeMethod("joinMeeting", {
      //   "meetingID": meetingID,
      //   "password": password,
      //   "username": username,
      // });
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
      print(e);
      print(s);
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
  }
}
