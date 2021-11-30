import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/common_page.dart';

class PDFViewerWidget extends StatelessWidget {
  const PDFViewerWidget({
    Key? key,
    required this.url,
  }) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        title: '',
        background: R.drawable.bg_lesson_detail,
        child: const PDF().cachedFromUrl(
          url,
          errorWidget: (error) => Center(child: Text(error.toString())),
        ),
      ),
    );
  }
}
