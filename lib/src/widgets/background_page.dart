import 'package:flutter/material.dart';

class BackgroundPage extends StatelessWidget {

  final String background;
  final Widget child;
  const BackgroundPage({Key? key, required this.background, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    background
                ),
                fit: BoxFit.fitWidth
            )
        ),
        child: child);
  }
}
