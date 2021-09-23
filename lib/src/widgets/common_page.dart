import 'package:flutter/material.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/custom_app_bar.dart';

class CommonPage extends StatelessWidget {
  final String background;
  final String? title;
  final Color? textColor;
  final Widget child;

  const CommonPage(
      {Key? key,
      required this.background,
      required this.child,
      this.title,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackgroundPage(
        background: background,
        child: SafeArea(
          top: true,
          child: Column(
            children: [
              CustomAppBar(
                title: title ?? "",
                textColor: textColor,
              ),
              Expanded(child: child)
            ],
          ),
        ));
  }
}
