import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/user/user_client.dart';
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
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: InteractiveViewer(
                  panEnabled: false, // Set it to false to prevent panning.
                  boundaryMargin: EdgeInsets.all(0),
                  minScale: 1,
                  maxScale: 4,
                  child: InAppWebView(
                      onLoadStart:
                          (InAppWebViewController controller, Uri? uri) {},
                      onLoadStop:
                          (InAppWebViewController controller, Uri? uri) {
                        BotToast.closeAllLoading();
                      },
                      initialUrlRequest: URLRequest(url: Uri.parse(url!)),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          cacheEnabled: false,
                        ),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
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
            ),
          ],
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
    });
  }
}
