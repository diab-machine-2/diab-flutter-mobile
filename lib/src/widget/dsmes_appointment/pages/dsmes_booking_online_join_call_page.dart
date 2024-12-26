import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewScreen extends StatefulWidget {
  final int telemedicineId;
  const WebViewScreen({
    Key? key,
    required this.telemedicineId,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String baseUrl = '';
  String accessToken = '';

  Future<void> _requestPermissions() async {
    // Request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    // Check each permission status
    statuses.forEach((permission, status) {
      debugPrint('$permission: $status');
    });

    // If any permission is denied, show dialog
    if (statuses.values.any((status) => status.isDenied)) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
              'Camera and microphone permissions are required for video calls. '
              'Please grant these permissions in your device settings.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  _initData() async {
    baseUrl = Utils.getDocosanDomainUrl();
    accessToken = await AppSettings.getDocosanToken();
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    final uri = '$baseUrl/vi/telemedicine/patient/${widget.telemedicineId}';
    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: R.color.transparent,
        title: Text(
          R.string.consult_online.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: R.color.color0xff111515,
            fontFamily: 'sfpro',
          ),
        ),
        leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            DsmesNavigationMixin.navigationKey.currentState?.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse(uri),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useOnLoadResource: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                clearCache: true,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                supportMultipleWindows: true,
                allowContentAccess: true,
                allowFileAccess: true,
                builtInZoomControls: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              controller.addJavaScriptHandler(
                handlerName: 'Flutter',
                callback: (args) {
                  if (args.isNotEmpty) {
                    debugPrint('Message from JavaScript: ${args[0]}');
                  }
                  return null;
                },
              );
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              debugPrint(
                  'Android permission requested from $origin for $resources');
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
            onLoadStart: (controller, url) async {
              setState(() => isLoading = true);
              if (url != null) {
                await CookieManager.instance().setCookie(
                  url: url,
                  name: "access_token",
                  value: accessToken,
                  domain: Utils.getDocosanDomain(),
                  path: "/",
                );

                await controller.evaluateJavascript(source: """
                  document.cookie = "access_token=$accessToken; path=/";
                  console.log('Cookie set via JavaScript:', document.cookie);
                """);
              }
            },
            onLoadStop: (controller, url) async {
              setState(() => isLoading = false);
              if (url != null) {
                // Check permissions
                final cameraStatus = await Permission.camera.status;
                final micStatus = await Permission.microphone.status;

                debugPrint('Camera permission: $cameraStatus');
                debugPrint('Microphone permission: $micStatus');

                // If permissions are granted, initialize media devices
                if (cameraStatus.isGranted && micStatus.isGranted) {
                  await controller.evaluateJavascript(source: """
                    navigator.mediaDevices.getUserMedia({ 
                      audio: true, 
                      video: {
                        facingMode: 'user'
                      }
                    })
                    .then(function(stream) {
                      console.log('Media permissions granted');
                      // Keep the stream active
                      window.mediaStream = stream;
                    })
                    .catch(function(error) {
                      console.error('Media permission error:', error);
                    });
                  """);
                } else {
                  debugPrint(
                      'Permissions not granted: Camera=$cameraStatus, Mic=$micStatus');
                }

                // Check cookies
                final cookiesJS = await controller.evaluateJavascript(
                  source: 'document.cookie',
                );
                debugPrint('Cookies after page load (JS): $cookiesJS');

                final cookiesManager =
                    await CookieManager.instance().getCookies(url: url);
                debugPrint(
                    'Cookies after page load (Manager): $cookiesManager');
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('Console: ${consoleMessage.message}');
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri == null) return NavigationActionPolicy.CANCEL;

              if (uri.toString() == "${Utils.getDocosanDomainUrl()}/") {
                if (mounted) {
                  DsmesNavigationMixin.navigationKey.currentState?.pop(context);
                }
                return NavigationActionPolicy.CANCEL;
              }

              if (uri.host.contains(Utils.getDocosanDomain())) {
                return NavigationActionPolicy.ALLOW;
              }

              return NavigationActionPolicy.CANCEL;
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> checkCookies() async {
    try {
      if (webViewController != null) {
        final currentUrl = await webViewController!.getUrl();
        if (currentUrl != null) {
          final cookies =
              await CookieManager.instance().getCookies(url: currentUrl);
          debugPrint('All cookies from Manager: $cookies');

          final accessTokenCookie = cookies.firstWhere(
            (cookie) => cookie.name == 'access_token',
            orElse: () => Cookie(name: '', value: '', domain: ''),
          );

          if (accessTokenCookie.name.isNotEmpty) {
            debugPrint('Found access_token: ${accessTokenCookie.value}');
          }
        }

        await webViewController!.evaluateJavascript(source: """
          console.log('All cookies:', document.cookie);
          window.flutter_inappwebview.callHandler('Flutter', 'Cookies: ' + document.cookie);
          
          let cookies = document.cookie.split(';');
          let accessToken = cookies.find(cookie => cookie.trim().startsWith('access_token='));
          if(accessToken) {
            window.flutter_inappwebview.callHandler('Flutter', 'Found access_token: ' + accessToken.trim());
          } else {
            window.flutter_inappwebview.callHandler('Flutter', 'access_token not found');
          }
        """);
      }
    } catch (e) {
      debugPrint('Error checking cookies: $e');
    }
  }

  @override
  void dispose() {
    if (webViewController != null) {
      webViewController!.evaluateJavascript(source: """
        if (window.mediaStream) {
          window.mediaStream.getTracks().forEach(track => track.stop());
        }
      """);
    }
    super.dispose();
  }
}
