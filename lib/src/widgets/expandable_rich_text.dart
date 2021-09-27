import 'package:flutter/material.dart';

class ExpandableRichText extends StatefulWidget {
  const ExpandableRichText(
    this.text, {
    this.maxLines = 5,
  })  : assert(text != null),
        assert(maxLines != null && maxLines > 0);

  final String text;
  final int maxLines;

  @override
  ExpandableRichTextState createState() => ExpandableRichTextState();
}

class ExpandableRichTextState extends State<ExpandableRichText> {
  late int maxLines;

  @override
  void initState() {
    super.initState();
    maxLines = widget.maxLines;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, sizeLayout) {
        final TextSpan span = TextSpan(
          text: widget.text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        );
        final TextPainter tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: sizeLayout.maxWidth);
        print(tp.didExceedMaxLines);
        return IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: span,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Visibility(
                visible: tp.didExceedMaxLines,
                child: InkWell(
                  onTap: () => setState(() => maxLines = 1000),
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: Row(
                      children: const [
                        Text('Show'),
                        Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
