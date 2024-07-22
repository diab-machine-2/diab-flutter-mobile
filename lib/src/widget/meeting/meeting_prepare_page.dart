import 'package:bot_toast/bot_toast.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/service/zalo_service.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/navigator_name.dart';

MethodChannel _channel = const MethodChannel("DiaB_MeetingMC");

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
                onPressed: () => Navigator.pushNamed(context, NavigatorName.test_ocr),
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

      bool authenticated = await _channel.invokeMethod("initZoom", {
        "jwtToken": jwtToken,
      });

      if (!authenticated) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Lỗi kết nối");
        return;
      }

      _channel.invokeMethod("joinMeeting", {
        "meetingID": meetingID,
        "password": password,
        "username": username,
      });
    } catch (e) {
      BotToast.showText(text: "Lỗi kết nối");
    } finally {
      BotToast.closeAllLoading();
    }
  }

  String _generateToken(String username) {
    const Map configs = {
      'ZOOM_SDK_KEY': 'CcZccx9xSvKnC_lNjaiHOw',
      'ZOOM_SDK_SECRET': 'ReEJdcGnz45oGin4FFFWOGbEIu8ToRPq',
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
}
