import 'package:flutter/material.dart';

class BackgroundPage extends StatelessWidget {
  final String background;
  final Widget child;
  final BoxFit fit;
  const BackgroundPage({
    Key? key,
    required this.background,
    required this.child,
    this.fit = BoxFit.fitWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(background), fit: fit)),
      child: child,
    );
  }
}
