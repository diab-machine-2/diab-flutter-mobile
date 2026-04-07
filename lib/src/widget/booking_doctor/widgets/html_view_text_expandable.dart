import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

import 'package:medical/res/R.dart';

class ExpandableHtmlWidget extends StatefulWidget {
  final String htmlContent;
  final TextStyle? textStyle;
  final int maxLines;
  final Color? expandButtonColor;

  const ExpandableHtmlWidget({
    Key? key,
    required this.htmlContent,
    this.textStyle,
    this.maxLines = 3,
    this.expandButtonColor,
  }) : super(key: key);

  @override
  _ExpandableHtmlWidgetState createState() => _ExpandableHtmlWidgetState();
}

class _ExpandableHtmlWidgetState extends State<ExpandableHtmlWidget> {
  bool _isExpanded = false;
  bool _hasOverflow = false;
  late String _plainText;

  @override
  void initState() {
    super.initState();
    _plainText = _stripHtmlTags(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate if text overflows
        final textPainter = TextPainter(
          text: TextSpan(
            text: _plainText,
            style: widget.textStyle ?? const TextStyle(fontSize: 15),
          ),
          maxLines: widget.maxLines,
          textDirection: ui.TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        final fullTextPainter = TextPainter(
          text: TextSpan(
            text: _plainText,
            style: widget.textStyle ?? const TextStyle(fontSize: 15),
          ),
          textDirection: ui.TextDirection.ltr,
        );

        fullTextPainter.layout(maxWidth: constraints.maxWidth);
        _hasOverflow = fullTextPainter.didExceedMaxLines ||
            fullTextPainter.height > textPainter.height;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: _buildCollapsedView(constraints.maxWidth),
              secondChild: HtmlWidget(
                widget.htmlContent,
                textStyle: widget.textStyle,
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            if (_hasOverflow)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded
                        ? R.string.conversation_message_read_less.tr()
                        : R.string.conversation_message_read_more.tr(),
                    style: TextStyle(
                      color: R.color.color0xff95682E,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCollapsedView(double maxWidth) {
    // Calculate how much text fits in the specified number of lines
    final textPainter = TextPainter(
      text: TextSpan(
        text: _plainText,
        style: widget.textStyle ?? const TextStyle(fontSize: 15),
      ),
      maxLines: widget.maxLines,
      textDirection: ui.TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    if (!textPainter.didExceedMaxLines) {
      // Text fits within maxLines, show original HTML
      return HtmlWidget(
        widget.htmlContent,
        textStyle: widget.textStyle,
      );
    }

    // Text exceeds maxLines, show truncated version
    final endIndex = textPainter
        .getPositionForOffset(
          Offset(maxWidth, textPainter.size.height),
        )
        .offset;

    // Find a good breaking point (word boundary)
    int breakPoint = endIndex;
    if (breakPoint < _plainText.length) {
      while (breakPoint > 0 && _plainText[breakPoint] != ' ') {
        breakPoint--;
      }
      if (breakPoint == 0) breakPoint = endIndex; // Fallback if no space found
    }

    final truncatedText = _plainText.substring(0, breakPoint);

    return RichText(
      text: TextSpan(
        text: truncatedText,
        style: widget.textStyle ?? const TextStyle(fontSize: 15),
        children: [
          TextSpan(
            text: "...",
            style: widget.textStyle ?? const TextStyle(fontSize: 15),
          ),
        ],
      ),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ');
  }
}
