import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class CampaignTestResultDetailScreen extends StatefulWidget {
  const CampaignTestResultDetailScreen({super.key, required this.result});

  final BcbExamResultModel result;

  @override
  State<CampaignTestResultDetailScreen> createState() =>
      _CampaignTestResultDetailScreenState();
}

class _CampaignTestResultDetailScreenState
    extends State<CampaignTestResultDetailScreen> {
  bool _isLoading = true;
  String? _errorText;
  int _pdfViewerReloadToken = 0;

  Future<void> _downloadFile() async {
    final fileUrl = widget.result.fileUrl;
    if (fileUrl == null || fileUrl.trim().isEmpty) {
      BotToast.showText(text: R.string.bcb_result_file_not_found.tr());
      return;
    }
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) {
      BotToast.showText(text: R.string.bcb_invalid_file_url.tr());
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      BotToast.showText(text: R.string.bcb_cannot_download_file.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileUrl = widget.result.fileUrl ?? '';
    final title = (widget.result.additionalServices?.trim().isNotEmpty == true)
        ? widget.result.additionalServices!
        : R.string.bcb_exam_result_default_title.tr();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        leadingWidth: 30,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: fileUrl.trim().isEmpty
                ? Center(child: Text(R.string.bcb_no_pdf_file.tr()))
                : Stack(
                    children: [
                      Positioned.fill(
                        child: SfPdfViewer.network(
                          fileUrl,
                          key: ValueKey('pdf_$fileUrl\_$_pdfViewerReloadToken'),
                          canShowScrollHead: true,
                          canShowPaginationDialog: false,
                          enableDoubleTapZooming: true,
                          onDocumentLoaded: (_) {
                            if (!mounted) return;
                            setState(() {
                              _isLoading = false;
                              _errorText = null;
                            });
                          },
                          onDocumentLoadFailed: (details) {
                            if (!mounted) return;
                            setState(() {
                              _isLoading = false;
                              _errorText = details.description;
                            });
                          },
                        ),
                      ),
                      if (_isLoading)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Colors.white,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      if (_errorText != null)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      R.string.bcb_cannot_load_pdf_in_app.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _errorText ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.redAccent),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isLoading = true;
                                              _errorText = null;
                                              _pdfViewerReloadToken++;
                                            });
                                          },
                                          child: Text(R.string.retry.tr()),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: _downloadFile,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                R.color.greenGradientBottom,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(R.string.bcb_open_external.tr()),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _downloadFile,
                        icon: const Icon(Icons.download_outlined),
                        label: Text(R.string.bcb_download.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: R.color.greenGradientBottom,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          BotToast.showText(
                            text: R.string.bcb_share_feature_in_development.tr(),
                          );
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: Text(R.string.share.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          foregroundColor: R.color.color0xff27272A,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
