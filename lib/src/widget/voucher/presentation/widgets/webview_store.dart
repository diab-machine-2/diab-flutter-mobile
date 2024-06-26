import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/app_bar_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewStore extends StatefulWidget {
  const WebviewStore({
    Key? key,
    required this.urlStore,
    this.rootPage = false,
  }) : super(key: key);
  final String urlStore;
  final bool rootPage;

  @override
  State<WebviewStore> createState() => _WebviewStoreState();
}

class _WebviewStoreState extends State<WebviewStore> {
  late InAppWebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void refreshView() {
    controller.goBack();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBarWidget(
        title: 'Cửa hàng',
        hasBackIcon: !widget.rootPage,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(widget.urlStore)),
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
            ),
            onWebViewCreated: (InAppWebViewController webViewController) {
              BotToast.closeAllLoading();
              controller = webViewController;
            },
            onLoadStart: (InAppWebViewController controller, Uri? url) async {
              setState(() {
                isLoading = true;
              });
              try {
                if (url != null && url.scheme.contains('zalo')) {
                  await launch(url.toString());
                  refreshView();
                }
                if (url != null && url.scheme.contains('tel')) {
                  await launch(url.toString());
                  refreshView();
                }
                if (url != null && url.scheme.contains('fb')) {
                  await launch(url.toString());
                  refreshView();
                }
                if (url != null && url.scheme.contains('mailto')) {
                  await launch(url.toString());
                  refreshView();
                }
                if (url != null && url.path.contains('referralCode')) {
                  await launch('https://click.diab.com.vn/referralCode/VdoJZzKZDN9rHSu88');
                  refreshView();
                }
              } catch (e) {
                setState(() {
                  isLoading = false;
                });
                Message.showToastMessage(context, 'DiaB đang xử lý bạn chờ chút nhé.');
              }
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              setState(() {
                isLoading = false;
              });
            },
          ),
          if (isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
    if (widget.rootPage) {
      return scaffold;
    }
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: scaffold,
    );
  }
}
