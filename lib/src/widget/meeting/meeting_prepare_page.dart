import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/utils/navigator_name.dart';

class MeetingPreparePage extends StatefulWidget {
  const MeetingPreparePage({super.key});

  @override
  State<MeetingPreparePage> createState() => _MeetingPreparePageState();
}

class _MeetingPreparePageState extends State<MeetingPreparePage> {
  TextEditingController _textController = TextEditingController(text: 'room-001');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
    final args =
        await zoomServiceHelper.generateMeetingArgument(topic, user?.fullName ?? "Test Meeting");

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
}
