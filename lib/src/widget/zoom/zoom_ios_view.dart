import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'widgets/confirm_exit_zoom.dart';

class ZoomIosView extends StatefulWidget {
  final String calendarID;

  const ZoomIosView({Key? key, required this.calendarID}) : super(key: key);

  @override
  State<ZoomIosView> createState() => _ZoomIosViewState();
}

class _ZoomIosViewState extends State<ZoomIosView> {
  late WebViewController _controller;
  String zoomUrl = "https://zoom.9solutions.vn/index.html?calendarId=";

  @override
  initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            BotToast.showLoading();
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            BotToast.closeAllLoading();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("heheh")),
          );
        },
      )
      ..loadRequest(Uri.parse(zoomUrl +
          widget.calendarID +
          "&phone=${AppSettings.userInfo!.phoneNumber}&userName=${AppSettings.userInfo?.fullName?.trim() ?? ''}"));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void runJS() async {
    _controller.runJavaScript(
        'document.querySelector(".footer__leave-btn-container button").click()');
    _controller.runJavaScript(
        'document.querySelector(".leave-meeting-options__btn").click()');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zoom"),
        leading: GestureDetector(
          onTap: () => ConfirmExitZoom.showDialogConfirm(context, onSubmit: () {
            Observable.instance.notifyObservers([],
                notifyName: Const.NAVIGATE_TO_ACTIVITY_TAB);
            Observable.instance
                .notifyObservers([], notifyName: "mark_completed_calendar");
            runJS();
            // Navigator.pop(context);
            // Navigator.pop(context);
          }),
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
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
