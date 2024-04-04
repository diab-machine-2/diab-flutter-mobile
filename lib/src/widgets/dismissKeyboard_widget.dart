import 'package:flutter/material.dart';

class DismissKeyBoardWidget extends StatelessWidget {
  final Widget child;
  const DismissKeyBoardWidget({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
