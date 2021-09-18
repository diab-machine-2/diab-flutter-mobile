import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

typedef ActionDescriptionCallback = Function(bool);

class CustomActionDescription extends StatefulWidget {
  final ActionDescriptionCallback callback;
  CustomActionDescription({Key key, this.callback}) : super(key: key);
  @override
  CustomActionDescriptionState createState() => CustomActionDescriptionState();
}

class CustomActionDescriptionState extends State<CustomActionDescription> {
  bool isClicked = false;

  showDes() {
    setState(() {
      isClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.callback(!isClicked);
        setState(() {
          isClicked = !isClicked;
        });
      },
      child: isClicked
          ? Image.asset(R.drawable.help_circle_active,
              width: 24, height: 24)
          : Image.asset(R.drawable.help_circle, width: 24, height: 24),
    );
  }
}
