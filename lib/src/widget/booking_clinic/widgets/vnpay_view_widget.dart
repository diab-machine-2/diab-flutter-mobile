import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: InAppWebView(
          initialUrlRequest:
              URLRequest(url: WebUri.uri(Uri.parse(widget.paymentUrl))),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useOnLoadResource: true,
            useShouldOverrideUrlLoading: true,
            // Enable app scheme URLs
            allowUniversalAccessFromFileURLs: true,
            // Enable external app launching
            javaScriptCanOpenWindowsAutomatically: true,
          ),
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url.toString();

            if (url.startsWith('intent://')) {
              print('[VNPAY] Intent URL: $url');

              try {
                // Parse the intent URL
                final uri = Uri.parse(url.replaceFirst('intent://', 'intent:'));

                // Extract all important parts from the intent URL
                final packageName = url.split('package=')[1].split(';')[0];
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
                final canLaunchApp = await canLaunchUrl(Uri.parse(deepLinkUrl));

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
        ),
      ),
    );
  }
}
