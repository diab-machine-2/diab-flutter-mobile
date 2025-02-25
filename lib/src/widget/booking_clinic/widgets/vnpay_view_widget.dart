import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:medical/res/R.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isPaymentHandled = false;
  bool hasError = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Expanded(
        child: Stack(
          children: [
            Container(
              child: InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri.uri(Uri.parse(widget.paymentUrl))),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useOnLoadResource: true,
                  useShouldOverrideUrlLoading: true,
                  // Enable app scheme URLs
                  allowUniversalAccessFromFileURLs: true,
                  // Add this settings prevent case unable to load webview
                  useHybridComposition: true,
                  // Enable external app launching
                ),
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url.toString();
                  print('[VNPAY] BANK URL: $url');

                  if (url.startsWith('intent://')) {
                    print('[VNPAY] Intent URL: $url');

                    try {
                      // Parse the intent URL
                      final uri =
                          Uri.parse(url.replaceFirst('intent://', 'intent:'));

                      // Extract all important parts from the intent URL
                      final packageName =
                          url.split('package=')[1].split(';')[0];
                      final scheme = url.split('scheme=')[1].split(';')[0];

                      // Extract the data parameter
                      final data = uri.queryParameters['data'];
                      final callbackUrl = uri.queryParameters['callbackurl'];

                      // Construct the deep link URL with all necessary parameters
                      final deepLinkData = {
                        'data': data,
                        'callbackurl': callbackUrl,
                      };

                      // Create the final URL with scheme and encoded parameters
                      final deepLinkUrl = Uri(
                        scheme: scheme,
                        host: 'view',
                        queryParameters: deepLinkData,
                      ).toString();

                      print('[VNPAY] Deep link URL: $deepLinkUrl');

                      // Try to launch the bank app with the payment data
                      final canLaunchApp =
                          await canLaunchUrl(Uri.parse(deepLinkUrl));

                      if (canLaunchApp) {
                        await launchUrl(
                          Uri.parse(deepLinkUrl),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // If app is not installed, open Play Store
                        final marketUrl =
                            Uri.parse('market://details?id=$packageName');
                        final httpUrl = Uri.parse(
                            'https://play.google.com/store/apps/details?id=$packageName');

                        try {
                          await launchUrl(marketUrl,
                              mode: LaunchMode.externalApplication);
                        } catch (_) {
                          await launchUrl(httpUrl,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    } catch (e) {
                      print('[VNPAY] Error launching app: $e');
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) {
                  if (url.toString().contains('vnp_ResponseCode') &&
                      !isPaymentHandled) {
                    final params = Uri.parse(url.toString()).queryParameters;
                    if (params['vnp_ResponseCode'] == '00') {
                      isPaymentHandled = true;
                      widget.onPaymentSuccess?.call(params);
                    } else {
                      widget.onPaymentError?.call(params);
                    }
                    // Navigator.of(context).pop();
                  }
                },
                onReceivedError: (controller, request, error) {
                  print('[VNPAY] Receive error: ${error.description}');
                  setState(() {
                    hasError = true;
                  });
                },
              ),
            ),
            if (hasError)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: R.color.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Container(
                      height: 44,
                      // width: 158,
                      decoration: BoxDecoration(
                        color: R.color.mainColor,
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [
                            R.color.greenGradientTop,
                            R.color.greenGradientMid,
                            R.color.greenGradientBottom,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          R.string.repayment.tr(),
                          style: TextStyle(
                            color: R.color.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
