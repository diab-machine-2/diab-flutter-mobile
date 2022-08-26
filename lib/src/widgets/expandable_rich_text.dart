import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableRichText extends StatefulWidget {
  const ExpandableRichText(
    this.data, {
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
    this.maxLines = 2,
    this.iconSize = 16,
    this.style,
    this.moreStyle,
    this.lessStyle,
    this.delimiterStyle,
    this.callback,
  });

  final int maxLines;

  final double iconSize;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  ///Called when state change between expanded/compress
  final Function(bool val)? callback;

  final String data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextStyle? delimiterStyle;

  @override
  ExpandableRichTextState createState() => ExpandableRichTextState();
}

const String _kEllipsis = '\u2026';

const String _kLineSeparator = '\u2028';

const String delimiter = _kEllipsis + ' ';

class ExpandableRichTextState extends State<ExpandableRichText> {
  final GlobalKey myKey = GlobalKey();
  bool _readMore = true;

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(myKey.currentContext?.size);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final TextStyle effectiveTextStyle =
        widget.style ?? const TextStyle(color: Colors.black);

    final TextAlign textAlign = defaultTextStyle.textAlign ?? TextAlign.start;
    final TextDirection textDirection = Directionality.of(context);
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final TextOverflow overflow = defaultTextStyle.overflow;
    final Locale? locale = Localizations.maybeLocaleOf(context);

    final Color colorClickableText =
        widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final TextStyle? _defaultLessStyle = widget.lessStyle ??
        effectiveTextStyle.copyWith(color: colorClickableText);
    final TextStyle? _defaultMoreStyle = widget.moreStyle ??
        effectiveTextStyle.copyWith(color: colorClickableText);
    final TextStyle? _defaultDelimiterStyle =
        widget.delimiterStyle ?? effectiveTextStyle;

    final TextSpan link = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: _readMore ? _defaultMoreStyle : _defaultLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    final TextSpan _delimiter = TextSpan(
      text: _readMore
          ? widget.trimCollapsedText.isNotEmpty
              ? delimiter
              : ''
          : '',
      style: _defaultDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Create a TextSpan with data
        final text = TextSpan(
          style: effectiveTextStyle,
          text: widget.data,
        );

        // Layout and measure link
        final TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.maxLines,
          ellipsis: overflow == TextOverflow.ellipsis ? delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final Size linkSize = textPainter.size;

        // Layout and measure delimiter
        textPainter.text = _delimiter;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final Size delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final Size textSize = textPainter.size;

        // Get the endIndex of data
        bool linkLongerThanLine = false;
        int endIndex;

        if (linkSize.width < maxWidth) {
          final readMoreSize =
              linkSize.width + delimiterSize.width + widget.iconSize;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl
                ? readMoreSize
                : textSize.width - readMoreSize,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          final TextPosition pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
          linkLongerThanLine = true;
        }

        TextSpan textSpan;

        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            style: effectiveTextStyle,
            text: _readMore
                ? widget.data.substring(0, endIndex) +
                    (linkLongerThanLine ? _kLineSeparator : '')
                : widget.data + ' ',
            children: [
              _delimiter,
              link,
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: GestureDetector(
                  onTap: _onTapLink,
                  child: Icon(
                    _readMore
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    key: myKey,
                    size: widget.iconSize,
                    color: _readMore
                        ? _defaultMoreStyle?.color
                        : _defaultLessStyle?.color,
                  ),
                ),
              )
            ],
          );
        } else {
          textSpan = TextSpan(
            style: effectiveTextStyle,
            text: widget.data,
          );
        }

        return RichText(
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          //softWrap,
          overflow: TextOverflow.clip,
          //overflow,
          textScaleFactor: textScaleFactor,
          text: textSpan,
        );
      },
    );
  }
}
