import 'package:flutter/material.dart';

class CustomTextMessageText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const CustomTextMessageText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines = 5,
  }) : super(key: key);

  @override
  _CustomTextMessageTextState createState() => _CustomTextMessageTextState();
}

class _CustomTextMessageTextState extends State<CustomTextMessageText>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastLinearToSlowEaseIn,
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: _isExpanded ? null : widget.maxLines,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        if (_isTextOverflowing())
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'View Less' : 'View More',
              style: TextStyle(
                color: Colors.blue,
                fontSize: widget.style?.fontSize ?? 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  bool _isTextOverflowing() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    return textPainter.didExceedMaxLines;
  }
}
