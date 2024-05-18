import 'package:flutter/material.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/meeting/widgets/video_view.dart';
import 'package:medical/src/widget/meeting/widgets/zoom_functional_button.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class MeetingWaitRoomPage extends StatefulWidget {
  final MeetingArguments args;
  const MeetingWaitRoomPage({super.key, required this.args});

  @override
  State<MeetingWaitRoomPage> createState() => _MeetingWaitRoomPageState();
}

class _MeetingWaitRoomPageState extends State<MeetingWaitRoomPage> {
  final ZoomVideoSdk _zoom = ZoomVideoSdk();

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  void _initStateAsync() async {
    // _zoom.joinSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: R.color.transparent,
        title: Text(widget.args.sessionName, style: R.style.appBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                children: <Widget>[
                  // Preview
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 180.0,
                        maxHeight: 320.0,
                        minWidth: 180.0,
                        minHeight: 240.0,
                      ),
                      child: VideoView(
                        preview: true,
                        avatarUrl: null,
                        user: null,
                        fullScreen: true,
                        resolution: VideoResolution.Resolution360,
                      ),
                    ),
                  ),

                  // spacing
                  const SizedBox(height: 24.0),

                  // rows with 2 buttons, camera + mic
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Camera
                      ZoomFunctionalButton(
                        assetPath: R.drawable.ic_zoom_wait_camera_off,
                        labelText: 'Tắt camera',
                        labelColor: R.color.primaryGreyColor,
                        onPressed: _toggleCamera,
                      ),
                      // Mic
                      ZoomFunctionalButton(
                        assetPath: R.drawable.ic_zoom_wait_mic_off,
                        labelText: 'Tắt mic',
                        labelColor: R.color.primaryGreyColor,
                        onPressed: _toggleMic,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryRoundedButton(
                title: 'Bắt đầu',
                height: 48.0,
                onPressed: _startMeeting,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _startMeeting() {}

  void _toggleCamera() {}

  void _toggleMic() {}
}
