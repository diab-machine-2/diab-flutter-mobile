import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  final String baseUrl = 'https://staging.docosan.com';
  final String accessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5zdGFnaW5nLmRvY29zYW4uY29tL2FwaS92ZXJpZnktb3RwIiwiaWF0IjoxNzMzMTI2Mzc4LCJleHAiOjE3MzU3MTgzNzgsIm5iZiI6MTczMzEyNjM3OCwianRpIjoiMkRHbDhwd2toR0lVQm9GOCIsInN1YiI6NDAzMzgsInBydiI6IjIzYmQ1Yzg5NDlmNjAwYWRiMzllNzAxYzQwMDg3MmRiN2E1OTc2ZjcifQ.dxo69v73FL0F3IC0YC2t3k9Fgvqf5ZPL3Qr6AQYUz1I';

  @override
  Widget build(BuildContext context) {
    final uri = '$baseUrl/vi/telemedicine/patient/${widget.telemedicineId}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView with Cookie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cookie),
            onPressed: checkCookies,
          ),
        ],
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
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
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
            onLoadStart: (controller, url) async {
              setState(() => isLoading = true);
              if (url != null) {
                // Set cookie using both CookieManager and JavaScript for redundancy
                await CookieManager.instance().setCookie(
                  url: url,
                  name: "access_token",
                  value: accessToken,
                  domain: "staging.docosan.com",
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
                // Check cookies using both methods
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
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri == null) return NavigationActionPolicy.CANCEL;

              // Allow navigation only to docosan domain
              if (uri.host.contains('staging.docosan.com')) {
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
          // Check using CookieManager
          final cookies =
              await CookieManager.instance().getCookies(url: currentUrl);
          debugPrint('All cookies from Manager: $cookies');

          // Check for access_token
          final accessTokenCookie = cookies.firstWhere(
            (cookie) => cookie.name == 'access_token',
            orElse: () => Cookie(name: '', value: '', domain: ''),
          );

          if (accessTokenCookie.name.isNotEmpty) {
            debugPrint('Found access_token: ${accessTokenCookie.value}');
          }
        }

        // Also check using JavaScript
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
    super.dispose();
  }
}