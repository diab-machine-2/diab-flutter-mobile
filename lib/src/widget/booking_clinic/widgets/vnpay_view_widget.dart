import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VNPayView extends StatefulWidget {
  const VNPayView({
    required this.paymentUrl,
    super.key,
    this.onPaymentSuccess,
    this.onPaymentError,
  });
  final String paymentUrl;
  final void Function(Map<String, dynamic> value)? onPaymentSuccess;
  final void Function(Map<String, dynamic> error)? onPaymentError;

  @override
  State<VNPayView> createState() => VNPayViewState();
}

class VNPayViewState extends State<VNPayView> {
  late InAppWebViewController webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Expanded(
          child: Container(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: WebUri.uri(Uri.parse(widget.paymentUrl))),
                  initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      useOnLoadResource: true,
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: true,
                      iframeAllow: "camera; microphone",
                      iframeAllowFullscreen: true),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStop: (controller, url) {
                    if (url.toString().contains('vnp_ResponseCode')) {
                      final params = Uri.parse(url.toString()).queryParameters;
                      if (params['vnp_ResponseCode'] == '00') {
                        widget.onPaymentSuccess?.call(params);
                      } else {
                        widget.onPaymentError?.call(params);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
