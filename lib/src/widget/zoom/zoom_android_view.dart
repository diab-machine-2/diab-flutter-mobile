import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/const.dart';
import 'widgets/confirm_exit_zoom.dart';

class ZoomAndroidView extends StatefulWidget {
  final String calendarID;

  const ZoomAndroidView({
    Key? key,
    required this.calendarID,
  }) : super(key: key);
  @override
  _ZoomAndroidViewState createState() => new _ZoomAndroidViewState();
}

class _ZoomAndroidViewState extends State<ZoomAndroidView> {
  late InAppWebViewController _webViewController;
  String? url;

  @override
  void initState() {
    initData();
    checkAndRequestPermission();
    super.initState();
  }

  initData() async {
    DynamicLinkConfig.instance.setZoomId(widget.calendarID);
    late UserModel? user;
    if (AppSettings.isGetUser == false) {
      user = await UserClient().fetchUser();
    } else {
      user = AppSettings.userInfo;
    }
    String _url =
        "https://zoom.diab.com.vn/index.html?calendarId=${widget.calendarID}&phone=${user!.phoneNumber}&userName=${user.fullName ?? ''}";
    setState(() {
      url = _url;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkAndRequestPermission() async {
    // PermissionStatus statusMicrophone = await Permission.microphone.status;
    // if (statusMicrophone.isDenied) {
    //   await Permission.microphone.request();
    // }
    // PermissionStatus statusCamera = await Permission.camera.request();
    // if (statusCamera.isDenied) {
    //   await Permission.camera.request();
    // }
  }

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      BotToast.showLoading();
      return SizedBox();
    } else {
      BotToast.closeAllLoading();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Zoom"),
        leading: GestureDetector(
          onTap: () => ConfirmExitZoom.showDialogConfirm(context, onSubmit: () {
            Observable.instance.notifyObservers([],
                notifyName: Const.NAVIGATE_TO_ACTIVITY_TAB);
            Observable.instance
                .notifyObservers([], notifyName: "mark_completed_calendar");
            Navigator.pop(context);
            Navigator.pop(context);
            _webViewController.evaluateJavascript(source: """
                var exitBtn = document.querySelector(".footer__leave-btn-container button");
                if(exitBtn){
                  document.querySelector(".footer__leave-btn-container button").click();
                  document.querySelector(".leave-meeting-options__btn").click()
                }
              """);
          }),
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InAppWebView(
                    onLoadStart: (InAppWebViewController controller, Uri? uri) {
                      Console.log("PHUONG", 'onLoadStart');
                    },
                    onLoadStop: (InAppWebViewController controller, Uri? uri) {
                      BotToast.closeAllLoading();
                      // _webViewController.evaluateJavascript(source: """
                      //   var joined = false;
                      //   var joinBtn = document.getElementById("join-btn");
                      //   var timeoutID;
                      //   function checkJoinBtn() {
                      //     if (joinBtn === null) {
                      //       joinBtn = document.getElementById("join-btn");
                      //       if(joined){
                      //         clearTimeout(timeoutID);
                      //       }
                      //     } else {
                      //         joinBtn.click();
                      //         joined = true;
                      //         joinBtn = document.getElementById("join-btn");
                      //     }
                      //     timeoutID = setTimeout(checkJoinBtn, 1000);
                      //   }
                      //   checkJoinBtn();

                      //   var accepted = false;
                      //   var acceptBtn = document.querySelector('.join-audio-by-voip button');
                      //   var timeoutID2;
                      //   function checkJoinAcceptAudio() {
                      //     if (acceptBtn === null) {
                      //       acceptBtn = document.querySelector('.join-audio-by-voip button');
                      //       if(accepted){
                      //         clearTimeout(timeoutID2);
                      //       }
                      //     } else {
                      //         acceptBtn.click();
                      //         accepted = true;
                      //         acceptBtn = document.querySelector('.join-audio-by-voip button');
                      //     }
                      //     timeoutID2 = setTimeout(checkJoinAcceptAudio, 1000);
                      //   }
                      //   checkJoinAcceptAudio();
                      // """);
                    },
                    initialUrlRequest: URLRequest(url: Uri.parse(url!)),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        mediaPlaybackRequiresUserGesture: false,
                      ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      Console.log("PHUONG", 'onWebViewCreated');
                      _webViewController = controller;
                    },
                    androidOnPermissionRequest:
                        (InAppWebViewController controller, String origin,
                            List<String> resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
