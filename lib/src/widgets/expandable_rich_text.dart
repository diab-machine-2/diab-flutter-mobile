import 'dart:math';

import 'package:flutter/material.dart';

class ExpandableRichText extends StatefulWidget {
  const ExpandableRichText(
      this.text, {
        this.maxLines = 5,
      }) : assert(text != null),
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
    return LayoutBuilder(builder: (context, sizeLayout) {
      TextSpan span =  TextSpan(
        text: """${widget.text}""",
        style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.normal
        ),
      );
      final tp = TextPainter(text: span, maxLines: maxLines, textDirection:TextDirection.ltr );
      tp.layout(maxWidth: sizeLayout.maxWidth);
      print(tp.didExceedMaxLines);
      return Container(
        // width: 200,
        child: Column(
          children: [
            RichText(
              text: span,
              maxLines: maxLines,
            ),
            Visibility(
              visible: tp.didExceedMaxLines,
              child: InkWell(
                onTap: () => setState(() => maxLines = 1000),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(Icons.keyboard_arrow_down_outlined, color: Colors.blue,),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    
    });
  }
}
