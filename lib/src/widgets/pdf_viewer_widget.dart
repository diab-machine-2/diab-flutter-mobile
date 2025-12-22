import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PDFViewerWidget extends StatefulWidget {
  const PDFViewerWidget({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;
  double _loadingProgress = 0;
  bool _useDirectUrl = false;

  @override
  Widget build(BuildContext context) {
    // Try Google Docs Viewer first, fallback to direct PDF URL
    final String pdfUrl = widget.url;
    final String viewerUrl = _useDirectUrl
        ? pdfUrl
        : 'https://docs.google.com/viewer?url=${Uri.encodeComponent(pdfUrl)}&embedded=true';

    return Scaffold(
      body: CommonPage(
        title: '',
        background: R.drawable.bg_lesson_detail,
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(viewerUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                useHybridComposition: true,
                supportZoom: true,
                builtInZoomControls: true,
                displayZoomControls: false,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _loadingProgress = 0;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _loadingProgress = progress / 100;
                  if (progress == 100) {
                    _isLoading = false;
                  }
                });
              },
              onLoadError: (controller, url, code, message) {
                // If Google Docs Viewer fails, try direct PDF URL
                if (!_useDirectUrl) {
                  setState(() {
                    _useDirectUrl = true;
                    _isLoading = true;
                  });
                  controller.loadUrl(
                      urlRequest: URLRequest(url: WebUri(pdfUrl)));
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading PDF... ${(_loadingProgress * 100).toInt()}%',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
