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

  Future<NavigationActionPolicy> _handleBankUrl(String url) async {
    print('[VNPAY] BANK URL: $url');

    // Handle intent:// URLs (format used by many banks on Android)
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
        await _launchUrlOrStore(deepLinkUrl, packageName);
      } catch (e) {
        print('[VNPAY] Error launching intent URL: $e');
      }
      return NavigationActionPolicy.CANCEL;
    }
    // Handle direct scheme URLs (banking apps with custom URL schemes)
    else if (url.contains('://') && !url.startsWith('http')) {
      print('[VNPAY] Direct scheme URL: $url');

      try {
        // Parse the URL to extract scheme, host and parameters
        final uri = Uri.parse(url);
        final scheme = uri.scheme;
        String? packageName;

        // Extract QR content parameter
        String? qrContent;
        if (uri.queryParameters.containsKey('qrContent')) {
          qrContent = uri.queryParameters['qrContent'];
        }

        final callbackUrl = uri.queryParameters['callbackurl'];

        // Known package mappings - extend this list as needed
        final knownSchemes = {
          'vpbankneo': 'com.vnpay.vpbankonline',
          'tcb': 'vn.com.techcombank.bb.app',
          // Add more mappings as you discover them
        };

        packageName = knownSchemes[scheme];

        // Reconstruct URL with consistent 'data' parameter
        // This aligns with the intent:// format for consistency
        if (qrContent != null && callbackUrl != null) {
          // Create URL with standardized parameters
          final standardizedUri = Uri(
            scheme: scheme,
            host: uri.host,
            path: uri.path,
            queryParameters: {
              'data': qrContent,
              'callbackurl': callbackUrl,
            },
          );

          print('[VNPAY] Standardized URL: ${standardizedUri.toString()}');

          // Try to launch with standardized format
          final launched =
              await _launchUrlOrStore(standardizedUri.toString(), packageName);
          if (launched) {
            return NavigationActionPolicy.CANCEL;
          }
        }

        // If standardization failed, try original URL as fallback
        await _launchUrlOrStore(url, packageName);
      } catch (e) {
        print('[VNPAY] Error handling direct scheme URL: $e');
      }
      return NavigationActionPolicy.CANCEL;
    }

    // Allow all other URLs to load normally
    return NavigationActionPolicy.ALLOW;
  }

  // Helper method to launch URL or open app store if not installed
  Future<bool> _launchUrlOrStore(String url, String? packageName) async {
    try {
      final canLaunch = await canLaunchUrl(Uri.parse(url));
      if (canLaunch) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else if (packageName != null) {
        // If app is not installed, open Play Store
        final marketUrl = Uri.parse('market://details?id=$packageName');
        final httpUrl = Uri.parse(
            'https://play.google.com/store/apps/details?id=$packageName');

        try {
          await launchUrl(marketUrl, mode: LaunchMode.externalApplication);
        } catch (_) {
          await launchUrl(httpUrl, mode: LaunchMode.externalApplication);
        }
        return true;
      }
    } catch (e) {
      print('[VNPAY] Error launching URL: $e');
    }
    return false;
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
                  return _handleBankUrl(url);
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
