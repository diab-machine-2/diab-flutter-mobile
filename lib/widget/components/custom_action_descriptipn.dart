import 'package:flutter/material.dart';

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
          ? Image.asset('assets/images/help_circle_active.png',
              width: 24, height: 24)
          : Image.asset('assets/images/help_circle.png', width: 24, height: 24),
    );
  }
}
