import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/utils/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'widgets/confirm_exit_zoom.dart';

class ZoomIosView extends StatefulWidget {
  final String calendarID;

  const ZoomIosView({
    Key? key,
    required this.calendarID,
  }) : super(key: key);

  @override
  State<ZoomIosView> createState() => _ZoomIosViewState();
}

class _ZoomIosViewState extends State<ZoomIosView> {
  late WebViewController _controller;
  String zoomUrl = "https://zoom.diab.com.vn/index.html?calendarId=";

  @override
  initState() {
    super.initState();
    checkAndRequestPermission();
    late final PlatformWebViewControllerCreationParams params =
        const PlatformWebViewControllerCreationParams();

    DynamicLinkConfig.instance.setZoomId(widget.calendarID);

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(zoomUrl +
          widget.calendarID +
          "&phone=${AppSettings.userInfo!.phoneNumber}&userName=${AppSettings.userInfo?.fullName?.trim() ?? ''}"));

    _controller = controller;
  }

  Future<void> checkAndRequestPermission() async {
    PermissionStatus statusMicrophone = await Permission.microphone.status;
    if (statusMicrophone.isDenied) {
      await Permission.microphone.request();
    }
    PermissionStatus statusCamera = await Permission.camera.request();
    if (statusCamera.isDenied) {
      await Permission.camera.request();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void runJS() async {
  //   _controller.runJavaScript("""
  //     var exitBtn = document.querySelector(".footer__leave-btn-container button");
  //     if(exitBtn){
  //       document.querySelector(".footer__leave-btn-container button").click();
  //       document.querySelector(".leave-meeting-options__btn").click()
  //     }
  //   """);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zoom"),
        actions: [
          GestureDetector(
            onTap: () => _exitZoomConfirmation(),
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.attentionText,
              ),
              child: Text(
                'Thoát',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
        leading: GestureDetector(
          onTap: () => _exitZoomConfirmation(),
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: InteractiveViewer(
        panEnabled: false, // Set it to false to prevent panning.
        boundaryMargin: EdgeInsets.all(0),
        minScale: 1,
        maxScale: 4,
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }

  _exitZoomConfirmation() {
    ConfirmExitZoom.showDialogConfirm(context, onSubmit: () {
      Observable.instance
          .notifyObservers([], notifyName: Const.NAVIGATE_TO_ACTIVITY_TAB);
      Observable.instance
          .notifyObservers([], notifyName: "mark_completed_calendar");
      Navigator.pop(context);
      Navigator.pop(context);
      // runJS();qq
    });
  }
}

class NativeJS {
  static String js() {
    const String tempJS = '''
        (function() {
          alert('Hello from JavaScript');
          // window.testing = function(){
          //   try {
          //     MyChannel.postMessage("Hello from My Injected Channel");
          //   } catch (e) {}
          //   return "Injected Return";
          // }
          // window.testing();
        })();
    ''';
    return tempJS;
  }
}
