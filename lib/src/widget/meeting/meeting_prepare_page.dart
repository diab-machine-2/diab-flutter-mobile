import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:zalo_flutter/zalo_flutter.dart';

class MeetingPreparePage extends StatefulWidget {
  const MeetingPreparePage({super.key});

  @override
  State<MeetingPreparePage> createState() => _MeetingPreparePageState();
}

class _MeetingPreparePageState extends State<MeetingPreparePage> {
  TextEditingController _textController = TextEditingController(text: 'room-001');

  @override
  void initState() {
    super.initState();
    _initZaloFlutter();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initZaloFlutter() async {
    if (Platform.isAndroid) {
      final String? hashKey = await ZaloFlutter.getHashKeyAndroid();
      print('HashKey: $hashKey');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Prepare'),
        actions: [
          IconButton(
            onPressed: () async {
              final Map<dynamic, dynamic>? data = await ZaloFlutter.login(
                refreshToken: null,
                // externalInfo: {},
              );
              try {
                print("login: $data");
                if (data?['isSuccess'] == true) {
                  final _accessToken = data?["data"]["accessToken"] as String?;
                  final _refreshToken = data?["data"]["refreshToken"] as String?;
                  print("accessToken: $_accessToken");
                  print("refreshToken: $_refreshToken");
                  return;
                }
              } catch (e) {
                print("login: $e");
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
          ],
        ),
      ),
    );
  }

  void _joinCall(BuildContext context) async {
    ZoomService zoomServiceHelper = ZoomService();
    bool ok = await zoomServiceHelper.grantPermission();
    if (!ok) {
      return;
    }

    Widget dialog = AlertDialog(
      title: Text('Enter Topic'),
      content: TextField(
        controller: _textController,
        decoration: InputDecoration(hintText: "Topic"),
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
    String topic = _textController.text;
    var user = AppSettings.userInfo;
    final args = zoomServiceHelper.generateMeetingArgument(topic, user?.fullName ?? "Test Meeting");

    Navigator.pushNamed(
      context,
      NavigatorName.meeting,
      arguments: args,
    );
  }
}
