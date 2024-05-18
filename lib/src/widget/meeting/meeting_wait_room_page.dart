import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/service/zoom_service.dart';
import 'package:medical/src/widget/meeting/widgets/zoom_functional_button.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class MeetingWaitRoomPage extends StatefulWidget {
  final MeetingArguments args;
  const MeetingWaitRoomPage({super.key, required this.args});

  @override
  State<MeetingWaitRoomPage> createState() => _MeetingWaitRoomPageState();
}

class _MeetingWaitRoomPageState extends State<MeetingWaitRoomPage> {
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isCameraInitializedFailed = false;
  bool _isMicInitializedFailed = false;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initStateAsync() async {
    try {
      bool isMicGranted = await ZoomService().grantPermission();
      if (!isMicGranted) {
        _isMicInitializedFailed = true;
        _isMicOn = false;
      }
      List<CameraDescription> cameras = await availableCameras();
      // find the front camera
      for (CameraDescription camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          _controller = CameraController(camera, ResolutionPreset.veryHigh);
          break;
        }
      }
      if (_controller == null) {
        _controller = CameraController(cameras[0], ResolutionPreset.veryHigh);
        return;
      }
      if (_isCameraOn) {
        await _controller!.initialize();
      }
    } catch (e) {
      _isCameraInitializedFailed = true;
      _isCameraOn = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundPage(
      background: R.drawable.bg_welcome,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: R.color.transparent,
          title: Text(widget.args.sessionName, style: R.style.appBarTitle),
          centerTitle: true,
          leading: IconButton(
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.textDark),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  // spacing
                  Expanded(flex: 1, child: SizedBox()),

                  // Preview
                  Container(
                    width: 180.0,
                    height: 320.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isCameraOn && (_controller?.value.isInitialized ?? false)
                        ? CameraPreview(_controller!)
                        : Container(
                            color: R.color.textDark,
                            alignment: Alignment.center,
                            child: _buildUserAvatar(),
                          ),
                  ),

                  // spacing
                  const SizedBox(height: 24.0),

                  // rows with 2 buttons, camera + mic
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Camera
                      Container(
                        width: 90.0,
                        child: ZoomFunctionalButton(
                          assetPath: _isCameraOn
                              ? R.drawable.ic_zoom_wait_camera_on
                              : R.drawable.ic_zoom_wait_camera_off,
                          labelText: (!_isCameraOn ? 'camera_turnon' : 'camera_turnon').tr(),
                          labelColor: R.color.primaryGreyColor,
                          onPressed: _toggleCamera,
                        ),
                      ),
                      // Mic
                      SizedBox(
                        width: 90.0,
                        child: ZoomFunctionalButton(
                          assetPath: _isMicOn
                              ? R.drawable.ic_zoom_wait_mic_on
                              : R.drawable.ic_zoom_wait_mic_off,
                          labelText: (!_isMicOn ? 'mic_turnon' : 'mic_turnoff').tr(),
                          labelColor: R.color.primaryGreyColor,
                          onPressed: _toggleMic,
                        ),
                      ),
                    ],
                  ),

                  // spacing
                  Expanded(flex: 2, child: SizedBox()),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryRoundedButton(
                  title: R.string.start.tr(),
                  height: 48.0,
                  onPressed: _startMeeting,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    final user = AppSettings.userInfo;
    final defaultAvatarWidget = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Icon(Icons.person, size: 72.0, color: R.color.white),
    );
    double expectSized = 96.0;
    return Container(
      clipBehavior: Clip.hardEdge,
      width: expectSized,
      height: expectSized,
      decoration: BoxDecoration(
        color: R.color.mainColor,
        borderRadius: BorderRadius.circular(expectSized / 2),
      ),
      child: user?.imageUrl?.url == null
          ? defaultAvatarWidget
          : Image.network(
              user!.imageUrl!.url!,
              width: expectSized,
              height: expectSized,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return defaultAvatarWidget;
              },
            ),
    );
  }

  void _startMeeting() {}

  void _toggleCamera() async {
    if (_controller == null || _isCameraInitializedFailed) {
      return;
    }
    try {
      if (!_controller!.value.isInitialized) {
        await _controller!.initialize();
      }
    } catch (e) {
      _isCameraInitializedFailed = true;
      return;
    }
    if (_isCameraOn) {
      await _controller!.pausePreview();
    } else {
      await _controller!.resumePreview();
    }
    _isCameraOn = !_isCameraOn;

    setState(() {});
  }

  void _toggleMic() async {
    if (_isMicInitializedFailed) {
      return;
    }
    _isMicOn = !_isMicOn;

    setState(() {});
  }
}
